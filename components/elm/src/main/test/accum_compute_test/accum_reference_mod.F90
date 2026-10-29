module accum_reference_mod
  ! The original serial accumulMod algorithm (update_accum_field_sl/ml, extract_accum_field_sl/ml
  ! before accumComputeMod), on plain arrays: the reference of test_accum_compute.
  use shr_kind_mod, only : r8 => shr_kind_r8
  implicit none
  private
  public :: ref_update, ref_extract
contains

  subroutine ref_update(acctype, period, initval, beg, end, numlev, val, nsteps, active, field, nstep)
    character(len=*), intent(in) :: acctype
    integer , intent(in) :: period, beg, end, numlev, nstep
    real(r8), intent(in) :: initval
    real(r8), intent(inout) :: val(beg:end, numlev)
    integer , intent(inout) :: nsteps(beg:end, numlev)
    logical , intent(in) :: active(beg:end)
    real(r8), intent(in) :: field(beg:end, numlev)
    integer :: j, k, accper
    logical :: time_to_reset

    if (acctype == 'timeavg') then
       time_to_reset = (mod(nstep,period) == 1 .or. period == 1) .and. (nstep /= 0)
       do j = 1,numlev
          do k = beg,end
             if (active(k)) then
                if (time_to_reset) then
                   val(k,j) = 0._r8
                   nsteps(k,j) = 0
                end if
                val(k,j) = val(k,j) + field(k,j)
                nsteps(k,j) = nsteps(k,j) + 1
                if (mod(nstep,period) == 0) then
                   if (nsteps(k,j) > 0) then
                      val(k,j) = val(k,j) / real(nsteps(k,j),r8)
                   else
                      val(k,j) = initval
                   end if
                end if
             end if
          end do
       end do
    else if (acctype == 'runmean') then
       do j = 1,numlev
          do k = beg,end
             if (active(k)) then
                nsteps(k,j) = min(nsteps(k,j) + 1, period)
                accper = nsteps(k,j)
                val(k,j) = ((accper-1)*val(k,j) + field(k,j)) / real(accper,r8)
             end if
          end do
       end do
    else if (acctype == 'runaccum') then
       do j = 1,numlev
          do k = beg,end
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
    end if
  end subroutine ref_update

  subroutine ref_extract(acctype, period, beg, end, numlev, val, field, nstep, spval)
    character(len=*), intent(in) :: acctype
    integer , intent(in) :: period, beg, end, numlev, nstep
    real(r8), intent(in) :: val(beg:end, numlev)
    real(r8), intent(out) :: field(beg:end, numlev)
    real(r8), intent(in) :: spval
    integer :: j, k
    if (acctype == 'timeavg' .and. mod(nstep,period) /= 0) then
       do j = 1,numlev
          do k = beg,end
             field(k,j) = spval
          end do
       end do
    else
       do j = 1,numlev
          do k = beg,end
             field(k,j) = val(k,j)
          end do
       end do
    end if
  end subroutine ref_extract

end module accum_reference_mod
