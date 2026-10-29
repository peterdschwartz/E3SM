program test_accum_compute
  ! accumComputeMod against the original serial algorithm (accum_reference_mod), bit for bit:
  ! every accumulation type, periods 1/6/24, single- and multi-level fields on bounds that
  ! don't start at 1, inactive points (changing every 7 steps), runaccum resets (-99999) and
  ! both clamps. Half the fields pass model arrays that are on the device (as ELM's are), the
  ! others local buffers that are not; every 10th step runs on the host (a host segment of the
  ! driver) after the fields moved to the device. Values, step counts and the extracted
  ! values are compared after every step.
  use shr_kind_mod, only : r8 => shr_kind_r8
  use accumComputeMod, only : accum_field, accum_type_code, accum_update, accum_extract, accum_host_values
  use accum_reference_mod, only : ref_update, ref_extract
  implicit none

  integer, parameter :: beg = 11, end = 410, nlev2 = 4, nsteps_run = 100
  real(r8), parameter :: spval = 1.e36_r8
  character(len=8), parameter :: types(3) = [character(len=8) :: 'timeavg', 'runmean', 'runaccum']
  integer, parameter :: periods(3) = [1, 6, 24]

  type :: test_field
     type(accum_field) :: f
     logical :: on_dev_arrays          ! model/out arrays are on the device
     real(r8), pointer :: model(:,:) => null(), out(:,:) => null()  ! pointers, as ELM's type components
     real(r8), allocatable :: rval(:,:), rout(:,:)
     integer , allocatable :: rnsteps(:,:)
  end type test_field

  type(test_field), allocatable, target :: t(:)
  logical, target :: active(beg:end)
  integer :: nf, it, ip, il, n, nstep, nbad, k
  integer(8) :: seed
  logical :: on_device
  real(r8), pointer :: pm(:), po(:)

  seed = 12345_8
  nf = size(types) * size(periods) * 2
  allocate(t(nf))
  call set_active(0)
  !$acc enter data copyin(active)

  n = 0
  do it = 1, size(types)
     do ip = 1, size(periods)
        do il = 1, 2
           n = n + 1
           associate (f => t(n)%f)
             write(f%name, '(a,i0)') 'F', n
             f%acctype = types(it)
             f%acctype_code = accum_type_code(types(it))
             f%period = periods(ip)
             f%beg1d = beg
             f%end1d = end
             f%numlev = merge(1, nlev2, il == 1)
             f%initval = merge(0._r8, 273.15_r8, types(it) == 'runaccum')
             allocate(f%val(beg:end, f%numlev), f%nsteps(beg:end, f%numlev))
             f%val = f%initval
             f%nsteps = 0
             f%active => active
             allocate(t(n)%model(beg:end, f%numlev), t(n)%out(beg:end, f%numlev))
             allocate(t(n)%rval(beg:end, f%numlev), t(n)%rout(beg:end, f%numlev), t(n)%rnsteps(beg:end, f%numlev))
             t(n)%rval = f%initval
             t(n)%rnsteps = 0
             t(n)%out = 0._r8
             t(n)%on_dev_arrays = mod(n, 2) == 0
             if (t(n)%on_dev_arrays) then
                !$acc enter data create(t(n)%model, t(n)%out)
             end if
           end associate
        end do
     end do
  end do

  nbad = 0
  do nstep = 0, nsteps_run
     if (mod(nstep, 7) == 6) then
        call set_active(nstep)
        !$acc update device(active)
     end if
     on_device = mod(nstep, 10) /= 5
     do n = 1, nf
        call fill(t(n))
        if (t(n)%on_dev_arrays) then
           !$acc update device(t(n)%model)
        end if
        associate (f => t(n)%f)
          if (f%numlev == 1) then
             ! through pointer dummies, as accumulMod's update/extract_accum_field_sl pass them
             pm => t(n)%model(:,1)
             po => t(n)%out(:,1)
             call update_sl(f, pm, nstep, on_device)
             call extract_sl(f, po, nstep, on_device)
          else
             call accum_update(f, t(n)%model, nstep, on_device)
             call accum_extract(f, t(n)%out, nstep, spval, on_device)
          end if
          if (t(n)%on_dev_arrays .and. on_device) then
             !$acc update self(t(n)%out)
          end if
          call ref_update(f%acctype, f%period, f%initval, beg, end, f%numlev, t(n)%rval, t(n)%rnsteps, &
               active, t(n)%model, nstep)
          call ref_extract(f%acctype, f%period, beg, end, f%numlev, t(n)%rval, t(n)%rout, nstep, spval)
          call accum_host_values(f)
          if (any(f%val /= t(n)%rval) .or. any(f%nsteps /= t(n)%rnsteps) .or. any(t(n)%out /= t(n)%rout)) then
             nbad = nbad + 1
             if (nbad <= 10) then
                k = maxloc(abs(f%val(:,1) - t(n)%rval(:,1)), dim=1) + beg - 1
                write(*,'(a,i4,1x,a,a,i3,a,l2,a,l2,a,i5,2es24.16,2i6)') 'MISMATCH step', nstep, f%acctype, &
                     ' period', f%period, ' device arrays', t(n)%on_dev_arrays, ' on_device', on_device, &
                     ' worst point', k, f%val(k,1), t(n)%rval(k,1), f%nsteps(k,1), t(n)%rnsteps(k,1)
             end if
          end if
        end associate
     end do
  end do

  if (nbad > 0) then
     write(*,'(a,i0,a)') 'FAIL: ', nbad, ' field-steps differ from the reference'
     error stop 1
  end if
  write(*,'(a,i0,a,i0,a)') 'PASS: ', nf, ' fields x ', nsteps_run + 1, ' steps bit-for-bit with the reference'

contains

  subroutine update_sl(f, p, nstep, on_device)
    type(accum_field), intent(inout) :: f
    real(r8), pointer :: p(:)
    integer, intent(in) :: nstep
    logical, intent(in) :: on_device
    real(r8), pointer :: field(:)
    field(beg:) => p
    call accum_update(f, field(beg:end), nstep, on_device)
  end subroutine update_sl

  subroutine extract_sl(f, p, nstep, on_device)
    type(accum_field), intent(inout) :: f
    real(r8), pointer :: p(:)
    integer, intent(in) :: nstep
    logical, intent(in) :: on_device
    real(r8), pointer :: field(:)
    field(beg:) => p
    call accum_extract(f, field(beg:end), nstep, spval, on_device)
  end subroutine extract_sl

  real(r8) function rand()
    ! a portable LCG (the same numbers with every compiler)
    seed = mod(1103515245_8 * seed + 12345_8, 2147483648_8)
    rand = real(seed, r8) / 2147483648._r8
  end function rand

  subroutine set_active(step)
    integer, intent(in) :: step
    integer :: k
    do k = beg, end
       active(k) = rand() > 0.15_r8 .or. step == 0 .and. k == beg
    end do
  end subroutine set_active

  subroutine fill(tf)
    type(test_field), intent(inout) :: tf
    integer :: j, k
    do j = 1, tf%f%numlev
       do k = beg, end
          select case (trim(tf%f%acctype))
          case ('runaccum')
             if (rand() < 0.05_r8) then
                tf%model(k,j) = -99999._r8
             else if (mod(k, 3) == 0) then
                tf%model(k,j) = 4000._r8 * rand()        ! reaches the 99999 clamp
             else
                tf%model(k,j) = 30._r8 * (rand() - 0.4_r8) ! reaches the 0 clamp
             end if
          case default
             tf%model(k,j) = 250._r8 + 50._r8 * rand() + 0.1_r8 * j
          end select
       end do
    end do
  end subroutine fill

end program test_accum_compute
