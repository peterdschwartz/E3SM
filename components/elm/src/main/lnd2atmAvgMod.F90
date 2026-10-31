module lnd2atmAvgMod

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! The gridcell averages of the land -> atmosphere export state (lnd2atmMod) as one table:
  ! each entry is a patch or column array (or one level of a 2d one), the gridcell array it
  ! is averaged into, and the c2l/l2g scale types. lnd2atmMod adds the entries once, from the
  ! configuration (the namelist decides which fields exist), in two groups: the minimal
  ! export state of the initialization (lnd2atm_minimal) and the rest of lnd2atm. Each step a
  ! group is averaged in one kernel, gangs over (entry, chunk of gridcells), with the same
  ! per-gridcell averages as subgridAveMod's p2g/c2g (subgridAveViewMod's *_range routines,
  ! the unity variants when both scale types are unity), so the results are bit-for-bit with
  ! the separate p2g/c2g calls this replaces. No ELM types: the view and the arrays are the
  ! caller's, so the standalone test (test/lnd2atm_avg_test) builds this module alone.
  !
  ! The table keeps contiguous pointers with the model arrays' own bounds, made from their
  ! first element (c_f_pointer): no temporary copies when they are passed to the averages, and
  ! one level of a 2d array works like a 1d one. With OpenACC the table goes to the device at the
  ! first average on the device after entries were added, and each pointer is attached then; the
  ! model arrays must be on the device by that time.
  !
  ! !USES:
  use shr_kind_mod, only : r8 => shr_kind_r8
  use shr_sys_mod , only : shr_sys_abort
  use elm_varctl  , only : iulog
  use subgridAveViewMod, only : subgrid_ave_view, scale_unity, p2g_range, c2g_range, p2g_range_unity, &
       c2g_range_unity
  !
  implicit none
  private
  !
  integer, parameter, public :: l2a_patch = 1, l2a_column = 2   ! subgrid level of the source
  integer, parameter, public :: l2a_minimal = 1, l2a_full = 2   ! groups: lnd2atm_minimal, the rest of lnd2atm
  integer, parameter :: gridcell_chunk = 128                    ! as subgridAveMod's wrappers

  type :: l2a_ptr
     real(r8), pointer, contiguous :: ptr(:) => null()
  end type l2a_ptr

  integer, parameter :: max_entries = 256
  integer :: nentries = 0
  integer :: entry_group(max_entries), entry_level(max_entries)
  integer :: entry_c2l(max_entries), entry_l2g(max_entries), entry_beg(max_entries)
  type(l2a_ptr) :: entry_src(max_entries), entry_dst(max_entries)
  logical :: built(2) = .false.
  integer :: ndevice = 0          ! entries on the device (the table's device copy is current if = nentries)

  public :: l2a_built          ! whether a group's entries were added
  public :: l2a_add            ! add an entry (source, destination, level, scale types) to a group
  public :: l2a_finish_group   ! the group is complete
  public :: l2a_average        ! average every entry of a group
  public :: l2a_reset          ! remove every entry (tests)

contains

  !------------------------------------------------------------------------
  logical function l2a_built(group)
    integer, intent(in) :: group
    l2a_built = built(group)
  end function l2a_built

  !------------------------------------------------------------------------
  subroutine l2a_add(group, level, src, src_beg, dst, dst_beg, c2l_scale_type, l2g_scale_type)
    ! src(src_beg:...) averaged into dst(dst_beg:...); both contiguous at run time (ELM's type
    ! components, or one level of a 2d component)
    use, intrinsic :: iso_c_binding, only : c_loc, c_f_pointer
    integer , intent(in) :: group, level
    real(r8), intent(in), target :: src(:)
    integer , intent(in) :: src_beg
    real(r8), intent(in), target :: dst(:)
    integer , intent(in) :: dst_beg
    integer , intent(in) :: c2l_scale_type, l2g_scale_type
    real(r8), pointer, contiguous :: p(:)
    integer :: n
    if (nentries >= max_entries) error stop 'lnd2atmAvgMod: too many entries (max_entries)'
    if (.not. is_contiguous(src) .or. .not. is_contiguous(dst)) error stop 'lnd2atmAvgMod: arrays must be contiguous'
    nentries = nentries + 1
    n = nentries
    entry_group(n) = group
    entry_level(n) = level
    entry_c2l(n) = c2l_scale_type
    entry_l2g(n) = l2g_scale_type
    entry_beg(n) = src_beg
    call c_f_pointer(c_loc(src(1)), p, [size(src)])
    entry_src(n)%ptr(src_beg:src_beg+size(src)-1) => p
    call c_f_pointer(c_loc(dst(1)), p, [size(dst)])
    entry_dst(n)%ptr(dst_beg:dst_beg+size(dst)-1) => p
  end subroutine l2a_add

  !------------------------------------------------------------------------
  subroutine l2a_finish_group(group)
    integer, intent(in) :: group
    built(group) = .true.
  end subroutine l2a_finish_group

  !------------------------------------------------------------------------
  subroutine device_copy()
    ! the table on the device (again, when entries were added since): metadata copied, every
    ! entry's arrays attached. The runtime skips the attach of a pointer whose target is not on
    ! the device and the kernel would then read host memory: every target is checked.
#ifdef _OPENACC
    use openacc, only : acc_is_present
#endif
    integer :: n
#ifdef _OPENACC
    character(len=128) :: msg
    integer :: nmissing
    ! report every missing array (not just the first), then abort
    nmissing = 0
    do n = 1, nentries
       if (.not. acc_is_present(entry_src(n)%ptr)) then
          nmissing = nmissing + 1
          write(iulog, '(a,i0,a,i0,a,i0,a)') 'lnd2atmAvgMod: entry ', n, ' of group ', entry_group(n), &
               ' (level ', entry_level(n), '): SOURCE array is not on the device'
       end if
       if (.not. acc_is_present(entry_dst(n)%ptr)) then
          nmissing = nmissing + 1
          write(iulog, '(a,i0,a,i0,a,i0,a)') 'lnd2atmAvgMod: entry ', n, ' of group ', entry_group(n), &
               ' (level ', entry_level(n), '): DESTINATION array is not on the device'
       end if
    end do
    if (nmissing > 0) then
       write(msg, '(a,i0,a)') 'lnd2atmAvgMod: ', nmissing, ' averaging arrays are not on the device (see log)'
       call shr_sys_abort(trim(msg))
    end if
#endif
    if (ndevice > 0) then
       do n = 1, ndevice
          !$acc exit data detach(entry_src(n)%ptr, entry_dst(n)%ptr)
       end do
       !$acc exit data delete(entry_group, entry_level, entry_c2l, entry_l2g, entry_beg, entry_src, entry_dst)
    end if
    !$acc enter data copyin(entry_group, entry_level, entry_c2l, entry_l2g, entry_beg, entry_src, entry_dst)
    do n = 1, nentries
       !$acc enter data attach(entry_src(n)%ptr, entry_dst(n)%ptr)
    end do
    ndevice = nentries
  end subroutine device_copy

  !------------------------------------------------------------------------
  subroutine l2a_average(group, view, begg, endg, on_device)
    ! every entry of the group: dst(begg:endg) = the gridcell average of src
    integer, intent(in) :: group
    type(subgrid_ave_view), intent(in) :: view
    integer, intent(in) :: begg, endg
    logical, intent(in) :: on_device
    integer :: n, chunk, nchunk, g0, g1
    if (on_device .and. ndevice /= nentries) call device_copy()
    nchunk = (endg - begg) / gridcell_chunk + 1
    !$acc parallel loop gang collapse(2) default(present) private(g0, g1) if(on_device)
    do n = 1, nentries
       do chunk = 1, nchunk
          if (entry_group(n) /= group) cycle
          g0 = begg + (chunk-1) * gridcell_chunk
          g1 = min(g0 + gridcell_chunk - 1, endg)
          if (entry_level(n) == l2a_patch) then
             if (entry_c2l(n) == scale_unity .and. entry_l2g(n) == scale_unity) then
                call p2g_range_unity(view, g0, g1, entry_src(n)%ptr, entry_beg(n), entry_dst(n)%ptr(g0:g1))
             else
                call p2g_range(view, g0, g1, entry_src(n)%ptr, entry_beg(n), entry_c2l(n), entry_l2g(n), &
                     entry_dst(n)%ptr(g0:g1))
             end if
          else
             if (entry_c2l(n) == scale_unity .and. entry_l2g(n) == scale_unity) then
                call c2g_range_unity(view, g0, g1, entry_src(n)%ptr, entry_beg(n), entry_dst(n)%ptr(g0:g1))
             else
                call c2g_range(view, g0, g1, entry_src(n)%ptr, entry_beg(n), entry_c2l(n), entry_l2g(n), &
                     entry_dst(n)%ptr(g0:g1))
             end if
          end if
       end do
    end do
  end subroutine l2a_average

  !------------------------------------------------------------------------
  subroutine l2a_reset()
    integer :: n
    do n = 1, ndevice
       !$acc exit data detach(entry_src(n)%ptr, entry_dst(n)%ptr)
    end do
    if (ndevice > 0) then
       !$acc exit data delete(entry_group, entry_level, entry_c2l, entry_l2g, entry_beg, entry_src, entry_dst)
    end if
    do n = 1, nentries
       nullify(entry_src(n)%ptr, entry_dst(n)%ptr)
    end do
    nentries = 0
    ndevice = 0
    built = .false.
  end subroutine l2a_reset

end module lnd2atmAvgMod
