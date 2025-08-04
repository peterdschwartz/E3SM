module ForcingUpdateMod

  use shr_kind_mod     , only : r8 => shr_kind_r8
  use atm2lndType      , only : atm2lnd_type, cplbypass_atminput_type
  use TopounitDataType , only : top_af, top_as
  use GridcellType     , only : grc_pp
  use TopounitType     , only : top_pp 
  use shr_const_mod    , only : SHR_CONST_TKFRZ, SHR_CONST_STEBOL
  use elm_varctl       , only: const_climate_hist, add_temperature, add_co2, use_cn
  use elm_varctl       , only: startdate_add_temperature, startdate_add_co2
  use elm_varctl       , only: co2_type, co2_ppmv,  use_c13, create_glacier_mec_landunit

  use elm_varcon       , only: rair, o2_molar_const, c13ratio
  use decompMod        , only : bounds_type
  use domainMod        , only : ldomain_gpu

  ! Constants to compute vapor pressure
  real(r8),parameter :: a0=6.107799961_r8, a1=4.436518521e-01_r8, &
       a2=1.428945805e-02_r8, a3=2.650648471e-04_r8, &
       a4=3.031240396e-06_r8, a5=2.034080948e-08_r8, &
       a6=6.136820929e-11_r8

  real(r8), parameter :: b0=6.109177956_r8, b1=5.034698970e-01_r8, &
       b2=1.886013408e-02_r8, b3=4.176223716e-04_r8, &
       b4=5.824720280e-06_r8, b5=4.838803174e-08_r8, &
       b6=1.838826904e-10_r8

  integer,parameter, dimension(13) :: caldaym = (/ 1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366 /)

  public :: update_forcings_cplbypass
  private :: szenith
contains

  real(r8) function tdc(t)
    !$acc routine seq
    implicit none
    real(r8), intent(in) :: t
    tdc = min( 50._r8, max(-50._r8,(t-SHR_CONST_TKFRZ)) )
  end function tdc
  real(r8) function esatw(t)
    !$acc routine seq
    implicit none
    real(r8), intent(in) :: t
    esatw = 100._r8*(a0+t*(a1+t*(a2+t*(a3+t*(a4+t*(a5+t*a6))))))
  end function esatw
  real(r8) function esati(t)
    !$acc routine seq
    implicit none
    real(r8), intent(in) :: t
    esati= 100._r8*(b0+t*(b1+t*(b2+t*(b3+t*(b4+t*(b5+t*b6))))))
  end function esati

  subroutine update_forcings_cplbypass(bounds, atm2lnd_vars, cpl_bypass_input, &
            dtime, thiscalday,tod, yr, mon, nstep)
    implicit none
    type(bounds_type)  , intent(in)   :: bounds
    type(atm2lnd_type), intent(inout) :: atm2lnd_vars
    type(cplbypass_atminput_type), intent(in) :: cpl_bypass_input 
    real(r8)  , intent(in)    :: dtime
    real(r8)  , intent(in)    :: thiscalday
    integer   , intent(in)    :: tod, yr, mon, nstep
    integer :: v, g, av, topo
    integer, parameter :: met_nvars = 7
    integer  :: swrad_period_len, swrad_period_start, thishr, thismin
    integer ::  aindex(2), starti(3), counti(3), tm, nindex(2)
    real(r8) :: wt1(14), wt2(14), tbot, t, qsat
    real(r8) :: swndf, swndr, swvdf, swvdr, ratio_rvrf, frac, q
    real(r8) :: e, ea, vp  ! vapor pressure (Pa)
    real(r8) :: avgcosz, thiscosz
    integer  :: sdate_addt, sy_addt, sm_addt, sd_addt
    integer  :: sdate_addco2, sy_addco2, sm_addco2, sd_addco2
    real(r8) :: forc_rainc    ! rainxy Atm flux mm/s
    real(r8) :: forc_t        ! atmospheric temperature (Kelvin)
    real(r8) :: forc_q        ! atmospheric specific humidity (kg/kg)
    real(r8) :: forc_pbot     ! atmospheric pressure (Pa)
    real(r8) :: forc_rainl    ! rainxy Atm flux mm/s
    real(r8) :: forc_snowc    ! snowfxy Atm flux  mm/s
    real(r8) :: forc_snowl    ! snowfxl Atm flux  mm/s
    real(r8) :: co2_ppmv_diag ! temporary
    real(r8) :: co2_ppmv_prog ! temporary
    real(r8) :: co2_ppmv_val  ! temporary
    integer  :: co2_type_idx  ! integer flag for co2_type
    integer :: igridcell
    integer :: begg, endg, begt, endt 


  end subroutine update_forcings_cplbypass

  real(r8) function szenith(xcoor, ycoor, ltm, jday, hr, min, offset)
    !Function to calcualte solar zenith angle
    !Used in coupler bypass mode to compute inerpolation for incoming solar
    !$acc routine seq
    use shr_kind_mod , only: r8 => shr_kind_r8
    implicit none
    !inputs
    real(r8) xcoor, ycoor, offset_min
    integer jday, hr, min, ltm, offset
    !working variables
    real(r8) d2r, r2d, lsn, latrad, decrad, decdeg, ha
    real(r8) hangle, harad, saltrad, saltdeg, sazirad, sazideg
    real(r8) szendeg,szenrad
    real,parameter :: pi = 3.14159265358979
    offset_min = offset/60d0   !note assumes 1hr or smaller timestep
    min = min - offset_min

    !adjust time for offsets
    if (min < 0) then
      hr = hr - 1
      min = min+60
    end if
    if (min >= 60) then
      hr = hr+1
      min = min-60
    end if
    if (hr < 0) then
      hr = hr+24
      jday = jday-1
    end if
    if (hr >= 24) then
      hr = hr-24
      jday = jday+1
    end if

    if (jday < 1) jday = 1
    if (xcoor > 180d0) xcoor = xcoor-360d0

    d2r     = pi/180d0
    r2d     = 1/d2r
    lsn     = 12.0d0+((ltm-xcoor)/15.0d0)
    latrad  = ycoor*d2r
    decrad  = 23.45*d2r*sin(d2r*360d0*(284d0+jday)/365d0)
    decdeg  = decrad*r2d
    ha      = hr+min/60.0d0
    hangle  = (lsn-ha)*60.0d0
    harad   = hangle*0.0043633d0

    saltrad = asin((sin(latrad)*sin(decrad))+(cos(latrad)*cos(decrad) &
         *cos(harad)))
    saltdeg = saltrad * r2d
    sazirad = asin(cos(decrad)*sin(harad)/cos(saltrad))
    sazideg = sazirad * r2d

    IF (saltdeg.LT.0.0d0 .OR. saltrad.GT.180.0d0) THEN  ! sun is below horizon
       saltdeg = 0.0d0
       saltrad = 0.0d0
       szendeg = 90.0d0
       szenrad = 90.0d0*d2r
       !mass    = 1229d0**.5d0             ! if solaralt=0 -> sin(0)=0
    ELSE
       szendeg = 90d0-saltdeg
       szenrad = szendeg*d2r
    ENDIF
    szenith = szendeg

  end function szenith

end module ForcingUpdateMod
