module shr_sys_mod
  ! Stub of share/util/shr_sys_mod for the standalone history unit test
  ! (CompactLayoutMod aborts through shr_sys_abort).
  implicit none
  private
  public :: shr_sys_abort
contains
  subroutine shr_sys_abort(string, rc)
    character(len=*), optional, intent(in) :: string
    integer         , optional, intent(in) :: rc
    if (present(string)) write(*,*) 'ABORT: ', trim(string)
    error stop 1
  end subroutine shr_sys_abort
end module shr_sys_mod
