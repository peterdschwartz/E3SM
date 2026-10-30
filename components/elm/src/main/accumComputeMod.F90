module accumComputeMod

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! The accumulator fields and their per-step update and extraction, for accumulMod (which
  ! keeps the field list, the name lookup, the initialization from the decomposition and the
  ! restart). No ELM types: the active flags are the caller's (ELM's top_pp/lun_pp/col_pp/
  ! veg_pp%active), so the standalone test (test/accum_compute_test) builds it alone.
  !
  ! With OpenACC the values and step counts of a field move to the device at its first update
  ! or extraction on the device (after the restart reads) and stay there; the active flags
  ! must be present already. The updates run as one kernel per call on the device and as the
  ! same loops on the host otherwise (on_device false: a host segment of the driver, CPU
  ! builds). The model arrays are assumed-shape without `contiguous`: accumulMod passes sections
  ! of pointers, and a contiguous dummy gets a temporary copy for those, so an extraction wrote
  ! the temporary instead of the device copy of the model array. A host call on a field that lives on the device pulls it first and pushes it
  ! after, so the two copies never diverge. The model array is copied only when it is not
  ! already on the device (a local buffer of the caller).
  !
  ! Inactive points are skipped, following the CLM (ctsm5.4.042) active-element fix.
  !
  ! !USES:
  use elm_varctl, only : elm_device_ready  ! compute constructs run on the host before the device copy
  use shr_kind_mod, only : r8 => shr_kind_r8
  !
  implicit none
  private
  !
  ! accumulation types
  integer, parameter, public :: ACCUM_TIMEAVG = 1   ! average over the period, valid at its end
  integer, parameter, public :: ACCUM_RUNMEAN = 2   ! running mean over (at most) the period
  integer, parameter, public :: ACCUM_RUNACCUM = 3  ! running sum, reset by accumResetVal
  real(r8), parameter, public :: accumResetVal = -99999._r8 ! used to do an annual reset ( put in for bug 1858)

  type, public :: accum_field
     character(len=  8) :: name     !field name
     character(len=128) :: desc     !field description
     character(len=  8) :: units    !field units
     character(len=  8) :: acctype  !accumulation type: ["timeavg","runmean","runaccum"]
     integer            :: acctype_code = 0 ! ACCUM_TIMEAVG / ACCUM_RUNMEAN / ACCUM_RUNACCUM
     character(len=  8) :: type1d   !subgrid type: ["gridcell","topounit","landunit","column" or "pft"]
     character(len=  8) :: type2d   !type2d ('','levsoi','numrad',..etc. )
     integer            :: beg1d    !subgrid type beginning index
     integer            :: end1d    !subgrid type ending index
     integer            :: num1d    !total subgrid points
     integer            :: numlev   !number of vertical levels in field
     logical, pointer   :: active(:) => null() ! whether each point is active
     logical, pointer   :: active_storage(:) => null() ! owned storage when no type-level active flag exists
     real(r8)           :: initval  !initial value of accumulated field
     real(r8), pointer  :: val(:,:) => null() !accumulated field
     integer , pointer  :: nsteps(:,:) => null() ! active accumulation step counts since last reset
     integer            :: period   !field accumulation period (in model time steps)
     logical            :: resident = .false. ! val and nsteps live on the device
  end type accum_field

  public :: accum_type_code      ! acctype string -> ACCUM_* (0 if unknown)
  public :: accum_update         ! accumulate one step of a field (1d: numlev 1, or 2d)
  public :: accum_extract        ! the current value (spval while a time average is not ready)
  public :: accum_host_values    ! device -> host of a resident field (restart write)
  public :: accum_device_values  ! host -> device of a resident field (restart read)

  interface accum_update
     module procedure accum_update_1d
     module procedure accum_update_2d
  end interface
  interface accum_extract
     module procedure accum_extract_1d
     module procedure accum_extract_2d
  end interface

contains

  !------------------------------------------------------------------------
  integer function accum_type_code(acctype)
    character(len=*), intent(in) :: acctype
    select case (trim(acctype))
    case ('timeavg')
       accum_type_code = ACCUM_TIMEAVG
    case ('runmean')
       accum_type_code = ACCUM_RUNMEAN
    case ('runaccum')
       accum_type_code = ACCUM_RUNACCUM
    case default
       accum_type_code = 0
    end select
  end function accum_type_code

  !------------------------------------------------------------------------
  subroutine make_resident(f, on_device)
    ! the first device call: the field's values and counts go to the device for good
    type(accum_field), intent(inout) :: f
    logical, intent(in) :: on_device
    if (.not. on_device .or. f%resident) return
    !$acc enter data copyin(f%val, f%nsteps)
    if (associated(f%active_storage)) then
       !$acc enter data copyin(f%active_storage)
    end if
    f%resident = .true.
  end subroutine make_resident

  subroutine accum_host_values(f)
    type(accum_field), intent(inout) :: f
    if (f%resident) then
       ! unconditional: the accumulators are resident here, not in the device-data layer, and this
       ! pull runs when the host takes over (restart write, host-mode update), i.e. with
       ! elm_device_ready already false (an if(elm_device_ready) here lost 10 steps of every
       ! accumulator in the GPU restart, 2026-10-30)
       !$acc update self(f%val, f%nsteps)
    end if
  end subroutine accum_host_values

  subroutine accum_device_values(f)
    type(accum_field), intent(inout) :: f
    if (f%resident) then
       !$acc update device(f%val, f%nsteps)
    end if
  end subroutine accum_device_values

  !------------------------------------------------------------------------
  subroutine accum_update_1d(f, field, nstep, on_device)
    ! single-level field: field(f%beg1d:f%end1d)
    type(accum_field), intent(inout) :: f
    real(r8), intent(in), target :: field(f%beg1d:)
    integer , intent(in) :: nstep
    logical , intent(in) :: on_device
    real(r8), pointer :: field2(:,:)
    field2(f%beg1d:f%end1d, 1:1) => field(f%beg1d:f%end1d)
    call make_resident(f, on_device)
    if (f%resident .and. .not. on_device) call accum_host_values(f)
    !$acc data copyin(field(f%beg1d:f%end1d)) if(on_device)
    call update_values(f%acctype_code, f%period, f%initval, f%beg1d, f%end1d, 1, &
         f%val, f%nsteps, f%active, field2, nstep, on_device)
    !$acc end data
    if (f%resident .and. .not. on_device) call accum_device_values(f)
  end subroutine accum_update_1d

  subroutine accum_update_2d(f, field, nstep, on_device)
    ! multi-level field: field(f%beg1d:f%end1d, 1:f%numlev)
    type(accum_field), intent(inout) :: f
    real(r8), intent(in) :: field(f%beg1d:, :)
    integer , intent(in) :: nstep
    logical , intent(in) :: on_device
    call make_resident(f, on_device)
    if (f%resident .and. .not. on_device) call accum_host_values(f)
    !$acc data copyin(field(f%beg1d:f%end1d, 1:f%numlev)) if(on_device)
    call update_values(f%acctype_code, f%period, f%initval, f%beg1d, f%end1d, f%numlev, &
         f%val, f%nsteps, f%active, field, nstep, on_device)
    !$acc end data
    if (f%resident .and. .not. on_device) call accum_device_values(f)
  end subroutine accum_update_2d

  subroutine update_values(acctype, period, initval, beg, end, numlev, val, nsteps, active, field, nstep, &
       on_device)
    ! the update of every (point, level): one kernel on the device
    integer , intent(in) :: acctype, period, beg, end, numlev, nstep
    real(r8), intent(in) :: initval
    real(r8), intent(inout) :: val(beg:end, numlev)
    integer , intent(inout) :: nsteps(beg:end, numlev)
    logical , intent(in) :: active(beg:)
    real(r8), intent(in) :: field(beg:, :)
    logical , intent(in) :: on_device
    integer :: j, k, accper
    logical :: time_to_reset, period_end

    select case (acctype)
    case (ACCUM_TIMEAVG)
       !time average field reset every accumulation period
       !normalize at end of accumulation period using active-point nsteps
       time_to_reset = (mod(nstep,period) == 1 .or. period == 1) .and. (nstep /= 0)
       period_end = mod(nstep,period) == 0
       !$acc parallel loop gang vector collapse(2) default(present) if(on_device)
       do j = 1, numlev
          do k = beg, end
             if (active(k)) then
                if (time_to_reset) then
                   val(k,j) = 0._r8
                   nsteps(k,j) = 0
                end if
                val(k,j) = val(k,j) + field(k,j)
                nsteps(k,j) = nsteps(k,j) + 1
                if (period_end) then
                   if (nsteps(k,j) > 0) then
                      val(k,j) = val(k,j) / real(nsteps(k,j),r8)
                   else
                      val(k,j) = initval
                   end if
                end if
             end if
          end do
       end do

    case (ACCUM_RUNMEAN)
       !running mean - only update active points; cap nsteps at period
       !$acc parallel loop gang vector collapse(2) default(present) private(accper) if(on_device)
       do j = 1, numlev
          do k = beg, end
             if (active(k)) then
                nsteps(k,j) = min(nsteps(k,j) + 1, period)
                accper = nsteps(k,j)
                val(k,j) = ((accper-1)*val(k,j) + field(k,j)) / real(accper,r8)
             end if
          end do
       end do

    case (ACCUM_RUNACCUM)
       !running accumulation field reset at trigger -99999
       !$acc parallel loop gang vector collapse(2) default(present) if(on_device)
       do j = 1, numlev
          do k = beg, end
             if (active(k)) then
                if (nint(field(k,j)) == -99999) then
                   val(k,j) = 0._r8
                   nsteps(k,j) = 0
                else
                   val(k,j) = min(max(val(k,j) + field(k,j), 0._r8), 99999._r8)
                   nsteps(k,j) = nsteps(k,j) + 1
                end if
             end if
          end do
       end do
    end select
  end subroutine update_values

  !------------------------------------------------------------------------
  subroutine accum_extract_1d(f, field, nstep, spval, on_device)
    ! the current value; spval while a time average is not ready
    type(accum_field), intent(inout) :: f
    real(r8), intent(inout), target :: field(f%beg1d:)
    integer , intent(in) :: nstep
    real(r8), intent(in) :: spval
    logical , intent(in) :: on_device
    real(r8), pointer :: field2(:,:)
    field2(f%beg1d:f%end1d, 1:1) => field(f%beg1d:f%end1d)
    call make_resident(f, on_device)
    if (f%resident .and. .not. on_device) call accum_host_values(f)
    !$acc data copyout(field(f%beg1d:f%end1d)) if(on_device)
    call extract_values(f%acctype_code, f%period, f%beg1d, f%end1d, 1, f%val, field2, nstep, spval, on_device)
    !$acc end data
  end subroutine accum_extract_1d

  subroutine accum_extract_2d(f, field, nstep, spval, on_device)
    type(accum_field), intent(inout) :: f
    real(r8), intent(inout) :: field(f%beg1d:, :)
    integer , intent(in) :: nstep
    real(r8), intent(in) :: spval
    logical , intent(in) :: on_device
    call make_resident(f, on_device)
    if (f%resident .and. .not. on_device) call accum_host_values(f)
    !$acc data copyout(field(f%beg1d:f%end1d, 1:f%numlev)) if(on_device)
    call extract_values(f%acctype_code, f%period, f%beg1d, f%end1d, f%numlev, f%val, field, nstep, spval, &
         on_device)
    !$acc end data
  end subroutine accum_extract_2d

  subroutine extract_values(acctype, period, beg, end, numlev, val, field, nstep, spval, on_device)
    integer , intent(in) :: acctype, period, beg, end, numlev, nstep
    real(r8), intent(in) :: val(beg:end, numlev)
    real(r8), intent(inout) :: field(beg:, :)
    real(r8), intent(in) :: spval
    logical , intent(in) :: on_device
    integer :: j, k
    logical :: not_ready
    not_ready = acctype == ACCUM_TIMEAVG .and. mod(nstep,period) /= 0
    !$acc parallel loop gang vector collapse(2) default(present) if(on_device)
    do j = 1, numlev
       do k = beg, end
          if (not_ready) then
             field(k,j) = spval  !assign absurd value when avg not ready
          else
             field(k,j) = val(k,j)
          end if
       end do
    end do
  end subroutine extract_values

end module accumComputeMod
