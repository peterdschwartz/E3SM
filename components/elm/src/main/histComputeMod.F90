module histComputeMod

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! Compute side of the ELM history: accumulates each time step's model
  ! fields into the history buffers, and normalizes / zeroes the buffers at the
  ! end of a history interval. histFileMod is the API: it owns the master field
  ! list, the tapes, the namelist, I/O and restart, and describes the active
  ! fields to this module (hist_compute_build) as a table of
  ! hist_active_field.
  !
  ! Layout
  ! - The buffers of all active fields on all tapes are one contiguous pool,
  !   ordered by tape, then field; each field is stored [output point, level].
  !   The tapes' hbuf/nacs are pointer views into the pool (hist_compute_views).
  ! - Model arrays are reached through histFileMod's pointer lists
  !   (elmptr_rs/elmptr_ra, passed in as src1/src2). The first element of a
  !   model array is the first point of its subgrid level, whatever its lower
  !   bound (some are sections with the lower bound reset to 1).
  !
  ! Per time step (hist_compute_update)
  ! - Multi-layer snow fields are first copied into snow_values with absent
  !   layers set to the field's no-snow value (spval or 0).
  ! - On the device (elm_device_ready): one kernel accumulates every field,
  !   one gang per block of block_size buffer elements. Every field starts on
  !   a block boundary, so a block is inside one field (block_field). Each
  !   element computes its sample, the point's value or the average of its
  !   gridcell (the x2g_point functions of subgridAveViewMod, which
  !   subgridAveMod's averages use too, so the sums and results are the same),
  !   and applies the field's time operation. The kernel is parallel over
  !   fields, levels and points at once; a gang per field left most of the
  !   device idle with few active fields and serialized a field's levels.
  ! - On the host (no device, or a build without OpenACC): field by field, in
  !   an order grouped by subgrid level (process_order). For each level of the
  !   field the code decides once what to do and calls routines that loop over
  !   the points: a field averaged to gridcells first gets its averages (the
  !   x2g_range routines) into gridcell_samples; then accumulate_samples
  !   applies the time operation, chosen once, to all points. Per element this
  !   is about twice as cheap as the device kernel's dispatch, which matters
  !   on the CPU.
  ! - Both paths give bit-for-bit the same buffers (the unit test checks each
  !   against the original algorithm).
  !
  ! Time operations (avgflag in histFileMod)
  !   'I' time_inst       the sample, spval if invalid
  !   'A' time_mean       mean of the valid samples
  !   'X' time_max        maximum, with the rules of the original ELM code:
  !   'M' time_min        minimum   - averaged to gridcells: a missing sample
  !                                   sets spval at any time in the interval;
  !                                 - native: a missing or inactive sample sets
  !                                   spval only if it is the first one;
  !                                 - nacs = 1 after every sample; once spval,
  !                                   max stays spval while min recovers.
  !   'U' time_max_valid  maximum of the valid samples (spval if none)
  !   'L' time_min_valid  minimum of the valid samples (spval if none)
  ! A sample is valid where its point is active (averaged fields: always) and
  ! its value isn't spval. For 'A', 'U' and 'L', nacs counts the valid samples.
  !
  ! OpenACC: the kernels reach the model arrays and the subgrid view through
  ! device pointers. hist_compute_attach attaches the arrays once they are on
  ! the device (after hist_compute_build, which may run before the model's
  ! copy): an attach to a target that is not present does nothing, the device
  ! pointer keeps the host address, and on a machine with unified addressing
  ! the kernel then silently reads the (stale) host array. So the attach checks
  ! that every target is present and aborts otherwise, and the device path
  ! refuses to run before it. The view is attached by subgrid_ave_view_attach
  ! under the same rule.
  !
  ! !USES:
  use elm_varctl, only : elm_device_ready, iulog  ! compute constructs run on the host before the device copy
  use shr_sys_mod      , only : shr_sys_abort
  use shr_kind_mod     , only : r8 => shr_kind_r8
  use subgridAveViewMod, only : subgrid_ave_view, spval
  use subgridAveViewMod, only : p2g_range, c2g_range, l2g_range, t2g_range
  use subgridAveViewMod, only : p2g_range_unity, c2g_range_unity, scale_unity
  use subgridAveViewMod, only : p2g_range_compact, c2g_range_compact
  use subgridAveViewMod, only : p2g_point, c2g_point, l2g_point, t2g_point
  use subgridAveViewMod, only : p2g_point_unity, c2g_point_unity
  use subgridAveViewMod, only : p2g_point_compact, c2g_point_compact
  use CompactLayoutMod , only : compact_groups, compact_ngroups, compact_lev_patch, compact_lev_col, &
                                compact_cidx_p, compact_cidx_c
  !
  implicit none
  private
  !
  ! !PUBLIC DATA:
  ! subgrid level of a model array
  integer, parameter, public :: lev_grid = 1, lev_topo = 2, lev_lun = 3, lev_col = 4, lev_patch = 5
  ! time operations
  integer, parameter, public :: time_inst = 1, time_mean = 2, time_max = 3, time_min = 4
  integer, parameter, public :: time_max_valid = 5, time_min_valid = 6
  ! multi-layer snow fields: value used where a snow layer is absent
  integer, parameter, public :: no_snow_unset  = 0 ! not a snow field
  integer, parameter, public :: no_snow_normal = 1 ! spval (the layer doesn't count)
  integer, parameter, public :: no_snow_zero   = 2 ! 0

  ! model array registered for a history field (histFileMod: elmptr_rs/elmptr_ra).
  ! Contiguous, so they are passed to the averages without copies.
  type, public :: hist_src1d
     real(r8), pointer, contiguous :: ptr(:) => null()
  end type hist_src1d
  type, public :: hist_src2d
     real(r8), pointer, contiguous :: ptr(:,:) => null()
  end type hist_src2d

  ! one active field of a tape
  type, public :: hist_active_field
     ! set by histFileMod
     integer :: source_index = 0             ! index into src1 (rank 1) or src2 (rank 2)
     integer :: source_rank  = 1
     integer :: source_level = lev_grid      ! subgrid level of the model array
     integer :: num_levels   = 1             ! levels of the field (num2d)
     integer :: time_op      = time_mean
     logical :: average_to_gridcell = .false.
     integer :: c2l_scale = 1, l2g_scale = 1 ! scale types (subgridAveMod's numbering)
     integer :: no_snow_behavior = no_snow_unset
     ! compact layout (CompactLayoutMod): the model array is column compact_slot of
     ! compact_groups(compact_group)%data, indexed by the view's cidx map; 0 = a full array
     integer :: compact_group = 0, compact_slot = 0
     integer :: compact_lev = 0               ! > 0: a rank-1 field reading level compact_lev of a rank-2 group
     ! set by hist_compute_build
     integer :: source_first = 1, source_last = 0 ! points of the source level
     integer :: first_point = 1, last_point = 0   ! output points (gridcells if averaged)
     integer :: buffer_offset = 0                 ! start of the field in hbuf_pool/nacs_pool
     integer :: snow_offset = -1                  ! start in snow_values (snow fields)
     integer :: sample_offset = -1                ! start in gridcell_samples (averaged fields)
  end type hist_active_field
  !
  ! !PUBLIC MEMBER FUNCTIONS:
  public :: hist_compute_build         ! set up buffers and the field table
  public :: hist_compute_attach        ! attach the model arrays on the device (OpenACC, after their copy)
  public :: hist_compute_views         ! pointer views of one field's buffers
  public :: hist_compute_update        ! accumulate the current time step
  public :: hist_compute_normalize     ! divide time averages by their sample counts (one tape)
  public :: hist_compute_zero          ! reset buffers and counters (one tape)
  public :: hist_compute_update_host   ! copy one tape's buffers device -> host (OpenACC)
  public :: hist_compute_update_device ! copy all buffers host -> device (OpenACC)
  !
  ! !PRIVATE DATA:
  real(r8), parameter :: big = 1.e50_r8   ! start of a max (-big) or min (+big)

  integer :: num_fields = 0
  integer :: max_levels = 0
  type(hist_active_field), allocatable :: fields(:)
  integer , allocatable :: tape_first_field(:)  ! fields of tape t: tape_first_field(t):tape_first_field(t+1)-1
  integer , allocatable :: process_order(:)     ! the fields grouped by (subgrid level, averaged)
  integer , allocatable :: snow_fields(:)       ! the fields that are snow fields
  real(r8), allocatable, target :: hbuf_pool(:)
  integer , allocatable, target :: nacs_pool(:)
  integer , allocatable :: block_field(:)       ! the field of each block of hbuf_pool (device kernel)
  real(r8), allocatable :: snow_values(:)       ! snow fields with absent layers filled in
  integer , allocatable :: snow_block_field(:)  ! the field of each block of snow_values
  real(r8), allocatable :: gridcell_samples(:)  ! host path: averages of the averaged fields at this step
  logical , allocatable :: all_active(:)        ! host path: .true. (points without an active check)
  logical :: extrasnowlayers = .false.          ! snow levels are ordered top layer first
  !$acc declare create(fields, hbuf_pool, nacs_pool, block_field, snow_values, snow_block_field, &
  !$acc                extrasnowlayers)
  ! Every field's buffers start on a multiple of block_size elements (hbuf_pool and
  ! snow_values are padded), so one block of the device kernel is inside one field
  integer, parameter :: block_size = 128

  ! model arrays attached on the device by hist_compute_attach
  integer, allocatable :: attached1(:), attached2(:)
  logical :: sources_attached = .false.
  !-----------------------------------------------------------------------

contains

  !-----------------------------------------------------------------------
  subroutine hist_compute_build(view, field_list, tape_first, src1, src2, extrasnow, ierr, errmsg)
    !
    ! !DESCRIPTION:
    ! Check the active fields, lay out their buffers (zeroed) and keep the
    ! field table. field_list(tape_first(t):tape_first(t+1)-1) are the fields
    ! of tape t. Existing buffers are discarded.
    !
    ! !ARGUMENTS:
    type(subgrid_ave_view) , intent(in)  :: view
    type(hist_active_field), intent(in)  :: field_list(:)
    integer                , intent(in)  :: tape_first(:)
    type(hist_src1d)       , intent(in)  :: src1(:)
    type(hist_src2d)       , intent(in)  :: src2(:)
    logical                , intent(in)  :: extrasnow  ! snow levels are ordered top layer first
    integer                , intent(out) :: ierr       ! field with an error, or 0
    character(len=*)       , intent(out) :: errmsg
    !
    ! !LOCAL VARIABLES:
    integer :: f, n, offset, snow_offset, sample_offset, num_points, num_snow, extent
    integer :: level, averaged, max_points
    logical :: was_attached
    !-----------------------------------------------------------------------

    ierr = 0
    errmsg = ' '
    was_attached = sources_attached
    call release(src1, src2)

    num_fields = size(field_list)
    allocate(fields(num_fields), tape_first_field(size(tape_first)))
    fields(:) = field_list(:)
    tape_first_field(:) = tape_first(:)
    extrasnowlayers = extrasnow

    offset = 0
    snow_offset = 0
    sample_offset = 0
    num_snow = 0
    max_levels = 0
    max_points = view%endg - view%begg + 1
    do f = 1, num_fields
       associate(fld => fields(f))
       call level_bounds(view, fld%source_level, fld%source_first, fld%source_last)
       num_points = fld%source_last - fld%source_first + 1

       ! the model array covers the level's points; a 2d array has levels
       ! 1:num_levels, a snow field's levels start at its lower bound
       if (fld%compact_group > 0) then
          ! a compact field: one level of a group buffer, read through the inverse map
          if (fld%compact_group > compact_ngroups) then
             ierr = f; errmsg = 'compact group does not exist'; return
          end if
          if (fld%no_snow_behavior /= no_snow_unset) then
             ierr = f; errmsg = 'compact fields cannot be snow fields'; return
          end if
          if (fld%source_rank == 1) then
             if (fld%num_levels /= 1) then
                ierr = f; errmsg = 'compact rank-1 field with levels'; return
             end if
             if (fld%compact_lev > 0) then
                if (compact_groups(fld%compact_group)%nlev < fld%compact_lev) then
                   ierr = f; errmsg = 'compact level slice beyond its group'; return
                end if
             else if (compact_groups(fld%compact_group)%nlev /= 0) then
                ierr = f; errmsg = 'compact rank-1 field in a rank-2 group without a level'; return
             end if
          else if (compact_groups(fld%compact_group)%nlev < fld%num_levels) then
             ierr = f; errmsg = 'compact rank-2 field: its group has fewer levels than num2d'; return
          end if
          if (fld%compact_slot < 1 .or. fld%compact_slot > compact_groups(fld%compact_group)%nfld) then
             ierr = f; errmsg = 'compact slot outside its group'; return
          end if
          if (.not. ((fld%source_level == lev_patch .and. compact_groups(fld%compact_group)%level == compact_lev_patch) &
               .or. (fld%source_level == lev_col .and. compact_groups(fld%compact_group)%level == compact_lev_col))) then
             ierr = f; errmsg = 'compact group level differs from the field level'; return
          end if
          if (fld%source_level == lev_patch .and. .not. allocated(compact_cidx_p)) then
             ierr = f; errmsg = 'compact patch field without a compact_cidx_p map'; return
          end if
          if (fld%source_level == lev_col .and. .not. allocated(compact_cidx_c)) then
             ierr = f; errmsg = 'compact column field without a compact_cidx_c map'; return
          end if
          extent = num_points
       else if (fld%source_rank == 1) then
          if (.not. associated(src1(fld%source_index)%ptr)) then
             ierr = f; errmsg = 'model array not associated'; return
          end if
          extent = size(src1(fld%source_index)%ptr)
       else
          if (.not. associated(src2(fld%source_index)%ptr)) then
             ierr = f; errmsg = 'model array not associated'; return
          end if
          extent = size(src2(fld%source_index)%ptr, 1)
          if (fld%no_snow_behavior /= no_snow_unset) then
             if (size(src2(fld%source_index)%ptr, 2) /= fld%num_levels) then
                ierr = f; errmsg = 'snow field: model array levels differ from the field levels'; return
             end if
          else if (lbound(src2(fld%source_index)%ptr, 2) > 1 .or. &
               ubound(src2(fld%source_index)%ptr, 2) < fld%num_levels) then
             ierr = f; errmsg = 'model array does not have levels 1:num2d'; return
          end if
       end if
       if (extent < num_points) then
          ierr = f; errmsg = 'model array smaller than its subgrid level'; return
       end if
       if (fld%no_snow_behavior /= no_snow_unset .and. (fld%source_rank /= 2 .or. &
            (fld%source_level /= lev_col .and. fld%source_level /= lev_patch))) then
          ierr = f; errmsg = 'snow fields must be column or patch arrays with levels'; return
       end if
       if (fld%average_to_gridcell .and. fld%source_level == lev_grid) fld%average_to_gridcell = .false.

       if (fld%no_snow_behavior /= no_snow_unset) then
          fld%snow_offset = snow_offset
          snow_offset = snow_offset + padded(num_points * fld%num_levels)
          num_snow = num_snow + 1
       end if
       if (fld%average_to_gridcell) then
          fld%first_point = view%begg
          fld%last_point  = view%endg
          fld%sample_offset = sample_offset
          sample_offset = sample_offset + (view%endg - view%begg + 1) * fld%num_levels
       else
          fld%first_point = fld%source_first
          fld%last_point  = fld%source_last
       end if
       fld%buffer_offset = offset
       offset = offset + padded((fld%last_point - fld%first_point + 1) * fld%num_levels)
       max_levels = max(max_levels, fld%num_levels)
       max_points = max(max_points, num_points)
       end associate
    end do

    allocate(hbuf_pool(offset), nacs_pool(offset), block_field(offset / block_size))
    allocate(snow_values(snow_offset), snow_block_field(snow_offset / block_size), snow_fields(num_snow))
    allocate(gridcell_samples(sample_offset), all_active(max_points), process_order(num_fields))
    hbuf_pool(:) = 0._r8
    nacs_pool(:) = 0
    all_active(:) = .true.
    num_snow = 0
    do f = 1, num_fields
       associate(fld => fields(f))
       extent = (fld%last_point - fld%first_point + 1) * fld%num_levels
       if (extent > 0) block_field(fld%buffer_offset / block_size + 1 : (fld%buffer_offset + extent - 1) / block_size + 1) = f
       if (fld%snow_offset >= 0) then
          num_snow = num_snow + 1
          snow_fields(num_snow) = f
          extent = (fld%source_last - fld%source_first + 1) * fld%num_levels
          if (extent > 0) snow_block_field(fld%snow_offset / block_size + 1 : (fld%snow_offset + extent - 1) / block_size + 1) = f
       end if
       end associate
    end do
    ! processing order: grouped by subgrid level, native fields before
    ! averaged ones, in tape order within a group
    n = 0
    do level = lev_grid, lev_patch
       do averaged = 0, 1
          do f = 1, num_fields
             if (fields(f)%source_level == level .and. &
                  (fields(f)%average_to_gridcell .eqv. (averaged == 1))) then
                n = n + 1
                process_order(n) = f
             end if
          end do
       end do
    end do

    !$acc update device(fields, hbuf_pool, nacs_pool, block_field, snow_block_field, extrasnowlayers)
    !$acc enter data copyin(tape_first_field, snow_fields, process_order)
    ! a rebuild after hist_compute_attach (the model arrays are on the device): attach again
    if (was_attached) call hist_compute_attach(src1, src2)

  end subroutine hist_compute_build

  !-----------------------------------------------------------------------
  pure integer function padded(n)
    ! n rounded up to a multiple of block_size
    integer, intent(in) :: n
    padded = ((n + block_size - 1) / block_size) * block_size
  end function padded

  !-----------------------------------------------------------------------
  pure subroutine level_bounds(view, level, first, last)
    ! First and last point of a subgrid level.
    type(subgrid_ave_view), intent(in) :: view
    integer, intent(in)  :: level
    integer, intent(out) :: first, last

    select case (level)
    case (lev_topo)
       first = view%begt ; last = view%endt
    case (lev_lun)
       first = view%begl ; last = view%endl
    case (lev_col)
       first = view%begc ; last = view%endc
    case (lev_patch)
       first = view%begp ; last = view%endp
    case default
       first = view%begg ; last = view%endg
    end select
  end subroutine level_bounds

  !-----------------------------------------------------------------------
  subroutine hist_compute_attach(src1, src2)
    !
    ! !DESCRIPTION:
    ! Put the pointer lists on the device and attach the model arrays the
    ! fields use to their device copies. Call once those copies exist (after
    ! hist_compute_build; the model copies its state later than the history
    ! setup). The runtime skips an attach whose target is not present, and the
    ! kernel would then read host memory, so every target is checked and a
    ! missing one aborts the run. A rebuild (hist_compute_build) re-attaches
    ! by itself.
    !
    ! !USES:
#ifdef _OPENACC
    use openacc, only : acc_is_present
#endif
    !
    ! !ARGUMENTS:
    type(hist_src1d), intent(in) :: src1(:)
    type(hist_src2d), intent(in) :: src2(:)
    !
    ! !LOCAL VARIABLES:
    logical :: used1(size(src1)), used2(size(src2))
    integer :: f, i
#ifdef _OPENACC
    integer :: cg, nmissing
    character(len=256) :: msg
#endif
    !-----------------------------------------------------------------------

    if (.not. allocated(fields)) return
    if (sources_attached) call detach_sources(src1, src2)

    used1(:) = .false.
    used2(:) = .false.
    do f = 1, num_fields
       if (fields(f)%compact_group > 0) then
          cycle   ! read from its group buffer (CompactLayoutMod keeps it on the device)
       else if (fields(f)%source_rank == 1) then
          used1(fields(f)%source_index) = .true.
       else
          used2(fields(f)%source_index) = .true.
       end if
    end do
    attached1 = pack([(i, i = 1, size(src1))], used1)
    attached2 = pack([(i, i = 1, size(src2))], used2)

#ifdef _OPENACC
    ! report every missing target (not just the first), then abort
    nmissing = 0
    do i = 1, size(attached1)
       if (.not. acc_is_present(src1(attached1(i))%ptr)) then
          nmissing = nmissing + 1
          write(iulog, '(a,i0,a,i0,a)') 'histComputeMod: rank-1 model array ', attached1(i), &
               ' of history field ', first_field_of(1, attached1(i)), ' is not on the device'
       end if
    end do
    do i = 1, size(attached2)
       if (.not. acc_is_present(src2(attached2(i))%ptr)) then
          nmissing = nmissing + 1
          write(iulog, '(a,i0,a,i0,a)') 'histComputeMod: rank-2 model array ', attached2(i), &
               ' of history field ', first_field_of(2, attached2(i)), ' is not on the device'
       end if
    end do
    do f = 1, num_fields
       cg = fields(f)%compact_group
       if (cg <= 0) cycle
       if (compact_groups(cg)%nlev > 0) then
          if (acc_is_present(compact_groups(cg)%data3)) cycle
       else
          if (acc_is_present(compact_groups(cg)%data)) cycle
       end if
       nmissing = nmissing + 1
       write(iulog, '(a,i0,a,i0,a)') 'histComputeMod: compact group ', cg, ' of history field ', f, &
            ' is not on the device'
    end do
    if (nmissing > 0) then
       write(msg, '(a,i0,a)') 'histComputeMod: ', nmissing, ' history source arrays are not on the device (see log)'
       call shr_sys_abort(trim(msg))
    end if
#endif

    !$acc enter data copyin(src1, src2)
    do i = 1, size(attached1)
       !$acc enter data attach(src1(attached1(i))%ptr)
    end do
    do i = 1, size(attached2)
       !$acc enter data attach(src2(attached2(i))%ptr)
    end do
    sources_attached = .true.

  contains

    integer function first_field_of(rank, index)
      ! the first field reading model array index of the given rank (for messages)
      integer, intent(in) :: rank, index
      integer :: k
      first_field_of = 0
      do k = 1, num_fields
         if (fields(k)%compact_group == 0 .and. fields(k)%source_rank == rank .and. &
              fields(k)%source_index == index) then
            first_field_of = k
            return
         end if
      end do
    end function first_field_of

  end subroutine hist_compute_attach

  !-----------------------------------------------------------------------
  subroutine detach_sources(src1, src2)
    ! Undo hist_compute_attach.
    type(hist_src1d), intent(in) :: src1(:)
    type(hist_src2d), intent(in) :: src2(:)
    integer :: i

    do i = 1, size(attached1)
       !$acc exit data detach(src1(attached1(i))%ptr)
    end do
    do i = 1, size(attached2)
       !$acc exit data detach(src2(attached2(i))%ptr)
    end do
    !$acc exit data delete(src1, src2)
    sources_attached = .false.

  end subroutine detach_sources

  !-----------------------------------------------------------------------
  subroutine release(src1, src2)
    ! Discard the buffers and the field table (and their device copies).
    type(hist_src1d), intent(in) :: src1(:)
    type(hist_src2d), intent(in) :: src2(:)

    if (.not. allocated(fields)) return
    if (sources_attached) call detach_sources(src1, src2)
    !$acc exit data delete(tape_first_field, snow_fields, process_order)
    deallocate(fields, tape_first_field, snow_fields, process_order, hbuf_pool, nacs_pool, block_field)
    deallocate(snow_values, snow_block_field, gridcell_samples, all_active)
    deallocate(attached1, attached2)
    num_fields = 0

  end subroutine release

  !-----------------------------------------------------------------------
  subroutine hist_compute_views(f, hbuf, nacs)
    !
    ! !DESCRIPTION:
    ! Pointer views of field f's buffers: [output point, level].
    !
    ! !ARGUMENTS:
    integer , intent(in) :: f
    real(r8), pointer, intent(out) :: hbuf(:,:)
    integer , pointer, intent(out) :: nacs(:,:)
    !
    ! !LOCAL VARIABLES:
    integer :: first, last, n
    !-----------------------------------------------------------------------

    first = fields(f)%first_point
    last  = fields(f)%last_point
    n = (last - first + 1) * fields(f)%num_levels
    hbuf(first:last, 1:fields(f)%num_levels) => hbuf_pool(fields(f)%buffer_offset+1 : fields(f)%buffer_offset+n)
    nacs(first:last, 1:fields(f)%num_levels) => nacs_pool(fields(f)%buffer_offset+1 : fields(f)%buffer_offset+n)

  end subroutine hist_compute_views

  !-----------------------------------------------------------------------
  subroutine hist_compute_update(view, src1, src2)
    !
    ! !DESCRIPTION:
    ! Accumulate the current values of all active fields into their buffers:
    ! on the device when the model state lives there, else on the host.
    !
    ! !ARGUMENTS:
    type(subgrid_ave_view), intent(in)  :: view
    type(hist_src1d)      , intent(in)  :: src1(:)
    type(hist_src2d)      , intent(in)  :: src2(:)
    !-----------------------------------------------------------------------

    if (elm_device_ready) then
       call update_device(view, src1, src2)
    else
       call update_host(view, src1, src2)
    end if

  end subroutine hist_compute_update

  !-----------------------------------------------------------------------
  subroutine update_host(view, src1, src2)
    !
    ! !DESCRIPTION:
    ! The host path: field by field, one level at a time, the time operation
    ! chosen once per level (see the module header).
    !
    ! !ARGUMENTS:
    type(subgrid_ave_view), intent(in)  :: view
    type(hist_src1d)      , intent(in)  :: src1(:)
    type(hist_src2d)      , intent(in)  :: src2(:)
    !
    ! !LOCAL VARIABLES:
    integer :: n, f, s, lev, i, clev
    !-----------------------------------------------------------------------

    ! snow fields: fill in the absent layers (the averages read plain value arrays)
    do s = 1, size(snow_fields)
       do lev = 1, max_levels
          f = snow_fields(s)
          if (lev > fields(f)%num_levels) cycle
          do i = fields(f)%source_first, fields(f)%source_last
             snow_values(snow_index(fields(f), i, lev)) = &
                  snow_layer_value(view, fields(f), src2(fields(f)%source_index)%ptr, &
                  size(src2(fields(f)%source_index)%ptr, 1), i, lev)
          end do
       end do
    end do

    ! every field: one gang per field, its levels in turn
    do n = 1, num_fields
       f = process_order(n)
       do lev = 1, fields(f)%num_levels
          if (fields(f)%snow_offset >= 0) then
             call field_level(view, fields(f), lev, snow_values(snow_index(fields(f), fields(f)%source_first, lev)), &
                  all_active, gridcell_samples, hbuf_pool, nacs_pool)
          else if (fields(f)%compact_group > 0) then
             if (compact_groups(fields(f)%compact_group)%nlev > 0) then
                ! the group level this field reads (gfortran -fcheck=all misjudges the bounds of this
                ! section when the merge is written inside the subscript)
                clev = merge(fields(f)%compact_lev, lev, fields(f)%compact_lev > 0)
                call field_level_compact(view, fields(f), lev, &
                     compact_groups(fields(f)%compact_group)%data3(:, clev, fields(f)%compact_slot), &
                     compact_cidx_p, compact_cidx_c, compact_groups(fields(f)%compact_group)%fill, &
                     all_active, gridcell_samples, hbuf_pool, nacs_pool)
             else
                call field_level_compact(view, fields(f), lev, &
                     compact_groups(fields(f)%compact_group)%data(:, fields(f)%compact_slot), &
                     compact_cidx_p, compact_cidx_c, compact_groups(fields(f)%compact_group)%fill, &
                     all_active, gridcell_samples, hbuf_pool, nacs_pool)
             end if
          else if (fields(f)%source_rank == 1) then
             call field_level(view, fields(f), lev, src1(fields(f)%source_index)%ptr, &
                  all_active, gridcell_samples, hbuf_pool, nacs_pool)
          else
             call field_level(view, fields(f), lev, src2(fields(f)%source_index)%ptr(:, lev), &
                  all_active, gridcell_samples, hbuf_pool, nacs_pool)
          end if
       end do
    end do

  end subroutine update_host

  !-----------------------------------------------------------------------
  subroutine update_device(view, src1, src2)
    !
    ! !DESCRIPTION:
    ! The device path (see the module header). The pool is processed in blocks of block_size elements (one gang each);
    ! every field starts on a block boundary, so a block belongs to one field
    ! (block_field) and decodes it once. Each element then computes its own
    ! sample (the gridcell average of the field's points for an averaged
    ! field, the point's value otherwise) and applies the field's time
    ! operation, so the kernel is parallel over fields, levels and points at
    ! once; elements of a block share the field, so neighbouring threads do
    ! the same work. Snow fields first get their absent layers filled in
    ! (snow_values), in the same blocks.
    !
    ! !ARGUMENTS:
    type(subgrid_ave_view), intent(in)  :: view
    type(hist_src1d)      , intent(in)  :: src1(:)
    type(hist_src2d)      , intent(in)  :: src2(:)
    !
    ! !LOCAL VARIABLES:
    integer  :: b, e, f, first, np, extent, rel0, lev0, i0
    integer  :: rel, lev, i, cg, clev, n1
    real(r8) :: sample
    logical  :: active
    !-----------------------------------------------------------------------

#ifdef _OPENACC
    ! without the attach the kernel would read host memory (see hist_compute_attach)
    if (.not. sources_attached) call shr_sys_abort('histComputeMod: device update before hist_compute_attach')
#endif

    ! snow fields: fill in the absent layers (the averages read plain value arrays)
    !$acc parallel loop gang default(present) private(f, first, np, extent, rel0, lev0, i0) &
    !$acc&   if(elm_device_ready)
    do b = 1, size(snow_block_field)
       f      = snow_block_field(b)
       first  = fields(f)%snow_offset
       np     = fields(f)%source_last - fields(f)%source_first + 1
       extent = np * fields(f)%num_levels
       rel0   = (b - 1) * block_size - first
       lev0   = rel0 / np + 1
       i0     = fields(f)%source_first + mod(rel0, np)
       !$acc loop vector private(rel, lev, i)
       do e = 1, block_size
          rel = rel0 + e - 1
          if (rel >= extent) cycle   ! padding after the field's last element
          call element_position(fields(f)%source_first, fields(f)%source_last, np, rel, lev0, i0, e, lev, i)
          snow_values(first + rel + 1) = &
               snow_layer_value(view, fields(f), src2(fields(f)%source_index)%ptr, &
                  size(src2(fields(f)%source_index)%ptr, 1), i, lev)
       end do
    end do

    !$acc parallel loop gang default(present) private(f, first, np, extent, rel0, lev0, i0) &
    !$acc&   if(elm_device_ready)
    do b = 1, size(block_field)
       f      = block_field(b)
       first  = fields(f)%buffer_offset
       np     = fields(f)%last_point - fields(f)%first_point + 1
       extent = np * fields(f)%num_levels
       rel0   = (b - 1) * block_size - first
       lev0   = rel0 / np + 1
       i0     = fields(f)%first_point + mod(rel0, np)
       !$acc loop vector private(rel, lev, i, cg, clev, n1, sample, active)
       do e = 1, block_size
          rel = rel0 + e - 1
          if (rel >= extent) cycle   ! padding after the field's last element
          call element_position(fields(f)%first_point, fields(f)%last_point, np, rel, lev0, i0, e, lev, i)
          ! the level's values: element off+1 of the (whole, contiguous) array is the first
          ! point of the source level. Whole arrays, not sections: a section actual needs
          ! a descriptor or a temporary inside the kernel (illegal addresses on the GPU)
          if (fields(f)%snow_offset >= 0) then
             sample = level_sample(view, fields(f), i, snow_values, &
                  snow_index(fields(f), fields(f)%source_first, lev) - 1)
          else if (fields(f)%compact_group > 0) then
             cg = fields(f)%compact_group
             if (compact_groups(cg)%nlev > 0) then
                clev = merge(fields(f)%compact_lev, lev, fields(f)%compact_lev > 0)
                n1 = size(compact_groups(cg)%data3, 1)
                sample = compact_sample(view, fields(f), i, compact_groups(cg)%data3, &
                     (clev - 1) * n1 + (fields(f)%compact_slot - 1) * n1 * size(compact_groups(cg)%data3, 2), &
                     compact_groups(cg)%fill)
             else
                sample = compact_sample(view, fields(f), i, compact_groups(cg)%data, &
                     (fields(f)%compact_slot - 1) * size(compact_groups(cg)%data, 1), compact_groups(cg)%fill)
             end if
          else if (fields(f)%source_rank == 1) then
             sample = level_sample(view, fields(f), i, src1(fields(f)%source_index)%ptr, 0)
          else
             sample = level_sample(view, fields(f), i, src2(fields(f)%source_index)%ptr, &
                  (lev - 1) * size(src2(fields(f)%source_index)%ptr, 1))
          end if
          active = item_active(view, fields(f), i)
          call accumulate_one(fields(f)%time_op, fields(f)%average_to_gridcell, sample, active, &
               hbuf_pool(first + rel + 1), nacs_pool(first + rel + 1))
       end do
    end do

  end subroutine update_device

  !-----------------------------------------------------------------------
  pure subroutine element_position(first_point, last_point, np, rel, lev0, i0, e, lev, i)
    !
    ! !DESCRIPTION:
    ! Level and point of element rel (0-based within the field, stored
    ! [point, level]) of a block whose first element is point i0 of level
    ! lev0 and whose e-th element this is. A block of at most np elements
    ! wraps to the next level at most once, so no division is needed then.
    !
    !$acc routine seq
    ! !ARGUMENTS:
    integer, intent(in)  :: first_point, last_point, np, rel, lev0, i0, e
    integer, intent(out) :: lev, i
    !-----------------------------------------------------------------------

    if (np >= block_size) then
       lev = lev0
       i   = i0 + e - 1
       if (i > last_point) then
          i   = i - np
          lev = lev + 1
       end if
    else
       lev = rel / np + 1
       i   = first_point + mod(rel, np)
    end if

  end subroutine element_position

  !-----------------------------------------------------------------------
  pure real(r8) function level_sample(view, fld, i, values, off)
    !
    ! !DESCRIPTION:
    ! The sample of output point i from the level's values (values(off+1) is
    ! the first point of the source level): the point's value, or the average
    ! of gridcell i (the x2g_point functions of subgridAveViewMod, which
    ! subgridAveMod's averages use too, so the sums and results are the same).
    ! The x2g_point functions index values(p - beg + 1): beg = source_first - off
    ! puts the level's first point at values(off+1).
    !
    !$acc routine seq
    ! !ARGUMENTS:
    type(subgrid_ave_view) , intent(in) :: view
    type(hist_active_field), intent(in) :: fld
    integer                , intent(in) :: i
    real(r8)               , intent(in) :: values(*)
    integer                , intent(in) :: off
    !
    ! !LOCAL VARIABLES:
    integer :: beg
    !-----------------------------------------------------------------------

    beg = fld%source_first - off
    if (.not. fld%average_to_gridcell) then
       level_sample = values(i - beg + 1)
       return
    end if
    select case (fld%source_level)
    case (lev_patch)
       if (fld%c2l_scale == scale_unity .and. fld%l2g_scale == scale_unity) then
          level_sample = p2g_point_unity(view, i, values, beg)
       else
          level_sample = p2g_point(view, i, values, beg, fld%c2l_scale, fld%l2g_scale)
       end if
    case (lev_col)
       if (fld%c2l_scale == scale_unity .and. fld%l2g_scale == scale_unity) then
          level_sample = c2g_point_unity(view, i, values, beg)
       else
          level_sample = c2g_point(view, i, values, beg, fld%c2l_scale, fld%l2g_scale)
       end if
    case (lev_lun)
       level_sample = l2g_point(view, i, values, beg, fld%l2g_scale)
    case (lev_topo)
       level_sample = t2g_point(view, i, values, beg)
    case default
       level_sample = values(i - beg + 1)
    end select

  end function level_sample

  !-----------------------------------------------------------------------
  pure real(r8) function compact_sample(view, fld, i, values, off, fill)
    !
    ! !DESCRIPTION:
    ! level_sample for a field in the compact layout: values(off+k) is compact
    ! index k of the level; a point outside the layout reads the group's fill
    ! value (map entry < 0) or spval (0).
    !
    !$acc routine seq
    ! !ARGUMENTS:
    type(subgrid_ave_view) , intent(in) :: view
    type(hist_active_field), intent(in) :: fld
    integer                , intent(in) :: i
    real(r8)               , intent(in) :: values(*)
    integer                , intent(in) :: off
    real(r8)               , intent(in) :: fill
    !
    ! !LOCAL VARIABLES:
    integer :: k
    !-----------------------------------------------------------------------

    if (fld%average_to_gridcell) then
       if (fld%source_level == lev_patch) then
          compact_sample = p2g_point_compact(view, i, values, off, compact_cidx_p, fill, fld%c2l_scale, fld%l2g_scale)
       else
          compact_sample = c2g_point_compact(view, i, values, off, compact_cidx_c, fill, fld%c2l_scale, fld%l2g_scale)
       end if
    else
       if (fld%source_level == lev_patch) then
          k = compact_cidx_p(i)
       else
          k = compact_cidx_c(i)
       end if
       if (k > 0) then
          compact_sample = values(off + k)
       else if (k < 0) then
          compact_sample = fill
       else
          compact_sample = spval
       end if
    end if

  end function compact_sample

  !-----------------------------------------------------------------------
  pure logical function item_active(view, fld, i)
    !
    ! !DESCRIPTION:
    ! Whether output point i counts: native output of a topounit, landunit,
    ! column or patch field needs an active point; averaged and gridcell
    ! fields have no active check.
    !
    !$acc routine seq
    ! !ARGUMENTS:
    type(subgrid_ave_view) , intent(in) :: view
    type(hist_active_field), intent(in) :: fld
    integer                , intent(in) :: i
    !-----------------------------------------------------------------------

    item_active = .true.
    if (fld%average_to_gridcell) return
    select case (fld%source_level)
    case (lev_topo)
       item_active = view%active_t(i)
    case (lev_lun)
       item_active = view%active_l(i)
    case (lev_col)
       item_active = view%active_c(i)
    case (lev_patch)
       item_active = view%active_p(i)
    end select

  end function item_active

  !-----------------------------------------------------------------------
  pure subroutine accumulate_one(time_op, gridcell_rule, sample, active, hbuf, nacs)
    !
    ! !DESCRIPTION:
    ! Apply the time operation to one buffer element (the rules are in the
    ! module header). A sample counts if its point is active and it isn't
    ! spval.
    !
    !$acc routine seq
    ! !ARGUMENTS:
    integer , intent(in)    :: time_op
    logical , intent(in)    :: gridcell_rule  ! averaged to gridcells: the 'X'/'M' rule for a missing sample
    real(r8), intent(in)    :: sample
    logical , intent(in)    :: active
    real(r8), intent(inout) :: hbuf
    integer , intent(inout) :: nacs
    !
    ! !LOCAL VARIABLES:
    logical :: valid
    !-----------------------------------------------------------------------

    valid = active .and. sample /= spval
    select case (time_op)
    case (time_inst)
       if (valid) then
          hbuf = sample
       else
          hbuf = spval
       end if
       nacs = 1
    case (time_mean)
       if (valid) then
          if (nacs == 0) hbuf = 0._r8
          hbuf = hbuf + sample
          nacs = nacs + 1
       else if (nacs == 0) then
          hbuf = spval
       end if
    case (time_max)
       if (valid) then
          if (nacs == 0) hbuf = -big
          hbuf = max(hbuf, sample)
       else if (gridcell_rule .or. nacs == 0) then
          hbuf = spval
       end if
       nacs = 1
    case (time_min)
       if (valid) then
          if (nacs == 0) hbuf = big
          hbuf = min(hbuf, sample)
       else if (gridcell_rule .or. nacs == 0) then
          hbuf = spval
       end if
       nacs = 1
    case (time_max_valid)
       if (valid) then
          if (nacs == 0) hbuf = -big
          hbuf = max(hbuf, sample)
          nacs = nacs + 1
       else if (nacs == 0) then
          hbuf = spval
       end if
    case (time_min_valid)
       if (valid) then
          if (nacs == 0) hbuf = big
          hbuf = min(hbuf, sample)
          nacs = nacs + 1
       else if (nacs == 0) then
          hbuf = spval
       end if
    end select

  end subroutine accumulate_one

  !-----------------------------------------------------------------------
  pure integer function snow_index(fld, i, lev)
    ! Position of point i, level lev of a snow field in snow_values.
    !$acc routine seq
    type(hist_active_field), intent(in) :: fld
    integer, intent(in) :: i, lev
    snow_index = fld%snow_offset + (lev - 1) * (fld%source_last - fld%source_first + 1) &
         + (i - fld%source_first + 1)
  end function snow_index

  !-----------------------------------------------------------------------
  pure real(r8) function snow_layer_value(view, fld, model_array, npoints, i, lev)
    !
    ! !DESCRIPTION:
    ! Value of a snow field at point i (column or patch), level lev, with the
    ! levels of absent snow layers set to the no-snow value. Levels are ordered
    ! bottom-up with the absent layers first, unless extrasnowlayers, where
    ! the top layer comes first and the absent layers last.
    !
    !$acc routine seq
    ! !ARGUMENTS:
    type(subgrid_ave_view) , intent(in) :: view
    type(hist_active_field), intent(in) :: fld
    real(r8)               , intent(in) :: model_array(*)   ! [point of the level, level from 1], npoints per level
    integer                , intent(in) :: npoints          ! (an assumed-size dummy: passing the pointer
    integer                , intent(in) :: i, lev           !  itself as assumed-shape needs a descriptor
                                                            !  temporary, which raced under multicore threads)
    !
    ! !LOCAL VARIABLES:
    integer  :: c, point_in_level, num_absent
    real(r8) :: no_snow_value
    !-----------------------------------------------------------------------

    if (fld%source_level == lev_patch) then
       c = view%col_of_pft(i)
    else
       c = i
    end if
    num_absent = fld%num_levels - abs(view%snl(c))
    no_snow_value = spval
    if (fld%no_snow_behavior == no_snow_zero) no_snow_value = 0._r8
    point_in_level = i - fld%source_first + 1

    if (.not. extrasnowlayers) then
       if (lev <= num_absent) then
          snow_layer_value = no_snow_value
       else
          snow_layer_value = model_array(point_in_level + (lev - 1) * npoints)
       end if
    else
       if (lev > fld%num_levels - num_absent) then
          snow_layer_value = no_snow_value
       else
          snow_layer_value = model_array(point_in_level + (lev + num_absent - 1) * npoints)
       end if
    end if

  end function snow_layer_value

  !-----------------------------------------------------------------------
  pure subroutine field_level(view, fld, lev, values, all_active, gridcell_samples, hbuf_pool, nacs_pool)
    !
    ! !DESCRIPTION:
    ! Accumulate level lev of field fld: average it to gridcells first if the
    ! field is averaged, then apply its time operation to all output points.
    ! The scratch and buffer pools are passed in (pure: no module state is
    ! changed); the field's part of them is found from its offsets.
    !
    ! !ARGUMENTS:
    type(subgrid_ave_view) , intent(in)    :: view
    type(hist_active_field), intent(in)    :: fld
    integer                , intent(in)    :: lev
    real(r8)               , intent(in)    :: values(*)           ! the level's values; values(1) is the first point of the source level
    logical                , intent(in)    :: all_active(:)       ! .true. (points without an active check)
    real(r8)               , intent(inout) :: gridcell_samples(*) ! averages of the averaged fields
    real(r8)               , intent(inout) :: hbuf_pool(*)
    integer                , intent(inout) :: nacs_pool(*)
    !
    ! !LOCAL VARIABLES:
    integer :: num_points, buffer_first, sample_first
    !-----------------------------------------------------------------------

    num_points   = fld%last_point - fld%first_point + 1
    buffer_first = fld%buffer_offset + (lev - 1) * num_points + 1

    if (fld%average_to_gridcell) then
       sample_first = fld%sample_offset + (lev - 1) * num_points + 1
       select case (fld%source_level)
       case (lev_patch)
          if (fld%c2l_scale == scale_unity .and. fld%l2g_scale == scale_unity) then
             call p2g_range_unity(view, view%begg, view%endg, values, view%begp, gridcell_samples(sample_first))
          else
             call p2g_range(view, view%begg, view%endg, values, view%begp, fld%c2l_scale, fld%l2g_scale, &
                  gridcell_samples(sample_first))
          end if
       case (lev_col)
          if (fld%c2l_scale == scale_unity .and. fld%l2g_scale == scale_unity) then
             call c2g_range_unity(view, view%begg, view%endg, values, view%begc, gridcell_samples(sample_first))
          else
             call c2g_range(view, view%begg, view%endg, values, view%begc, fld%c2l_scale, fld%l2g_scale, &
                  gridcell_samples(sample_first))
          end if
       case (lev_lun)
          call l2g_range(view, view%begg, view%endg, values, view%begl, fld%l2g_scale, gridcell_samples(sample_first))
       case (lev_topo)
          call t2g_range(view, view%begg, view%endg, values, view%begt, gridcell_samples(sample_first))
       end select
       call accumulate_samples(fld%time_op, .true., num_points, gridcell_samples(sample_first), &
            all_active, hbuf_pool(buffer_first), nacs_pool(buffer_first))
    else
       select case (fld%source_level)
       case (lev_topo)
          call accumulate_samples(fld%time_op, .false., num_points, values, view%active_t, &
               hbuf_pool(buffer_first), nacs_pool(buffer_first))
       case (lev_lun)
          call accumulate_samples(fld%time_op, .false., num_points, values, view%active_l, &
               hbuf_pool(buffer_first), nacs_pool(buffer_first))
       case (lev_col)
          call accumulate_samples(fld%time_op, .false., num_points, values, view%active_c, &
               hbuf_pool(buffer_first), nacs_pool(buffer_first))
       case (lev_patch)
          call accumulate_samples(fld%time_op, .false., num_points, values, view%active_p, &
               hbuf_pool(buffer_first), nacs_pool(buffer_first))
       case default
          call accumulate_samples(fld%time_op, .false., num_points, values, all_active, &
               hbuf_pool(buffer_first), nacs_pool(buffer_first))
       end select
    end if

  end subroutine field_level

  !-----------------------------------------------------------------------
  pure subroutine field_level_compact(view, fld, lev, values, cidx_p, cidx_c, fill, all_active, gridcell_samples, &
       hbuf_pool, nacs_pool)
    !
    ! !DESCRIPTION:
    ! field_level for level lev of a field in the compact layout: values(k) is
    ! the value of the point whose compact index is k (cidx_p / cidx_c, the maps
    ! of CompactLayoutMod, passed each step because they are reallocated when
    ! the filters change); a point with cidx -1 (active, on a special landunit)
    ! has the group's fill value and a point with cidx 0 has spval, as the
    ! full layout held.
    !
    ! !ARGUMENTS:
    type(subgrid_ave_view) , intent(in)    :: view
    type(hist_active_field), intent(in)    :: fld
    integer                , intent(in)    :: lev
    real(r8)               , intent(in)    :: values(*)           ! compact values of the level
    integer                , intent(in)    :: cidx_p(view%begp:)  ! compact index per patch
    integer                , intent(in)    :: cidx_c(view%begc:)  ! compact index per column
    real(r8)               , intent(in)    :: fill
    logical                , intent(in)    :: all_active(:)
    real(r8)               , intent(inout) :: gridcell_samples(*)
    real(r8)               , intent(inout) :: hbuf_pool(*)
    integer                , intent(inout) :: nacs_pool(*)
    !
    ! !LOCAL VARIABLES:
    integer :: num_points, buffer_first, sample_first
    !-----------------------------------------------------------------------

    num_points   = fld%last_point - fld%first_point + 1
    buffer_first = fld%buffer_offset + (lev - 1) * num_points + 1

    if (fld%average_to_gridcell) then
       sample_first = fld%sample_offset + (lev - 1) * num_points + 1
       if (fld%source_level == lev_patch) then
          call p2g_range_compact(view, view%begg, view%endg, values, cidx_p, fill, fld%c2l_scale, fld%l2g_scale, &
               gridcell_samples(sample_first))
       else
          call c2g_range_compact(view, view%begg, view%endg, values, cidx_c, fill, fld%c2l_scale, fld%l2g_scale, &
               gridcell_samples(sample_first))
       end if
       call accumulate_samples(fld%time_op, .true., num_points, gridcell_samples(sample_first), &
            all_active, hbuf_pool(buffer_first), nacs_pool(buffer_first))
    else if (fld%source_level == lev_patch) then
       call accumulate_samples_compact(fld%time_op, num_points, values, &
            cidx_p(fld%source_first:fld%source_last), fill, &
            view%active_p, hbuf_pool(buffer_first), nacs_pool(buffer_first))
    else
       call accumulate_samples_compact(fld%time_op, num_points, values, &
            cidx_c(fld%source_first:fld%source_last), fill, &
            view%active_c, hbuf_pool(buffer_first), nacs_pool(buffer_first))
    end if

  end subroutine field_level_compact

  !-----------------------------------------------------------------------
  pure subroutine accumulate_samples_compact(time_op, n, values, cidx, fill, active, hbuf, nacs)
    !
    ! !DESCRIPTION:
    ! accumulate_samples (native output, gridcell_rule false) for a compact
    ! field: point i's sample is values(cidx(i)) when cidx(i) > 0, fill when
    ! cidx(i) < 0 and spval otherwise. Kept as a separate routine so the
    ! full-array path is untouched.
    !
    ! !ARGUMENTS:
    integer , intent(in)    :: time_op
    integer , intent(in)    :: n
    real(r8), intent(in)    :: values(*)   ! compact values
    integer , intent(in)    :: cidx(*)     ! cidx(i): compact index of point i (first point of the level = 1)
    real(r8), intent(in)    :: fill
    logical , intent(in)    :: active(:)
    real(r8), intent(inout) :: hbuf(*)
    integer , intent(inout) :: nacs(*)
    !
    ! !LOCAL VARIABLES:
    integer  :: i, k
    real(r8) :: s
    logical  :: valid
    !-----------------------------------------------------------------------

    select case (time_op)
    case (time_inst)
       do i = 1, n
          k = cidx(i)
          if (k > 0) then
             s = values(k)
          else if (k < 0) then
             s = fill
          else
             s = spval
          end if
          valid = active(i) .and. s /= spval
          if (valid) then
             hbuf(i) = s
          else
             hbuf(i) = spval
          end if
          nacs(i) = 1
       end do

    case (time_mean)
       do i = 1, n
          k = cidx(i)
          if (k > 0) then
             s = values(k)
          else if (k < 0) then
             s = fill
          else
             s = spval
          end if
          valid = active(i) .and. s /= spval
          if (valid) then
             if (nacs(i) == 0) hbuf(i) = 0._r8
             hbuf(i) = hbuf(i) + s
             nacs(i) = nacs(i) + 1
          else if (nacs(i) == 0) then
             hbuf(i) = spval
          end if
       end do

    case (time_max)
       do i = 1, n
          k = cidx(i)
          if (k > 0) then
             s = values(k)
          else if (k < 0) then
             s = fill
          else
             s = spval
          end if
          valid = active(i) .and. s /= spval
          if (valid) then
             if (nacs(i) == 0) hbuf(i) = -big
             hbuf(i) = max(hbuf(i), s)
          else if (nacs(i) == 0) then
             hbuf(i) = spval
          end if
          nacs(i) = 1
       end do

    case (time_min)
       do i = 1, n
          k = cidx(i)
          if (k > 0) then
             s = values(k)
          else if (k < 0) then
             s = fill
          else
             s = spval
          end if
          valid = active(i) .and. s /= spval
          if (valid) then
             if (nacs(i) == 0) hbuf(i) = big
             hbuf(i) = min(hbuf(i), s)
          else if (nacs(i) == 0) then
             hbuf(i) = spval
          end if
          nacs(i) = 1
       end do

    case (time_max_valid)
       do i = 1, n
          k = cidx(i)
          if (k > 0) then
             s = values(k)
          else if (k < 0) then
             s = fill
          else
             s = spval
          end if
          valid = active(i) .and. s /= spval
          if (valid) then
             if (nacs(i) == 0) hbuf(i) = -big
             hbuf(i) = max(hbuf(i), s)
             nacs(i) = nacs(i) + 1
          else if (nacs(i) == 0) then
             hbuf(i) = spval
          end if
       end do

    case (time_min_valid)
       do i = 1, n
          k = cidx(i)
          if (k > 0) then
             s = values(k)
          else if (k < 0) then
             s = fill
          else
             s = spval
          end if
          valid = active(i) .and. s /= spval
          if (valid) then
             if (nacs(i) == 0) hbuf(i) = big
             hbuf(i) = min(hbuf(i), s)
             nacs(i) = nacs(i) + 1
          else if (nacs(i) == 0) then
             hbuf(i) = spval
          end if
       end do
    end select

  end subroutine accumulate_samples_compact

  !-----------------------------------------------------------------------
  pure subroutine accumulate_samples(time_op, gridcell_rule, n, samples, active, hbuf, nacs)
    !
    ! !DESCRIPTION:
    ! Accumulate n samples into their buffers (rules in the module
    ! description). gridcell_rule selects the 'X'/'M' rules of fields averaged
    ! to gridcells.
    !
    ! !ARGUMENTS:
    integer , intent(in)    :: time_op
    logical , intent(in)    :: gridcell_rule
    integer , intent(in)    :: n
    real(r8), intent(in)    :: samples(*)
    logical , intent(in)    :: active(:)   ! active(i): point i is active
    real(r8), intent(inout) :: hbuf(*)
    integer , intent(inout) :: nacs(*)
    !
    ! !LOCAL VARIABLES:
    integer :: i
    logical :: valid
    !-----------------------------------------------------------------------

    select case (time_op)
    case (time_inst)
       do i = 1, n
          valid = active(i) .and. samples(i) /= spval
          if (valid) then
             hbuf(i) = samples(i)
          else
             hbuf(i) = spval
          end if
          nacs(i) = 1
       end do

    case (time_mean)
       do i = 1, n
          valid = active(i) .and. samples(i) /= spval
          if (valid) then
             if (nacs(i) == 0) hbuf(i) = 0._r8
             hbuf(i) = hbuf(i) + samples(i)
             nacs(i) = nacs(i) + 1
          else if (nacs(i) == 0) then
             hbuf(i) = spval
          end if
       end do

    case (time_max)
       if (gridcell_rule) then
          do i = 1, n
             valid = active(i) .and. samples(i) /= spval
             if (valid) then
                if (nacs(i) == 0) hbuf(i) = -big
                hbuf(i) = max(hbuf(i), samples(i))
             else
                hbuf(i) = spval
             end if
             nacs(i) = 1
          end do
       else
          do i = 1, n
             valid = active(i) .and. samples(i) /= spval
             if (valid) then
                if (nacs(i) == 0) hbuf(i) = -big
                hbuf(i) = max(hbuf(i), samples(i))
             else if (nacs(i) == 0) then
                hbuf(i) = spval
             end if
             nacs(i) = 1
          end do
       end if

    case (time_min)
       if (gridcell_rule) then
          do i = 1, n
             valid = active(i) .and. samples(i) /= spval
             if (valid) then
                if (nacs(i) == 0) hbuf(i) = big
                hbuf(i) = min(hbuf(i), samples(i))
             else
                hbuf(i) = spval
             end if
             nacs(i) = 1
          end do
       else
          do i = 1, n
             valid = active(i) .and. samples(i) /= spval
             if (valid) then
                if (nacs(i) == 0) hbuf(i) = big
                hbuf(i) = min(hbuf(i), samples(i))
             else if (nacs(i) == 0) then
                hbuf(i) = spval
             end if
             nacs(i) = 1
          end do
       end if

    case (time_max_valid)
       do i = 1, n
          valid = active(i) .and. samples(i) /= spval
          if (valid) then
             if (nacs(i) == 0) hbuf(i) = -big
             hbuf(i) = max(hbuf(i), samples(i))
             nacs(i) = nacs(i) + 1
          else if (nacs(i) == 0) then
             hbuf(i) = spval
          end if
       end do

    case (time_min_valid)
       do i = 1, n
          valid = active(i) .and. samples(i) /= spval
          if (valid) then
             if (nacs(i) == 0) hbuf(i) = big
             hbuf(i) = min(hbuf(i), samples(i))
             nacs(i) = nacs(i) + 1
          else if (nacs(i) == 0) then
             hbuf(i) = spval
          end if
       end do
    end select

  end subroutine accumulate_samples

  !-----------------------------------------------------------------------
  subroutine hist_compute_normalize(t)
    !
    ! !DESCRIPTION:
    ! Divide the time means of tape t by their number of samples.
    !
    ! !ARGUMENTS:
    integer, intent(in) :: t
    !
    ! !LOCAL VARIABLES:
    integer :: f, n, first, last
    !-----------------------------------------------------------------------

    !$acc parallel loop gang default(present) private(first, last) if(elm_device_ready)
    do f = tape_first_field(t), tape_first_field(t+1) - 1
       if (fields(f)%time_op /= time_mean) cycle
       first = fields(f)%buffer_offset + 1
       last  = fields(f)%buffer_offset + (fields(f)%last_point - fields(f)%first_point + 1) * fields(f)%num_levels
       !$acc loop vector
       do n = first, last
          if (nacs_pool(n) /= 0) hbuf_pool(n) = hbuf_pool(n) / real(nacs_pool(n), r8)
       end do
    end do

  end subroutine hist_compute_normalize

  !-----------------------------------------------------------------------
  subroutine hist_compute_zero(t)
    !
    ! !DESCRIPTION:
    ! Zero the buffers and counters of tape t.
    !
    ! !ARGUMENTS:
    integer, intent(in) :: t
    !
    ! !LOCAL VARIABLES:
    integer :: n, first, last
    !-----------------------------------------------------------------------

    call tape_range(t, first, last)
    !$acc parallel loop default(present) if(elm_device_ready)
    do n = first, last
       hbuf_pool(n) = 0._r8
       nacs_pool(n) = 0
    end do
    ! hist_htapes_wrapup (a host segment, flag off) zeroes the host copy; the buffers accumulate
    ! on the device (hist_compute_update), and the whole-state transitions don't carry these
    ! private pools, so push the zeros there
    if (.not. elm_device_ready .and. last >= first) then
       !$acc update device(hbuf_pool(first:last), nacs_pool(first:last))
    end if

  end subroutine hist_compute_zero

  !-----------------------------------------------------------------------
  subroutine hist_compute_update_host(t)
    !
    ! !DESCRIPTION:
    ! Copy tape t's buffers to the host before they are written (OpenACC).
    !
    ! !ARGUMENTS:
    integer, intent(in) :: t
    !
    ! !LOCAL VARIABLES:
    integer :: first, last
    !-----------------------------------------------------------------------

    call tape_range(t, first, last)
    if (last < first) return
    !$acc update self(hbuf_pool(first:last), nacs_pool(first:last))

  end subroutine hist_compute_update_host

  !-----------------------------------------------------------------------
  subroutine hist_compute_update_device()
    !
    ! !DESCRIPTION:
    ! Copy all buffers to the device after they were read on the host
    ! (restart; OpenACC).
    !-----------------------------------------------------------------------

    !$acc update device(hbuf_pool, nacs_pool)

  end subroutine hist_compute_update_device

  !-----------------------------------------------------------------------
  pure subroutine tape_range(t, first, last)
    ! The positions of tape t's buffers in the pool (last < first if none).
    integer, intent(in)  :: t
    integer, intent(out) :: first, last
    integer :: f_last

    first = 1
    last  = 0
    if (tape_first_field(t+1) <= tape_first_field(t)) return
    f_last = tape_first_field(t+1) - 1
    first = fields(tape_first_field(t))%buffer_offset + 1
    last  = fields(f_last)%buffer_offset + &
         (fields(f_last)%last_point - fields(f_last)%first_point + 1) * fields(f_last)%num_levels
  end subroutine tape_range

end module histComputeMod
