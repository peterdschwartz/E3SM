module dynSubgridDriverMod

#include "shr_assert.h"

  !---------------------------------------------------------------------------
  !
  ! !DESCRIPTION:
  ! High-level routines for dynamic subgrid areas (prescribed transient Patches and
  ! dynamic landunits).
  !
  ! !USES:
  use elm_varctl, only : elm_device_ready  ! compute constructs run on the host before the device copy
  use shr_kind_mod           , only : r8 => shr_kind_r8
  use perf_mod                , only : t_startf, t_stopf
  use dynSubgridControlMod, only : get_flanduse_timeseries
  use dynSubgridControlMod, only : get_do_transient_pfts, get_do_transient_crops
  use dynSubgridControlMod, only : get_do_harvest
  use dynSubgridControlMod, only : set_subgrid_weights_updated
  use dynPriorWeightsMod  , only : prior_weights_type
  use dynPatchStateUpdaterMod      , only : patch_state_updater_type
  use dynColumnStateUpdaterMod     , only : column_state_updater_type
  use UrbanParamsType     , only : urbanparams_type
  use CanopyStateType     , only : canopystate_type
  use CNStateType         , only : cnstate_type
  use EnergyFluxType      , only : energyflux_type
  use LakeStateType       , only : lakestate_type
  use PhotosynthesisType  , only : photosyns_type
  use SoilHydrologyType   , only : soilhydrology_type
  use SoilStateType       , only : soilstate_type
  use glc2lndMod          , only : glc2lnd_type
  use iac2lndMod          , only : iac2lnd_type
  use dynLandunitAreaMod  , only : update_landunit_weights
  use CropType            , only : crop_type
  use dyncropFileMod      , only : dyncrop_init, dyncrop_interp, dyncrop_will_update
  use filterMod           , only : filter, filter_inactive_and_active

  use GridcellDataType    , only : gridcell_carbon_state, gridcell_carbon_flux
  use ColumnStateTypes, only : column_carbon_state
  use ColumnFluxTypes, only : column_carbon_flux
  use ColumnDataType      , only : col_ns, col_ps
  use VegetationStateTypes, only : vegetation_carbon_state
  use VegetationDataType, only : veg_ns, veg_ps

  use elm_varctl          , only : iac_present
  use shr_log_mod         , only : errMsg => shr_log_errMsg
  use decompMod           , only : bounds_type, BOUNDS_LEVEL_PROC
  use ColumnType          , only : col_pp
  use VegetationType      , only : veg_pp
  use elm_varctl          , only : iulog
  !
  ! !PUBLIC MEMBER FUNCTIONS:
  implicit none
  private
  save

  public :: dynSubgrid_init             ! initialize transient land cover
  public :: dynSubgrid_driver           ! top-level driver for transient land cover
  public :: dynSubgrid_wrapup_weight_changes ! reconcile various variables after subgrid weights change

  ! !PRIVATE MEMBER FUNCTIONS:
  private :: dyn_iac_init          ! init for iac instead of files
  private :: set_iac_veg_weights   ! calc veg_pp weights with iac

  !
  ! !PRIVATE TYPES:
  ! saved weights from before the subgrid weight updates
  type(prior_weights_type) :: prior_weights

  ! object used to update patch-level states after subgrid weight updates
  type(patch_state_updater_type), target :: patch_state_updater

  ! object used to update column-level states after subgrid weight updates
  type(column_state_updater_type), target :: column_state_updater
  !---------------------------------------------------------------------------

contains

  !-----------------------------------------------------------------------
  subroutine dynSubgrid_init(bounds, glc2lnd_vars, crop_vars)
    !
    ! !DESCRIPTION:
    ! Determine initial subgrid weights for prescribed transient Patches and/or
    ! dynamic landunits. Note that these weights will be overwritten in a restart run.
    !
    ! This should be called from initialization.
    !
    ! Note that dynpft_init / dynpft_interp need to be called from outside any loops over
    ! clumps - so this routine needs to be called from outside any loops over clumps.
    !
    ! !USES:
    use decompMod                , only : bounds_type, BOUNDS_LEVEL_PROC
    use decompMod                , only : get_proc_clumps, get_clump_bounds
    use dynpftFileMod            , only : dynpft_init
    use dynHarvestMod            , only : dynHarvest_init
    use dynpftFileMod            , only : dynpft_interp
    use elm_varctl               , only : fates_harvest_mode
    use dynFATESLandUseChangeMod , only : fates_harvest_hlmlanduse
    !
    ! !ARGUMENTS:
    type(bounds_type) , intent(in)    :: bounds  ! processor-level bounds
    type(glc2lnd_type), intent(inout) :: glc2lnd_vars
    type(crop_type)   , intent(inout) :: crop_vars
    !
    ! !LOCAL VARIABLES:
    integer           :: nclumps      ! number of clumps on this processor
    integer           :: nc           ! clump index
    type(bounds_type) :: bounds_clump ! clump-level bounds
    character(len=*), parameter :: subname = 'dynSubgrid_init'
    !-----------------------------------------------------------------------

    SHR_ASSERT(bounds%level == BOUNDS_LEVEL_PROC, subname // ': argument must be PROC-level bounds')

    nclumps = get_proc_clumps()

    prior_weights        = prior_weights_type(bounds)
    patch_state_updater  = patch_state_updater_type(bounds)
    column_state_updater = column_state_updater_type(bounds, nclumps)

    ! Initialize stuff for prescribed transient Patches
    if (get_do_transient_pfts()) then
       call dynpft_init(bounds, dynpft_filename=get_flanduse_timeseries())
    end if

    ! Initialize stuff for harvest (currently shares the flanduse_timeseries file)
    if (get_do_harvest() .or. fates_harvest_mode == fates_harvest_hlmlanduse) then
       call dynHarvest_init(bounds, harvest_filename=get_flanduse_timeseries())
    end if

    ! Initialize stuff for prescribed transient crops
    if (get_do_transient_crops()) then
       call dyncrop_init(bounds, dyncrop_filename=get_flanduse_timeseries())
    end if

    ! Initialize for iac instead of files
    if (iac_present) then
       call dyn_iac_init(bounds)
    end if

    ! ------------------------------------------------------------------------
    ! Set initial subgrid weights for aspects that are read from file. This is relevant
    ! for cold start and use_init_interp-based initialization.
    ! ------------------------------------------------------------------------

    if (get_do_transient_pfts()) then
       call dynpft_interp(bounds)
    end if

    if (get_do_transient_crops()) then
       call dyncrop_interp(bounds, crop_vars)
    end if

    !$OMP PARALLEL DO PRIVATE (nc, bounds_clump)
    do nc = 1, nclumps
       call get_clump_bounds(nc, bounds_clump)
       call dynSubgrid_wrapup_weight_changes(bounds_clump, glc2lnd_vars)
    end do
    !$OMP END PARALLEL DO

  end subroutine dynSubgrid_init

  !-----------------------------------------------------------------------
  subroutine dynSubgrid_driver(bounds_proc, &
       urbanparams_vars, soilstate_vars, soilhydrology_vars, lakestate_vars, &
       energyflux_vars, canopystate_vars, photosyns_vars, cnstate_vars, &
       veg_cs, c13_veg_cs, c14_veg_cs, &
       col_cs, c13_col_cs, c14_col_cs, col_cf, &
       grc_cs, grc_cf, glc2lnd_vars, crop_vars, iac2lnd_vars)
    !
    ! !DESCRIPTION:
    ! Update subgrid weights for prescribed transient Patches and/or dynamic
    ! landunits. Also do related adjustments (water & energy, carbon & nitrogen).
    !
    ! This should be called every time step in CLM's run loop.
    !
    ! Note that this routine operates partly at the proc-level (outside an OMP region),
    ! and partly at the clump level (inside OMP regions). Thus, this must be called from
    ! OUTSIDE any loops over clumps in the driver.
    !
    ! !USES:
    use elm_varctl           , only : use_cn, create_glacier_mec_landunit, iac_present
    use elm_varctl           , only : use_fates, use_fates_luh, fates_harvest_mode
    use elm_varctl           , only : use_fates_potentialveg
    use decompMod            , only : bounds_type, get_proc_clumps, get_clump_bounds
    use decompMod            , only : BOUNDS_LEVEL_PROC
    use dynInitColumnsMod    , only : initialize_new_columns
    use dynConsBiogeophysMod , only : dyn_hwcontent_init, dyn_hwcontent_final
    use dynConsBiogeochemMod , only : dyn_cnbal_patch, dyn_cnbal_column
    use dynpftFileMod        , only : dynpft_interp
    use dynHarvestMod        , only : dynHarvest_interp_harvest_types

    use dynFATESLandUseChangeMod, only : dynFatesLandUseInterp
    use dynFATESLandUseChangeMod , only : fates_harvest_hlmlanduse

    use dynEDMod             , only : dyn_ED
    use reweightMod          , only : reweight_wrapup
    use subgridWeightsMod    , only : compute_higher_order_weights, set_subgrid_diagnostic_fields
    use CarbonStateUpdate1Mod   , only : CarbonStateUpdateDynPatch
    use NitrogenStateUpdate1Mod   , only : NitrogenStateUpdateDynPatch
    use PhosphorusStateUpdate1Mod , only : PhosphorusStateUpdateDynPatch
    use dynPatchStateUpdaterMod   , only : set_old_patch_weights, set_new_patch_weights
    use dynColumnStateUpdaterMod  , only : set_old_column_weights, set_new_column_weights
    use dynPriorWeightsMod        , only : set_prior_weights
    use elm_time_manager , only : get_step_size, is_first_step, is_first_restart_step
    use elm_varctl, only :  iulog
    use columndatatype, only : c13_col_cf, c14_col_cf, col_es, col_nf, col_pf, col_ws  ! spel acc-sync
    use gridcelldatatype, only : c13_grc_cf, c14_grc_cf, grc_nf, grc_pf  ! spel acc-sync
    use vegetationdatatype, only : c13_veg_cf, c14_veg_cf, veg_cf, veg_nf, veg_pf  ! spel acc-sync
    use landunittype, only : lun_pp  ! spel acc-sync
    use pftvarcon, only : is_pft_known_to_model  ! spel acc-sync
    use subgridweightsmod, only : subgrid_weights_diagnostics  ! spel acc-sync

    !
    ! !ARGUMENTS:
    type(bounds_type)        , intent(in)    :: bounds_proc  ! processor-level bounds
    type(urbanparams_type)   , intent(in)    :: urbanparams_vars
    type(soilstate_type)     , intent(in)    :: soilstate_vars
    type(soilhydrology_type) , intent(inout) :: soilhydrology_vars
    type(lakestate_type)     , intent(in)    :: lakestate_vars
    type(energyflux_type)    , intent(inout) :: energyflux_vars
    type(canopystate_type)   , intent(inout) :: canopystate_vars
    type(photosyns_type)     , intent(inout) :: photosyns_vars
    type(cnstate_type)       , intent(inout) :: cnstate_vars
    type(vegetation_carbon_state), intent(inout) :: veg_cs
    type(vegetation_carbon_state), intent(inout) :: c13_veg_cs
    type(vegetation_carbon_state), intent(inout) :: c14_veg_cs
    type(column_carbon_state)    , intent(inout) :: col_cs
    type(column_carbon_state)    , intent(inout) :: c13_col_cs
    type(column_carbon_state)    , intent(inout) :: c14_col_cs
    type(column_carbon_flux)     , intent(inout) :: col_cf
    type(gridcell_carbon_state)  , intent(inout) :: grc_cs
    type(gridcell_carbon_flux)   , intent(inout) :: grc_cf
    type(glc2lnd_type)       , intent(inout) :: glc2lnd_vars

    type(crop_type)          , intent(inout) :: crop_vars

    type(iac2lnd_type)       , intent(inout) :: iac2lnd_vars

    !
    ! !LOCAL VARIABLES:
    integer           :: nclumps      ! number of clumps on this processor
    integer           :: nc           ! clump index
    type(bounds_type) :: bounds_clump ! clump-level bounds
    real(r8)          :: dt
    logical           :: weights_updated ! some provider may have changed subgrid weights this step
    logical           :: crop_updated    ! new annual crop data were applied this step
    character(len=*), parameter :: subname = 'dynSubgrid_driver'
    !-----------------------------------------------------------------------

    SHR_ASSERT(bounds_proc%level == BOUNDS_LEVEL_PROC, subname // ': argument must be PROC-level bounds')

    nclumps = get_proc_clumps()
    dt = real(get_step_size(), r8)

    ! Subgrid weights can change in this step only if one of these providers is
    ! active: transient natural PFTs (interpolated every step), FATES, coupled
    ! glacier or IAC areas, or new annual crop data (checked below). On the first
    ! step of a run or restart, always do the full update.
    weights_updated = get_do_transient_pfts() .or. use_fates .or. use_fates_luh .or. &
         create_glacier_mec_landunit .or. iac_present .or. &
         is_first_step() .or. is_first_restart_step()
    ! Annual crop data: dyncrop_interp below reports the same through crop_updated, but the
    ! weight bookkeeping in the first clump loop must know it before the weights change.
    if (get_do_transient_crops()) weights_updated = weights_updated .or. dyncrop_will_update()
    ! ==========================================================================
    ! Do initialization, prior to land cover change
    ! ==========================================================================

    !$OMP PARALLEL DO PRIVATE (nc, bounds_clump)
    do nc = 1, nclumps
       call get_clump_bounds(nc, bounds_clump)

       call t_startf('dyn_hwcontent_init')
       !$acc update device(bounds_clump%begc, bounds_clump%begc_all, bounds_clump%begc_ghost, &
       !$acc&   bounds_clump%begcohort, bounds_clump%begg, bounds_clump%begg_all, bounds_clump%begg_ghost, &
       !$acc&   bounds_clump%begl, bounds_clump%begl_all, bounds_clump%begl_ghost, bounds_clump%begp, &
       !$acc&   bounds_clump%begp_all, bounds_clump%begp_ghost, bounds_clump%begt, bounds_clump%begt_all, &
       !$acc&   bounds_clump%begt_ghost, bounds_clump%clump_index, bounds_clump%endc, bounds_clump%endc_all, &
       !$acc&   bounds_clump%endc_ghost, bounds_clump%endcohort, bounds_clump%endg, bounds_clump%endg_all, &
       !$acc&   bounds_clump%endg_ghost, bounds_clump%endl, bounds_clump%endl_all, bounds_clump%endl_ghost, &
       !$acc&   bounds_clump%endp, bounds_clump%endp_all, bounds_clump%endp_ghost, bounds_clump%endt, &
       !$acc&   bounds_clump%endt_all, bounds_clump%endt_ghost, bounds_clump%level) if_present
       call dyn_hwcontent_init(bounds_clump, &
            filter(nc)%num_nolakec, filter(nc)%nolakec, &
            filter(nc)%num_lakec, filter(nc)%lakec, &
            urbanparams_vars, soilstate_vars, soilhydrology_vars, lakestate_vars, &
            energyflux_vars)
       !$acc update self(col_pp%wtgcell, veg_pp%wtgcell) if_present if(elm_device_ready)
       call t_stopf('dyn_hwcontent_init')

       ! The old weights, the prior active flags and the natural-veg template columns are
       ! read only by the weight-change path below (any_changes, initialize_new_columns, the
       ! C/N/P conservation): nothing to record when no weight changes this step.
       if (weights_updated) then
          call t_startf('dyn_prior_weights')
          call set_prior_weights(prior_weights, bounds_clump)
          call set_old_patch_weights  (patch_state_updater,bounds_clump)
          call set_old_column_weights (column_state_updater,bounds_clump)
          call t_stopf('dyn_prior_weights')
          !$acc update device(column_state_updater%cwtgcell_old, column_state_updater%natveg_template_col, &
          !$acc&   patch_state_updater%cwtgcell_old, patch_state_updater%pwtgcell_old, prior_weights%cactive, &
          !$acc&   prior_weights%pwtcol) if_present
       end if
    end do
    !$OMP END PARALLEL DO

    ! ==========================================================================
    ! Do land cover change that requires I/O, and thus must be outside a threaded region
    ! ==========================================================================

    if (get_do_transient_pfts()) then
       call dynpft_interp(bounds_proc)
       !$acc update device(veg_pp%wtcol) if_present
    end if

    if (get_do_transient_crops()) then
       call dyncrop_interp(bounds_proc,crop_vars, data_updated=crop_updated)
       weights_updated = weights_updated .or. crop_updated
       !$acc update device(col_pp%wtlunit, crop_vars%fertnitro_patch, crop_vars%fertphosp_patch, &
       !$acc&   is_pft_known_to_model, lun_pp%wttopounit) if_present
    end if
    call set_subgrid_weights_updated(weights_updated)

    if (get_do_harvest() .or. fates_harvest_mode == fates_harvest_hlmlanduse) then
       call dynHarvest_interp_harvest_types(bounds_proc)
    end if

    if (use_fates_luh .and. .not. use_fates_potentialveg) then
       call dynFatesLandUseInterp(bounds_proc)
    end if

    ! pft and harvest come from iac when active
    ! The above namelist values are false in this case
    !       may want to ensure this with namelist checks

    if (iac_present) then
       call iac2lnd_vars%update_iac2lnd(bounds_proc)
    end if

    ! ==========================================================================
    ! Do everything else related to land cover change
    ! ==========================================================================

    !$OMP PARALLEL DO PRIVATE (nc, bounds_clump)
    do nc = 1, nclumps
       call get_clump_bounds(nc, bounds_clump)
       !$acc update device(bounds_clump%begc, bounds_clump%begc_all, bounds_clump%begc_ghost, &
       !$acc&   bounds_clump%begcohort, bounds_clump%begg, bounds_clump%begg_all, bounds_clump%begg_ghost, &
       !$acc&   bounds_clump%begl, bounds_clump%begl_all, bounds_clump%begl_ghost, bounds_clump%begp, &
       !$acc&   bounds_clump%begp_all, bounds_clump%begp_ghost, bounds_clump%begt, bounds_clump%begt_all, &
       !$acc&   bounds_clump%begt_ghost, bounds_clump%clump_index, bounds_clump%endc, bounds_clump%endc_all, &
       !$acc&   bounds_clump%endc_ghost, bounds_clump%endcohort, bounds_clump%endg, bounds_clump%endg_all, &
       !$acc&   bounds_clump%endg_ghost, bounds_clump%endl, bounds_clump%endl_all, bounds_clump%endl_ghost, &
       !$acc&   bounds_clump%endp, bounds_clump%endp_all, bounds_clump%endp_ghost, bounds_clump%endt, &
       !$acc&   bounds_clump%endt_all, bounds_clump%endt_ghost, bounds_clump%level) if_present

       if (use_fates) then
          call dyn_ED(bounds_clump)
       end if

       if (create_glacier_mec_landunit) then
          call glc2lnd_vars%update_glc2lnd(bounds_clump)
       end if
       !if (create_glacier_mec_landunit) then
      !    call glc2lnd_vars_update_glc2lnd_acc(glc2lnd_vars ,bounds_clump)
       !end if

       ! Everything following this point in this loop only needs to be called if we have
       ! actually changed some weights in this time step. This is also required in the
       ! first time step of the run to update filters to reflect state of CISM
       ! (particularly mask that is past through coupler).

       ! When no weights changed, the weight reconciliation, the diagnostic fields,
       ! the initialization of new columns and the C, N and P conservation updates
       ! below have nothing to do: every patch and column keeps its weight, so all
       ! dwt fluxes are zero (and stay as set by ZeroDWT) and no state changes.
       if (weights_updated) then
          call t_startf('dyn_wrapup_weights')
          call dynSubgrid_wrapup_weight_changes(bounds_clump, glc2lnd_vars)
          call t_stopf('dyn_wrapup_weights')
       end if
       ! New weights and the per-patch/column change records: read only under weights_updated
       ! below (dyn_cnbal_patch/column); without a change they would equal the old ones.
       if (weights_updated) then
          !$acc update self(col_pp%wtgcell, veg_pp%wtgcell) if_present if(elm_device_ready)
          call set_new_patch_weights (patch_state_updater ,bounds_clump)
          call set_new_column_weights(column_state_updater,bounds_clump, nc)
          !$acc update device(column_state_updater%any_changes, column_state_updater%area_gained_col, &
          !$acc&   column_state_updater%cwtgcell_new, patch_state_updater%dwt, &
          !$acc&   patch_state_updater%growing_new_fraction, patch_state_updater%growing_old_fraction, &
          !$acc&   patch_state_updater%pwtgcell_new) if_present
       end if


       if (weights_updated) then
          ! spel acc-sync: device data this host code uses
          !$acc update self(col_es%t_soisno, col_ws%h2osoi_ice, col_ws%h2osoi_liq, col_ws%h2osoi_vol, &
          !$acc&   soilhydrology_vars%wa_col) if_present if(elm_device_ready)
          call t_startf('dyn_diagnostic_fields')
          call set_subgrid_diagnostic_fields(bounds_clump)
          !$acc update self(col_es%t_soisno, col_pp%wtgcell, col_ws%h2osoi_ice, col_ws%h2osoi_liq, &
          !$acc&   col_ws%h2osoi_vol, soilhydrology_vars%wa_col) if_present if(elm_device_ready)
          call t_stopf('dyn_diagnostic_fields')

          call t_startf('dyn_init_new_columns')
          call initialize_new_columns(bounds_clump, &
               prior_weights%cactive(bounds_clump%begc:bounds_clump%endc), soilhydrology_vars )
          call t_stopf('dyn_init_new_columns')
          !$acc update device(col_es%t_soisno, col_ws%h2osoi_ice, col_ws%h2osoi_liq, col_ws%h2osoi_vol, &
          !$acc&   soilhydrology_vars%wa_col, subgrid_weights_diagnostics%pct_cft, &
          !$acc&   subgrid_weights_diagnostics%pct_glc_mec, subgrid_weights_diagnostics%pct_landunit, &
          !$acc&   subgrid_weights_diagnostics%pct_nat_pft) if_present
       end if


       call t_startf('dyn_hwcontent_final')
       call dyn_hwcontent_final(bounds_clump, &
            filter(nc)%num_nolakec, filter(nc)%nolakec, &
            filter(nc)%num_lakec, filter(nc)%lakec, &
            urbanparams_vars, soilstate_vars, soilhydrology_vars, lakestate_vars, &
            energyflux_vars, dt)
       call t_stopf('dyn_hwcontent_final')

       if (use_cn .and. weights_updated) then
          ! spel acc-sync: device data this host code uses
          !$acc update self(c13_col_cf%core%dwt_conv_flux, c13_col_cf%core%dwt_crop_product_gain, &
          !$acc&   c13_col_cf%core%dwt_deadcroot_to_cwd, c13_col_cf%core%dwt_froot_to_litr_cel, &
          !$acc&   c13_col_cf%core%dwt_froot_to_litr_lig, c13_col_cf%core%dwt_froot_to_litr_met, &
          !$acc&   c13_col_cf%core%dwt_livecroot_to_cwd, c13_col_cf%core%dwt_prod100_gain, &
          !$acc&   c13_col_cf%core%dwt_prod10_gain, c13_col_cf%core%dwt_slash_flux, &
          !$acc&   c13_grc_cf%core%dwt_conv_flux, c13_grc_cf%core%dwt_prod100_gain, &
          !$acc&   c13_grc_cf%core%dwt_prod10_gain, c13_grc_cf%core%dwt_seed_to_deadstem, &
          !$acc&   c13_grc_cf%core%dwt_seed_to_leaf, c13_veg_cs%core%cropseed_deficit, &
          !$acc&   c13_veg_cs%core%deadcroot, c13_veg_cs%core%deadcroot_storage, &
          !$acc&   c13_veg_cs%core%deadcroot_xfer, c13_veg_cs%core%deadstem, &
          !$acc&   c13_veg_cs%core%deadstem_storage, c13_veg_cs%core%deadstem_xfer, c13_veg_cs%core%dispveg, &
          !$acc&   c13_veg_cs%core%froot, c13_veg_cs%core%froot_storage, c13_veg_cs%core%froot_xfer, &
          !$acc&   c13_veg_cs%core%grain, c13_veg_cs%core%grain_storage, c13_veg_cs%core%grain_xfer, &
          !$acc&   c13_veg_cs%core%leaf, c13_veg_cs%core%leaf_storage, c13_veg_cs%core%leaf_xfer, &
          !$acc&   c13_veg_cs%core%livecroot, c13_veg_cs%core%livecroot_storage, &
          !$acc&   c13_veg_cs%core%livecroot_xfer, c13_veg_cs%core%livestem, &
          !$acc&   c13_veg_cs%core%livestem_storage, c13_veg_cs%core%livestem_xfer, c13_veg_cs%core%pool, &
          !$acc&   c13_veg_cs%core%storveg, c13_veg_cs%core%totpft, c13_veg_cs%core%totveg, &
          !$acc&   c13_veg_cs%core%trunc_sink, c13_veg_cs%gresp_storage, c13_veg_cs%gresp_xfer, &
          !$acc&   c13_veg_cs%xsmrpool, c14_col_cf%core%dwt_conv_flux, c14_col_cf%core%dwt_crop_product_gain, &
          !$acc&   c14_col_cf%core%dwt_deadcroot_to_cwd, c14_col_cf%core%dwt_froot_to_litr_cel, &
          !$acc&   c14_col_cf%core%dwt_froot_to_litr_lig, c14_col_cf%core%dwt_froot_to_litr_met, &
          !$acc&   c14_col_cf%core%dwt_livecroot_to_cwd, c14_col_cf%core%dwt_prod100_gain, &
          !$acc&   c14_col_cf%core%dwt_prod10_gain, c14_col_cf%core%dwt_slash_flux, &
          !$acc&   c14_grc_cf%core%dwt_conv_flux, c14_grc_cf%core%dwt_prod100_gain, &
          !$acc&   c14_grc_cf%core%dwt_prod10_gain, c14_grc_cf%core%dwt_seed_to_deadstem, &
          !$acc&   c14_grc_cf%core%dwt_seed_to_leaf, c14_veg_cs%core%cropseed_deficit, &
          !$acc&   c14_veg_cs%core%deadcroot, c14_veg_cs%core%deadcroot_storage, &
          !$acc&   c14_veg_cs%core%deadcroot_xfer, c14_veg_cs%core%deadstem, &
          !$acc&   c14_veg_cs%core%deadstem_storage, c14_veg_cs%core%deadstem_xfer, c14_veg_cs%core%dispveg, &
          !$acc&   c14_veg_cs%core%froot, c14_veg_cs%core%froot_storage, c14_veg_cs%core%froot_xfer, &
          !$acc&   c14_veg_cs%core%grain, c14_veg_cs%core%grain_storage, c14_veg_cs%core%grain_xfer, &
          !$acc&   c14_veg_cs%core%leaf, c14_veg_cs%core%leaf_storage, c14_veg_cs%core%leaf_xfer, &
          !$acc&   c14_veg_cs%core%livecroot, c14_veg_cs%core%livecroot_storage, &
          !$acc&   c14_veg_cs%core%livecroot_xfer, c14_veg_cs%core%livestem, &
          !$acc&   c14_veg_cs%core%livestem_storage, c14_veg_cs%core%livestem_xfer, c14_veg_cs%core%pool, &
          !$acc&   c14_veg_cs%core%storveg, c14_veg_cs%core%totpft, c14_veg_cs%core%totveg, &
          !$acc&   c14_veg_cs%core%trunc_sink, c14_veg_cs%gresp_storage, c14_veg_cs%gresp_xfer, &
          !$acc&   c14_veg_cs%xsmrpool, canopystate_vars%laisha_patch, canopystate_vars%laisun_patch, &
          !$acc&   cnstate_vars%annavg_t2m_col, cnstate_vars%annavg_t2m_patch, &
          !$acc&   cnstate_vars%annmax_retransn_patch, cnstate_vars%annmax_retransp_patch, &
          !$acc&   cnstate_vars%annsum_potential_gpp_patch, cnstate_vars%bglfr_froot_patch, &
          !$acc&   cnstate_vars%bglfr_leaf_patch, cnstate_vars%bgtr_patch, cnstate_vars%c_allometry_patch, &
          !$acc&   cnstate_vars%croot_prof_patch, cnstate_vars%days_active_patch, &
          !$acc&   cnstate_vars%dormant_flag_patch, cnstate_vars%downreg_patch, &
          !$acc&   cnstate_vars%froot_prof_patch, cnstate_vars%lgsf_patch, cnstate_vars%n_allometry_patch, &
          !$acc&   cnstate_vars%offset_counter_patch, cnstate_vars%offset_fdd_patch, &
          !$acc&   cnstate_vars%offset_flag_patch, cnstate_vars%offset_swi_patch, &
          !$acc&   cnstate_vars%onset_counter_patch, cnstate_vars%onset_fdd_patch, &
          !$acc&   cnstate_vars%onset_flag_patch, cnstate_vars%onset_gdd_patch, &
          !$acc&   cnstate_vars%onset_gddflag_patch, cnstate_vars%onset_swi_patch, &
          !$acc&   cnstate_vars%p_allometry_patch, cnstate_vars%rc14_atm_patch, &
          !$acc&   cnstate_vars%tempavg_t2m_patch, cnstate_vars%tempmax_retransn_patch, &
          !$acc&   cnstate_vars%tempmax_retransp_patch, cnstate_vars%tempsum_potential_gpp_patch, &
          !$acc&   col_cf%core%dwt_conv_flux, col_cf%core%dwt_crop_product_gain, &
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
          !$acc&   grc_cf%core%dwt_seed_to_deadstem, grc_cf%core%dwt_seed_to_leaf, grc_nf%core%dwt_conv_flux, &
          !$acc&   grc_nf%core%dwt_prod100_gain, grc_nf%core%dwt_prod10_gain, &
          !$acc&   grc_nf%core%dwt_seed_to_deadstem, grc_nf%core%dwt_seed_to_leaf, grc_nf%dwt_seedn_to_npool, &
          !$acc&   grc_pf%core%dwt_conv_flux, grc_pf%core%dwt_prod100_gain, grc_pf%core%dwt_prod10_gain, &
          !$acc&   grc_pf%core%dwt_seed_to_deadstem, grc_pf%core%dwt_seed_to_leaf, grc_pf%dwt_seedp_to_ppool, &
          !$acc&   photosyns_vars%alphapsnsha_patch, photosyns_vars%alphapsnsun_patch, &
          !$acc&   photosyns_vars%c13_psnsha_patch, photosyns_vars%c13_psnsun_patch, &
          !$acc&   photosyns_vars%c14_psnsha_patch, photosyns_vars%c14_psnsun_patch, &
          !$acc&   photosyns_vars%psnsha_patch, photosyns_vars%psnsun_patch, &
          !$acc&   photosyns_vars%rc13_canair_patch, photosyns_vars%rc13_psnsha_patch, &
          !$acc&   photosyns_vars%rc13_psnsun_patch, veg_cf%annsum_npp, veg_cf%availc, &
          !$acc&   veg_cf%core%plant_alloc, veg_cf%core%prev_froot_to_litter, &
          !$acc&   veg_cf%core%prev_leaf_to_litter, veg_cf%excess_cflux, veg_cf%gpp_before_downreg, &
          !$acc&   veg_cf%tempsum_npp, veg_cf%xsmrpool_recover, veg_cs%core%cropseed_deficit, &
          !$acc&   veg_cs%core%deadcroot, veg_cs%core%deadcroot_storage, veg_cs%core%deadcroot_xfer, &
          !$acc&   veg_cs%core%deadstem, veg_cs%core%deadstem_storage, veg_cs%core%deadstem_xfer, &
          !$acc&   veg_cs%core%dispveg, veg_cs%core%froot, veg_cs%core%froot_storage, veg_cs%core%froot_xfer, &
          !$acc&   veg_cs%core%grain, veg_cs%core%grain_storage, veg_cs%core%grain_xfer, veg_cs%core%leaf, &
          !$acc&   veg_cs%core%leaf_storage, veg_cs%core%leaf_xfer, veg_cs%core%livecroot, &
          !$acc&   veg_cs%core%livecroot_storage, veg_cs%core%livecroot_xfer, veg_cs%core%livestem, &
          !$acc&   veg_cs%core%livestem_storage, veg_cs%core%livestem_xfer, veg_cs%core%pool, &
          !$acc&   veg_cs%core%storveg, veg_cs%core%totpft, veg_cs%core%totveg, veg_cs%core%trunc_sink, &
          !$acc&   veg_cs%gresp_storage, veg_cs%gresp_xfer, veg_cs%xsmrpool, veg_nf%core%plant_alloc, &
          !$acc&   veg_nf%retrans%avail_retrans, veg_nf%uptake%plant_demand, veg_ns%core%cropseed_deficit, &
          !$acc&   veg_ns%core%deadcroot, veg_ns%core%deadcroot_storage, veg_ns%core%deadcroot_xfer, &
          !$acc&   veg_ns%core%deadstem, veg_ns%core%deadstem_storage, veg_ns%core%deadstem_xfer, &
          !$acc&   veg_ns%core%dispveg, veg_ns%core%froot, veg_ns%core%froot_storage, veg_ns%core%froot_xfer, &
          !$acc&   veg_ns%core%grain, veg_ns%core%grain_storage, veg_ns%core%grain_xfer, veg_ns%core%leaf, &
          !$acc&   veg_ns%core%leaf_storage, veg_ns%core%leaf_xfer, veg_ns%core%livecroot, &
          !$acc&   veg_ns%core%livecroot_storage, veg_ns%core%livecroot_xfer, veg_ns%core%livestem, &
          !$acc&   veg_ns%core%livestem_storage, veg_ns%core%livestem_xfer, veg_ns%core%pool, &
          !$acc&   veg_ns%core%storveg, veg_ns%core%totpft, veg_ns%core%totveg, veg_ns%core%trunc_sink, &
          !$acc&   veg_ns%retrans%pool, veg_pf%core%plant_alloc, veg_pf%retrans%avail_retrans, &
          !$acc&   veg_pf%uptake%plant_demand, veg_ps%core%cropseed_deficit, veg_ps%core%deadcroot, &
          !$acc&   veg_ps%core%deadcroot_storage, veg_ps%core%deadcroot_xfer, veg_ps%core%deadstem, &
          !$acc&   veg_ps%core%deadstem_storage, veg_ps%core%deadstem_xfer, veg_ps%core%dispveg, &
          !$acc&   veg_ps%core%froot, veg_ps%core%froot_storage, veg_ps%core%froot_xfer, veg_ps%core%grain, &
          !$acc&   veg_ps%core%grain_storage, veg_ps%core%grain_xfer, veg_ps%core%leaf, &
          !$acc&   veg_ps%core%leaf_storage, veg_ps%core%leaf_xfer, veg_ps%core%livecroot, &
          !$acc&   veg_ps%core%livecroot_storage, veg_ps%core%livecroot_xfer, veg_ps%core%livestem, &
          !$acc&   veg_ps%core%livestem_storage, veg_ps%core%livestem_xfer, veg_ps%core%pool, &
          !$acc&   veg_ps%core%storveg, veg_ps%core%totpft, veg_ps%core%totveg, veg_ps%core%trunc_sink, &
          !$acc&   veg_ps%retrans%pool) if_present if(elm_device_ready)
          call t_startf('dyn_cnbal_patch')
          call dyn_cnbal_patch(bounds_clump, &
               filter_inactive_and_active(nc)%num_soilp, filter_inactive_and_active(nc)%soilp, &
               filter_inactive_and_active(nc)%num_soilc, filter_inactive_and_active(nc)%soilc, &
               prior_weights, &
               patch_state_updater, &
               canopystate_vars, photosyns_vars, cnstate_vars, &
               veg_cs, c13_veg_cs, c14_veg_cs, &
               veg_ns, veg_ps, dt)
          call t_stopf('dyn_cnbal_patch')

          ! Transfer root/seed litter C/N/P to decomposer pools
          call t_startf('dyn_CNPStateUpdateDynPatch')
          !$acc update device(c13_col_cf%core%dwt_conv_flux, c13_col_cf%core%dwt_crop_product_gain, &
          !$acc&   c13_col_cf%core%dwt_deadcroot_to_cwd, c13_col_cf%core%dwt_froot_to_litr_cel, &
          !$acc&   c13_col_cf%core%dwt_froot_to_litr_lig, c13_col_cf%core%dwt_froot_to_litr_met, &
          !$acc&   c13_col_cf%core%dwt_livecroot_to_cwd, c13_col_cf%core%dwt_prod100_gain, &
          !$acc&   c13_col_cf%core%dwt_prod10_gain, c13_col_cf%core%dwt_slash_flux, &
          !$acc&   c13_grc_cf%core%dwt_conv_flux, c13_grc_cf%core%dwt_prod100_gain, &
          !$acc&   c13_grc_cf%core%dwt_prod10_gain, c13_grc_cf%core%dwt_seed_to_deadstem, &
          !$acc&   c13_grc_cf%core%dwt_seed_to_leaf, c13_veg_cf%core%dwt_conv_flux, &
          !$acc&   c13_veg_cf%core%dwt_crop_product_gain, c13_veg_cf%core%dwt_prod100_gain, &
          !$acc&   c13_veg_cf%core%dwt_prod10_gain, c13_veg_cf%core%dwt_seed_to_deadstem, &
          !$acc&   c13_veg_cf%core%dwt_seed_to_leaf, c13_veg_cs%core%cropseed_deficit, &
          !$acc&   c13_veg_cs%core%deadcroot, c13_veg_cs%core%deadcroot_storage, &
          !$acc&   c13_veg_cs%core%deadcroot_xfer, c13_veg_cs%core%deadstem, &
          !$acc&   c13_veg_cs%core%deadstem_storage, c13_veg_cs%core%deadstem_xfer, c13_veg_cs%core%dispveg, &
          !$acc&   c13_veg_cs%core%froot, c13_veg_cs%core%froot_storage, c13_veg_cs%core%froot_xfer, &
          !$acc&   c13_veg_cs%core%grain, c13_veg_cs%core%grain_storage, c13_veg_cs%core%grain_xfer, &
          !$acc&   c13_veg_cs%core%leaf, c13_veg_cs%core%leaf_storage, c13_veg_cs%core%leaf_xfer, &
          !$acc&   c13_veg_cs%core%livecroot, c13_veg_cs%core%livecroot_storage, &
          !$acc&   c13_veg_cs%core%livecroot_xfer, c13_veg_cs%core%livestem, &
          !$acc&   c13_veg_cs%core%livestem_storage, c13_veg_cs%core%livestem_xfer, c13_veg_cs%core%pool, &
          !$acc&   c13_veg_cs%core%storveg, c13_veg_cs%core%totpft, c13_veg_cs%core%totveg, &
          !$acc&   c13_veg_cs%core%trunc_sink, c13_veg_cs%gresp_storage, c13_veg_cs%gresp_xfer, &
          !$acc&   c13_veg_cs%xsmrpool, c14_col_cf%core%dwt_conv_flux, c14_col_cf%core%dwt_crop_product_gain, &
          !$acc&   c14_col_cf%core%dwt_deadcroot_to_cwd, c14_col_cf%core%dwt_froot_to_litr_cel, &
          !$acc&   c14_col_cf%core%dwt_froot_to_litr_lig, c14_col_cf%core%dwt_froot_to_litr_met, &
          !$acc&   c14_col_cf%core%dwt_livecroot_to_cwd, c14_col_cf%core%dwt_prod100_gain, &
          !$acc&   c14_col_cf%core%dwt_prod10_gain, c14_col_cf%core%dwt_slash_flux, &
          !$acc&   c14_grc_cf%core%dwt_conv_flux, c14_grc_cf%core%dwt_prod100_gain, &
          !$acc&   c14_grc_cf%core%dwt_prod10_gain, c14_grc_cf%core%dwt_seed_to_deadstem, &
          !$acc&   c14_grc_cf%core%dwt_seed_to_leaf, c14_veg_cf%core%dwt_conv_flux, &
          !$acc&   c14_veg_cf%core%dwt_crop_product_gain, c14_veg_cf%core%dwt_prod100_gain, &
          !$acc&   c14_veg_cf%core%dwt_prod10_gain, c14_veg_cf%core%dwt_seed_to_deadstem, &
          !$acc&   c14_veg_cf%core%dwt_seed_to_leaf, c14_veg_cs%core%cropseed_deficit, &
          !$acc&   c14_veg_cs%core%deadcroot, c14_veg_cs%core%deadcroot_storage, &
          !$acc&   c14_veg_cs%core%deadcroot_xfer, c14_veg_cs%core%deadstem, &
          !$acc&   c14_veg_cs%core%deadstem_storage, c14_veg_cs%core%deadstem_xfer, c14_veg_cs%core%dispveg, &
          !$acc&   c14_veg_cs%core%froot, c14_veg_cs%core%froot_storage, c14_veg_cs%core%froot_xfer, &
          !$acc&   c14_veg_cs%core%grain, c14_veg_cs%core%grain_storage, c14_veg_cs%core%grain_xfer, &
          !$acc&   c14_veg_cs%core%leaf, c14_veg_cs%core%leaf_storage, c14_veg_cs%core%leaf_xfer, &
          !$acc&   c14_veg_cs%core%livecroot, c14_veg_cs%core%livecroot_storage, &
          !$acc&   c14_veg_cs%core%livecroot_xfer, c14_veg_cs%core%livestem, &
          !$acc&   c14_veg_cs%core%livestem_storage, c14_veg_cs%core%livestem_xfer, c14_veg_cs%core%pool, &
          !$acc&   c14_veg_cs%core%storveg, c14_veg_cs%core%totpft, c14_veg_cs%core%totveg, &
          !$acc&   c14_veg_cs%core%trunc_sink, c14_veg_cs%gresp_storage, c14_veg_cs%gresp_xfer, &
          !$acc&   c14_veg_cs%xsmrpool, canopystate_vars%laisha_patch, canopystate_vars%laisun_patch, &
          !$acc&   cnstate_vars%alloc_pnow_patch, cnstate_vars%annavg_t2m_patch, &
          !$acc&   cnstate_vars%annmax_retransn_patch, cnstate_vars%annmax_retransp_patch, &
          !$acc&   cnstate_vars%annsum_potential_gpp_patch, cnstate_vars%bglfr_froot_patch, &
          !$acc&   cnstate_vars%bglfr_leaf_patch, cnstate_vars%bglfr_patch, cnstate_vars%bgtr_patch, &
          !$acc&   cnstate_vars%c_allometry_patch, cnstate_vars%days_active_patch, &
          !$acc&   cnstate_vars%dormant_flag_patch, cnstate_vars%downreg_patch, cnstate_vars%lfpftd_patch, &
          !$acc&   cnstate_vars%lgsf_patch, cnstate_vars%n_allometry_patch, &
          !$acc&   cnstate_vars%offset_counter_patch, cnstate_vars%offset_fdd_patch, &
          !$acc&   cnstate_vars%offset_flag_patch, cnstate_vars%offset_swi_patch, &
          !$acc&   cnstate_vars%onset_counter_patch, cnstate_vars%onset_fdd_patch, &
          !$acc&   cnstate_vars%onset_flag_patch, cnstate_vars%onset_gdd_patch, &
          !$acc&   cnstate_vars%onset_gddflag_patch, cnstate_vars%onset_swi_patch, &
          !$acc&   cnstate_vars%p_allometry_patch, cnstate_vars%rc14_atm_patch, &
          !$acc&   cnstate_vars%tempavg_t2m_patch, cnstate_vars%tempmax_retransn_patch, &
          !$acc&   cnstate_vars%tempmax_retransp_patch, cnstate_vars%tempsum_potential_gpp_patch, &
          !$acc&   col_cf%core%dwt_conv_flux, col_cf%core%dwt_crop_product_gain, &
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
          !$acc&   grc_cf%core%dwt_seed_to_deadstem, grc_cf%core%dwt_seed_to_leaf, grc_nf%core%dwt_conv_flux, &
          !$acc&   grc_nf%core%dwt_prod100_gain, grc_nf%core%dwt_prod10_gain, &
          !$acc&   grc_nf%core%dwt_seed_to_deadstem, grc_nf%core%dwt_seed_to_leaf, grc_nf%dwt_seedn_to_npool, &
          !$acc&   grc_pf%core%dwt_conv_flux, grc_pf%core%dwt_prod100_gain, grc_pf%core%dwt_prod10_gain, &
          !$acc&   grc_pf%core%dwt_seed_to_deadstem, grc_pf%core%dwt_seed_to_leaf, grc_pf%dwt_seedp_to_ppool, &
          !$acc&   photosyns_vars%alphapsnsha_patch, photosyns_vars%alphapsnsun_patch, &
          !$acc&   photosyns_vars%c13_psnsha_patch, photosyns_vars%c13_psnsun_patch, &
          !$acc&   photosyns_vars%c14_psnsha_patch, photosyns_vars%c14_psnsun_patch, &
          !$acc&   photosyns_vars%psnsha_patch, photosyns_vars%psnsun_patch, &
          !$acc&   photosyns_vars%rc13_canair_patch, photosyns_vars%rc13_psnsha_patch, &
          !$acc&   photosyns_vars%rc13_psnsun_patch, veg_cf%annsum_npp, veg_cf%availc, &
          !$acc&   veg_cf%core%dwt_conv_flux, veg_cf%core%dwt_crop_product_gain, &
          !$acc&   veg_cf%core%dwt_prod100_gain, veg_cf%core%dwt_prod10_gain, &
          !$acc&   veg_cf%core%dwt_seed_to_deadstem, veg_cf%core%dwt_seed_to_leaf, veg_cf%core%plant_alloc, &
          !$acc&   veg_cf%core%prev_froot_to_litter, veg_cf%core%prev_leaf_to_litter, veg_cf%excess_cflux, &
          !$acc&   veg_cf%gpp_before_downreg, veg_cf%tempsum_npp, veg_cf%xsmrpool_c13ratio, &
          !$acc&   veg_cf%xsmrpool_recover, veg_cs%core%cropseed_deficit, veg_cs%core%deadcroot, &
          !$acc&   veg_cs%core%deadcroot_storage, veg_cs%core%deadcroot_xfer, veg_cs%core%deadstem, &
          !$acc&   veg_cs%core%deadstem_storage, veg_cs%core%deadstem_xfer, veg_cs%core%dispveg, &
          !$acc&   veg_cs%core%froot, veg_cs%core%froot_storage, veg_cs%core%froot_xfer, veg_cs%core%grain, &
          !$acc&   veg_cs%core%grain_storage, veg_cs%core%grain_xfer, veg_cs%core%leaf, &
          !$acc&   veg_cs%core%leaf_storage, veg_cs%core%leaf_xfer, veg_cs%core%livecroot, &
          !$acc&   veg_cs%core%livecroot_storage, veg_cs%core%livecroot_xfer, veg_cs%core%livestem, &
          !$acc&   veg_cs%core%livestem_storage, veg_cs%core%livestem_xfer, veg_cs%core%pool, &
          !$acc&   veg_cs%core%storveg, veg_cs%core%totpft, veg_cs%core%totveg, veg_cs%core%trunc_sink, &
          !$acc&   veg_cs%gresp_storage, veg_cs%gresp_xfer, veg_cs%xsmrpool, veg_nf%core%dwt_conv_flux, &
          !$acc&   veg_nf%core%dwt_crop_product_gain, veg_nf%core%dwt_prod100_gain, &
          !$acc&   veg_nf%core%dwt_prod10_gain, veg_nf%core%dwt_seed_to_deadstem, &
          !$acc&   veg_nf%core%dwt_seed_to_leaf, veg_nf%core%plant_alloc, veg_nf%dwt_seedn_to_npool, &
          !$acc&   veg_nf%retrans%avail_retrans, veg_nf%uptake%plant_demand, veg_ns%core%cropseed_deficit, &
          !$acc&   veg_ns%core%deadcroot, veg_ns%core%deadcroot_storage, veg_ns%core%deadcroot_xfer, &
          !$acc&   veg_ns%core%deadstem, veg_ns%core%deadstem_storage, veg_ns%core%deadstem_xfer, &
          !$acc&   veg_ns%core%dispveg, veg_ns%core%froot, veg_ns%core%froot_storage, veg_ns%core%froot_xfer, &
          !$acc&   veg_ns%core%grain, veg_ns%core%grain_storage, veg_ns%core%grain_xfer, veg_ns%core%leaf, &
          !$acc&   veg_ns%core%leaf_storage, veg_ns%core%leaf_xfer, veg_ns%core%livecroot, &
          !$acc&   veg_ns%core%livecroot_storage, veg_ns%core%livecroot_xfer, veg_ns%core%livestem, &
          !$acc&   veg_ns%core%livestem_storage, veg_ns%core%livestem_xfer, veg_ns%core%pool, &
          !$acc&   veg_ns%core%storveg, veg_ns%core%totpft, veg_ns%core%totveg, veg_ns%core%trunc_sink, &
          !$acc&   veg_ns%retrans%pool, veg_pf%core%dwt_conv_flux, veg_pf%core%dwt_crop_product_gain, &
          !$acc&   veg_pf%core%dwt_prod100_gain, veg_pf%core%dwt_prod10_gain, &
          !$acc&   veg_pf%core%dwt_seed_to_deadstem, veg_pf%core%dwt_seed_to_leaf, veg_pf%core%plant_alloc, &
          !$acc&   veg_pf%dwt_seedp_to_ppool, veg_pf%retrans%avail_retrans, veg_pf%uptake%plant_demand, &
          !$acc&   veg_ps%core%cropseed_deficit, veg_ps%core%deadcroot, veg_ps%core%deadcroot_storage, &
          !$acc&   veg_ps%core%deadcroot_xfer, veg_ps%core%deadstem, veg_ps%core%deadstem_storage, &
          !$acc&   veg_ps%core%deadstem_xfer, veg_ps%core%dispveg, veg_ps%core%froot, &
          !$acc&   veg_ps%core%froot_storage, veg_ps%core%froot_xfer, veg_ps%core%grain, &
          !$acc&   veg_ps%core%grain_storage, veg_ps%core%grain_xfer, veg_ps%core%leaf, &
          !$acc&   veg_ps%core%leaf_storage, veg_ps%core%leaf_xfer, veg_ps%core%livecroot, &
          !$acc&   veg_ps%core%livecroot_storage, veg_ps%core%livecroot_xfer, veg_ps%core%livestem, &
          !$acc&   veg_ps%core%livestem_storage, veg_ps%core%livestem_xfer, veg_ps%core%pool, &
          !$acc&   veg_ps%core%storveg, veg_ps%core%totpft, veg_ps%core%totveg, veg_ps%core%trunc_sink, &
          !$acc&   veg_ps%retrans%pool) if_present
          call CarbonStateUpdateDynPatch(bounds_clump, &
               filter_inactive_and_active(nc)%num_soilc, filter_inactive_and_active(nc)%soilc,dt)

          call NitrogenStateUpdateDynPatch(bounds_clump, &
               filter_inactive_and_active(nc)%num_soilc, filter_inactive_and_active(nc)%soilc,dt)

          call PhosphorusStateUpdateDynPatch(bounds_clump, &
               filter_inactive_and_active(nc)%num_soilc, filter_inactive_and_active(nc)%soilc,dt)
          call t_stopf('dyn_CNPStateUpdateDynPatch')

       end if

       if((use_cn .or. use_fates) .and. weights_updated)then
          call t_startf('dyn_cnbal_column')
          call dyn_cnbal_column(bounds_clump, nc, column_state_updater, &
               col_cs, c13_col_cs, c14_col_cs, &
               col_ns, col_ps )
          call t_stopf('dyn_cnbal_column')
       end if

    end do
    !$OMP END PARALLEL DO

  end subroutine dynSubgrid_driver

  !-----------------------------------------------------------------------
  subroutine dynSubgrid_wrapup_weight_changes(bounds_clump, glc2lnd_vars)
    !
    ! !DESCRIPTION:
    ! Reconcile various variables after subgrid weights change
    ! !USES:
    use decompMod         , only : bounds_type
    use subgridWeightsMod , only : compute_higher_order_weights
    use reweightMod       , only : reweight_wrapup
    use decompMod         , only : BOUNDS_LEVEL_CLUMP
    !
    ! !ARGUMENTS:
    type(bounds_type)  , intent(in)    :: bounds_clump ! clump-level bounds
    type(glc2lnd_type) , intent(inout) :: glc2lnd_vars
    !
    ! !LOCAL VARIABLES:

    character(len=*), parameter :: subname = 'dynSubgrid_wrapup_weight_changes'
    !-----------------------------------------------------------------------
    associate( &
      icemask_grc => glc2lnd_vars%icemask_grc &
      )
    !SHR_ASSERT(bounds_clump%level == BOUNDS_LEVEL_CLUMP, subname // ': argument must be CLUMP-level bounds')

    call update_landunit_weights(bounds_clump)

    call compute_higher_order_weights(bounds_clump)

    if (iac_present) then
       ! make sure weights are all in order before applying the new pft wts
       ! this is because the active elements need to be correct
       call reweight_wrapup(bounds_clump, &
            glc2lnd_vars%icemask_grc(bounds_clump%begg:bounds_clump%endg))
       call set_iac_veg_weights(bounds_clump)
    end if

    ! Here: filters are re-made
    !
    ! This call requires clump-level bounds, which is why we need to ensure that the
    ! argument to this routine is clump-level bounds
    call reweight_wrapup(bounds_clump, icemask_grc(bounds_clump%begg:bounds_clump%endg))

    end associate
  end subroutine dynSubgrid_wrapup_weight_changes

 !-----------------------------------------------------------------------
  subroutine dyn_iac_init(bounds)
    !
    ! !DESCRIPTION:
    ! Initialize data structures for harvest information and check pft #s
    ! Copies initial weights into iac weight array
    ! This should be called once, during model initialization.
    ! !USES:
    use dynHarvestMod   , only : harvest_rates, num_harvest_vars
    use dynHarvestMod   , only : do_cn_harvest
    use elm_varpar     , only : numpft, maxpatch_pft
    use abortutils          , only : endrun
    !
    ! !ARGUMENTS:
    type(bounds_type), intent(in) :: bounds           ! proc-level bounds
    !
    ! !LOCAL VARIABLES:
    integer :: ier        ! error code
    integer :: p

    character(len=*), parameter :: subname = 'dyn_iac_init'
  !-----------------------------------------------------------------------

    SHR_ASSERT_ALL(bounds%level == BOUNDS_LEVEL_PROC, subname // ': argument must be PROC-level bounds')

    ! We need to allocate if do_harvest = .false., because then
    ! dynHarvest_ini() has not been called but we still need
    ! harvest_rates.  Should we switch on do_harvest == .false.?
    if (.not. get_do_harvest()) then
       allocate(harvest_rates(num_harvest_vars,bounds%begg:bounds%endg),stat=ier)
       if (ier /= 0) then
          call endrun(msg=' allocation error for harvest: '//errMsg(__FILE__, &
                          __LINE__))
       end if

       harvest_rates(:,:) = 0._r8
    end if

    if ( maxpatch_pft /= numpft+1 ) then
       call endrun(msg=' maxpatch_pft does NOT equal numpft+1'// &
                   ' -- this is invalid for dynamic PFT case'// &
                   'for dynamic PFT case: '// &
                   errMsg(__FILE__, __LINE__) )
    end if

    ! set the cn harveset flag
    do_cn_harvest = .true.

    ! fill the iac weights with initial values
    ! so that dynsubgrid_wrapup_weight_changes works in init
    do p = bounds%begp, bounds%endp
       veg_pp%wtgcell_iac(p) = veg_pp%wtgcell(p)
    end do

  end subroutine dyn_iac_init

  !-----------------------------------------------------------------------
  subroutine set_iac_veg_weights(bounds)
    !
    ! !DESCRIPTION:
    ! Set veg_pp weights from veg_pp%wtgcell_iac
    ! The wtcol value sums need to be normalized to 1
    ! This is called after all other weights have been updated,
    !    and before checks, if the iac is active
    !
    ! !USES:
    !
    ! !ARGUMENTS:
    implicit none
    type(bounds_type), intent(in) :: bounds  ! clump bounds
    !
    ! !LOCAL VARIABLES:
    integer :: p, c, l, t, g      ! indices for pft, col, lu, topo, gcell
    real(r8), allocatable :: sumwtcol(:), sumwtlunit(:), sumwttopounit(:), &
                             sumwtgcell(:)
    character(len=*), parameter :: subname = 'set_iac_veg_weights'
    logical :: weights_equal_1
    real(r8), parameter :: tolerance = 1.e-12_r8  ! tolerance for weight sums
  !-----------------------------------------------------------------------

    integer :: spel_i1  ! spel section-loop indices
    ! spel acc-sync: device data this host code uses
    !$acc update self(sumwtcol) if_present if(elm_device_ready)
    allocate(sumwtcol(bounds%begc:bounds%endc))
    !$acc update device(sumwtcol) if_present
    !$acc data copy(sumwtcol) if(elm_device_ready)
    !$acc parallel loop gang vector default(present) copyin(bounds) if(elm_device_ready)
    do spel_i1 = bounds%begc, bounds%endc  ! spel section-loop
       sumwtcol(spel_i1) = 0._r8
    end do
    ! spel acc-sync: device data this host code uses
    !$acc update self(sumwtlunit) if_present if(elm_device_ready)
    !$acc end data
    allocate(sumwtlunit(bounds%begl:bounds%endl))
    !$acc update device(sumwtlunit) if_present
    !$acc data copy(sumwtlunit) if(elm_device_ready)
    !$acc parallel loop gang vector default(present) copyin(bounds) if(elm_device_ready)
    do spel_i1 = bounds%begl, bounds%endl  ! spel section-loop
       sumwtlunit(spel_i1) = 0._r8
    end do
    ! spel acc-sync: device data this host code uses
    !$acc update self(sumwttopounit) if_present if(elm_device_ready)
    !$acc end data
    allocate(sumwttopounit(bounds%begt:bounds%endt))
    !$acc update device(sumwttopounit) if_present
    !$acc data copy(sumwttopounit) if(elm_device_ready)
    !$acc parallel loop gang vector default(present) copyin(bounds) if(elm_device_ready)
    do spel_i1 = bounds%begt, bounds%endt  ! spel section-loop
       sumwttopounit(spel_i1) = 0._r8
    end do
    ! spel acc-sync: device data this host code uses
    !$acc update self(sumwtgcell) if_present if(elm_device_ready)
    !$acc end data
    allocate(sumwtgcell(bounds%begg:bounds%endg))
    !$acc update device(sumwtgcell) if_present
    !$acc data copy(sumwtgcell) if(elm_device_ready)
    !$acc parallel loop gang vector default(present) copyin(bounds) if(elm_device_ready)
    do spel_i1 = bounds%begg, bounds%endg  ! spel section-loop
       sumwtgcell(spel_i1) = 0._r8
    end do
    !$acc end data

    ! First calc the wtcol and sum the values
    ! fill bare pft value if col wtgcell is zero
    ! calculate the higher order wts
    ! spel acc-sync: device data this host code uses
    !$acc update self(sumwtcol, sumwtgcell, sumwtlunit, sumwttopounit, &
    !$acc&   veg_pp%wtgcell_iac) if_present if(elm_device_ready)
    !$acc update self(col_pp%wtgcell, col_pp%wttopounit, sumwtcol, sumwtgcell, sumwtlunit, sumwttopounit, &
    !$acc&   veg_pp%wtgcell, veg_pp%wtgcell_iac, veg_pp%wtlunit, veg_pp%wttopounit) if_present if(elm_device_ready)
    do p = bounds%begp, bounds%endp
       c = veg_pp%column(p)
       l = veg_pp%landunit(p)
       t = veg_pp%topounit(p)
       g = veg_pp%gridcell(p)
       if (col_pp%wtgcell(c) .eq. 0._r8) then
          if (veg_pp%itype(p) .eq. 0) then
             veg_pp%wtcol(p) = 1._r8
          else
             veg_pp%wtcol(p) = 0._r8
          end if
       else
          veg_pp%wtcol(p) = veg_pp%wtgcell_iac(p) / col_pp%wtgcell(c)
       end if
       veg_pp%wtlunit(p)    = veg_pp%wtcol(p) * col_pp%wtlunit(c)
       veg_pp%wttopounit(p) = veg_pp%wtcol(p) * col_pp%wttopounit(c)
       veg_pp%wtgcell(p)    = veg_pp%wtcol(p) * col_pp%wtgcell(c)
       ! get the sums for normalizing below
       sumwtcol(c) = sumwtcol(c) + veg_pp%wtcol(p)
    end do

    ! Normalize the wtcol if necessary and recalc higher order weights
    do c = bounds%begc,bounds%endc
       weights_equal_1 = (abs(sumwtcol(c) - 1._r8) <= tolerance)
       if (.not.weights_equal_1) then
          do p = bounds%begp, bounds%endp
             if (veg_pp%column(p) .eq. c) then
                if (sumwtcol(c) .eq. 0._r8) then
                   write(iulog,*) subname//'setting wtcol to zero'// &
                                  'for p, c, l, g ', p,c,l,g
                   veg_pp%wtcol(p) = 0._r8
                else
                   veg_pp%wtcol(p) = veg_pp%wtcol(p) / sumwtcol(c)
                end if
                veg_pp%wtlunit(p)    = veg_pp%wtcol(p) * col_pp%wtlunit(c)
                veg_pp%wttopounit(p) = veg_pp%wtcol(p) * col_pp%wttopounit(c)
                veg_pp%wtgcell(p)    = veg_pp%wtcol(p) * col_pp%wtgcell(c)
             end if
          end do
       end if
    end do

    ! Normalize the wtlunit if necessary and recalc higher order weights

    ! Normalize the wttopounit if necessary and recalc higher order weights

    ! Normalize the wtgcell if necessary and recalc higher order weights

    deallocate(sumwtcol)
    deallocate(sumwtlunit)
    deallocate(sumwttopounit)
    deallocate(sumwtgcell)
    !$acc update device(sumwtcol, sumwtgcell, sumwtlunit, sumwttopounit, veg_pp%wtcol, veg_pp%wtgcell, &
    !$acc&   veg_pp%wtlunit, veg_pp%wttopounit) if_present

  endsubroutine set_iac_veg_weights

end module dynSubgridDriverMod
