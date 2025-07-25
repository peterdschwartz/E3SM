! this module is a version of components/eam/src/physics/cam/physconst.F90
! modified to facilitate bridging to the fortran ZM deep convection scheme
module zm_eamxx_bridge_physconst

   ! Physical constants.  Use CCSM shared values whenever available.

   use zm_eamxx_bridge_params, only: r8, pcols, pver, pverp
   ! use shr_kind_mod,  only: r8 => shr_kind_r8
   use shr_const_mod, only: shr_const_g,      shr_const_stebol, shr_const_tkfrz,  &
                            shr_const_mwdair, shr_const_rdair,  shr_const_mwwv,   &
                            shr_const_latice, shr_const_latvap, shr_const_cpdair, &
                            shr_const_rhofw,  shr_const_cpwv,   shr_const_rgas,   &
                            shr_const_karman, shr_const_pstd,   shr_const_rhodair,&
                            shr_const_avogad, shr_const_boltz,  shr_const_cpfw,   &
                            shr_const_rwv,    shr_const_zvir,   shr_const_pi,     &
                            shr_const_rearth, shr_const_sday,   shr_const_cday,   &
                            shr_const_spval,  shr_const_omega,  shr_const_cpvir,  &
                            shr_const_tktrip
   ! use ppgrid,        only: pcols, pver, pverp, begchunk, endchunk   ! Dimensions and chunk bounds

   implicit none

   private
   save
   
   ! Constantants for MAM spciesi classes
   integer, public, parameter :: spec_class_undefined  = 0
   integer, public, parameter :: spec_class_cldphysics = 1
   integer, public, parameter :: spec_class_aerosol    = 2
   integer, public, parameter :: spec_class_gas        = 3
   integer, public, parameter :: spec_class_other      = 4

   ! Constants based off share code or defined in physconst

   real(r8), public, parameter :: avogad      = shr_const_avogad     ! Avogadro's number (molecules/kmole)
   real(r8), public, parameter :: boltz       = shr_const_boltz      ! Boltzman's constant (J/K/molecule)
   real(r8), public, parameter :: cday        = shr_const_cday       ! sec in calendar day ~ sec
   real(r8), public, parameter :: cpair       = shr_const_cpdair     ! specific heat of dry air (J/K/kg)
   real(r8), public, parameter :: cpliq       = shr_const_cpfw       ! specific heat of fresh h2o (J/K/kg)
   real(r8), public, parameter :: karman      = shr_const_karman     ! Von Karman constant
   real(r8), public, parameter :: latice      = shr_const_latice     ! Latent heat of fusion (J/kg)
   real(r8), public, parameter :: latvap      = shr_const_latvap     ! Latent heat of vaporization (J/kg)
   real(r8), public, parameter :: pi          = shr_const_pi         ! 3.14...
   real(r8), public, parameter :: pstd        = shr_const_pstd       ! Standard pressure (Pascals)
   real(r8), public, parameter :: r_universal = shr_const_rgas       ! Universal gas constant (J/K/kmol)
   real(r8), public, parameter :: rhoh2o      = shr_const_rhofw      ! Density of liquid water (STP)
   real(r8), public, parameter :: spval       = shr_const_spval      !special value 
   real(r8), public, parameter :: stebol      = shr_const_stebol     ! Stefan-Boltzmann's constant (W/m^2/K^4)
   real(r8), public, parameter :: h2otrip     = shr_const_tktrip     ! Triple point temperature of water (K)

   real(r8), public, parameter :: c0          = 2.99792458e8_r8      ! Speed of light in a vacuum (m/s)
   real(r8), public, parameter :: planck      = 6.6260755e-34_r8     ! Planck's constant (J.s)

   ! Molecular weights
   real(r8), public, parameter :: mwco2       =  44._r8             ! molecular weight co2
   real(r8), public, parameter :: mwn2o       =  44._r8             ! molecular weight n2o
   real(r8), public, parameter :: mwch4       =  16._r8             ! molecular weight ch4
   real(r8), public, parameter :: mwf11       = 136._r8             ! molecular weight cfc11
   real(r8), public, parameter :: mwf12       = 120._r8             ! molecular weight cfc12
   real(r8), public, parameter :: mwo3        =  48._r8             ! molecular weight O3
   real(r8), public, parameter :: mwso2       =  64._r8
   real(r8), public, parameter :: mwso4       =  96._r8
   real(r8), public, parameter :: mwh2o2      =  34._r8
   real(r8), public, parameter :: mwdms       =  62._r8
   real(r8), public, parameter :: mwnh4       =  18._r8


   ! modifiable physical constants for aquaplanet or doubly periodic mode

   real(r8), public           :: gravit       = shr_const_g     ! gravitational acceleration (m/s**2)
   real(r8), public           :: sday         = shr_const_sday  ! sec in siderial day ~ sec
   real(r8), public           :: mwh2o        = shr_const_mwwv  ! molecular weight h2o
   real(r8), public           :: cpwv         = shr_const_cpwv  ! specific heat of water vapor (J/K/kg)
   real(r8), public           :: mwdry        = shr_const_mwdair! molecular weight dry air
   real(r8), public           :: rearth       = shr_const_rearth! radius of earth (m)
   real(r8), public           :: tmelt        = shr_const_tkfrz ! Freezing point of water (K)
   real(r8), public           :: omega        = shr_const_omega ! earth rot ~ rad/sec   

!---------------  Variables below here are derived from those above -----------------------

   real(r8), public           :: rga          = 1._r8/shr_const_g                 ! reciprocal of gravit
   real(r8), public           :: ra           = 1._r8/shr_const_rearth            ! reciprocal of earth radius
   real(r8), public           :: rh2o         = shr_const_rwv                     ! Water vapor gas constant ~ J/K/kg
   real(r8), public           :: rair         = shr_const_rdair   ! Dry air gas constant     ~ J/K/kg
   real(r8), public           :: epsilo       = shr_const_mwwv/shr_const_mwdair   ! ratio of h2o to dry air molecular weights 
   real(r8), public           :: zvir         = shr_const_zvir                    ! (rh2o/rair) - 1
   real(r8), public           :: cpvir        = shr_const_cpvir                   ! CPWV/CPDAIR - 1.0
   real(r8), public           :: rhodair      = shr_const_rhodair                 ! density of dry air at STP  ~ kg/m^3
   real(r8), public           :: cappa        = (shr_const_rgas/shr_const_mwdair)/shr_const_cpdair  ! R/Cp
   real(r8), public           :: ez           ! Coriolis expansion coeff -> omega/sqrt(0.375)   
   real(r8), public           :: Cpd_on_Cpv   = shr_const_cpdair/shr_const_cpwv

!---------------  Variables below here are for WACCM-X -----------------------
   real(r8), public, dimension(:,:,:), pointer :: cpairv ! composition dependent specific heat at constant pressure
   real(r8), public, dimension(:,:,:), pointer :: rairv  ! composition dependent gas "constant"
   real(r8), public, dimension(:,:,:), pointer :: cappav ! rairv/cpairv
   real(r8), public, dimension(:,:,:), pointer :: mbarv  ! composition dependent atmosphere mean mass
   real(r8), public, dimension(:,:,:), pointer :: kmvis  ! molecular viscosity      kg/m/s
   real(r8), public, dimension(:,:,:), pointer :: kmcnd  ! molecular conductivity   J/m/s/K
                         
!---------------  Variables below here are for turbulent mountain stress -----------------------

   real(r8), public           :: tms_orocnst
   real(r8), public           :: tms_z0fac

end module zm_eamxx_bridge_physconst

