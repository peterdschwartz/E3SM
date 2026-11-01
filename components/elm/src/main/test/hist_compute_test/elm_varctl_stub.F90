module elm_varctl_stub
  ! Stub of ELM's elm_varctl flag for the standalone history test (the test passes it to histComputeMod)
  implicit none
  logical, public :: elm_device_ready = .true.
  integer, public :: iulog = 6
end module elm_varctl_stub
