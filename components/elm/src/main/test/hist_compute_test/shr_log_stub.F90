module shr_log_mod
  ! Stub of share/util/shr_log_mod for the standalone history and lnd2atm tests
  ! (histComputeMod and lnd2atmAvgMod write their messages to shr_log_Unit).
  implicit none
  private
  integer, public :: shr_log_Unit = 6
end module shr_log_mod
