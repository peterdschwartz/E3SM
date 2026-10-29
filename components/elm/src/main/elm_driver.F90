module elm_driver

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! This module provides the main ELM driver physics calling sequence.  Most
  ! computations occurs over ``clumps'' of gridcells (and associated subgrid
  ! scale entities) assigned to each MPI process. Computation is further
  ! parallelized by looping over clumps on each process using shared memory OpenMP.
  !
  ! !USES:
  use elm_varctl, only : elm_device_ready  ! compute constructs run on the host before the device copy
  use ElmDeviceDataMod, only : elm_device_init, elm_device_copyin, elm_device_update, elm_device_resident  ! spel device-data
  use ElmDeviceDataMod, only : elm_device_fullsync, elm_device_pull_all, elm_device_filters_update  ! spel targeted
  use DeepCopyBiogeophysMod, only : update_canopystate_type, update_energyflux_type, update_photosyns_type, update_soilstate_type, update_waterflux_type  ! spel targeted
  use DeepCopyCouplingMod, only : update_atm2lnd_type  ! spel targeted
  use DeepCopySoilNutrientMod, only : update_ch4_type, update_elm_interface_data_type  ! spel targeted
  use DeepCopyVegNutrientMod, only : update_cnstate_type  ! spel targeted
  use shr_kind_mod           , only : r8 => shr_kind_r8
  use shr_sys_mod            , only : shr_sys_flush
  use shr_log_mod            , only : errMsg => shr_log_errMsg
  use elm_varctl             , only : wrtdia, iulog, create_glacier_mec_landunit, use_fates, use_firn_percolation_and_compaction
  use elm_varctl             , only : use_cn, use_lch4, use_voc, use_noio, use_c13, use_c14
  use elm_varctl             , only : use_erosion, use_fates_sp, use_fan
  use elm_varctl             , only : iac_present
  use elm_varctl             , only : mpi_sync_nstep_freq
  use elm_varctl             , only : nsrest, nsrStartup
  use elm_varctl             , only : fates_radiation_model
  use elm_varctl             , only : finidat
  use elm_time_manager       , only : get_step_size, get_curr_date, get_ref_date, get_nstep, is_beg_curr_day, get_curr_time_string
  use elm_time_manager       , only : is_first_restart_step
  use elm_time_manager       , only : get_curr_calday, get_days_per_year
  use elm_varpar             , only : nlevsno, nlevgrnd, crop_prog
  use spmdMod                , only : masterproc, mpicom
  use decompMod              , only : get_proc_clumps, get_clump_bounds, get_proc_bounds, bounds_type
  use filterMod              , only : filter, filter_inactive_and_active
  use histFileMod            , only : hist_update_hbuf, hist_htapes_wrapup
  use restFileMod            , only : restFile_write, restFile_filename
  use abortutils             , only : endrun
  !
  use dynSubgridDriverMod    , only : dynSubgrid_driver
  use BalanceCheckMod        , only : BeginColWaterBalance, ColWaterBalanceCheck
  use BalanceCheckMod        , only : BeginGridWaterBalance, GridBalanceCheck
  !
  use CanopyTemperatureMod   , only : CanopyTemperature ! (formerly Biogeophysics1Mod)
  use SoilTemperatureMod     , only : SoilTemperature
  use LakeTemperatureMod     , only : LakeTemperature
  !
  use BareGroundFluxesMod    , only : BareGroundFluxes
  use CanopyFluxesMod        , only : CanopyFluxes
  use SedYieldMod            , only : SoilErosion
  use SoilFluxesMod          , only : SoilFluxes ! (formerly Biogeophysics2Mod)
  use UrbanFluxesMod         , only : UrbanFluxes
  use LakeFluxesMod          , only : LakeFluxes
  !
  use HydrologyNoDrainageMod , only : HydrologyNoDrainage ! (formerly Hydrology2Mod)
  use HydrologyDrainageMod   , only : HydrologyDrainage   ! (formerly Hydrology2Mod)
  use CanopyHydrologyMod     , only : CanopyHydrology     ! (formerly Hydrology1Mod)
  use LakeHydrologyMod       , only : LakeHydrology
  !
  use AerosolMod             , only : AerosolMasses
  use SnowSnicarMod          , only : SnowAge_grain
  use SurfaceAlbedoMod       , only : SurfaceAlbedo
  use UrbanAlbedoMod         , only : UrbanAlbedo
  !
  use SurfaceRadiationMod    , only : SurfaceRadiation, CanopySunShadeFractions
  use UrbanRadiationMod      , only : UrbanRadiation
  !
  use SedFluxType            , only : sedflux_type
  !clm_interface
  use EcosystemDynMod      , only : EcosystemDynNoLeaching1, EcosystemDynNoLeaching2

  use EcosystemDynMod      , only : EcosystemDynLeaching
  use VegStructUpdateMod   , only : VegStructUpdate
  use AnnualUpdateMod      , only : AnnualUpdate
  use EcosystemBalanceCheckMod      , only : BeginColCBalance, BeginColNBalance, ColCBalanceCheck, ColNBalanceCheck
  use EcosystemBalanceCheckMod      , only : BeginColPBalance, ColPBalanceCheck
  use EcosystemBalanceCheckMod      , only : BeginGridCBalance, GridCBalanceCheck
  use EcosystemBalanceCheckMod      , only : BeginGridNBalance
  use EcosystemBalanceCheckMod      , only : BeginGridPBalance
  use EcosystemBalanceCheckMod      , only : EndGridCBalanceAfterDynSubgridDriver
  use EcosystemBalanceCheckMod      , only : EndGridNBalanceAfterDynSubgridDriver
  use EcosystemBalanceCheckMod      , only : EndGridPBalanceAfterDynSubgridDriver
  use VerticalProfileMod   , only : decomp_vertprofiles
  use FireMod              , only : FireInterp
  use SatellitePhenologyMod  , only : SatellitePhenology, interpMonthlyVeg
  use ndepStreamMod          , only : ndep_interp
  use pdepStreamMod          , only : pdep_interp
  use ActiveLayerMod         , only : alt_calc
  use CH4Mod                 , only : CH4
  use DUSTMod                , only : DustDryDep, DustEmission
  use VOCEmissionMod         , only : VOCEmission

  !
  use filterMod              , only : setFilters, setExposedvegpFilters
  !
  use atm2lndMod             , only : downscale_forcings, topographic_effects_on_radiation
  use lnd2atmMod             , only : lnd2atm
  use lnd2glcMod             , only : lnd2glc_type
  use lnd2iacMod             , only : lnd2iac_type
  use iac2lndMod             , only : iac2lnd_type
  !
  use seq_drydep_mod         , only : n_drydep, drydep_method, DD_XLND
  use DryDepVelocity         , only : depvel_compute
  !
  use DaylengthMod           , only : UpdateDaylength
  use perf_mod
  !
  use elm_instMod            , only : ch4_vars
  use elm_instMod            , only : crop_vars
  use elm_instMod            , only : cnstate_vars
  use elm_instMod            , only : dust_vars
  use elm_instMod            , only : vocemis_vars
  use elm_instMod            , only : drydepvel_vars
  use elm_instMod            , only : aerosol_vars
  use elm_instMod            , only : canopystate_vars
  use elm_instMod            , only : energyflux_vars
  use elm_instMod            , only : frictionvel_vars
  use elm_instMod            , only : lakestate_vars
  use elm_instMod            , only : photosyns_vars
  use elm_instMod            , only : sedflux_vars
  use elm_instMod            , only : soilstate_vars
  use elm_instMod            , only : soilhydrology_vars
  use elm_instMod            , only : solarabs_vars
  use elm_instMod            , only : soilhydrology_vars
  use elm_instMod            , only : surfalb_vars
  use elm_instMod            , only : surfrad_vars
  use elm_instMod            , only : temperature_vars
  use elm_instMod            , only : col_es
  use elm_instMod            , only : waterflux_vars
  use elm_instMod            , only : waterstate_vars
  use elm_instMod            , only : atm2lnd_vars
  use elm_instMod            , only : ocn2lnd_vars
  use elm_instMod            , only : lnd2atm_vars
  use elm_instMod            , only : glc2lnd_vars
  use elm_instMod            , only : lnd2glc_vars
  use elm_instMod            , only : lnd2iac_vars
  use elm_instMod            , only : iac2lnd_vars
  use elm_instMod            , only : soil_water_retention_curve
  use elm_instMod            , only : chemstate_vars
  use elm_instMod            , only : alm_fates
  use elm_instMod            , only : sedflux_vars
  use UrbanParamsType        , only : urbanparams_vars

  use GridcellType           , only : grc_pp
  use GridcellDataType       , only : grc_cs, c13_grc_cs, c14_grc_cs
  use GridcellDataType       , only : grc_cf, c13_grc_cf, c14_grc_cf
  use GridcellDataType       , only : grc_ns, grc_nf
  use GridcellDataType       , only : grc_ps, grc_pf
  use TopounitDataType       , only : top_as, top_af
  use LandunitType           , only : lun_pp
  use ColumnType             , only : col_pp
  use ColumnDataType         , only : col_es, col_ef, col_ws, col_wf
  use ColumnDataType         , only : col_cs, c13_col_cs, c14_col_cs
  use ColumnDataType         , only : col_cf, c13_col_cf, c14_col_cf
  use ColumnDataType         , only : col_ns, col_nf
  use ColumnDataType         , only : col_ps, col_pf
  use VegetationType         , only : veg_pp
  use VegetationDataType     , only : veg_es, veg_ws, veg_wf, veg_cf
  use VegetationDataType     , only : veg_cs, c13_veg_cs, c14_veg_cs
  use VegetationDataType     , only : veg_ns, veg_nf
  use VegetationDataType     , only : veg_ps, veg_pf
  use FanStreamMod           , only : fanstream_interp

  !----------------------------------------------------------------------------
  ! bgc interface & pflotran:
  use elm_varctl             , only : use_elm_interface
  use elm_instMod            , only : elm_interface_data
  use elm_interface_funcsMod , only : get_elm_data
  ! (1) clm_bgc through interface
  use elm_varctl             , only : use_elm_bgc
  use elm_interface_funcsMod , only : elm_bgc_run, update_bgc_data_elm2elm
  ! (2) pflotran
  use elm_time_manager            , only : nsstep, nestep
  use elm_varctl                  , only : use_pflotran, pf_cmode, pf_hmode, pf_tmode
  use elm_interface_funcsMod      , only : update_bgc_data_pf2elm, update_th_data_pf2elm
  use elm_interface_pflotranMod   , only : elm_pf_run, elm_pf_write_restart
  use elm_interface_pflotranMod   , only : elm_pf_finalize
  !----------------------------------------------------------------------------
  use WaterBudgetMod              , only : WaterBudget_Reset, WaterBudget_Run, WaterBudget_Accum, WaterBudget_Print
  use WaterBudgetMod              , only : WaterBudget_SetBeginningMonthlyStates
  use WaterBudgetMod              , only : WaterBudget_SetEndingMonthlyStates
  use HeatBudgetMod                , only : HeatBudget_Reset, HeatBudget_Run, HeatBudget_Accum, HeatBudget_Print
  use HeatBudgetMod                , only : HeatBudget_SetBeginningStates, HeatBudget_SetEndingStates
  use CNPBudgetMod                , only : CNPBudget_Run, CNPBudget_Accum, CNPBudget_Print, CNPBudget_Reset
  use CNPBudgetMod                , only : CNPBudget_SetBeginningMonthlyStates, CNPBudget_SetEndingMonthlyStates
  use elm_varctl                  , only : do_budgets, budget_inst, budget_daily, budget_month
  use elm_varctl                  , only : budget_ann, budget_ltann, budget_ltend
  use elm_varctl                  , only : use_finetop_rad

  use timeinfoMod
  !
  ! !PUBLIC TYPES:
  implicit none
  !
  ! !PUBLIC MEMBER FUNCTIONS:
  public :: elm_drv            ! Main elm driver
  !
  ! !PRIVATE MEMBER FUNCTIONS:
  private :: elm_drv_patch2col
  private :: elm_drv_init      ! Initialization of variables needed from previous timestep
  private :: write_diagnostic  ! Write diagnostic information to log file
  !-----------------------------------------------------------------------

contains

  !-----------------------------------------------------------------------
  subroutine elm_drv(doalb, nextsw_cday, declinp1, declin, rstwr, nlend, rdate)
    !
    ! !DESCRIPTION:
    !
    ! First phase of the clm driver calling the clm physics. An outline of
    ! the calling tree is given in the description of this module.
    !
    ! !USES:
     use elm_varctl            , only : fates_spitfire_mode
     use elm_varctl            , only : fates_seeddisp_cadence
     use FATESFireFactoryMod   , only : scalar_lightning
     use FatesInterfaceTypesMod, only : fates_dispersal_cadence_none
     use cnpbudgetmod, only : c_budg_stateg  ! spel targeted
     use daylengthmod, only : first_step  ! spel targeted
     use dynharvestmod, only : harvest_rates  ! spel targeted
     use elm_varctl, only : scmlat, scmlon  ! spel targeted
     use gridcelldatatype, only : grc_ef, grc_es, grc_wf, grc_ws  ! spel targeted
     use totalwaterandheatmod, only : heat_base_temp  ! spel targeted
     use vegetationdatatype, only : c13_veg_cf, c14_veg_cf  ! spel targeted
     
    ! !ARGUMENTS:
    implicit none
    logical ,        intent(in) :: doalb       ! true if time for surface albedo calc
    real(r8),        intent(in) :: nextsw_cday ! calendar day for nstep+1
    real(r8),        intent(in) :: declinp1    ! declination angle for next time step
    real(r8),        intent(in) :: declin      ! declination angle for current time step
    logical,         intent(in) :: rstwr       ! true => write restart file this step
    logical,         intent(in) :: nlend       ! true => end of run on this step
    character(len=*),intent(in) :: rdate       ! restart file time stamp for name
    !
    ! !LOCAL VARIABLES:
    integer              :: nstep                   ! time step number
    integer              :: nc, c, p, l, g          ! indices
    integer              :: nclumps                 ! number of clumps on this processor
    integer              :: yrp1                    ! year (0, ...) for nstep+1
    integer              :: monp1                   ! month (1, ..., 12) for nstep+1
    integer              :: dayp1                   ! day of month (1, ..., 31) for nstep+1
    integer              :: secp1                   ! seconds into current date for nstep+1
    integer              :: yr                      ! year (0, ...)
    integer              :: mon                     ! month (1, ..., 12)
    integer              :: day                     ! day of month (1, ..., 31)
    integer              :: sec                     ! seconds of the day
    integer              :: ncdate                  ! current date
    integer              :: nbdate                  ! base date (reference date)
    integer              :: kyr                     ! thousand years, equals 2 at end of first year
    character(len=256)   :: filer                   ! restart file name
    integer              :: ier                     ! error code
    character(len=256)   :: dateTimeString
    type(bounds_type)    :: bounds_clump
    type(bounds_type)    :: bounds_proc
    !-----------------------------------------------------------------------

#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before get_curr_time_string
#endif
    !$acc update device(atm2lnd_vars%deficit_grc, atm2lnd_vars%forc_aer_grc, atm2lnd_vars%forc_flood_grc, &
    !$acc&   atm2lnd_vars%forc_hgt_grc, atm2lnd_vars%forc_hgt_q_grc, atm2lnd_vars%forc_hgt_t_grc, &
    !$acc&   atm2lnd_vars%forc_hgt_u_grc, atm2lnd_vars%forc_lwrad_not_downscaled_grc, &
    !$acc&   atm2lnd_vars%forc_pbot_not_downscaled_grc, atm2lnd_vars%forc_pc13o2_grc, &
    !$acc&   atm2lnd_vars%forc_pch4_grc, atm2lnd_vars%forc_pco2_grc, atm2lnd_vars%forc_po2_grc, &
    !$acc&   atm2lnd_vars%forc_q_not_downscaled_grc, atm2lnd_vars%forc_rain_not_downscaled_grc, &
    !$acc&   atm2lnd_vars%forc_rh_grc, atm2lnd_vars%forc_rho_not_downscaled_grc, &
    !$acc&   atm2lnd_vars%forc_snow_not_downscaled_grc, atm2lnd_vars%forc_solad_grc, &
    !$acc&   atm2lnd_vars%forc_solai_grc, atm2lnd_vars%forc_solar_grc, &
    !$acc&   atm2lnd_vars%forc_t_not_downscaled_grc, atm2lnd_vars%forc_th_not_downscaled_grc, &
    !$acc&   atm2lnd_vars%forc_u_grc, atm2lnd_vars%forc_v_grc, atm2lnd_vars%forc_vp_grc, &
    !$acc&   atm2lnd_vars%forc_wind_grc, atm2lnd_vars%frac_h2orof_grc, atm2lnd_vars%h2orof_grc, &
    !$acc&   atm2lnd_vars%supply_grc, atm2lnd_vars%volr_grc, atm2lnd_vars%volrmch_grc, glc2lnd_vars%frac_grc, &
    !$acc&   glc2lnd_vars%hflx_grc, glc2lnd_vars%icemask_coupled_fluxes_grc, glc2lnd_vars%icemask_grc, &
    !$acc&   glc2lnd_vars%topo_grc, iac2lnd_vars%frac_pft, iac2lnd_vars%frac_pft_prev, &
    !$acc&   iac2lnd_vars%harvest_frac, iulog, lnd2iac_vars%forc_hdm, ocn2lnd_vars%frac_h2oocn_grc, &
    !$acc&   ocn2lnd_vars%ssh_grc, top_af%lwrad, top_af%rain, top_af%snow, top_af%solad, top_af%solai, &
    !$acc&   top_af%solar, top_as%pbot, top_as%pc13o2bot, top_as%pch4bot, top_as%pco2bot, top_as%po2bot, &
    !$acc&   top_as%qbot, top_as%rhbot, top_as%rhobot, top_as%tau_est, top_as%tbot, top_as%thbot, &
    !$acc&   top_as%ubot, top_as%ugust, top_as%vbot, top_as%windbot, top_as%wsresp, &
    !$acc&   top_as%zbot) if_present if(.not. elm_device_fullsync)
    call get_curr_time_string(dateTimeString)
    if (masterproc) then
       write(iulog,*)'Beginning timestep   : ',trim(dateTimeString)
       call shr_sys_flush(iulog)
    endif
    ! Determine processor bounds and clumps for this processor

    call get_proc_bounds(bounds_proc)
#ifdef _OPENACC
    ! device copies of the bounds: kernels read them (associate names of bounds%beg/end*);
    ! get_clump_bounds updates the device copy of bounds_clump (if_present)
    !$acc enter data copyin(bounds_proc) create(bounds_clump)
#endif
#ifdef _OPENACC
    ! spel device-data: the whole state to the device if initialization did not (fallback)
    if (.not. elm_device_resident) then
       call t_startf('device_copyin')
       call elm_device_copyin()
       call t_stopf('device_copyin')
    end if
#endif
    nclumps = get_proc_clumps()
    nstep_mod = get_nstep()
    first_restart_step_mod = is_first_restart_step()
    dtime_mod = real(get_step_size(),r8)
    call get_curr_date(year_curr,mon_curr, day_curr,secs_curr)
    dayspyr_mod = get_days_per_year()
    jday_mod = get_curr_calday()

    if (mpi_sync_nstep_freq > 0) then
       if (mod(nstep_mod,mpi_sync_nstep_freq) == 0) then
          call MPI_Barrier(mpicom, ier)
          if (masterproc) then
             write(iulog,*)'                       A MPI_Barrier is added in this timestep.'
          end if
       end if
    end if
    !$acc update device(day_curr, dtime_mod, first_restart_step_mod, mon_curr, nstep_mod, secs_curr, &
    !$acc&   year_curr) if_present if(.not. elm_device_fullsync)

    if (do_budgets) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before waterbudget_reset
#endif
       call WaterBudget_Reset()
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before heatbudget_reset
#endif
       call HeatBudget_Reset()

       if (use_cn) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before cnpbudget_reset
#endif
          call CNPBudget_Reset()
       end if
    end if


    ! ============================================================================
    ! Specified phenology
    ! ============================================================================

    if (use_cn) then
       ! For dry-deposition need to call CLMSP so that mlaidiff is obtained
       if ( n_drydep > 0 .and. drydep_method == DD_XLND ) then
          call t_startf('interpMonthlyVeg')
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before interpmonthlyveg
#endif
          call interpMonthlyVeg(bounds_proc, canopystate_vars)
          call t_stopf('interpMonthlyVeg')
       endif

    elseif(use_fates) then
       if(use_fates_sp) then
       
          ! For FATES satellite phenology mode interpolate the weights for
          ! time-interpolation of monthly vegetation data (as in SP mode below)
          ! Also for FATES with dry-deposition as above need to call CLMSP so that mlaidiff is obtained
          !if ( use_fates_sp .or. (n_drydep > 0 .and. drydep_method == DD_XLND ) ) then
          ! Replace with this when we have dry-deposition working
          ! For now don't allow for dry-deposition because of issues in #1044 EBK Jun/17/2022
          call t_startf('interpMonthlyVeg')
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before interpmonthlyveg
#endif
          call interpMonthlyVeg(bounds_proc, canopystate_vars)
          call t_stopf('interpMonthlyVeg')
       end if
    else
       ! Determine weights for time interpolation of monthly vegetation data.
       ! This also determines whether it is time to read new monthly vegetation and
       ! obtain updated leaf area index [mlai1,mlai2], stem area index [msai1,msai2],
       ! vegetation top [mhvt1,mhvt2] and vegetation bottom [mhvb1,mhvb2]. The
       ! weights obtained here are used in subroutine SatellitePhenology to obtain time
       ! interpolated values.
       if (doalb .or. ( n_drydep > 0 .and. drydep_method == DD_XLND )) then
          call t_startf('interpMonthlyVeg')
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before interpmonthlyveg
#endif
          call interpMonthlyVeg(bounds_proc, canopystate_vars)
          call t_stopf('interpMonthlyVeg')
       end if
    end if
    !$acc update device(canopystate_vars%mlaidiff_patch, scmlat, &
    !$acc&   scmlon) if_present if(.not. elm_device_fullsync)

    ! ==================================================================================
    ! Determine decomp vertical profiles
    !
    ! These routines (alt_calc & decomp_vertprofiles) need to be called before
    ! pftdyn_cnbal, and it appears that they need to be called before pftdyn_interp and
    ! the associated filter updates, too (otherwise we get a carbon balance error)
    ! ==================================================================================

    !$OMP PARALLEL DO PRIVATE (nc,bounds_clump)
    do nc = 1,nclumps
       call get_clump_bounds(nc, bounds_clump)
       !$acc enter data copyin(bounds_clump)  ! the private copy of this OpenMP loop: kernels read it

       call t_startf("decomp_vert")
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before alt_calc
#endif
       call alt_calc(filter(nc)%num_soilc, filter(nc)%soilc, &
            canopystate_vars)

       !  Note (WJS, 6-12-13): Because of this routine's placement in the driver sequence
       !  (it is called very early in each timestep, before weights are adjusted and
       !  filters are updated), it may be necessary for this routine to compute values over
       !  inactive as well as active points (since some inactive points may soon become
       !  active) - so that's what is done now. Currently, it seems to be okay to do this,
       !  because the variables computed here seem to only depend on quantities that are
       !  valid over inactive as well as active points.

       if(use_fates .or. use_cn) then

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before decomp_vertprofiles
#endif
          call decomp_vertprofiles(bounds_clump, &
               filter_inactive_and_active(nc)%num_soilc, &
               filter_inactive_and_active(nc)%soilc, &
               filter_inactive_and_active(nc)%num_soilp, &
               filter_inactive_and_active(nc)%soilp, &
               soilstate_vars, canopystate_vars, cnstate_vars)
       end if
       call t_stopf("decomp_vert")
       !$acc exit data delete(bounds_clump)
    end do
    !$OMP END PARALLEL DO

    ! ============================================================================
    ! Zero fluxes for transient land cover
    ! ============================================================================

    !$OMP PARALLEL DO PRIVATE (nc,bounds_clump)
    do nc = 1,nclumps
       call get_clump_bounds(nc, bounds_clump)
       !$acc enter data copyin(bounds_clump)  ! the private copy of this OpenMP loop: kernels read it

       call t_startf('beggridwbal')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before begingridwaterbalance
#endif
       call BeginGridWaterBalance(bounds_clump,               &
            filter(nc)%num_nolakec, filter(nc)%nolakec,       &
            filter(nc)%num_lakec, filter(nc)%lakec,           &
            filter(nc)%num_hydrologyc, filter(nc)%hydrologyc, &
            soilhydrology_vars )
       if (do_budgets) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before heatbudget_setbeginningstates
#endif
          call HeatBudget_SetBeginningStates(bounds_clump)
       end if
       ! spel targeted: device data this host code uses
       !$acc update self(c13_grc_cf%hrv_deadstemc_to_prod100c, c13_grc_cf%hrv_deadstemc_to_prod10c, &
       !$acc&   c14_grc_cf%hrv_deadstemc_to_prod100c, c14_grc_cf%hrv_deadstemc_to_prod10c, &
       !$acc&   veg_cs%core%dispveg, veg_cs%core%storveg, veg_cs%core%totpft, veg_ns%core%dispveg, &
       !$acc&   veg_ns%core%storveg, veg_ns%core%totpft, veg_ns%core%totveg, veg_ps%core%dispveg, &
       !$acc&   veg_ps%core%storveg, veg_ps%core%totpft, &
       !$acc&   veg_ps%core%totveg) if_present if(.not. elm_device_fullsync)
       call t_stopf('beggridwbal')


       call t_startf('cnpinit')

       if (use_cn) then
          call t_startf('cnpvegzero')

#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
          call veg_cs%ZeroDwt(bounds_clump)
          if (use_c13) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
             call c13_grc_cf%ZeroDWT(bounds_clump)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
             call c13_col_cf%ZeroDWT(bounds_clump)
          end if
          if (use_c14) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
             call c14_grc_cf%ZeroDWT(bounds_clump)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
             call c14_col_cf%ZeroDWT(bounds_clump)
          end if
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
          call veg_ns%ZeroDWT(bounds_clump)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
          call veg_ps%ZeroDWT(bounds_clump)
          call t_stopf('cnpvegzero')
       end if
       !$acc update device(c13_col_cf%core%dwt_conv_flux, c13_col_cf%core%dwt_crop_product_gain, &
       !$acc&   c13_col_cf%core%dwt_deadcroot_to_cwd, c13_col_cf%core%dwt_froot_to_litr_cel, &
       !$acc&   c13_col_cf%core%dwt_froot_to_litr_lig, c13_col_cf%core%dwt_froot_to_litr_met, &
       !$acc&   c13_col_cf%core%dwt_livecroot_to_cwd, c13_col_cf%core%dwt_prod100_gain, &
       !$acc&   c13_col_cf%core%dwt_prod10_gain, c13_col_cf%core%dwt_slash_flux, &
       !$acc&   c13_grc_cf%core%dwt_conv_flux, c13_grc_cf%core%dwt_prod100_gain, &
       !$acc&   c13_grc_cf%core%dwt_prod10_gain, c13_grc_cf%core%dwt_seed_to_deadstem, &
       !$acc&   c13_grc_cf%core%dwt_seed_to_leaf, c13_grc_cf%hrv_deadstemc_to_prod100c, &
       !$acc&   c13_grc_cf%hrv_deadstemc_to_prod10c, c14_col_cf%core%dwt_conv_flux, &
       !$acc&   c14_col_cf%core%dwt_crop_product_gain, c14_col_cf%core%dwt_deadcroot_to_cwd, &
       !$acc&   c14_col_cf%core%dwt_froot_to_litr_cel, c14_col_cf%core%dwt_froot_to_litr_lig, &
       !$acc&   c14_col_cf%core%dwt_froot_to_litr_met, c14_col_cf%core%dwt_livecroot_to_cwd, &
       !$acc&   c14_col_cf%core%dwt_prod100_gain, c14_col_cf%core%dwt_prod10_gain, &
       !$acc&   c14_col_cf%core%dwt_slash_flux, c14_grc_cf%core%dwt_conv_flux, &
       !$acc&   c14_grc_cf%core%dwt_prod100_gain, c14_grc_cf%core%dwt_prod10_gain, &
       !$acc&   c14_grc_cf%core%dwt_seed_to_deadstem, c14_grc_cf%core%dwt_seed_to_leaf, &
       !$acc&   c14_grc_cf%hrv_deadstemc_to_prod100c, c14_grc_cf%hrv_deadstemc_to_prod10c, &
       !$acc&   veg_cs%core%dispveg, veg_cs%core%storveg, veg_cs%core%totpft, veg_ns%core%dispveg, &
       !$acc&   veg_ns%core%storveg, veg_ns%core%totpft, veg_ns%core%totveg, veg_ps%core%dispveg, &
       !$acc&   veg_ps%core%storveg, veg_ps%core%totpft, &
       !$acc&   veg_ps%core%totveg) if_present if(.not. elm_device_fullsync)

       if (use_cn .or. use_fates) then
          ! spel targeted: device data this host code uses
          !$acc update self(grc_cf%hrv_deadstemc_to_prod100c, &
          !$acc&   grc_cf%hrv_deadstemc_to_prod10c) if_present if(.not. elm_device_fullsync)
          call t_startf('cnpzero')
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
          call grc_cf%ZeroDWT(bounds_clump)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
          call col_cf%ZeroDWT(bounds_clump)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
          call grc_nf%ZeroDWT(bounds_clump)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
          call col_nf%ZeroDWT(bounds_clump)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
          call grc_pf%ZeroDWT(bounds_clump)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before zerodwt
#endif
          call col_pf%ZeroDWT(bounds_clump)
          call t_stopf('cnpzero')
          !$acc update device(col_cf%core%dwt_conv_flux, col_cf%core%dwt_crop_product_gain, &
          !$acc&   col_cf%core%dwt_deadcroot_to_cwd, col_cf%core%dwt_froot_to_litr_cel, &
          !$acc&   col_cf%core%dwt_froot_to_litr_lig, col_cf%core%dwt_froot_to_litr_met, &
          !$acc&   col_cf%core%dwt_livecroot_to_cwd, col_cf%core%dwt_prod100_gain, &
          !$acc&   col_cf%core%dwt_prod10_gain, col_cf%core%dwt_slash_flux, col_nf%core%dwt_conv_flux, &
          !$acc&   col_nf%core%dwt_crop_product_gain, col_nf%core%dwt_deadcroot_to_cwd, &
          !$acc&   col_nf%core%dwt_froot_to_litr_cel, col_nf%core%dwt_froot_to_litr_lig, &
          !$acc&   col_nf%core%dwt_froot_to_litr_met, col_nf%core%dwt_livecroot_to_cwd, &
          !$acc&   col_nf%core%dwt_prod100_gain, col_nf%core%dwt_prod10_gain, col_nf%core%dwt_slash_flux, &
          !$acc&   col_pf%core%dwt_conv_flux, col_pf%core%dwt_crop_product_gain, &
          !$acc&   col_pf%core%dwt_deadcroot_to_cwd, col_pf%core%dwt_froot_to_litr_cel, &
          !$acc&   col_pf%core%dwt_froot_to_litr_lig, col_pf%core%dwt_froot_to_litr_met, &
          !$acc&   col_pf%core%dwt_livecroot_to_cwd, col_pf%core%dwt_prod100_gain, &
          !$acc&   col_pf%core%dwt_prod10_gain, col_pf%core%dwt_slash_flux, grc_cf%core%dwt_conv_flux, &
          !$acc&   grc_cf%core%dwt_prod100_gain, grc_cf%core%dwt_prod10_gain, &
          !$acc&   grc_cf%core%dwt_seed_to_deadstem, grc_cf%core%dwt_seed_to_leaf, &
          !$acc&   grc_cf%hrv_deadstemc_to_prod100c, grc_cf%hrv_deadstemc_to_prod10c, &
          !$acc&   grc_nf%core%dwt_conv_flux, grc_nf%core%dwt_prod100_gain, grc_nf%core%dwt_prod10_gain, &
          !$acc&   grc_nf%core%dwt_seed_to_deadstem, grc_nf%core%dwt_seed_to_leaf, grc_nf%dwt_seedn_to_npool, &
          !$acc&   grc_pf%core%dwt_conv_flux, grc_pf%core%dwt_prod100_gain, grc_pf%core%dwt_prod10_gain, &
          !$acc&   grc_pf%core%dwt_seed_to_deadstem, grc_pf%core%dwt_seed_to_leaf, &
          !$acc&   grc_pf%dwt_seedp_to_ppool) if_present if(.not. elm_device_fullsync)
       end if

       call t_startf('cnpvegsumm')
       if(use_cn) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call veg_cs%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               filter(nc)%num_soilp, filter(nc)%soilp, col_cs)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call veg_ns%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               filter(nc)%num_soilp, filter(nc)%soilp, col_ns)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call veg_ps%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               filter(nc)%num_soilp, filter(nc)%soilp, col_ps)

       elseif(use_fates)then
          ! In this scenario, we simply zero all of the
          ! column level variables that would had been upscaled
          ! in the veg summary with p2c
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before zeroforfates
#endif
          call col_cs%ZeroForFates(bounds_clump,filter(nc)%num_soilc, filter(nc)%soilc)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before zeroforfates
#endif
          call col_ns%ZeroForFates(bounds_clump,filter(nc)%num_soilc, filter(nc)%soilc)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before zeroforfates
#endif
          call col_ps%ZeroForFates(bounds_clump,filter(nc)%num_soilc, filter(nc)%soilc)
       end if
       call t_stopf('cnpvegsumm')

       if(use_cn .or. use_fates)then

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call col_cs%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call col_ns%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call col_ps%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before begingridcbalance
#endif
          call BeginGridCBalance(bounds_clump, col_cs, grc_cs)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before begingridnbalance
#endif
          call BeginGridNBalance(bounds_clump, col_ns, grc_ns)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before begingridpbalance
#endif
          call BeginGridPBalance(bounds_clump, col_ps, grc_ps)

       end if

       call t_stopf('cnpinit')


       !$acc exit data delete(bounds_clump)
    end do
    !$OMP END PARALLEL DO

    ! ============================================================================
    ! Update subgrid weights with dynamic landcover (prescribed transient patches,
    ! and or dynamic landunits), and do related adjustments. Note that this
    ! call needs to happen outside loops over nclumps.
    ! ============================================================================

    call elm_device_filters_update(to_device=.false.)  ! spel targeted
    ! spel targeted: device data this host code uses
    !$acc update self(c13_col_cs%core%decomp_pools_vr, c13_col_cs%core%prod1, c13_col_cs%core%prod10, &
    !$acc&   c13_col_cs%core%prod100, c13_col_cs%core%trunc_sink_vr, c13_veg_cs%core%cropseed_deficit, &
    !$acc&   c13_veg_cs%core%deadcroot, c13_veg_cs%core%deadcroot_storage, c13_veg_cs%core%deadcroot_xfer, &
    !$acc&   c13_veg_cs%core%deadstem, c13_veg_cs%core%deadstem_storage, c13_veg_cs%core%deadstem_xfer, &
    !$acc&   c13_veg_cs%core%dispveg, c13_veg_cs%core%froot, c13_veg_cs%core%froot_storage, &
    !$acc&   c13_veg_cs%core%froot_xfer, c13_veg_cs%core%grain, c13_veg_cs%core%grain_storage, &
    !$acc&   c13_veg_cs%core%grain_xfer, c13_veg_cs%core%leaf, c13_veg_cs%core%leaf_storage, &
    !$acc&   c13_veg_cs%core%leaf_xfer, c13_veg_cs%core%livecroot, c13_veg_cs%core%livecroot_storage, &
    !$acc&   c13_veg_cs%core%livecroot_xfer, c13_veg_cs%core%livestem, c13_veg_cs%core%livestem_storage, &
    !$acc&   c13_veg_cs%core%livestem_xfer, c13_veg_cs%core%pool, c13_veg_cs%core%storveg, &
    !$acc&   c13_veg_cs%core%totpft, c13_veg_cs%core%totveg, c13_veg_cs%core%trunc_sink, &
    !$acc&   c13_veg_cs%gresp_storage, c13_veg_cs%gresp_xfer, c13_veg_cs%xsmrpool, &
    !$acc&   c14_col_cs%core%decomp_pools_vr, c14_col_cs%core%prod1, c14_col_cs%core%prod10, &
    !$acc&   c14_col_cs%core%prod100, c14_col_cs%core%trunc_sink_vr, c14_veg_cs%core%cropseed_deficit, &
    !$acc&   c14_veg_cs%core%deadcroot, c14_veg_cs%core%deadcroot_storage, c14_veg_cs%core%deadcroot_xfer, &
    !$acc&   c14_veg_cs%core%deadstem, c14_veg_cs%core%deadstem_storage, c14_veg_cs%core%deadstem_xfer, &
    !$acc&   c14_veg_cs%core%dispveg, c14_veg_cs%core%froot, c14_veg_cs%core%froot_storage, &
    !$acc&   c14_veg_cs%core%froot_xfer, c14_veg_cs%core%grain, c14_veg_cs%core%grain_storage, &
    !$acc&   c14_veg_cs%core%grain_xfer, c14_veg_cs%core%leaf, c14_veg_cs%core%leaf_storage, &
    !$acc&   c14_veg_cs%core%leaf_xfer, c14_veg_cs%core%livecroot, c14_veg_cs%core%livecroot_storage, &
    !$acc&   c14_veg_cs%core%livecroot_xfer, c14_veg_cs%core%livestem, c14_veg_cs%core%livestem_storage, &
    !$acc&   c14_veg_cs%core%livestem_xfer, c14_veg_cs%core%pool, c14_veg_cs%core%storveg, &
    !$acc&   c14_veg_cs%core%totpft, c14_veg_cs%core%totveg, c14_veg_cs%core%trunc_sink, &
    !$acc&   c14_veg_cs%gresp_storage, c14_veg_cs%gresp_xfer, c14_veg_cs%xsmrpool, &
    !$acc&   canopystate_vars%laisha_patch, canopystate_vars%laisun_patch, cnstate_vars%annavg_t2m_col, &
    !$acc&   cnstate_vars%annavg_t2m_patch, cnstate_vars%annmax_retransn_patch, &
    !$acc&   cnstate_vars%annmax_retransp_patch, cnstate_vars%annsum_potential_gpp_patch, &
    !$acc&   cnstate_vars%bglfr_froot_patch, cnstate_vars%bglfr_leaf_patch, cnstate_vars%bgtr_patch, &
    !$acc&   cnstate_vars%c_allometry_patch, cnstate_vars%croot_prof_patch, cnstate_vars%days_active_patch, &
    !$acc&   cnstate_vars%dormant_flag_patch, cnstate_vars%downreg_patch, cnstate_vars%froot_prof_patch, &
    !$acc&   cnstate_vars%lgsf_patch, cnstate_vars%n_allometry_patch, cnstate_vars%offset_counter_patch, &
    !$acc&   cnstate_vars%offset_fdd_patch, cnstate_vars%offset_flag_patch, cnstate_vars%offset_swi_patch, &
    !$acc&   cnstate_vars%onset_counter_patch, cnstate_vars%onset_fdd_patch, cnstate_vars%onset_flag_patch, &
    !$acc&   cnstate_vars%onset_gdd_patch, cnstate_vars%onset_gddflag_patch, cnstate_vars%onset_swi_patch, &
    !$acc&   cnstate_vars%p_allometry_patch, cnstate_vars%rc14_atm_patch, cnstate_vars%tempavg_t2m_patch, &
    !$acc&   cnstate_vars%tempmax_retransn_patch, cnstate_vars%tempmax_retransp_patch, &
    !$acc&   cnstate_vars%tempsum_potential_gpp_patch, col_cs%core%decomp_pools_vr, col_cs%core%prod1, &
    !$acc&   col_cs%core%prod10, col_cs%core%prod100, col_cs%core%trunc_sink_vr, col_es%t_h2osfc, &
    !$acc&   col_es%t_soisno, col_ns%core%decomp_pools_vr, col_ns%core%prod1, col_ns%core%prod10, &
    !$acc&   col_ns%core%prod100, col_ns%core%trunc_sink_vr, col_ns%fan_grz_fract, col_ns%fan_totn, &
    !$acc&   col_ns%fert_u1, col_ns%fert_u2, col_ns%manure_a_app, col_ns%manure_a_grz, &
    !$acc&   col_ns%manure_n_stored, col_ns%manure_r_app, col_ns%manure_r_grz, col_ns%manure_tan_stored, &
    !$acc&   col_ns%manure_u_app, col_ns%manure_u_grz, col_ns%mineral%smin_vr, col_ns%smin_nh4_vr, &
    !$acc&   col_ns%smin_no3_vr, col_ns%tan_f1, col_ns%tan_f2, col_ns%tan_f3, col_ns%tan_f4, col_ns%tan_g1, &
    !$acc&   col_ns%tan_g2, col_ns%tan_g3, col_ns%tan_s0, col_ns%tan_s1, col_ns%tan_s2, col_ns%tan_s3, &
    !$acc&   col_pp%dz, col_pp%snl, col_ps%core%decomp_pools_vr, col_ps%core%prod1, col_ps%core%prod10, &
    !$acc&   col_ps%core%prod100, col_ps%core%trunc_sink_vr, col_ps%labilep_vr, col_ps%occlp_vr, &
    !$acc&   col_ps%primp_vr, col_ps%secondp_vr, col_ps%solutionp_vr, col_ws%h2osfc, col_ws%h2osno, &
    !$acc&   col_ws%h2osoi_ice, col_ws%h2osoi_liq, col_ws%h2osoi_vol, grc_es%heat1, grc_es%heat2, &
    !$acc&   grc_ws%ice1, grc_ws%ice2, grc_ws%liq1, grc_ws%liq2, heat_base_temp, &
    !$acc&   lakestate_vars%lake_icefrac_col, photosyns_vars%alphapsnsha_patch, &
    !$acc&   photosyns_vars%alphapsnsun_patch, photosyns_vars%c13_psnsha_patch, &
    !$acc&   photosyns_vars%c13_psnsun_patch, photosyns_vars%c14_psnsha_patch, &
    !$acc&   photosyns_vars%c14_psnsun_patch, photosyns_vars%psnsha_patch, photosyns_vars%psnsun_patch, &
    !$acc&   photosyns_vars%rc13_canair_patch, photosyns_vars%rc13_psnsha_patch, &
    !$acc&   photosyns_vars%rc13_psnsun_patch, soilhydrology_vars%wa_col, veg_cf%annsum_npp, veg_cf%availc, &
    !$acc&   veg_cf%core%plant_alloc, veg_cf%core%prev_froot_to_litter, veg_cf%core%prev_leaf_to_litter, &
    !$acc&   veg_cf%excess_cflux, veg_cf%gpp_before_downreg, veg_cf%tempsum_npp, veg_cf%xsmrpool_recover, &
    !$acc&   veg_cs%core%cropseed_deficit, veg_cs%core%deadcroot, veg_cs%core%deadcroot_storage, &
    !$acc&   veg_cs%core%deadcroot_xfer, veg_cs%core%deadstem, veg_cs%core%deadstem_storage, &
    !$acc&   veg_cs%core%deadstem_xfer, veg_cs%core%dispveg, veg_cs%core%froot, veg_cs%core%froot_storage, &
    !$acc&   veg_cs%core%froot_xfer, veg_cs%core%grain, veg_cs%core%grain_storage, veg_cs%core%grain_xfer, &
    !$acc&   veg_cs%core%leaf, veg_cs%core%leaf_storage, veg_cs%core%leaf_xfer, veg_cs%core%livecroot, &
    !$acc&   veg_cs%core%livecroot_storage, veg_cs%core%livecroot_xfer, veg_cs%core%livestem, &
    !$acc&   veg_cs%core%livestem_storage, veg_cs%core%livestem_xfer, veg_cs%core%pool, veg_cs%core%storveg, &
    !$acc&   veg_cs%core%totpft, veg_cs%core%totveg, veg_cs%core%trunc_sink, veg_cs%gresp_storage, &
    !$acc&   veg_cs%gresp_xfer, veg_cs%xsmrpool, veg_nf%core%plant_alloc, veg_nf%retrans%avail_retrans, &
    !$acc&   veg_nf%uptake%plant_demand, veg_ns%core%cropseed_deficit, veg_ns%core%deadcroot, &
    !$acc&   veg_ns%core%deadcroot_storage, veg_ns%core%deadcroot_xfer, veg_ns%core%deadstem, &
    !$acc&   veg_ns%core%deadstem_storage, veg_ns%core%deadstem_xfer, veg_ns%core%dispveg, veg_ns%core%froot, &
    !$acc&   veg_ns%core%froot_storage, veg_ns%core%froot_xfer, veg_ns%core%grain, veg_ns%core%grain_storage, &
    !$acc&   veg_ns%core%grain_xfer, veg_ns%core%leaf, veg_ns%core%leaf_storage, veg_ns%core%leaf_xfer, &
    !$acc&   veg_ns%core%livecroot, veg_ns%core%livecroot_storage, veg_ns%core%livecroot_xfer, &
    !$acc&   veg_ns%core%livestem, veg_ns%core%livestem_storage, veg_ns%core%livestem_xfer, veg_ns%core%pool, &
    !$acc&   veg_ns%core%storveg, veg_ns%core%totpft, veg_ns%core%totveg, veg_ns%core%trunc_sink, &
    !$acc&   veg_ns%retrans%pool, veg_pf%core%plant_alloc, veg_pf%retrans%avail_retrans, &
    !$acc&   veg_pf%uptake%plant_demand, veg_ps%core%cropseed_deficit, veg_ps%core%deadcroot, &
    !$acc&   veg_ps%core%deadcroot_storage, veg_ps%core%deadcroot_xfer, veg_ps%core%deadstem, &
    !$acc&   veg_ps%core%deadstem_storage, veg_ps%core%deadstem_xfer, veg_ps%core%dispveg, veg_ps%core%froot, &
    !$acc&   veg_ps%core%froot_storage, veg_ps%core%froot_xfer, veg_ps%core%grain, veg_ps%core%grain_storage, &
    !$acc&   veg_ps%core%grain_xfer, veg_ps%core%leaf, veg_ps%core%leaf_storage, veg_ps%core%leaf_xfer, &
    !$acc&   veg_ps%core%livecroot, veg_ps%core%livecroot_storage, veg_ps%core%livecroot_xfer, &
    !$acc&   veg_ps%core%livestem, veg_ps%core%livestem_storage, veg_ps%core%livestem_xfer, veg_ps%core%pool, &
    !$acc&   veg_ps%core%storveg, veg_ps%core%totpft, veg_ps%core%totveg, veg_ps%core%trunc_sink, &
    !$acc&   veg_ps%retrans%pool, veg_ws%h2ocan) if_present if(.not. elm_device_fullsync)
    call t_startf('dyn_subgrid')
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! dynSubgrid_driver runs on the host (out of the GPU port): its kernels follow elm_device_ready
#endif
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before dynsubgrid_driver
#endif
    call dynSubgrid_driver(bounds_proc,                                      &
       urbanparams_vars, soilstate_vars, soilhydrology_vars, lakestate_vars, &
       energyflux_vars, canopystate_vars, photosyns_vars, cnstate_vars,                       &
       veg_cs, c13_veg_cs, c14_veg_cs,         &
       col_cs, c13_col_cs, c14_col_cs, col_cf,  &
       grc_cs, grc_cf , glc2lnd_vars,  crop_vars, iac2lnd_vars)
    call t_stopf('dyn_subgrid')
    call elm_device_filters_update(to_device=.true.)  ! spel targeted
    !$acc update device(c13_col_cf%core%dwt_conv_flux, c13_col_cf%core%dwt_crop_product_gain, &
    !$acc&   c13_col_cf%core%dwt_deadcroot_to_cwd, c13_col_cf%core%dwt_froot_to_litr_cel, &
    !$acc&   c13_col_cf%core%dwt_froot_to_litr_lig, c13_col_cf%core%dwt_froot_to_litr_met, &
    !$acc&   c13_col_cf%core%dwt_livecroot_to_cwd, c13_col_cf%core%dwt_prod100_gain, &
    !$acc&   c13_col_cf%core%dwt_prod10_gain, c13_col_cf%core%dwt_slash_flux, &
    !$acc&   c13_col_cs%core%decomp_pools_vr, c13_col_cs%core%dyn_bal_adjustments, c13_col_cs%core%prod1, &
    !$acc&   c13_col_cs%core%prod10, c13_col_cs%core%prod100, c13_col_cs%core%trunc_sink_vr, &
    !$acc&   c13_grc_cf%core%dwt_conv_flux, c13_grc_cf%core%dwt_prod100_gain, &
    !$acc&   c13_grc_cf%core%dwt_prod10_gain, c13_grc_cf%core%dwt_seed_to_deadstem, &
    !$acc&   c13_grc_cf%core%dwt_seed_to_leaf, c13_grc_cs%core%seed, c13_veg_cf%core%dwt_conv_flux, &
    !$acc&   c13_veg_cf%core%dwt_crop_product_gain, c13_veg_cf%core%dwt_prod100_gain, &
    !$acc&   c13_veg_cf%core%dwt_prod10_gain, c13_veg_cf%core%dwt_seed_to_deadstem, &
    !$acc&   c13_veg_cf%core%dwt_seed_to_leaf, c13_veg_cs%core%cropseed_deficit, c13_veg_cs%core%deadcroot, &
    !$acc&   c13_veg_cs%core%deadcroot_storage, c13_veg_cs%core%deadcroot_xfer, c13_veg_cs%core%deadstem, &
    !$acc&   c13_veg_cs%core%deadstem_storage, c13_veg_cs%core%deadstem_xfer, c13_veg_cs%core%dispveg, &
    !$acc&   c13_veg_cs%core%froot, c13_veg_cs%core%froot_storage, c13_veg_cs%core%froot_xfer, &
    !$acc&   c13_veg_cs%core%grain, c13_veg_cs%core%grain_storage, c13_veg_cs%core%grain_xfer, &
    !$acc&   c13_veg_cs%core%leaf, c13_veg_cs%core%leaf_storage, c13_veg_cs%core%leaf_xfer, &
    !$acc&   c13_veg_cs%core%livecroot, c13_veg_cs%core%livecroot_storage, c13_veg_cs%core%livecroot_xfer, &
    !$acc&   c13_veg_cs%core%livestem, c13_veg_cs%core%livestem_storage, c13_veg_cs%core%livestem_xfer, &
    !$acc&   c13_veg_cs%core%pool, c13_veg_cs%core%storveg, c13_veg_cs%core%totpft, c13_veg_cs%core%totveg, &
    !$acc&   c13_veg_cs%core%trunc_sink, c13_veg_cs%gresp_storage, c13_veg_cs%gresp_xfer, &
    !$acc&   c13_veg_cs%xsmrpool, c14_col_cf%core%dwt_conv_flux, c14_col_cf%core%dwt_crop_product_gain, &
    !$acc&   c14_col_cf%core%dwt_deadcroot_to_cwd, c14_col_cf%core%dwt_froot_to_litr_cel, &
    !$acc&   c14_col_cf%core%dwt_froot_to_litr_lig, c14_col_cf%core%dwt_froot_to_litr_met, &
    !$acc&   c14_col_cf%core%dwt_livecroot_to_cwd, c14_col_cf%core%dwt_prod100_gain, &
    !$acc&   c14_col_cf%core%dwt_prod10_gain, c14_col_cf%core%dwt_slash_flux, &
    !$acc&   c14_col_cs%core%decomp_pools_vr, c14_col_cs%core%dyn_bal_adjustments, c14_col_cs%core%prod1, &
    !$acc&   c14_col_cs%core%prod10, c14_col_cs%core%prod100, c14_col_cs%core%trunc_sink_vr, &
    !$acc&   c14_grc_cf%core%dwt_conv_flux, c14_grc_cf%core%dwt_prod100_gain, &
    !$acc&   c14_grc_cf%core%dwt_prod10_gain, c14_grc_cf%core%dwt_seed_to_deadstem, &
    !$acc&   c14_grc_cf%core%dwt_seed_to_leaf, c14_grc_cs%core%seed, c14_veg_cf%core%dwt_conv_flux, &
    !$acc&   c14_veg_cf%core%dwt_crop_product_gain, c14_veg_cf%core%dwt_prod100_gain, &
    !$acc&   c14_veg_cf%core%dwt_prod10_gain, c14_veg_cf%core%dwt_seed_to_deadstem, &
    !$acc&   c14_veg_cf%core%dwt_seed_to_leaf, c14_veg_cs%core%cropseed_deficit, c14_veg_cs%core%deadcroot, &
    !$acc&   c14_veg_cs%core%deadcroot_storage, c14_veg_cs%core%deadcroot_xfer, c14_veg_cs%core%deadstem, &
    !$acc&   c14_veg_cs%core%deadstem_storage, c14_veg_cs%core%deadstem_xfer, c14_veg_cs%core%dispveg, &
    !$acc&   c14_veg_cs%core%froot, c14_veg_cs%core%froot_storage, c14_veg_cs%core%froot_xfer, &
    !$acc&   c14_veg_cs%core%grain, c14_veg_cs%core%grain_storage, c14_veg_cs%core%grain_xfer, &
    !$acc&   c14_veg_cs%core%leaf, c14_veg_cs%core%leaf_storage, c14_veg_cs%core%leaf_xfer, &
    !$acc&   c14_veg_cs%core%livecroot, c14_veg_cs%core%livecroot_storage, c14_veg_cs%core%livecroot_xfer, &
    !$acc&   c14_veg_cs%core%livestem, c14_veg_cs%core%livestem_storage, c14_veg_cs%core%livestem_xfer, &
    !$acc&   c14_veg_cs%core%pool, c14_veg_cs%core%storveg, c14_veg_cs%core%totpft, c14_veg_cs%core%totveg, &
    !$acc&   c14_veg_cs%core%trunc_sink, c14_veg_cs%gresp_storage, c14_veg_cs%gresp_xfer, &
    !$acc&   c14_veg_cs%xsmrpool, canopystate_vars%laisha_patch, canopystate_vars%laisun_patch, &
    !$acc&   cnstate_vars%alloc_pnow_patch, cnstate_vars%annavg_t2m_patch, &
    !$acc&   cnstate_vars%annmax_retransn_patch, cnstate_vars%annmax_retransp_patch, &
    !$acc&   cnstate_vars%annsum_potential_gpp_patch, cnstate_vars%bglfr_froot_patch, &
    !$acc&   cnstate_vars%bglfr_leaf_patch, cnstate_vars%bglfr_patch, cnstate_vars%bgtr_patch, &
    !$acc&   cnstate_vars%c_allometry_patch, cnstate_vars%days_active_patch, cnstate_vars%dormant_flag_patch, &
    !$acc&   cnstate_vars%downreg_patch, cnstate_vars%lfpftd_patch, cnstate_vars%lgsf_patch, &
    !$acc&   cnstate_vars%n_allometry_patch, cnstate_vars%offset_counter_patch, &
    !$acc&   cnstate_vars%offset_fdd_patch, cnstate_vars%offset_flag_patch, cnstate_vars%offset_swi_patch, &
    !$acc&   cnstate_vars%onset_counter_patch, cnstate_vars%onset_fdd_patch, cnstate_vars%onset_flag_patch, &
    !$acc&   cnstate_vars%onset_gdd_patch, cnstate_vars%onset_gddflag_patch, cnstate_vars%onset_swi_patch, &
    !$acc&   cnstate_vars%p_allometry_patch, cnstate_vars%rc14_atm_patch, cnstate_vars%tempavg_t2m_patch, &
    !$acc&   cnstate_vars%tempmax_retransn_patch, cnstate_vars%tempmax_retransp_patch, &
    !$acc&   cnstate_vars%tempsum_potential_gpp_patch, col_cf%core%dwt_conv_flux, &
    !$acc&   col_cf%core%dwt_crop_product_gain, col_cf%core%dwt_deadcroot_to_cwd, &
    !$acc&   col_cf%core%dwt_froot_to_litr_cel, col_cf%core%dwt_froot_to_litr_lig, &
    !$acc&   col_cf%core%dwt_froot_to_litr_met, col_cf%core%dwt_livecroot_to_cwd, &
    !$acc&   col_cf%core%dwt_prod100_gain, col_cf%core%dwt_prod10_gain, col_cf%core%dwt_slash_flux, &
    !$acc&   col_cs%core%decomp_pools_vr, col_cs%core%dyn_bal_adjustments, col_cs%core%prod1, &
    !$acc&   col_cs%core%prod10, col_cs%core%prod100, col_cs%core%trunc_sink_vr, col_es%t_soisno, &
    !$acc&   col_nf%core%dwt_conv_flux, col_nf%core%dwt_crop_product_gain, col_nf%core%dwt_deadcroot_to_cwd, &
    !$acc&   col_nf%core%dwt_froot_to_litr_cel, col_nf%core%dwt_froot_to_litr_lig, &
    !$acc&   col_nf%core%dwt_froot_to_litr_met, col_nf%core%dwt_livecroot_to_cwd, &
    !$acc&   col_nf%core%dwt_prod100_gain, col_nf%core%dwt_prod10_gain, col_nf%core%dwt_slash_flux, &
    !$acc&   col_ns%core%decomp_pools_vr, col_ns%core%dyn_bal_adjustments, col_ns%core%prod1, &
    !$acc&   col_ns%core%prod10, col_ns%core%prod100, col_ns%core%trunc_sink_vr, col_ns%fan_grz_fract, &
    !$acc&   col_ns%fan_totn, col_ns%fert_u1, col_ns%fert_u2, col_ns%manure_a_app, col_ns%manure_a_grz, &
    !$acc&   col_ns%manure_n_stored, col_ns%manure_r_app, col_ns%manure_r_grz, col_ns%manure_tan_stored, &
    !$acc&   col_ns%manure_u_app, col_ns%manure_u_grz, col_ns%mineral%smin_vr, col_ns%smin_nh4_vr, &
    !$acc&   col_ns%smin_no3_vr, col_ns%tan_f1, col_ns%tan_f2, col_ns%tan_f3, col_ns%tan_f4, col_ns%tan_g1, &
    !$acc&   col_ns%tan_g2, col_ns%tan_g3, col_ns%tan_s0, col_ns%tan_s1, col_ns%tan_s2, col_ns%tan_s3, &
    !$acc&   col_pf%core%dwt_conv_flux, col_pf%core%dwt_crop_product_gain, col_pf%core%dwt_deadcroot_to_cwd, &
    !$acc&   col_pf%core%dwt_froot_to_litr_cel, col_pf%core%dwt_froot_to_litr_lig, &
    !$acc&   col_pf%core%dwt_froot_to_litr_met, col_pf%core%dwt_livecroot_to_cwd, &
    !$acc&   col_pf%core%dwt_prod100_gain, col_pf%core%dwt_prod10_gain, col_pf%core%dwt_slash_flux, &
    !$acc&   col_pp%active, col_pp%glc_topo, col_pp%wtgcell, col_pp%wtlunit, col_pp%wttopounit, &
    !$acc&   col_ps%core%decomp_pools_vr, col_ps%core%dyn_bal_adjustments, col_ps%core%prod1, &
    !$acc&   col_ps%core%prod10, col_ps%core%prod100, col_ps%core%trunc_sink_vr, col_ps%labilep_vr, &
    !$acc&   col_ps%occlp_vr, col_ps%primp_vr, col_ps%secondp_vr, col_ps%solutionp_vr, col_ws%h2osoi_ice, &
    !$acc&   col_ws%h2osoi_liq, col_ws%h2osoi_vol, glc2lnd_vars%glc_dyn_runoff_routing_grc, &
    !$acc&   grc_cf%core%dwt_conv_flux, grc_cf%core%dwt_prod100_gain, grc_cf%core%dwt_prod10_gain, &
    !$acc&   grc_cf%core%dwt_seed_to_deadstem, grc_cf%core%dwt_seed_to_leaf, grc_cs%core%seed, &
    !$acc&   grc_ef%eflx_dynbal, grc_es%heat1, grc_es%heat2, grc_es%liquid_water_temp1, &
    !$acc&   grc_es%liquid_water_temp2, grc_nf%core%dwt_conv_flux, grc_nf%core%dwt_prod100_gain, &
    !$acc&   grc_nf%core%dwt_prod10_gain, grc_nf%core%dwt_seed_to_deadstem, grc_nf%core%dwt_seed_to_leaf, &
    !$acc&   grc_nf%dwt_seedn_to_npool, grc_ns%core%seed, grc_pf%core%dwt_conv_flux, &
    !$acc&   grc_pf%core%dwt_prod100_gain, grc_pf%core%dwt_prod10_gain, grc_pf%core%dwt_seed_to_deadstem, &
    !$acc&   grc_pf%core%dwt_seed_to_leaf, grc_pf%dwt_seedp_to_ppool, grc_ps%core%seed, &
    !$acc&   grc_wf%qflx_ice_dynbal, grc_wf%qflx_liq_dynbal, grc_ws%ice1, grc_ws%ice2, grc_ws%liq1, &
    !$acc&   grc_ws%liq2, harvest_rates, lun_pp%active, lun_pp%wtgcell, lun_pp%wttopounit, &
    !$acc&   photosyns_vars%alphapsnsha_patch, photosyns_vars%alphapsnsun_patch, &
    !$acc&   photosyns_vars%c13_psnsha_patch, photosyns_vars%c13_psnsun_patch, &
    !$acc&   photosyns_vars%c14_psnsha_patch, photosyns_vars%c14_psnsun_patch, photosyns_vars%psnsha_patch, &
    !$acc&   photosyns_vars%psnsun_patch, photosyns_vars%rc13_canair_patch, photosyns_vars%rc13_psnsha_patch, &
    !$acc&   photosyns_vars%rc13_psnsun_patch, soilhydrology_vars%wa_col, veg_cf%annsum_npp, veg_cf%availc, &
    !$acc&   veg_cf%core%dwt_conv_flux, veg_cf%core%dwt_crop_product_gain, veg_cf%core%dwt_prod100_gain, &
    !$acc&   veg_cf%core%dwt_prod10_gain, veg_cf%core%dwt_seed_to_deadstem, veg_cf%core%dwt_seed_to_leaf, &
    !$acc&   veg_cf%core%plant_alloc, veg_cf%core%prev_froot_to_litter, veg_cf%core%prev_leaf_to_litter, &
    !$acc&   veg_cf%excess_cflux, veg_cf%gpp_before_downreg, veg_cf%tempsum_npp, veg_cf%xsmrpool_c13ratio, &
    !$acc&   veg_cf%xsmrpool_recover, veg_cs%core%cropseed_deficit, veg_cs%core%deadcroot, &
    !$acc&   veg_cs%core%deadcroot_storage, veg_cs%core%deadcroot_xfer, veg_cs%core%deadstem, &
    !$acc&   veg_cs%core%deadstem_storage, veg_cs%core%deadstem_xfer, veg_cs%core%dispveg, veg_cs%core%froot, &
    !$acc&   veg_cs%core%froot_storage, veg_cs%core%froot_xfer, veg_cs%core%grain, veg_cs%core%grain_storage, &
    !$acc&   veg_cs%core%grain_xfer, veg_cs%core%leaf, veg_cs%core%leaf_storage, veg_cs%core%leaf_xfer, &
    !$acc&   veg_cs%core%livecroot, veg_cs%core%livecroot_storage, veg_cs%core%livecroot_xfer, &
    !$acc&   veg_cs%core%livestem, veg_cs%core%livestem_storage, veg_cs%core%livestem_xfer, veg_cs%core%pool, &
    !$acc&   veg_cs%core%storveg, veg_cs%core%totpft, veg_cs%core%totveg, veg_cs%core%trunc_sink, &
    !$acc&   veg_cs%gresp_storage, veg_cs%gresp_xfer, veg_cs%xsmrpool, veg_nf%core%dwt_conv_flux, &
    !$acc&   veg_nf%core%dwt_crop_product_gain, veg_nf%core%dwt_prod100_gain, veg_nf%core%dwt_prod10_gain, &
    !$acc&   veg_nf%core%dwt_seed_to_deadstem, veg_nf%core%dwt_seed_to_leaf, veg_nf%core%plant_alloc, &
    !$acc&   veg_nf%dwt_seedn_to_npool, veg_nf%retrans%avail_retrans, veg_nf%uptake%plant_demand, &
    !$acc&   veg_ns%core%cropseed_deficit, veg_ns%core%deadcroot, veg_ns%core%deadcroot_storage, &
    !$acc&   veg_ns%core%deadcroot_xfer, veg_ns%core%deadstem, veg_ns%core%deadstem_storage, &
    !$acc&   veg_ns%core%deadstem_xfer, veg_ns%core%dispveg, veg_ns%core%froot, veg_ns%core%froot_storage, &
    !$acc&   veg_ns%core%froot_xfer, veg_ns%core%grain, veg_ns%core%grain_storage, veg_ns%core%grain_xfer, &
    !$acc&   veg_ns%core%leaf, veg_ns%core%leaf_storage, veg_ns%core%leaf_xfer, veg_ns%core%livecroot, &
    !$acc&   veg_ns%core%livecroot_storage, veg_ns%core%livecroot_xfer, veg_ns%core%livestem, &
    !$acc&   veg_ns%core%livestem_storage, veg_ns%core%livestem_xfer, veg_ns%core%pool, veg_ns%core%storveg, &
    !$acc&   veg_ns%core%totpft, veg_ns%core%totveg, veg_ns%core%trunc_sink, veg_ns%retrans%pool, &
    !$acc&   veg_pf%core%dwt_conv_flux, veg_pf%core%dwt_crop_product_gain, veg_pf%core%dwt_prod100_gain, &
    !$acc&   veg_pf%core%dwt_prod10_gain, veg_pf%core%dwt_seed_to_deadstem, veg_pf%core%dwt_seed_to_leaf, &
    !$acc&   veg_pf%core%plant_alloc, veg_pf%dwt_seedp_to_ppool, veg_pf%retrans%avail_retrans, &
    !$acc&   veg_pf%uptake%plant_demand, veg_pp%active, veg_pp%wtcol, veg_pp%wtgcell, veg_pp%wtgcell_iac, &
    !$acc&   veg_pp%wtlunit, veg_pp%wttopounit, veg_ps%core%cropseed_deficit, veg_ps%core%deadcroot, &
    !$acc&   veg_ps%core%deadcroot_storage, veg_ps%core%deadcroot_xfer, veg_ps%core%deadstem, &
    !$acc&   veg_ps%core%deadstem_storage, veg_ps%core%deadstem_xfer, veg_ps%core%dispveg, veg_ps%core%froot, &
    !$acc&   veg_ps%core%froot_storage, veg_ps%core%froot_xfer, veg_ps%core%grain, veg_ps%core%grain_storage, &
    !$acc&   veg_ps%core%grain_xfer, veg_ps%core%leaf, veg_ps%core%leaf_storage, veg_ps%core%leaf_xfer, &
    !$acc&   veg_ps%core%livecroot, veg_ps%core%livecroot_storage, veg_ps%core%livecroot_xfer, &
    !$acc&   veg_ps%core%livestem, veg_ps%core%livestem_storage, veg_ps%core%livestem_xfer, veg_ps%core%pool, &
    !$acc&   veg_ps%core%storveg, veg_ps%core%totpft, veg_ps%core%totveg, veg_ps%core%trunc_sink, &
    !$acc&   veg_ps%retrans%pool) if_present if(.not. elm_device_fullsync)

    if (use_cn  .or. use_fates) then
       nstep = get_nstep()

       if (nstep < 2 )then
          if (masterproc) then
             write(iulog,*) '--WARNING-- skipping CN balance check for first timestep'
          end if
       else
          call t_startf('cnbalchk_at_grid')

          !$OMP PARALLEL DO PRIVATE (nc,bounds_clump)
          do nc = 1,nclumps
             call get_clump_bounds(nc, bounds_clump)
             !$acc enter data copyin(bounds_clump)  ! the private copy of this OpenMP loop: kernels read it

             if(use_cn) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
                call veg_cs%Summary(bounds_clump, &
                     filter(nc)%num_soilc, filter(nc)%soilc, &
                     filter(nc)%num_soilp, filter(nc)%soilp, col_cs)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
                call veg_ns%Summary(bounds_clump, &
                     filter(nc)%num_soilc, filter(nc)%soilc, &
                     filter(nc)%num_soilp, filter(nc)%soilp, col_ns)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
                call veg_ps%Summary(bounds_clump, &
                     filter(nc)%num_soilc, filter(nc)%soilc, &
                     filter(nc)%num_soilp, filter(nc)%soilp, col_ps)

             elseif(use_fates)then
                ! In this scenario, we simply zero all of the
                ! column level variables that would had been upscaled
                ! in the veg summary with p2c
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before zeroforfates
#endif
                call col_cs%ZeroForFates(bounds_clump,filter(nc)%num_soilc, filter(nc)%soilc)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before zeroforfates
#endif
                call col_ns%ZeroForFates(bounds_clump,filter(nc)%num_soilc, filter(nc)%soilc)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before zeroforfates
#endif
                call col_ps%ZeroForFates(bounds_clump,filter(nc)%num_soilc, filter(nc)%soilc)
             end if

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
             call col_cs%Summary(bounds_clump, &
                  filter(nc)%num_soilc, filter(nc)%soilc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
             call col_ns%Summary(bounds_clump, &
                  filter(nc)%num_soilc, filter(nc)%soilc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
             call col_ps%Summary(bounds_clump, &
                  filter(nc)%num_soilc, filter(nc)%soilc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before endgridcbalanceafterdynsubgriddriver
#endif
             call EndGridCBalanceAfterDynSubgridDriver(bounds_clump, &
                  filter(nc)%num_soilc, filter(nc)%soilc, &
                  col_cs, grc_cs, grc_cf)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before endgridnbalanceafterdynsubgriddriver
#endif
             call EndGridNBalanceAfterDynSubgridDriver(bounds_clump, &
                  filter(nc)%num_soilc, filter(nc)%soilc, &
                  col_ns, grc_ns, grc_nf)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before endgridpbalanceafterdynsubgriddriver
#endif
             call EndGridPBalanceAfterDynSubgridDriver(bounds_clump, &
                  filter(nc)%num_soilc, filter(nc)%soilc, &
                  col_ps, grc_ps, grc_pf)

             !$acc exit data delete(bounds_clump)
          end do
          !$OMP END PARALLEL DO
          call t_stopf('cnbalchk_at_grid')

       end if
    end if


    ! ============================================================================
    ! Initialize the mass balance checks for water.
    !
    ! Currently, I believe this needs to be done after weights are updated for
    ! prescribed transient patches, because column-level water is not
    ! generally conserved when weights change (instead the difference is put in
    ! the grid cell-level terms, qflx_liq_dynbal, etc.). In the future, we may
    ! want to change the balance checks to ensure that the grid cell-level water
    ! is conserved, considering qflx_liq_dynbal; in this case, the call to
    ! BeginWaterBalance should be moved to before the weight updates.
    !
    ! For CNP: This needs to be done after dynSubgrid_driver, because the
    ! changes due to dynamic area adjustments can break column-level conservation
    ! ============================================================================

    !$OMP PARALLEL DO PRIVATE (nc,bounds_clump)
    do nc = 1,nclumps
       call get_clump_bounds(nc, bounds_clump)
       !$acc enter data copyin(bounds_clump)  ! the private copy of this OpenMP loop: kernels read it

       call t_startf('begwbal')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before begincolwaterbalance
#endif
       call BeginColWaterBalance(bounds_clump,                &
            filter(nc)%num_nolakec, filter(nc)%nolakec,       &
            filter(nc)%num_lakec, filter(nc)%lakec,           &
            filter(nc)%num_hydrologyc, filter(nc)%hydrologyc, &
            soilhydrology_vars )
       call t_stopf('begwbal')


       call t_startf('begcnpbal')
       ! call veg summary before col summary, for p2c
       if (use_cn) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call veg_cs%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               filter(nc)%num_soilp, filter(nc)%soilp, col_cs)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call veg_ns%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               filter(nc)%num_soilp, filter(nc)%soilp, col_ns)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call veg_ps%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               filter(nc)%num_soilp, filter(nc)%soilp, col_ps)
       elseif(use_fates)then
          ! In this scenario, we simply zero all of the
          ! column level variables that would had been upscaled
          ! in the veg summary with p2c
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before zeroforfates
#endif
          call col_cs%ZeroForFates(bounds_clump,filter(nc)%num_soilc, filter(nc)%soilc)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before zeroforfates
#endif
          call col_ns%ZeroForFates(bounds_clump,filter(nc)%num_soilc, filter(nc)%soilc)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before zeroforfates
#endif
          call col_ps%ZeroForFates(bounds_clump,filter(nc)%num_soilc, filter(nc)%soilc)
       end if
       call t_stopf('begcnpbal')


       if (use_cn  .or. use_fates) then
          call t_startf('begcnpbalwf')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call col_cs%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call col_ns%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before summary
#endif
          call col_ps%Summary(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before begincolcbalance
#endif
          call BeginColCBalance(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               col_cs)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before begincolnbalance
#endif
          call BeginColNBalance(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               col_ns)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before begincolpbalance
#endif
          call BeginColPBalance(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               col_ps)

          call t_stopf('begcnpbalwf')
       end if


       if (do_budgets) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before waterbudget_setbeginningmonthlystates
#endif
          call WaterBudget_SetBeginningMonthlyStates(bounds_clump )
          if (use_cn) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before cnpbudget_setbeginningmonthlystates
#endif
             call CNPBudget_SetBeginningMonthlyStates(bounds_clump, col_cs, grc_cs)
          endif
       endif

       !$acc exit data delete(bounds_clump)
    end do
    !$OMP END PARALLEL DO



#ifndef CPL_BYPASS

    if (use_cn .or. use_fates) then

       ! ============================================================================
       ! Update dynamic N deposition field, on albedo timestep
       ! currently being done outside clumps loop, but no reason why it couldn't be
       ! re-written to go inside.
       ! ============================================================================

       call t_startf('ndep_interp')
       ! PET: switching CN timestep
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before ndep_interp
#endif
       if (.not. elm_device_fullsync) call update_atm2lnd_type(atm2lnd_vars, .false.)  ! spel targeted: called code the analysis excludes
       call ndep_interp(bounds_proc, atm2lnd_vars)
       if (.not. elm_device_fullsync) call update_atm2lnd_type(atm2lnd_vars, .true.)  ! spel targeted
       call t_stopf('ndep_interp')
    end if


    if (use_cn) then
       call t_startf('fireinterp')
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before fireinterp
#endif
       call FireInterp(bounds_proc)
       call t_stopf('fireinterp')
    elseif (use_fates) then
       ! fates_spitfire_mode is assigned an integer value in the namelist
       ! see bld/namelist_files/namelist_definition.xml for details
       if (fates_spitfire_mode > scalar_lightning) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before interpfileinputs
#endif
          call alm_fates%InterpFileInputs(bounds_proc)
       end if
    end if

    if (use_cn .or. use_fates) then
       ! ============================================================================
       ! Update dynamic P deposition field, on albedo timestep
       ! currently being done outside clumps loop, but no reason why it couldn't be
       ! re-written to go inside.
       ! ============================================================================

       call t_startf('pdep_interp')
       ! PET: switching CN timestep
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before pdep_interp
#endif
       call pdep_interp(bounds_proc, atm2lnd_vars)
       call t_stopf('pdep_interp')
    end if

#endif

    if (use_fan) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before fanstream_interp
#endif
       call fanstream_interp(bounds_proc, atm2lnd_vars)
    end if

    ! ============================================================================
    ! Initialize variables from previous time step, downscale atm forcings, and
    ! Determine canopy interception and precipitation onto ground surface.
    ! Determine the fraction of foliage covered by water and the fraction
    ! of foliage that is dry and transpiring. Initialize snow layer if the
    ! snow accumulation exceeds 10 mm.
    ! ============================================================================

    !$OMP PARALLEL DO PRIVATE (nc,l,c, bounds_clump)
    do nc = 1,nclumps
       call get_clump_bounds(nc, bounds_clump)
       !$acc enter data copyin(bounds_clump)  ! the private copy of this OpenMP loop: kernels read it

       call t_startf('drvinit')

#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before updatedaylength
#endif
       call UpdateDaylength(bounds_clump, declin)
       !$acc update device(first_step, grc_pp%dayl, grc_pp%prev_dayl) if_present if(.not. elm_device_fullsync)

       ! Initialze variables needed for new driver time step
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before elm_drv_init
#endif
       call elm_drv_init(bounds_clump, &
            filter(nc)%num_nolakec, filter(nc)%nolakec, &
            filter(nc)%num_nolakep, filter(nc)%nolakep, &
            filter(nc)%num_soilp  , filter(nc)%soilp,   &
            canopystate_vars, energyflux_vars)

       if (use_finetop_rad) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before topographic_effects_on_radiation
#endif
            call topographic_effects_on_radiation(bounds_clump, &
                 atm2lnd_vars, nextsw_cday, declinp1, &
                 lnd2atm_vars)
       endif

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before downscale_forcings
#endif
       call downscale_forcings(bounds_clump, &
            filter(nc)%num_do_smb_c, filter(nc)%do_smb_c, &
            atm2lnd_vars)

       call t_stopf('drvinit')

       ! ============================================================================
       ! Canopy Hydrology
       ! (1) water storage of intercepted precipitation
       ! (2) direct throughfall and canopy drainage of precipitation
       ! (3) fraction of foliage covered by water and the fraction is dry and transpiring
       ! (4) snow layer initialization if the snow accumulation exceeds 10 mm.
       ! ============================================================================

       call t_startf('canhydro')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before canopyhydrology
#endif
       call CanopyHydrology(bounds_clump, &
            filter(nc)%num_nolakec, filter(nc)%nolakec, &
            filter(nc)%num_nolakep, filter(nc)%nolakep, &
            atm2lnd_vars, canopystate_vars, &
            aerosol_vars )
       call t_stopf('canhydro')

       ! ============================================================================
       ! Surface Radiation
       ! ============================================================================

       call t_startf('surfrad')

       ! Surface Radiation primarily for non-urban columns

       ! Most of the surface radiation calculations are agnostic to the forest-model
       ! but the calculations of the fractions of sunlit and shaded canopies
       ! are specific, calculate them first.
       ! The nourbanp filter is set in dySubgrid_driver (earlier in this call)
       ! over the patch index range defined by bounds_clump%begp:bounds_proc%endp

       if(use_fates) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before wrap_sunfrac
#endif
          call alm_fates%wrap_sunfrac(bounds_clump, top_af, canopystate_vars)
       else
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before canopysunshadefractions
#endif
          call CanopySunShadeFractions(filter(nc)%num_nourbanp, filter(nc)%nourbanp,    &
                                       surfalb_vars, canopystate_vars,                  &
                                       solarabs_vars)
       end if

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before surfaceradiation
#endif
       call SurfaceRadiation(bounds_clump,                                 &
            filter(nc)%num_nourbanp, filter(nc)%nourbanp,                  &
            filter(nc)%num_urbanp, filter(nc)%urbanp    ,                  &
            filter(nc)%num_urbanc, filter(nc)%urbanc,                      &
            canopystate_vars, surfalb_vars, &
            solarabs_vars, surfrad_vars)

       ! Surface Radiation for only urban columns

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before urbanradiation
#endif
       call UrbanRadiation(                                                    &
            filter(nc)%num_nourbanl, filter(nc)%nourbanl,                      &
            filter(nc)%num_urbanl, filter(nc)%urbanl,                          &
            urbanparams_vars, solarabs_vars, surfalb_vars)

       call t_stopf('surfrad')

       ! ============================================================================
       ! Determine leaf temperature and surface fluxes based on ground
       ! temperature from previous time step.
       ! ============================================================================

       call t_startf('bgp1')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before canopytemperature
#endif
       call CanopyTemperature(bounds_clump,                                   &
            filter(nc)%num_nolakec, filter(nc)%nolakec,                       &
            filter(nc)%num_nolakep, filter(nc)%nolakep,                       &
            atm2lnd_vars, canopystate_vars, soilstate_vars, frictionvel_vars, &
            energyflux_vars)
       call t_stopf('bgp1')

       ! ============================================================================
       ! Determine fluxes
       ! ============================================================================

       call t_startf('bgflux')

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before reset
#endif
       call col_wf%Reset(bounds_clump, filter(nc)%num_nolakec , filter(nc)%nolakec)

       ! Split the non-lake, non-urban patch filter into bare-ground and
       ! vegetated sub-filters. This depends on the snow-dependent
       ! frac_veg_nosno flag, so it must be redone every time step.

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before setexposedvegpfilters
#endif
       call setExposedvegpFilters(bounds_clump, filter, &
            canopystate_vars%frac_veg_nosno_patch(bounds_clump%begp:bounds_clump%endp))

       ! Bareground fluxes for all patches except lakes and urban landunits

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before baregroundfluxes
#endif
       call BareGroundFluxes(bounds_clump,                                       &
            filter(nc)%num_nolakeurban_barep, filter(nc)%nolakeurban_barep,       &
            canopystate_vars, soilstate_vars,                                     &
            frictionvel_vars, ch4_vars  )
       call t_stopf('bgflux')

       ! non-bareground fluxes for all patches except lakes and urban landunits
       ! Calculate canopy temperature, latent and sensible fluxes from the canopy,
       ! and leaf water change by evapotranspiration

       call t_startf('canflux')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before canopyfluxes
#endif
       call CanopyFluxes(bounds_clump,                                                   &
            filter(nc)%num_nolakeurban_barep, filter(nc)%nolakeurban_barep,              &
            filter(nc)%num_nolakeurban_vegp,  filter(nc)%nolakeurban_vegp,               &
            canopystate_vars, cnstate_vars, energyflux_vars,               &
            frictionvel_vars, soilstate_vars, solarabs_vars, surfalb_vars,               &
            ch4_vars, photosyns_vars )
       call t_stopf('canflux')

       ! Fluxes for all urban landunits

       call t_startf('uflux')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before urbanfluxes
#endif
       call UrbanFluxes(bounds_clump,                        &
            filter(nc)%num_urbanl, filter(nc)%urbanl,        &
            filter(nc)%num_urbanc, filter(nc)%urbanc,        &
            filter(nc)%num_urbanp, filter(nc)%urbanp,        &
            urbanparams_vars, soilstate_vars,                &
            frictionvel_vars)
       call t_stopf('uflux')

       ! Fluxes for all lake landunits

       call t_startf('bgplake')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before lakefluxes
#endif
       call LakeFluxes(bounds_clump,                                         &
            filter(nc)%num_lakec, filter(nc)%lakec,                          &
            filter(nc)%num_lakep, filter(nc)%lakep,                          &
            atm2lnd_vars, solarabs_vars, frictionvel_vars,  &
            energyflux_vars, lakestate_vars)

       ! ============================================================================
       ! DUST and VOC emissions
       ! ============================================================================

       call t_startf('bgc')

       ! Dust mobilization (C. Zender's modified codes)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before dustemission
#endif
       call DustEmission(bounds_clump,                      &
            filter(nc)%num_nolakep, filter(nc)%nolakep,     &
            atm2lnd_vars, soilstate_vars, canopystate_vars, &
            frictionvel_vars, dust_vars)

       ! Dust dry deposition (C. Zender's modified codes)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before dustdrydep
#endif
       call DustDryDep(bounds_clump, &
            atm2lnd_vars, frictionvel_vars, dust_vars)

       ! VOC emission (A. Guenther's MEGAN (2006) model)
       if (use_voc) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before vocemission
#endif
          if (.not. elm_device_fullsync) call update_photosyns_type(photosyns_vars, .false.)  ! spel targeted: called code the analysis excludes
          if (.not. elm_device_fullsync) call update_canopystate_type(canopystate_vars, .false.)  ! spel targeted: called code the analysis excludes
          if (.not. elm_device_fullsync) call update_atm2lnd_type(atm2lnd_vars, .false.)  ! spel targeted: called code the analysis excludes
          call VOCEmission(bounds_clump,                                         &
               filter(nc)%num_soilp, filter(nc)%soilp,                           &
               atm2lnd_vars, canopystate_vars, photosyns_vars, temperature_vars, &
               vocemis_vars)
          if (.not. elm_device_fullsync) call update_photosyns_type(photosyns_vars, .true.)  ! spel targeted
          if (.not. elm_device_fullsync) call update_canopystate_type(canopystate_vars, .true.)  ! spel targeted
          if (.not. elm_device_fullsync) call update_atm2lnd_type(atm2lnd_vars, .true.)  ! spel targeted
       end if

       call t_stopf('bgc')

       ! ============================================================================
       ! Determine temperatures
       ! ============================================================================
       ! Set lake temperature

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before laketemperature
#endif
       call LakeTemperature(bounds_clump,             &
            filter(nc)%num_lakec, filter(nc)%lakec,   &
            filter(nc)%num_lakep, filter(nc)%lakep,   &
            solarabs_vars, soilstate_vars,  ch4_vars, &
            lakestate_vars)
       call t_stopf('bgplake')

       ! Set soil/snow temperatures including ground temperature

       call t_startf('soiltemperature')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before soiltemperature
#endif
       call SoilTemperature(bounds_clump,                     &
            filter(nc)%num_urbanl  , filter(nc)%urbanl,       &
            filter(nc)%num_nolakec , filter(nc)%nolakec,      &
            urbanparams_vars, canopystate_vars, &
            solarabs_vars, soilstate_vars )
       call t_stopf('soiltemperature')


       ! ============================================================================
       ! update surface fluxes for new ground temperature.
       ! ============================================================================

       call t_startf('bgp2')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before soilfluxes
#endif
       call SoilFluxes(bounds_clump,                       &
            filter(nc)%num_urbanl,  filter(nc)%urbanl,     &
            filter(nc)%num_nolakec, filter(nc)%nolakec,    &
            filter(nc)%num_nolakep, filter(nc)%nolakep,    &
            atm2lnd_vars, solarabs_vars, canopystate_vars, &
            energyflux_vars )
       call t_stopf('bgp2')

       ! ============================================================================
       ! Perform averaging from patch level to column level
       ! ============================================================================

       call t_startf('patch2col')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before elm_drv_patch2col
#endif
       call elm_drv_patch2col(bounds_clump, filter(nc)%num_nolakec, filter(nc)%nolakec, energyflux_vars)
       call t_stopf('patch2col')

       ! ============================================================================
       ! Vertical (column) soil and surface hydrology
       ! ============================================================================

       ! Note that filter_snowc and filter_nosnowc are returned by
       ! LakeHydrology after the new snow filter is built

       call t_startf('hydro without drainage')

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before hydrologynodrainage
#endif
       call HydrologyNoDrainage(bounds_clump,                                &
            filter(nc)%num_nolakec, filter(nc)%nolakec,                      &
            filter(nc)%num_hydrologyc, filter(nc)%hydrologyc,                &
            filter(nc)%num_hydrononsoic, filter(nc)%hydrononsoic,            &
            filter(nc)%num_urbanc, filter(nc)%urbanc,                        &
            filter(nc)%num_snowc, filter(nc)%snowc,                          &
            filter(nc)%num_nosnowc, filter(nc)%nosnowc,canopystate_vars,     &
            atm2lnd_vars, ocn2lnd_vars, soilstate_vars,                      &
            soilhydrology_vars, aerosol_vars )

       !  Calculate column-integrated aerosol masses, and
       !  mass concentrations for radiative calculations and output
       !  (based on new snow level state, after SnowFilter is rebuilt.
       !  NEEDS TO BE AFTER SnowFiler is rebuilt, otherwise there
       !  can be zero snow layers but an active column in filter)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before aerosolmasses
#endif
       call AerosolMasses( bounds_clump,                                   &
            num_on=filter(nc)%num_snowc, filter_on=filter(nc)%snowc,       &
            num_off=filter(nc)%num_nosnowc, filter_off=filter(nc)%nosnowc, &
            aerosol_vars=aerosol_vars)

       call t_stopf('hydro without drainage')

       ! ============================================================================
       ! Lake hydrology
       ! ============================================================================

       ! Note that filter_lakesnowc and filter_lakenosnowc are returned by
       ! LakeHydrology after the new snow filter is built

       call t_startf('hylake')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before lakehydrology
#endif
       call LakeHydrology(bounds_clump,                                                      &
            filter(nc)%num_lakec, filter(nc)%lakec,                                          &
            filter(nc)%num_lakep, filter(nc)%lakep,                                          &
            filter(nc)%num_lakesnowc, filter(nc)%lakesnowc,                                  &
            filter(nc)%num_lakenosnowc, filter(nc)%lakenosnowc,                              &
            atm2lnd_vars, soilstate_vars,  &
            aerosol_vars, lakestate_vars)

       !  Calculate column-integrated aerosol masses, and
       !  mass concentrations for radiative calculations and output
       !  (based on new snow level state, after SnowFilter is rebuilt.
       !  NEEDS TO BE AFTER SnowFiler is rebuilt, otherwise there
       !  can be zero snow layers but an active column in filter)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before aerosolmasses
#endif
       call AerosolMasses(bounds_clump,                                            &
            num_on=filter(nc)%num_lakesnowc, filter_on=filter(nc)%lakesnowc,       &
            num_off=filter(nc)%num_lakenosnowc, filter_off=filter(nc)%lakenosnowc, &
            aerosol_vars=aerosol_vars)

       ! Must be done here because must use a snow filter for lake columns

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before snowage_grain
#endif
       call SnowAge_grain(bounds_clump,                         &
            filter(nc)%num_lakesnowc, filter(nc)%lakesnowc,     &
            filter(nc)%num_lakenosnowc, filter(nc)%lakenosnowc )


       call t_stopf('hylake')

       ! ============================================================================
       ! ! Fraction of soil covered by snow (Z.-L. Yang U. Texas)
       ! ============================================================================

       ! on the device: SnowAge_grain before and the next routines run there (a host loop here was
       ! overwritten by the next device -> host transition)
       !$acc parallel loop gang vector default(present) private(l) if(elm_device_ready)
       do c = bounds_clump%begc,bounds_clump%endc
          l = col_pp%landunit(c)
          if (lun_pp%urbpoi(l)) then
             ! Urban landunit use Bonan 1996 (LSM Technical Note)
             col_ws%frac_sno(c) = min( col_ws%snow_depth(c)/0.05_r8, 1._r8)
          end if
       end do

       ! ============================================================================
       ! Snow aging routine based on Flanner and Zender (2006), Linking snowpack
       ! microphysics and albedo evolution, JGR, and Brun (1989), Investigation of
       ! wet-snow metamorphism in respect of liquid-water content, Ann. Glaciol.
       ! ============================================================================
       ! Note the snow filters here do not include lakes
       ! TODO: move this up

       call t_startf('snow_init')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before snowage_grain
#endif
       call SnowAge_grain(bounds_clump,                 &
            filter(nc)%num_snowc, filter(nc)%snowc,     &
            filter(nc)%num_nosnowc, filter(nc)%nosnowc )
       call t_stopf('snow_init')

       ! ============================================================================
       ! Update sediment fluxes from land unit
       ! ============================================================================

       if (use_cn .and. use_erosion) then
          ! spel targeted: device data this host code uses
          !$acc update self(canopystate_vars%hbot_patch, canopystate_vars%htop_patch, &
          !$acc&   canopystate_vars%tlai_patch, cnstate_vars%croot_prof_patch, cnstate_vars%froot_prof_patch, &
          !$acc&   col_cs%core%decomp_pools_vr, col_wf%qflx_qrgwl, col_wf%qflx_surf, col_ws%frac_sno, &
          !$acc&   veg_cs%core%deadcroot, veg_cs%core%froot, veg_cs%core%livecroot, veg_wf%qflx_dirct_rain, &
          !$acc&   veg_wf%qflx_leafdrip, &
          !$acc&   veg_wf%qflx_real_irrig_patch) if_present if(.not. elm_device_fullsync)
          call t_startf('erosion')
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before soilerosion
#endif
          call SoilErosion(bounds_clump, filter(nc)%num_soilc, filter(nc)%soilc, &
               canopystate_vars, cnstate_vars, soilstate_vars, sedflux_vars)
          call t_stopf('erosion')
          !$acc update device(sedflux_vars%sed_crop_ero_col, sedflux_vars%sed_ero_col, &
          !$acc&   sedflux_vars%sed_p_ero_col, sedflux_vars%sed_q_ero_col, &
          !$acc&   sedflux_vars%sed_yld_col) if_present if(.not. elm_device_fullsync)
       end if

       ! ============================================================================
       ! Ecosystem dynamics: Uses CN, or static parameterizations
       ! ============================================================================

       call t_startf('ecosysdyn')
       if (use_cn)then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before cropincrementyear
#endif
          call crop_vars%CropIncrementYear(filter(nc)%num_pcropp, filter(nc)%pcropp, &
                                           filter(nc)%num_ppercropp, filter(nc)%ppercropp)
       endif


       ! FIX(SPM,032414)  push these checks into the routines below and/or make this consistent.


       if (use_cn .or. use_fates) then

          ! fully prognostic canopy structure and C-N biogeochemistry
          ! - crop model:  crop algorithms called from within CNEcosystemDyn

          !===========================================================================================
          ! clm_interface: 'EcosystemDynNoLeaching' is divided into 2 subroutines (1 & 2): BEGIN
          ! EcosystemDynNoLeaching1 is called before clm_interface
          ! EcosystemDynNoLeaching2 is called after clm_interface
          !===========================================================================================
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before ecosystemdynnoleaching1
#endif
          call EcosystemDynNoLeaching1(bounds_clump,         &
                    filter(nc)%num_soilc, filter(nc)%soilc,  &
                    filter(nc)%num_soilp, filter(nc)%soilp,  &
                    filter(nc)%num_pcropp, filter(nc)%pcropp, &
                    filter(nc)%num_ppercropp, filter(nc)%ppercropp, &
                    cnstate_vars,            &
                    atm2lnd_vars,            &
                    canopystate_vars, soilstate_vars, crop_vars,   &
                    ch4_vars, photosyns_vars, frictionvel_vars )

          !--------------------------------------------------------------------------------
          if (use_elm_interface) then
              ! STEP-1: pass data from CLM to elm_interface_data (INTERFACE DATA TYPE)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before get_elm_data
#endif
              if (.not. elm_device_fullsync) call update_ch4_type(ch4_vars, .false.)  ! spel targeted: called code the analysis excludes
              if (.not. elm_device_fullsync) call update_cnstate_type(cnstate_vars, .false.)  ! spel targeted: called code the analysis excludes
              if (.not. elm_device_fullsync) call update_energyflux_type(energyflux_vars, .false.)  ! spel targeted: called code the analysis excludes
              if (.not. elm_device_fullsync) call update_waterflux_type(waterflux_vars, .false.)  ! spel targeted: called code the analysis excludes
              if (.not. elm_device_fullsync) call update_soilstate_type(soilstate_vars, .false.)  ! spel targeted: called code the analysis excludes
              if (.not. elm_device_fullsync) call update_atm2lnd_type(atm2lnd_vars, .false.)  ! spel targeted: called code the analysis excludes
              if (.not. elm_device_fullsync) call update_elm_interface_data_type(elm_interface_data, .false.)  ! spel targeted: called code the analysis excludes
              call get_elm_data(elm_interface_data,bounds_clump,                     &
                        filter(nc)%num_soilc, filter(nc)%soilc,                      &
                        filter(nc)%num_soilp, filter(nc)%soilp,                      &
                        atm2lnd_vars, soilstate_vars,                                &
                        waterstate_vars, waterflux_vars,                             &
                        temperature_vars, energyflux_vars,                           &
                        cnstate_vars, &
                        ch4_vars)
              if (.not. elm_device_fullsync) call update_ch4_type(ch4_vars, .true.)  ! spel targeted
              if (.not. elm_device_fullsync) call update_cnstate_type(cnstate_vars, .true.)  ! spel targeted
              if (.not. elm_device_fullsync) call update_energyflux_type(energyflux_vars, .true.)  ! spel targeted
              if (.not. elm_device_fullsync) call update_waterflux_type(waterflux_vars, .true.)  ! spel targeted
              if (.not. elm_device_fullsync) call update_soilstate_type(soilstate_vars, .true.)  ! spel targeted
              if (.not. elm_device_fullsync) call update_atm2lnd_type(atm2lnd_vars, .true.)  ! spel targeted
              if (.not. elm_device_fullsync) call update_elm_interface_data_type(elm_interface_data, .true.)  ! spel targeted


              if (use_pflotran .and. pf_cmode) then
                 call t_startf('pflotran')
                 ! -------------------------------------------------------------------------
                 ! PFLOTRAN calling for solving below-ground and ground-surface processes,
                 ! including thermal, hydrological and biogeochemical processes
                 ! STEP-2: (1) pass data from elm_interface_data to pflotran
                 ! STEP-2: (2) run pflotran
                 ! STEP-2: (3) update elm_interface_data from pflotran
                 ! -------------------------------------------------------------------------
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before elm_pf_run
#endif
                 if (.not. elm_device_fullsync) call update_elm_interface_data_type(elm_interface_data, .false.)  ! spel targeted: called code the analysis excludes
                 call elm_pf_run(elm_interface_data, bounds_clump, filter, nc)
                 if (.not. elm_device_fullsync) call update_elm_interface_data_type(elm_interface_data, .true.)  ! spel targeted

                 ! STEP-3: update CLM from elm_interface_data
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before update_bgc_data_pf2elm
#endif
                 if (.not. elm_device_fullsync) call update_ch4_type(ch4_vars, .false.)  ! spel targeted: called code the analysis excludes
                 if (.not. elm_device_fullsync) call update_cnstate_type(cnstate_vars, .false.)  ! spel targeted: called code the analysis excludes
                 call update_bgc_data_pf2elm(elm_interface_data%bgc,         &
                        bounds_clump,filter(nc)%num_soilc, filter(nc)%soilc, &
                        filter(nc)%num_soilp, filter(nc)%soilp,              &
                        cnstate_vars, &
                        ch4_vars)
                 if (.not. elm_device_fullsync) call update_ch4_type(ch4_vars, .true.)  ! spel targeted
                 if (.not. elm_device_fullsync) call update_cnstate_type(cnstate_vars, .true.)  ! spel targeted

                 call t_stopf('pflotran')

              elseif (use_elm_bgc) then
                 call t_startf('elm-bgc via interface')
                 ! -------------------------------------------------------------------------
                 ! run elm-bgc (SoilLittDecompAlloc) through interface
                 ! STEP-2: (1) pass data from elm_interface_data to SoilLittDecompAlloc
                 ! STEP-2: (2) run SoilLittDecompAlloc
                 ! STEP-2: (3) update elm_interface_data from SoilLittDecompAlloc
                 ! -------------------------------------------------------------------------
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before elm_bgc_run
#endif
                 if (.not. elm_device_fullsync) call update_ch4_type(ch4_vars, .false.)  ! spel targeted: called code the analysis excludes
                 if (.not. elm_device_fullsync) call update_cnstate_type(cnstate_vars, .false.)  ! spel targeted: called code the analysis excludes
                 if (.not. elm_device_fullsync) call update_soilstate_type(soilstate_vars, .false.)  ! spel targeted: called code the analysis excludes
                 if (.not. elm_device_fullsync) call update_canopystate_type(canopystate_vars, .false.)  ! spel targeted: called code the analysis excludes
                 if (.not. elm_device_fullsync) call update_elm_interface_data_type(elm_interface_data, .false.)  ! spel targeted: called code the analysis excludes
                 call elm_bgc_run(elm_interface_data, bounds_clump,          &
                        filter(nc)%num_soilc, filter(nc)%soilc,              &
                        filter(nc)%num_soilp, filter(nc)%soilp,              &
                        canopystate_vars, soilstate_vars,                    &
                        temperature_vars, waterstate_vars,                   &
                        cnstate_vars, ch4_vars)
                 if (.not. elm_device_fullsync) call update_ch4_type(ch4_vars, .true.)  ! spel targeted
                 if (.not. elm_device_fullsync) call update_cnstate_type(cnstate_vars, .true.)  ! spel targeted
                 if (.not. elm_device_fullsync) call update_soilstate_type(soilstate_vars, .true.)  ! spel targeted
                 if (.not. elm_device_fullsync) call update_canopystate_type(canopystate_vars, .true.)  ! spel targeted
                 if (.not. elm_device_fullsync) call update_elm_interface_data_type(elm_interface_data, .true.)  ! spel targeted

                 ! STEP-3: update CLM from elm_interface_data
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before update_bgc_data_elm2elm
#endif
                 if (.not. elm_device_fullsync) call update_ch4_type(ch4_vars, .false.)  ! spel targeted: called code the analysis excludes
                 if (.not. elm_device_fullsync) call update_cnstate_type(cnstate_vars, .false.)  ! spel targeted: called code the analysis excludes
                 call update_bgc_data_elm2elm(elm_interface_data%bgc,        &
                        bounds_clump, filter(nc)%num_soilc, filter(nc)%soilc,&
                        filter(nc)%num_soilp, filter(nc)%soilp,              &
                        cnstate_vars, &
                        ch4_vars)
                 if (.not. elm_device_fullsync) call update_ch4_type(ch4_vars, .true.)  ! spel targeted
                 if (.not. elm_device_fullsync) call update_cnstate_type(cnstate_vars, .true.)  ! spel targeted
                 call t_stopf('elm-bgc via interface')
              end if !if (use_pflotran .and. pf_cmode)
          end if !if (use_elm_interface)
          !--------------------------------------------------------------------------------

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before ecosystemdynnoleaching2
#endif
          call EcosystemDynNoLeaching2(bounds_clump,                &
                filter(nc)%num_soilc, filter(nc)%soilc,             &
                filter(nc)%num_soilp, filter(nc)%soilp,             &
                filter(nc)%num_pcropp, filter(nc)%pcropp, doalb,    &
                filter(nc)%num_ppercropp, filter(nc)%ppercropp,     &
                cnstate_vars,  atm2lnd_vars,          &
                canopystate_vars, soilstate_vars, crop_vars, ch4_vars, &
                photosyns_vars, soilhydrology_vars, energyflux_vars,   &
                sedflux_vars, solarabs_vars)

          !===========================================================================================
          ! clm_interface: 'EcosystemDynNoLeaching' is divided into 2 subroutines (1 & 2): END
          !===========================================================================================
          if(.not.use_fates)then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before annualupdate
#endif
            call AnnualUpdate(bounds_clump,            &
                 filter(nc)%num_soilc, filter(nc)%soilc, &
                 filter(nc)%num_soilp, filter(nc)%soilp, &
                 cnstate_vars)
          end if
             
          if (use_fates_sp) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before satellitephenology
#endif
            call SatellitePhenology(bounds_clump,               &
            filter_inactive_and_active(nc)%num_soilp, filter_inactive_and_active(nc)%soilp,    &
            waterstate_vars, canopystate_vars)
          endif
             
       else ! not ( if-use_cn   or if-use_fates)
          if (doalb) then
             ! Prescribed biogeography - prescribed canopy structure, some prognostic carbon fluxes
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before satellitephenology
#endif
             call SatellitePhenology(bounds_clump,               &
                  filter(nc)%num_nolakep, filter(nc)%nolakep,    &
                  waterstate_vars, canopystate_vars)
          end if
       end if  ! end of if-use_cn   or if-use_fates

       call t_stopf('ecosysdyn')

       ! Dry Deposition of chemical tracers (Wesely (1998) parameterizaion)
       call t_startf('depvel')
       if(.not.use_fates)then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before depvel_compute
#endif
         ! spel targeted: device data this host code uses
         !$acc update self(canopystate_vars%elai_patch, col_ws%h2osoi_vol, col_ws%snow_depth, &
         !$acc&   frictionvel_vars%vds_patch, top_af%solad) if_present if(.not. elm_device_fullsync)
         call depvel_compute(bounds_clump, &
              atm2lnd_vars, canopystate_vars, frictionvel_vars, &
              photosyns_vars, drydepvel_vars)
       end if
       call t_stopf('depvel')


       if (use_lch4) then
          !warning: do not call ch4 before AnnualUpdate, which will fail the ch4 model
          call t_startf('ch4')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before ch4
#endif
          call CH4 (bounds_clump,                                                                  &
               filter(nc)%num_soilc, filter(nc)%soilc,                                             &
               filter(nc)%num_lakec, filter(nc)%lakec,                                             &
               filter(nc)%num_soilp, filter(nc)%soilp,                                             &
               atm2lnd_vars, lakestate_vars, canopystate_vars, soilstate_vars, soilhydrology_vars, &
               energyflux_vars, ch4_vars, lnd2atm_vars, alm_fates)
          call t_stopf('ch4')
       end if

       ! Dry Deposition of chemical tracers (Wesely (1998) parameterizaion)
       call t_startf('depvel')
       if(.not.use_fates)then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before depvel_compute
#endif
         ! spel targeted: device data this host code uses
         !$acc update self(canopystate_vars%elai_patch, col_ws%h2osoi_vol, col_ws%snow_depth, &
         !$acc&   frictionvel_vars%vds_patch, top_af%solad) if_present if(.not. elm_device_fullsync)
         call depvel_compute(bounds_clump, &
              atm2lnd_vars, canopystate_vars, frictionvel_vars, &
              photosyns_vars, drydepvel_vars)
       end if
       call t_stopf('depvel')
       ! ============================================================================
       ! Calculate soil/snow hydrology with drainage (subsurface runoff)
       ! ============================================================================

       call t_startf('hydro2 drainage')

       if (use_elm_interface .and. (use_pflotran .and. pf_hmode)) then
         ! pflotran only works on 'soilc' (already done above).
         ! here for non-soil hydrology columns
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before hydrologydrainage
#endif
         call HydrologyDrainage(bounds_clump,                     &
            filter(nc)%num_nolakec, filter(nc)%nolakec,           &
            filter(nc)%num_hydrononsoic, filter(nc)%hydrononsoic, &
            filter(nc)%num_urbanc, filter(nc)%urbanc,             &
            filter(nc)%num_do_smb_c, filter(nc)%do_smb_c,         &
            atm2lnd_vars, glc2lnd_vars, ocn2lnd_vars,             &
            soilhydrology_vars, soilstate_vars)

       else

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before hydrologydrainage
#endif
         call HydrologyDrainage(bounds_clump,                 &
            filter(nc)%num_nolakec, filter(nc)%nolakec,       &
            filter(nc)%num_hydrologyc, filter(nc)%hydrologyc, &
            filter(nc)%num_urbanc, filter(nc)%urbanc,         &
            filter(nc)%num_do_smb_c, filter(nc)%do_smb_c,     &
            atm2lnd_vars, glc2lnd_vars, ocn2lnd_vars,         &
            soilhydrology_vars, soilstate_vars)

       end if

       call t_stopf('hydro2 drainage')



       if (use_cn .or. use_fates) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before ecosystemdynleaching
#endif
          call EcosystemDynLeaching(bounds_clump,                &
             filter(nc)%num_soilc, filter(nc)%soilc,             &
             filter(nc)%num_soilp, filter(nc)%soilp,             &
             filter(nc)%num_pcropp, filter(nc)%pcropp, doalb,    &
             cnstate_vars,  frictionvel_vars, canopystate_vars )
       end if

       ! ============================================================================
       ! Update Vegetation
       ! ============================================================================

       ! Execute FATES dynamics
       if ( use_fates ) then
          
          ! FATES has its own running mean functions, such as 24hr
          ! vegetation temperature and exponential moving averages
          ! for leaf photosynthetic acclimation temperature. These
          ! moving averages are updated here
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before wrapupdatefatesrmean
#endif
          call alm_fates%WrapUpdateFatesRmean(nc)
          
           ! Update high-frequency history diagnostics for FATES
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before wrap_update_hifrq_hist
#endif
           call alm_fates%wrap_update_hifrq_hist(bounds_clump, solarabs_vars)
           if ( is_beg_curr_day() ) then ! run ED at the start of each day
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before dynamics_driv
#endif
               call alm_fates%dynamics_driv( bounds_clump, top_as,          &
                    top_af, atm2lnd_vars, soilstate_vars, &
                    canopystate_vars, frictionvel_vars, soil_water_retention_curve)
           end if
       end if

       if (use_cn .and. doalb) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before vegstructupdate
#endif
           call VegStructUpdate(filter(nc)%num_soilp, filter(nc)%soilp,   &
                frictionvel_vars, cnstate_vars, &
                canopystate_vars, crop_vars)
       end if


       ! ============================================================================
       ! Check the energy and water balance, also carbon and nitrogen balance
       ! ============================================================================

       call t_startf('balchk')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before colwaterbalancecheck
#endif
       call ColWaterBalanceCheck(bounds_clump, &
            filter(nc)%num_do_smb_c, filter(nc)%do_smb_c, &
            atm2lnd_vars, glc2lnd_vars, solarabs_vars,  &
            energyflux_vars, canopystate_vars)
       call t_stopf('balchk')

       call t_startf('gridbalchk')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before gridbalancecheck
#endif
       call GridBalanceCheck(bounds_clump                  , &
            atm2lnd_vars, glc2lnd_vars,                      &
            energyflux_vars, soilhydrology_vars)
       call t_stopf('gridbalchk')

       if (do_budgets) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before waterbudget_setendingmonthlystates
#endif
          call WaterBudget_SetEndingMonthlyStates(bounds_clump)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before heatbudget_setendingstates
#endif
          call HeatBudget_SetEndingStates(bounds_clump)
          if (use_cn) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before cnpbudget_setendingmonthlystates
#endif
             call CNPBudget_SetEndingMonthlyStates(bounds_clump, col_cs, grc_cs)
          endif
       endif

       if (use_cn .or. use_fates) then

          call t_startf('cnbalchk')

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before colcbalancecheck
#endif
          call ColCBalanceCheck(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               col_cs, col_cf)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before colnbalancecheck
#endif
          call ColNBalanceCheck(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               col_ns, col_nf)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before colpbalancecheck
#endif
          call ColPBalanceCheck(bounds_clump, &
               filter(nc)%num_soilc, filter(nc)%soilc, &
               col_ps, col_pf)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before gridcbalancecheck
#endif
          call GridCBalanceCheck(bounds_clump, col_cs, col_cf, grc_cs, grc_cf)

          call t_stopf('cnbalchk')
       end if


       ! ============================================================================
       ! Determine albedos for next time step
       ! ============================================================================
       
       ! On the first step, send the solar zenith angles to FATES on non-continue restarts
       ! for the two-stream radiation scheme.
       if (use_fates .and. .not.doalb .and. get_nstep() == 1 .and. nsrest == nsrStartup) then
          if ( trim(finidat) == '' .or. fates_radiation_model=='twostream') then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before wrap_canopy_radiation
#endif
             call alm_fates%wrap_canopy_radiation(bounds_clump,surfalb_vars,nextsw_cday,declinp1)
          end if
       end if
       
       if ( doalb ) then
       
          ! Albedos for non-urban columns
          call t_startf('surfalb')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before surfacealbedo
#endif
          call SurfaceAlbedo(bounds_clump,                      &
               filter_inactive_and_active(nc)%num_nourbanc,     &
               filter_inactive_and_active(nc)%nourbanc,         &
               filter_inactive_and_active(nc)%num_nourbanp,     &
               filter_inactive_and_active(nc)%nourbanp,         &
               filter_inactive_and_active(nc)%num_urbanc,       &
               filter_inactive_and_active(nc)%urbanc,           &
               filter_inactive_and_active(nc)%num_urbanp,       &
               filter_inactive_and_active(nc)%urbanp,           &
               nextsw_cday, declinp1,                           &
               aerosol_vars, canopystate_vars, &
               lakestate_vars, surfalb_vars )
          call t_stopf('surfalb')

          ! Albedos for urban columns
          if (filter_inactive_and_active(nc)%num_urbanl > 0) then
             call t_startf('urbsurfalb')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before urbanalbedo
#endif
             call UrbanAlbedo(bounds_clump,                  &
                  filter_inactive_and_active(nc)%num_urbanl, &
                  filter_inactive_and_active(nc)%urbanl,     &
                  filter_inactive_and_active(nc)%num_urbanc, &
                  filter_inactive_and_active(nc)%urbanc,     &
                  filter_inactive_and_active(nc)%num_urbanp, &
                  filter_inactive_and_active(nc)%urbanp,     &
                  urbanparams_vars, solarabs_vars, surfalb_vars)
             call t_stopf('urbsurfalb')
          end if

       end if

       !$acc exit data delete(bounds_clump)
    end do
    !$OMP END PARALLEL DO

    ! Pass fates seed dispersal information to all nodes
    if (use_fates) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before wrapglobalseeddispersal
#endif
       if (fates_seeddisp_cadence /= fates_dispersal_cadence_none) call alm_fates%WrapGlobalSeedDispersal()
    end if
    
    ! ============================================================================
    ! Determine gridcell averaged properties to send to atm
    ! ============================================================================


    ! spel targeted: device data this host code uses
    !$acc update self(col_es%t_soisno, col_wf%qflx_glcice) if_present if(.not. elm_device_fullsync)
    call t_startf('lnd2atm')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before lnd2atm
#endif
    call lnd2atm(bounds_proc,                                   &
         atm2lnd_vars, surfalb_vars, frictionvel_vars,          &
         energyflux_vars, solarabs_vars, drydepvel_vars,        &
         vocemis_vars, dust_vars, ch4_vars, soilhydrology_vars, &
         sedflux_vars, lnd2atm_vars)
    call t_stopf('lnd2atm')

    ! ============================================================================
    ! Determine gridcell averaged properties to send to glc
    ! ============================================================================

    if (create_glacier_mec_landunit) then
       call t_startf('lnd2glc')
       !$OMP PARALLEL DO PRIVATE (nc, bounds_clump)
       do nc = 1,nclumps
          call get_clump_bounds(nc, bounds_clump)
          !$acc enter data copyin(bounds_clump)  ! the private copy of this OpenMP loop: kernels read it
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before update_lnd2glc
#endif
          call lnd2glc_vars%update_lnd2glc(bounds_clump,       &
               filter(nc)%num_do_smb_c, filter(nc)%do_smb_c,   &
               init=.false.)
          !$acc exit data delete(bounds_clump)
       end do
       !$OMP END PARALLEL DO
       call t_stopf('lnd2glc')
    end if
    !$acc update device(lnd2glc_vars%qice_grc, lnd2glc_vars%topo_grc, &
    !$acc&   lnd2glc_vars%tsrf_grc) if_present if(.not. elm_device_fullsync)

    ! ============================================================================
    ! Update stuff to send to iac
    ! ============================================================================

    if (iac_present) then
       call t_startf('lnd2iac')
       !$OMP PARALLEL DO PRIVATE (nc, bounds_clump)
       do nc = 1,nclumps
          call get_clump_bounds(nc, bounds_clump)
          !$acc enter data copyin(bounds_clump)  ! the private copy of this OpenMP loop: kernels read it
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before update_lnd2iac
#endif
          call lnd2iac_vars%update_lnd2iac(bounds_clump, lnd2atm_vars)
          !$acc exit data delete(bounds_clump)
       end do
       !$OMP END PARALLEL DO
       call t_stopf('lnd2iac')
    end if

    ! ============================================================================
    ! Write global average diagnostics to standard output
    ! ============================================================================

    nstep = get_nstep()
    if (wrtdia) call mpi_barrier(mpicom,ier)
    call t_startf('wrtdiag')
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before write_diagnostic
#endif
    call write_diagnostic(bounds_proc, wrtdia, nstep, lnd2atm_vars)
    call t_stopf('wrtdiag')

    ! ============================================================================
    ! Update accumulators
    ! ============================================================================

    ! FIX(SPM,032414) double check why this isn't called for ED

    if (nstep > 0) then

       call t_startf('accum')

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before updateaccvars
#endif
       call atm2lnd_vars%UpdateAccVars(bounds_proc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before updateaccvars
#endif
       call top_as%UpdateAccVars(bounds_proc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before updateaccvars
#endif
       call top_af%UpdateAccVars(bounds_proc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before updateaccvars
#endif
       call veg_es%UpdateAccVars(bounds_proc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before updateaccvars
#endif
       call canopystate_vars%UpdateAccVars(bounds_proc)

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before updateaccvars
#endif
       call energyflux_vars%UpdateAccVars(bounds_proc)

       if (crop_prog) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before updateaccvars
#endif
          call crop_vars%UpdateAccVars(bounds_proc, temperature_vars)
       end if

#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before updateaccvars
#endif
       call cnstate_vars%UpdateAccVars(bounds_proc)
       
       if(use_fates) then
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before updateaccvars
#endif
          call alm_fates%UpdateAccVars(bounds_proc)
       end if

       call t_stopf('accum')

    end if

    ! ============================================================================
    ! Update history buffer
    ! ============================================================================

    call t_startf('hbuf')
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before hist_update_hbuf
#endif
    call hist_update_hbuf(bounds_proc)
    call t_stopf('hbuf')

    ! ============================================================================
    ! Compute heat and water budgets (heat first, matching the coupler log)
    ! ============================================================================
    if (get_nstep()>0 .and. do_budgets) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before heatbudget_run
#endif
       ! spel targeted: device data this host code uses
       !$acc update self(atm2lnd_vars%forc_lwrad_not_downscaled_grc, grc_ef%heat_phase_corr, &
       !$acc&   grc_ef%heat_state_adj, grc_es%beg_hc, grc_es%beg_hc_lake, grc_es%beg_hc_soi, &
       !$acc&   grc_ws%beg_h2ocan, grc_ws%beg_h2osfc, grc_ws%beg_h2osno, grc_ws%beg_h2osoi_ice, &
       !$acc&   grc_ws%beg_h2osoi_liq, grc_ws%begwb, grc_ws%end_h2ocan, grc_ws%end_h2osfc, grc_ws%end_h2osno, &
       !$acc&   grc_ws%end_h2osoi_ice, grc_ws%end_h2osoi_liq, grc_ws%endwb, grc_ws%errh2o, &
       !$acc&   soilhydrology_vars%beg_wa_grc, &
       !$acc&   soilhydrology_vars%end_wa_grc) if_present if(.not. elm_device_fullsync)
       call HeatBudget_Run(bounds_proc, atm2lnd_vars, lnd2atm_vars)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before heatbudget_accum
#endif
       call HeatBudget_Accum()
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before heatbudget_print
#endif
       call HeatBudget_Print(budget_inst,  budget_daily,  budget_month,  &
            budget_ann,  budget_ltann,  budget_ltend)

#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before waterbudget_run
#endif
       call WaterBudget_Run(bounds_proc, atm2lnd_vars, lnd2atm_vars, &
            soilhydrology_vars)
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before waterbudget_accum
#endif
       call WaterBudget_Accum()
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before waterbudget_print
#endif
       call WaterBudget_Print(budget_inst,  budget_daily,  budget_month,  &
            budget_ann,  budget_ltann,  budget_ltend)

       if (use_cn .and. do_budgets) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before cnpbudget_run
#endif
          ! spel targeted: device data this host code uses
          !$acc update self(grc_cf%er, grc_cf%fire_closs, grc_cf%gpp, grc_cf%hrv_xsmrpool_to_atm, &
          !$acc&   grc_cf%prod100_loss, grc_cf%prod10_loss, grc_cf%prod1_loss, grc_cf%som_c_leached, &
          !$acc&   grc_cf%somc_yield, grc_cs%beg_cropseedc_deficit, grc_cs%beg_ctrunc, grc_cs%beg_cwdc, &
          !$acc&   grc_cs%beg_totc, grc_cs%beg_totlitc, grc_cs%beg_totpftc, grc_cs%beg_totprodc, &
          !$acc&   grc_cs%beg_totsomc, grc_cs%core%balance_err, grc_cs%end_cropseedc_deficit, &
          !$acc&   grc_cs%end_ctrunc, grc_cs%end_cwdc, grc_cs%end_totc, grc_cs%end_totlitc, &
          !$acc&   grc_cs%end_totpftc, grc_cs%end_totprodc, &
          !$acc&   grc_cs%end_totsomc) if_present if(.not. elm_device_fullsync)
          call CNPBudget_Run(bounds_proc, atm2lnd_vars, lnd2atm_vars, grc_cs, grc_cf)
#ifdef _OPENACC
    call elm_device_update(to_device=.true., line=__LINE__)  ! spel device-data: host -> device before cnpbudget_accum
#endif
          call CNPBudget_Accum()
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before cnpbudget_print
#endif
          ! spel targeted: device data this host code uses
          !$acc update self(c_budg_stateg) if_present if(.not. elm_device_fullsync)
          call CNPBudget_Print(budget_inst,  budget_daily,  budget_month,  &
               budget_ann,  budget_ltann,  budget_ltend)
          !$acc update device(c_budg_stateg) if_present if(.not. elm_device_fullsync)
      end if
    endif

    ! ============================================================================
    ! History/Restart output
    ! ============================================================================

    if (.not. use_noio) then

       call t_startf('elm_drv_io')

       ! Create history and write history tapes if appropriate
       call t_startf('elm_drv_io_htapes')

#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before hist_htapes_wrapup
#endif
       call hist_htapes_wrapup( rstwr, nlend, bounds_proc,                    &
            soilstate_vars%watsat_col(bounds_proc%begc:bounds_proc%endc, 1:), &
            soilstate_vars%sucsat_col(bounds_proc%begc:bounds_proc%endc, 1:), &
            soilstate_vars%bsw_col(bounds_proc%begc:bounds_proc%endc, 1:),    &
            soilstate_vars%hksat_col(bounds_proc%begc:bounds_proc%endc, 1:))

       call t_stopf('elm_drv_io_htapes')
       ! Write restart/initial files if appropriate
       if (rstwr) then
          call t_startf('elm_drv_io_wrest')
          filer = restFile_filename(rdate=rdate)

#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before restfile_write
#endif
          call elm_device_pull_all()  ! spel targeted: restart writes read the whole state
          call restFile_write( bounds_proc, filer,                          &
               atm2lnd_vars, aerosol_vars, canopystate_vars, cnstate_vars,  &
               ch4_vars, energyflux_vars, frictionvel_vars, lakestate_vars, &
               photosyns_vars, soilhydrology_vars,     &
               soilstate_vars, solarabs_vars, surfalb_vars,  &
               sedflux_vars, alm_fates, crop_vars, rdate=rdate )
         
         !----------------------------------------------
         ! pflotran (off now)
         ! if (use_pflotran) then
         !     call elm_pf_write_restart(rdate)
         ! end if
         !----------------------------------------------


          call t_stopf('elm_drv_io_wrest')
       end if
       call t_stopf('elm_drv_io')

    end if

    if (use_pflotran .and. nstep>=nestep) then
#ifdef _OPENACC
    call elm_device_update(to_device=.false., line=__LINE__)  ! spel device-data: device -> host before elm_pf_finalize
#endif
       call elm_pf_finalize()
    end if

#ifdef _OPENACC
    ! the code after elm_drv (lnd2atm, the coupler export, history and restart writes) works on
    ! the host: the state goes back there (no copy when it already is)
    call elm_device_update(to_device=.false., line=__LINE__)
    !$acc exit data delete(bounds_proc, bounds_clump)
#endif
  ! spel targeted: device data this host code uses
  !$acc update self(lnd2iac_vars%cdd, lnd2iac_vars%hdd) if_present if(.not. elm_device_fullsync)
  end subroutine elm_drv

  !-----------------------------------------------------------------------
  subroutine elm_drv_init(bounds, &
       num_nolakec, filter_nolakec, &
       num_nolakep, filter_nolakep, &
       num_soilp  , filter_soilp, &
       canopystate_vars,  energyflux_vars)
    !
    ! !DESCRIPTION:
    ! Initialization of clm driver variables needed from previous timestep
    !
    ! !USES:
    use shr_kind_mod       , only : r8 => shr_kind_r8
    use elm_varpar         , only : nlevsno
    use elm_varcon         , only : h2osno_max
    use landunit_varcon    , only : istice_mec
    use CanopyStateType    , only : canopystate_type
    use EnergyFluxType     , only : energyflux_type
    !
    ! !ARGUMENTS:
    type(bounds_type)     , intent(in)    :: bounds
    integer               , intent(in)    :: num_nolakec       ! number of non-lake points in column filter
    integer               , intent(in)    :: filter_nolakec(:) ! column filter for non-lake points
    integer               , intent(in)    :: num_nolakep       ! number of non-lake points in patch filter
    integer               , intent(in)    :: filter_nolakep(:) ! patch filter for non-lake points
    integer               , intent(in)    :: num_soilp         ! number of soil points in patch filter
    integer               , intent(in)    :: filter_soilp(:)   ! patch filter for soil points
    type(canopystate_type), intent(inout) :: canopystate_vars
    type(energyflux_type) , intent(inout) :: energyflux_vars
    !
    ! !LOCAL VARIABLES:
    integer :: l, c, p, f, j         ! indices
    integer :: fp, fc                  ! filter indices
    !-----------------------------------------------------------------------

    associate(                                                             &
         snl                => col_pp%snl                                   , & ! Input:  [integer  (:)   ]  number of snow layers

         h2osno             => col_ws%h2osno                , & ! Input:  [real(r8) (:)   ]  snow water (mm H2O)
         h2osoi_ice         => col_ws%h2osoi_ice            , & ! Input:  [real(r8) (:,:) ]  ice lens (kg/m2)
         h2osoi_liq         => col_ws%h2osoi_liq            , & ! Input:  [real(r8) (:,:) ]  liquid water (kg/m2)
         do_capsnow         => col_ws%do_capsnow            , & ! Output: [logical  (:)   ]  true => do snow capping
         h2osno_old         => col_ws%h2osno_old            , & ! Output: [real(r8) (:)   ]  snow water (mm H2O) at previous time step
         frac_iceold        => col_ws%frac_iceold           , & ! Output: [real(r8) (:,:) ]  fraction of ice relative to the tot water

         elai               => canopystate_vars%elai_patch               , & ! Input:  [real(r8) (:)   ]  one-sided leaf area index with burying by snow
         esai               => canopystate_vars%esai_patch               , & ! Input:  [real(r8) (:)   ]  one-sided stem area index with burying by snow
         frac_veg_nosno     => canopystate_vars%frac_veg_nosno_patch     , & ! Output: [integer  (:)   ]  fraction of vegetation not covered by snow (0 OR 1) [-]
         frac_veg_nosno_alb => canopystate_vars%frac_veg_nosno_alb_patch , & ! Output: [integer  (:)   ]  fraction of vegetation not covered by snow (0 OR 1) [-]

         qflx_glcice        => col_wf%qflx_glcice            , & ! Output: [real(r8) (:)   ]  flux of new glacier ice (mm H2O/s) [+ = ice grows]

         qflx_glcice_diag   => col_wf%qflx_glcice_diag       , & ! Output: [real(r8) (:)   ]  flux of new glacier ice (mm H2O/s) [+ = ice grows]

         eflx_bot           => col_ef%eflx_bot              , & ! Output: [real(r8) (:)   ]  heat flux from beneath soil/ice column (W/m**2)

         cisun_z            => photosyns_vars%cisun_z_patch              , & ! Output: [real(r8) (:)   ]  intracellular sunlit leaf CO2 (Pa)
         cisha_z            => photosyns_vars%cisha_z_patch                & ! Output: [real(r8) (:)   ]  intracellular shaded leaf CO2 (Pa)
         )

      ! Initialize intracellular CO2 (Pa) parameters each timestep for use in VOCEmission
      !$acc parallel loop gang vector default(present) if(elm_device_ready) copyin(bounds)
      do p = bounds%begp,bounds%endp
         cisun_z(p,:) = -999._r8
         cisha_z(p,:) = -999._r8
      end do

      !$acc parallel loop gang vector default(present) private(l) if(elm_device_ready) copyin(bounds)
      do c = bounds%begc,bounds%endc
         l = col_pp%landunit(c)

         ! Save snow mass at previous time step
         h2osno_old(c) = h2osno(c)

         if (.not. use_firn_percolation_and_compaction) then
            ! Decide whether to cap snow
            if (h2osno(c) > h2osno_max) then
               do_capsnow(c) = .true.
            else
               do_capsnow(c) = .false.
            end if
         ! else, snow capping subroutine in SnowHydrologyMod
         end if

         ! Reset flux from beneath soil/ice column
         eflx_bot(c)  = 0._r8

         ! Initialize qflx_glcice everywhere, to zero.
         qflx_glcice(c) = 0._r8
         qflx_glcice_diag(c) = 0._r8

      end do

      ! Initialize fraction of vegetation not covered by snow

      !$acc parallel loop gang vector default(present) if(elm_device_ready) copyin(bounds)
      do p = bounds%begp,bounds%endp
         if (veg_pp%active(p)) then
            frac_veg_nosno(p) = frac_veg_nosno_alb(p)
         else
            frac_veg_nosno(p) = 0._r8
         end if
      end do

      ! Initialize set of previous time-step variables
      ! Ice fraction of snow at previous time step

      !$acc parallel loop gang vector collapse(2) default(present) private(c) if(elm_device_ready) copyin(bounds)
      do j = -nlevsno+1,0
         do f = 1, num_nolakec
            c = filter_nolakec(f)
            if (j >= snl(c) + 1) then
               frac_iceold(c,j) = h2osoi_ice(c,j)/(h2osoi_liq(c,j)+h2osoi_ice(c,j))
            end if
         end do
      end do

    end associate

  end subroutine elm_drv_init

  !-----------------------------------------------------------------------
  subroutine elm_drv_patch2col (bounds, num_nolakec, filter_nolakec, &
         energyflux_vars )
    !
    ! !DESCRIPTION:
    ! Averages over all patchs for variables defined over both soil and lake
    ! to provide the column-level averages of state and flux variables
    ! defined at the patch level.
    !
    ! !USES:
    use EnergyFluxType , only : energyflux_type
    use subgridAveMod  , only : p2c
    !
    ! !ARGUMENTS:
    type(bounds_type)     , intent(in)    :: bounds
    integer               , intent(in)    :: num_nolakec       ! number of column non-lake points in column filter
    integer               , intent(in)    :: filter_nolakec(:) ! column filter for non-lake points
    type(energyflux_type) , intent(inout) :: energyflux_vars
    !
    ! !LOCAL VARIABLES:
    integer :: c,fc              ! indices
    integer :: num_allc          ! number of active column points
    integer :: filter_allc(bounds%endp-bounds%begp+1)    ! filter for all active column points
    ! -----------------------------------------------------------------
    associate( &
      h2ocan_patch       => veg_ws%h2ocan , &
      h2ocan_col         => col_ws%h2ocan , &
      qflx_ev_snow_patch => veg_wf%qflx_ev_snow , &
      qflx_ev_snow_col   => col_wf%qflx_ev_snow, &
      qflx_ev_soil_patch =>veg_wf%qflx_ev_soil ,&
      qflx_ev_soil_col   =>col_wf%qflx_ev_soil ,&
      qflx_ev_h2osfc_patch => veg_wf%qflx_ev_h2osfc , &
      qflx_ev_h2osfc_col   => col_wf%qflx_ev_h2osfc , &
      qflx_evap_soi_patch => veg_wf%qflx_evap_soi   , &
      qflx_evap_soi_col   => col_wf%qflx_evap_soi   , &
      qflx_evap_tot_patch => veg_wf%qflx_evap_tot   , &
      qflx_evap_tot_col   => col_wf%qflx_evap_tot   , &
      qflx_rain_grnd_patch => veg_wf%qflx_rain_grnd , &
      qflx_rain_grnd_col   => col_wf%qflx_rain_grnd , &
      qflx_snow_grnd_patch => veg_wf%qflx_snow_grnd , &
      qflx_snow_grnd_col   => col_wf%qflx_snow_grnd , &
      qflx_snwcp_liq_patch => veg_wf%qflx_snwcp_liq , &
      qflx_snwcp_liq_col   => col_wf%qflx_snwcp_liq , &
      qflx_snwcp_ice_patch => veg_wf%qflx_snwcp_ice , &
      qflx_snwcp_ice_col   => col_wf%qflx_snwcp_ice , &
      qflx_tran_veg_patch  => veg_wf%qflx_tran_veg  , &
      qflx_tran_veg_col    => col_wf%qflx_tran_veg  , &
      qflx_evap_grnd_patch => veg_wf%qflx_evap_grnd , &
      qflx_evap_grnd_col   => col_wf%qflx_evap_grnd , &
      qflx_prec_grnd_patch => veg_wf%qflx_prec_grnd , &
      qflx_prec_grnd_col   => col_wf%qflx_prec_grnd , &
      qflx_dew_grnd_patch  => veg_wf%qflx_dew_grnd  , &
      qflx_dew_grnd_col    => col_wf%qflx_dew_grnd  , &
      qflx_dirct_rain_patch => veg_wf%qflx_dirct_rain , &
      qflx_dirct_rain_col   => col_wf%qflx_dirct_rain , &
      qflx_leafdrip_patch   => veg_wf%qflx_leafdrip   , &
      qflx_leafdrip_col     => col_wf%qflx_leafdrip   , &
      qflx_sub_snow_patch   => veg_wf%qflx_sub_snow   , &
      qflx_sub_snow_col     => col_wf%qflx_sub_snow   , &
      qflx_dew_snow_patch   => veg_wf%qflx_dew_snow   , &
      qflx_dew_snow_col     => col_wf%qflx_dew_snow   , &
      qflx_irrig_patch     => veg_wf%qflx_irrig_patch , &
      qflx_irrig_col       => col_wf%qflx_irrig       , &
      qflx_evap_veg_patch  => veg_wf%qflx_evap_veg    , &
      qflx_evap_veg_col    => col_wf%qflx_evap_veg     &
      )
    ! Set up a filter for all active column points

    fc = 0
    do c = bounds%begc,bounds%endc
       if (col_pp%active(c)) then
          fc = fc + 1
          filter_allc(fc) = c
       end if
    end do
    num_allc = fc

    ! Note: lake points are excluded from many of the following
    ! averages. For some fields, this is because the field doesn't
    ! apply over lakes. However, for many others, this is because the
    ! field is computed in LakeHydrologyMod, which is called after
    ! this routine; thus, for lakes, the column-level values of these
    ! fields are explicitly set in LakeHydrologyMod. (The fields that
    ! are included here for lakes are computed elsewhere, e.g., in
    ! LakeFluxesMod.)

    ! Averaging for patch water state variables

    call p2c (bounds, num_nolakec, filter_nolakec, &
         h2ocan_patch(bounds%begp:bounds%endp), &
         h2ocan_col(bounds%begc:bounds%endc))

    ! Averaging for patch evaporative flux variables

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_ev_snow_patch(bounds%begp:bounds%endp), &
         qflx_ev_snow_col(bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_ev_soil_patch(bounds%begp:bounds%endp), &
         qflx_ev_soil_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_ev_h2osfc_patch(bounds%begp:bounds%endp), &
         qflx_ev_h2osfc_col  (bounds%begc:bounds%endc))

    ! Averaging for patch water flux variables

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_evap_soi_patch(bounds%begp:bounds%endp), &
         qflx_evap_soi_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_evap_tot_patch(bounds%begp:bounds%endp), &
         qflx_evap_tot_col(bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_rain_grnd_patch(bounds%begp:bounds%endp), &
         qflx_rain_grnd_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_snow_grnd_patch(bounds%begp:bounds%endp), &
         qflx_snow_grnd_col  (bounds%begc:bounds%endc))

    if (.not. use_firn_percolation_and_compaction) then
       !$acc data copy(filter_allc) if(elm_device_ready)
       call p2c (bounds, num_allc, filter_allc, &
            veg_wf%qflx_snwcp_liq(bounds%begp:bounds%endp), &
            col_wf%qflx_snwcp_liq(bounds%begc:bounds%endc))
            !TODO - WJS has suggested that at this point qflx_snwcp_liq_patch should
            ! now be set to nan in order to ensure that this variable is not used
            ! for the remainder of the timestep - other variables where this should
            ! occur in this routine should be examined as well

            ! For lakes, this field is initially set in LakeFluxesMod (which
            ! is called before this routine; hence it is appropriate to
            ! include lake columns in this p2c call.  However, it is later
            ! overwritten in LakeHydrologyMod, both on the patch and the column
            ! level.

       !$acc end data
       !$acc data copy(filter_allc) if(elm_device_ready)
       call p2c (bounds, num_allc, filter_allc, &
            veg_wf%qflx_snwcp_ice(bounds%begp:bounds%endp), &
            col_wf%qflx_snwcp_ice(bounds%begc:bounds%endc))
       !$acc end data
    end if

    !$acc data copy(filter_allc) if(elm_device_ready)
    call p2c (bounds, num_allc, filter_allc, &
         qflx_snwcp_liq_patch(bounds%begp:bounds%endp), &
         qflx_snwcp_liq_col  (bounds%begc:bounds%endc))

    !$acc end data
    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_tran_veg_patch(bounds%begp:bounds%endp), &
         qflx_tran_veg_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_evap_grnd_patch(bounds%begp:bounds%endp), &
         qflx_evap_grnd_col  (bounds%begc:bounds%endc))

    !$acc data copy(filter_allc) if(elm_device_ready)
    call p2c (bounds, num_allc, filter_allc, &
         qflx_evap_soi_patch(bounds%begp:bounds%endp), &
         qflx_evap_soi_col  (bounds%begc:bounds%endc))

    !$acc end data
    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_prec_grnd_patch(bounds%begp:bounds%endp), &
         qflx_prec_grnd_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_dew_grnd_patch(bounds%begp:bounds%endp), &
         qflx_dew_grnd_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_dirct_rain_patch(bounds%begp:bounds%endp), &
         qflx_dirct_rain_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_leafdrip_patch(bounds%begp:bounds%endp), &
         qflx_leafdrip_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_sub_snow_patch(bounds%begp:bounds%endp), &
         qflx_sub_snow_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_dew_snow_patch(bounds%begp:bounds%endp), &
         qflx_dew_snow_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_irrig_patch(bounds%begp:bounds%endp), &
         qflx_irrig_col  (bounds%begc:bounds%endc))

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_tran_veg_patch(bounds%begp:bounds%endp), &
         qflx_tran_veg_col  (bounds%begc:bounds%endc) )

    call p2c (bounds, num_nolakec, filter_nolakec, &
         qflx_evap_veg_patch(bounds%begp:bounds%endp), &
         qflx_evap_veg_col  (bounds%begc:bounds%endc))

    end associate

  end subroutine elm_drv_patch2col

  !------------------------------------------------------------------------
  subroutine write_diagnostic (bounds, wrtdia, nstep, lnd2atm_vars)
    !
    ! !DESCRIPTION:
    ! Write diagnostic surface temperature output each timestep.  Written to
    ! be fast but not bit-for-bit because order of summations can change each
    ! timestep.
    !
    ! !USES:
    use decompMod  , only : get_proc_global
    use spmdMod    , only : masterproc, npes, MPI_REAL8
    use spmdMod    , only : MPI_STATUS_SIZE, mpicom, MPI_SUM
    use shr_sys_mod, only : shr_sys_flush
    use abortutils , only : endrun
    use shr_log_mod, only : errMsg => shr_log_errMsg
    use lnd2atmType, only : lnd2atm_type
    !
    ! !ARGUMENTS:
    type(bounds_type)  , intent(in) :: bounds
    logical            , intent(in) :: wrtdia     !true => write diagnostic
    integer            , intent(in) :: nstep      !model time step
    type(lnd2atm_type) , intent(in) :: lnd2atm_vars
    !
    ! !REVISION HISTORY:
    ! Created by Mariana Vertenstein
    !
    ! !LOCAL VARIABLES:
    integer :: p                       ! loop index
    integer :: numg                    ! total number of gridcells across all processors
    integer :: ier                     ! error status
    real(r8):: psum                    ! partial sum of ts
    real(r8):: tsum                    ! sum of ts
    real(r8):: tsxyav                  ! average ts for diagnostic output
    integer :: status(MPI_STATUS_SIZE) ! mpi status
    character(len=256)   :: dateTimeString
    !------------------------------------------------------------------------

    call get_proc_global(ng=numg)

    if (wrtdia) then

       call t_barrierf('sync_write_diag', mpicom)
       psum = sum(lnd2atm_vars%t_rad_grc(bounds%begg:bounds%endg))
       call mpi_reduce(psum, tsum, 1, MPI_REAL8, MPI_SUM, 0, mpicom, ier)
       if (ier/=0) then
          write(iulog,*) 'write_diagnostic: Error in mpi_reduce()'
          call endrun(msg=errMsg(__FILE__, __LINE__))
       end if
       if (masterproc) then
          tsxyav = tsum / numg
          write(iulog,1000) nstep, tsxyav
          call shr_sys_flush(iulog)
       end if

    else

#ifndef CPL_BYPASS
       call get_curr_time_string(dateTimeString)
       if (masterproc) then
          write(iulog,*)'   Completed timestep: ',trim(dateTimeString)
          call shr_sys_flush(iulog)
       end if
#endif

    endif

1000 format (1x,'nstep = ',i10,'   TS = ',f21.15)

  end subroutine write_diagnostic

end module elm_driver
