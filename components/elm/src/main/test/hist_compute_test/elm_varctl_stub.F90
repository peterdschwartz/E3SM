module elm_varctl
  ! Stub of ELM's elm_varctl for the standalone history and lnd2atm tests (the modules use elm_device_ready)
  implicit none
  logical, public :: elm_device_ready = .true.
  integer, public :: iulog = 6
end module elm_varctl
