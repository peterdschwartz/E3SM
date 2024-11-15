module DeepCopyColumnMod
  use columntype,only: column_physical_properties
  use columndatatype,only: column_energy_state
  use columndatatype,only: column_water_state
  use columndatatype,only: column_carbon_state
  use columndatatype,only: column_phosphorus_flux
  use columndatatype,only: column_nitrogen_state
  use columndatatype,only: column_phosphorus_state
  use columndatatype,only: column_energy_flux
  use columndatatype,only: column_water_flux
  use columndatatype,only: column_carbon_flux
  use columndatatype,only: column_nitrogen_flux
  implicit none
  public :: deepcopy_column_physical_properties
  public :: deepcopy_column_energy_state
  public :: deepcopy_column_water_state
  public :: deepcopy_column_carbon_state
  public :: deepcopy_column_phosphorus_flux
  public :: deepcopy_column_nitrogen_state
  public :: deepcopy_column_phosphorus_state
  public :: deepcopy_column_energy_flux
  public :: deepcopy_column_water_flux
  public :: deepcopy_column_carbon_flux
  public :: deepcopy_column_nitrogen_flux

  public :: deepcopy_column_types
contains

  subroutine deepcopy_column_types(col_pp, col_es, col_ef,col_ws,&
                                  col_wf, col_cs,col_cf,col_ps,&
                                  col_pf,col_ns,col_nf)
    type(column_physical_properties), intent(inout) :: col_pp
    type(column_energy_state), intent(inout) :: col_es
    type(column_energy_flux), intent(inout) :: col_ef
    type(column_water_state), intent(inout) :: col_ws
    type(column_water_flux), intent(inout) :: col_wf
    type(column_carbon_state), intent(inout) :: col_cs
    type(column_carbon_flux), intent(inout) :: col_cf
    type(column_phosphorus_state), intent(inout) :: col_ps
    type(column_phosphorus_flux), intent(inout) :: col_pf
    type(column_nitrogen_state), intent(inout) :: col_ns
    type(column_nitrogen_flux), intent(inout) :: col_nf

    call deepcopy_column_physical_properties(col_pp)
    call deepcopy_column_energy_state(col_es)
    call deepcopy_column_energy_flux(col_ef)
    call deepcopy_column_water_state(col_ws)
    call deepcopy_column_water_flux(col_wf)
    call deepcopy_column_carbon_state(col_cs)
    call deepcopy_column_carbon_flux(col_cf)
    call deepcopy_column_phosphorus_state(col_ps)
    call deepcopy_column_phosphorus_flux(col_pf)
    call deepcopy_column_nitrogen_state(col_ns)
    call deepcopy_column_nitrogen_flux(col_nf)

  end subroutine deepcopy_column_types

  subroutine deepcopy_column_physical_properties(this_type)
    type(column_physical_properties), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%gridcell(:),&
    !$acc& this_type%wtgcell(:),&
    !$acc& this_type%topounit(:),&
    !$acc& this_type%wttopounit(:),&
    !$acc& this_type%landunit(:),&
    !$acc& this_type%wtlunit(:),&
    !$acc& this_type%pfti(:),&
    !$acc& this_type%pftf(:),&
    !$acc& this_type%npfts(:),&
    !$acc& this_type%itype(:),&
    !$acc& this_type%active(:),&
    !$acc& this_type%snl(:),&
    !$acc& this_type%dz(:,:),&
    !$acc& this_type%z(:,:),&
    !$acc& this_type%zi(:,:),&
    !$acc& this_type%zii(:),&
    !$acc& this_type%lakedepth(:),&
    !$acc& this_type%dz_lake(:,:),&
    !$acc& this_type%z_lake(:,:),&
    !$acc& this_type%glc_topo(:),&
    !$acc& this_type%micro_sigma(:),&
    !$acc& this_type%n_melt(:),&
    !$acc& this_type%topo_slope(:),&
    !$acc& this_type%topo_std(:),&
    !$acc& this_type%hslp_p10(:,:),&
    !$acc& this_type%nlevbed(:),&
    !$acc& this_type%zibed(:),&
    !$acc& this_type%hydrologically_active(:),&
    !$acc& this_type%is_fates(:))
  end subroutine deepcopy_column_physical_properties
  subroutine deepcopy_column_energy_state(this_type)
    type(column_energy_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%t_soisno(:,:),&
    !$acc& this_type%t_ssbef(:,:),&
    !$acc& this_type%t_h2osfc(:),&
    !$acc& this_type%t_h2osfc_bef(:),&
    !$acc& this_type%t_soi10cm(:),&
    !$acc& this_type%t_soi17cm(:),&
    !$acc& this_type%t_grnd(:),&
    !$acc& this_type%t_lake(:,:),&
    !$acc& this_type%t_grnd_r(:),&
    !$acc& this_type%t_grnd_u(:),&
    !$acc& this_type%snot_top(:),&
    !$acc& this_type%dtdz_top(:),&
    !$acc& this_type%thv(:),&
    !$acc& this_type%hc_soi(:),&
    !$acc& this_type%hc_soisno(:),&
    !$acc& this_type%emg(:),&
    !$acc& this_type%fact(:,:),&
    !$acc& this_type%c_h2osfc(:),&
    !$acc& this_type%t_nearsurf(:))
  end subroutine deepcopy_column_energy_state
  subroutine deepcopy_column_water_state(this_type)
    type(column_water_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%h2osoi_liq(:,:),&
    !$acc& this_type%h2osoi_ice(:,:),&
    !$acc& this_type%h2osoi_vol(:,:),&
    !$acc& this_type%h2osfc(:),&
    !$acc& this_type%h2ocan(:),&
    !$acc& this_type%wslake_col(:),&
    !$acc& this_type%total_plant_stored_h2o(:),&
    !$acc& this_type%h2osoi_liqvol(:,:),&
    !$acc& this_type%h2osoi_icevol(:,:),&
    !$acc& this_type%h2osoi_liq_old(:,:),&
    !$acc& this_type%h2osoi_ice_old(:,:),&
    !$acc& this_type%bw(:,:),&
    !$acc& this_type%smp_l(:,:),&
    !$acc& this_type%soilp(:,:),&
    !$acc& this_type%swe_old(:,:),&
    !$acc& this_type%snw_rds(:,:),&
    !$acc& this_type%air_vol(:,:),&
    !$acc& this_type%qg_snow(:),&
    !$acc& this_type%qg_soil(:),&
    !$acc& this_type%qg_h2osfc(:),&
    !$acc& this_type%qg(:),&
    !$acc& this_type%dqgdt(:),&
    !$acc& this_type%h2osoi_liqice_10cm(:),&
    !$acc& this_type%h2osno(:),&
    !$acc& this_type%h2osno_old(:),&
    !$acc& this_type%h2osno_top(:),&
    !$acc& this_type%sno_liq_top(:),&
    !$acc& this_type%snowice(:),&
    !$acc& this_type%snowliq(:),&
    !$acc& this_type%int_snow(:),&
    !$acc& this_type%snow_depth(:),&
    !$acc& this_type%snowdp(:),&
    !$acc& this_type%snow_persistence(:),&
    !$acc& this_type%snw_rds_top(:),&
    !$acc& this_type%do_capsnow(:),&
    !$acc& this_type%frac_sno(:),&
    !$acc& this_type%frac_sno_eff(:),&
    !$acc& this_type%frac_iceold(:,:),&
    !$acc& this_type%frac_h2osfc(:),&
    !$acc& this_type%wf(:),&
    !$acc& this_type%wf2(:),&
    !$acc& this_type%finundated(:),&
    !$acc& this_type%begwb(:),&
    !$acc& this_type%endwb(:),&
    !$acc& this_type%errh2o(:),&
    !$acc& this_type%errh2osno(:),&
    !$acc& this_type%h2osoi_liq_depth_intg(:),&
    !$acc& this_type%h2osoi_ice_depth_intg(:),&
    !$acc& this_type%vsfm_fliq_col_1d(:),&
    !$acc& this_type%vsfm_sat_col_1d(:),&
    !$acc& this_type%vsfm_mass_col_1d(:),&
    !$acc& this_type%vsfm_smpl_col_1d(:),&
    !$acc& this_type%vsfm_soilp_col_1d(:))
  end subroutine deepcopy_column_water_state
  subroutine deepcopy_column_carbon_state(this_type)
    type(column_carbon_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%rootc(:),&
    !$acc& this_type%totvegc(:),&
    !$acc& this_type%leafc(:),&
    !$acc& this_type%deadstemc(:),&
    !$acc& this_type%fuelc(:),&
    !$acc& this_type%fuelc_crop(:),&
    !$acc& this_type%frootc(:),&
    !$acc& this_type%seedc(:),&
    !$acc& this_type%prod1c(:),&
    !$acc& this_type%prod10c(:),&
    !$acc& this_type%prod100c(:),&
    !$acc& this_type%totprodc(:),&
    !$acc& this_type%dyn_cbal_adjustments(:),&
    !$acc& this_type%totpftc(:),&
    !$acc& this_type%cwdc(:),&
    !$acc& this_type%ctrunc(:),&
    !$acc& this_type%totabgc(:),&
    !$acc& this_type%totecosysc(:),&
    !$acc& this_type%totcolc(:),&
    !$acc& this_type%totblgc(:),&
    !$acc& this_type%totvegc_abg(:),&
    !$acc& this_type%begcb(:),&
    !$acc& this_type%endcb(:),&
    !$acc& this_type%errcb(:),&
    !$acc& this_type%totpftc_beg(:),&
    !$acc& this_type%cwdc_beg(:),&
    !$acc& this_type%totlitc_beg(:),&
    !$acc& this_type%totsomc_beg(:),&
    !$acc& this_type%totpftc_end(:),&
    !$acc& this_type%cwdc_end(:),&
    !$acc& this_type%totlitc_end(:),&
    !$acc& this_type%totsomc_end(:),&
    !$acc& this_type%cropseedc_deficit(:),&
    !$acc& this_type%decomp_cpools_vr(:,:,:),&
    !$acc& this_type%ctrunc_vr(:,:),&
    !$acc& this_type%decomp_som2c_vr(:,:),&
    !$acc& this_type%decomp_cpools_1m(:,:),&
    !$acc& this_type%decomp_cpools(:,:),&
    !$acc& this_type%totlitc_1m(:),&
    !$acc& this_type%totsomc_1m(:),&
    !$acc& this_type%totlitc(:),&
    !$acc& this_type%totsomc(:),&
    !$acc& this_type%species)
  end subroutine deepcopy_column_carbon_state
  subroutine deepcopy_column_phosphorus_flux(this_type)
    type(column_phosphorus_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%pdep_to_sminp(:),&
    !$acc& this_type%fert_p_to_sminp(:),&
    !$acc& this_type%hrv_deadstemp_to_prod10p(:),&
    !$acc& this_type%hrv_deadstemp_to_prod100p(:),&
    !$acc& this_type%hrv_cropp_to_prod1p(:),&
    !$acc& this_type%sminp_to_plant(:),&
    !$acc& this_type%potential_immob_p(:),&
    !$acc& this_type%actual_immob_p(:),&
    !$acc& this_type%gross_pmin(:),&
    !$acc& this_type%net_pmin(:),&
    !$acc& this_type%supplement_to_sminp(:),&
    !$acc& this_type%prod1p_loss(:),&
    !$acc& this_type%prod10p_loss(:),&
    !$acc& this_type%prod100p_loss(:),&
    !$acc& this_type%product_ploss(:),&
    !$acc& this_type%pinputs(:),&
    !$acc& this_type%poutputs(:),&
    !$acc& this_type%fire_ploss(:),&
    !$acc& this_type%fire_decomp_ploss(:),&
    !$acc& this_type%fire_ploss_p2c(:),&
    !$acc& this_type%som_p_leached(:),&
    !$acc& this_type%somp_erode(:),&
    !$acc& this_type%somp_deposit(:),&
    !$acc& this_type%somp_yield(:),&
    !$acc& this_type%labilep_erode(:),&
    !$acc& this_type%labilep_deposit(:),&
    !$acc& this_type%labilep_yield(:),&
    !$acc& this_type%secondp_erode(:),&
    !$acc& this_type%secondp_deposit(:),&
    !$acc& this_type%secondp_yield(:),&
    !$acc& this_type%occlp_erode(:),&
    !$acc& this_type%occlp_deposit(:),&
    !$acc& this_type%occlp_yield(:),&
    !$acc& this_type%primp_erode(:),&
    !$acc& this_type%primp_deposit(:),&
    !$acc& this_type%primp_yield(:),&
    !$acc& this_type%m_p_to_litr_met_fire(:,:),&
    !$acc& this_type%m_p_to_litr_cel_fire(:,:),&
    !$acc& this_type%m_p_to_litr_lig_fire(:,:),&
    !$acc& this_type%potential_immob_p_vr(:,:),&
    !$acc& this_type%actual_immob_p_vr(:,:),&
    !$acc& this_type%sminp_to_plant_vr(:,:),&
    !$acc& this_type%supplement_to_sminp_vr(:,:),&
    !$acc& this_type%gross_pmin_vr(:,:),&
    !$acc& this_type%net_pmin_vr(:,:),&
    !$acc& this_type%biochem_pmin_to_ecosysp_vr(:,:),&
    !$acc& this_type%biochem_pmin_ppools_vr(:,:,:),&
    !$acc& this_type%biochem_pmin_vr(:,:),&
    !$acc& this_type%biochem_pmin(:),&
    !$acc& this_type%biochem_pmin_to_plant(:),&
    !$acc& this_type%dwt_slash_pflux(:),&
    !$acc& this_type%dwt_conv_pflux(:),&
    !$acc& this_type%dwt_prod10p_gain(:),&
    !$acc& this_type%dwt_prod100p_gain(:),&
    !$acc& this_type%dwt_crop_productp_gain(:),&
    !$acc& this_type%dwt_ploss(:),&
    !$acc& this_type%wood_harvestp(:),&
    !$acc& this_type%dwt_frootp_to_litr_met_p(:,:),&
    !$acc& this_type%dwt_frootp_to_litr_cel_p(:,:),&
    !$acc& this_type%dwt_frootp_to_litr_lig_p(:,:),&
    !$acc& this_type%dwt_livecrootp_to_cwdp(:,:),&
    !$acc& this_type%dwt_deadcrootp_to_cwdp(:,:),&
    !$acc& this_type%decomp_cascade_ptransfer_vr(:,:,:),&
    !$acc& this_type%decomp_cascade_sminp_flux_vr(:,:,:),&
    !$acc& this_type%m_decomp_ppools_to_fire_vr(:,:,:),&
    !$acc& this_type%decomp_cascade_ptransfer(:,:),&
    !$acc& this_type%decomp_cascade_sminp_flux(:,:),&
    !$acc& this_type%m_decomp_ppools_to_fire(:,:),&
    !$acc& this_type%phenology_p_to_litr_met_p(:,:),&
    !$acc& this_type%phenology_p_to_litr_cel_p(:,:),&
    !$acc& this_type%phenology_p_to_litr_lig_p(:,:),&
    !$acc& this_type%gap_mortality_p_to_litr_met_p(:,:),&
    !$acc& this_type%gap_mortality_p_to_litr_cel_p(:,:),&
    !$acc& this_type%gap_mortality_p_to_litr_lig_p(:,:),&
    !$acc& this_type%gap_mortality_p_to_cwdp(:,:),&
    !$acc& this_type%fire_mortality_p_to_cwdp(:,:),&
    !$acc& this_type%harvest_p_to_litr_met_p(:,:),&
    !$acc& this_type%harvest_p_to_litr_cel_p(:,:),&
    !$acc& this_type%harvest_p_to_litr_lig_p(:,:),&
    !$acc& this_type%harvest_p_to_cwdp(:,:),&
    !$acc& this_type%primp_to_labilep_vr(:,:),&
    !$acc& this_type%primp_to_labilep(:),&
    !$acc& this_type%labilep_to_secondp_vr(:,:),&
    !$acc& this_type%labilep_to_secondp(:),&
    !$acc& this_type%secondp_to_labilep_vr(:,:),&
    !$acc& this_type%secondp_to_labilep(:),&
    !$acc& this_type%secondp_to_occlp_vr(:,:),&
    !$acc& this_type%secondp_to_occlp(:),&
    !$acc& this_type%sminp_leached_vr(:,:),&
    !$acc& this_type%sminp_leached(:),&
    !$acc& this_type%decomp_ppools_leached(:,:),&
    !$acc& this_type%decomp_ppools_transport_tendency(:,:,:),&
    !$acc& this_type%decomp_ppools_sourcesink(:,:,:),&
    !$acc& this_type%labilep_yield_vr(:,:),&
    !$acc& this_type%secondp_yield_vr(:,:),&
    !$acc& this_type%occlp_yield_vr(:,:),&
    !$acc& this_type%primp_yield_vr(:,:),&
    !$acc& this_type%decomp_ppools_erode(:,:),&
    !$acc& this_type%decomp_ppools_deposit(:,:),&
    !$acc& this_type%decomp_ppools_yield(:,:),&
    !$acc& this_type%decomp_ppools_yield_vr(:,:,:),&
    !$acc& this_type%adsorb_to_labilep_vr(:,:),&
    !$acc& this_type%desorb_to_solutionp_vr(:,:),&
    !$acc& this_type%adsorb_to_labilep(:),&
    !$acc& this_type%desorb_to_solutionp(:),&
    !$acc& this_type%pmpf_decomp_cascade(:,:,:),&
    !$acc& this_type%plant_p_uptake_flux(:),&
    !$acc& this_type%soil_p_immob_flux(:),&
    !$acc& this_type%soil_p_immob_flux_vr(:,:),&
    !$acc& this_type%soil_p_grossmin_flux(:),&
    !$acc& this_type%smin_p_to_plant(:),&
    !$acc& this_type%plant_to_litter_pflux(:),&
    !$acc& this_type%plant_to_cwd_pflux(:),&
    !$acc& this_type%plant_pdemand(:),&
    !$acc& this_type%plant_pdemand_vr(:,:),&
    !$acc& this_type%col_plant_pdemand_vr(:,:),&
    !$acc& this_type%externalp_to_decomp_ppools(:,:,:),&
    !$acc& this_type%externalp_to_decomp_delta(:),&
    !$acc& this_type%sminp_net_transport_vr(:,:),&
    !$acc& this_type%sminp_net_transport_delta(:))
  end subroutine deepcopy_column_phosphorus_flux
  subroutine deepcopy_column_nitrogen_state(this_type)
    type(column_nitrogen_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%decomp_npools_vr(:,:,:),&
    !$acc& this_type%ntrunc_vr(:,:),&
    !$acc& this_type%sminn_vr(:,:),&
    !$acc& this_type%smin_no3_vr(:,:),&
    !$acc& this_type%smin_nh4_vr(:,:),&
    !$acc& this_type%smin_nh4sorb_vr(:,:),&
    !$acc& this_type%decomp_npools(:,:),&
    !$acc& this_type%decomp_npools_1m(:,:),&
    !$acc& this_type%smin_no3(:),&
    !$acc& this_type%smin_nh4(:),&
    !$acc& this_type%smin_nh4sorb(:),&
    !$acc& this_type%sminn(:),&
    !$acc& this_type%ntrunc(:),&
    !$acc& this_type%cwdn(:),&
    !$acc& this_type%totlitn(:),&
    !$acc& this_type%totsomn(:),&
    !$acc& this_type%totlitn_1m(:),&
    !$acc& this_type%totsomn_1m(:),&
    !$acc& this_type%totecosysn(:),&
    !$acc& this_type%totcoln(:),&
    !$acc& this_type%totabgn(:),&
    !$acc& this_type%totblgn(:),&
    !$acc& this_type%totvegn(:),&
    !$acc& this_type%totpftn(:),&
    !$acc& this_type%plant_n_buffer(:),&
    !$acc& this_type%plant_nbuffer(:),&
    !$acc& this_type%seedn(:),&
    !$acc& this_type%cropseedn_deficit(:),&
    !$acc& this_type%prod1n(:),&
    !$acc& this_type%prod10n(:),&
    !$acc& this_type%prod100n(:),&
    !$acc& this_type%totprodn(:),&
    !$acc& this_type%dyn_nbal_adjustments(:),&
    !$acc& this_type%totpftn_beg(:),&
    !$acc& this_type%totpftn_end(:),&
    !$acc& this_type%cwdn_beg(:),&
    !$acc& this_type%cwdn_end(:),&
    !$acc& this_type%totlitn_beg(:),&
    !$acc& this_type%totlitn_end(:),&
    !$acc& this_type%totsomn_beg(:),&
    !$acc& this_type%totsomn_end(:),&
    !$acc& this_type%sminn_beg(:),&
    !$acc& this_type%sminn_end(:),&
    !$acc& this_type%smin_no3_beg(:),&
    !$acc& this_type%smin_no3_end(:),&
    !$acc& this_type%smin_nh4_beg(:),&
    !$acc& this_type%smin_nh4_end(:),&
    !$acc& this_type%totprodn_beg(:),&
    !$acc& this_type%totprodn_end(:),&
    !$acc& this_type%seedn_beg(:),&
    !$acc& this_type%seedn_end(:),&
    !$acc& this_type%ntrunc_beg(:),&
    !$acc& this_type%ntrunc_end(:),&
    !$acc& this_type%begnb(:),&
    !$acc& this_type%endnb(:),&
    !$acc& this_type%errnb(:))
  end subroutine deepcopy_column_nitrogen_state
  subroutine deepcopy_column_phosphorus_state(this_type)
    type(column_phosphorus_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%ptrunc_vr(:,:),&
    !$acc& this_type%solutionp_vr(:,:),&
    !$acc& this_type%labilep_vr(:,:),&
    !$acc& this_type%secondp_vr(:,:),&
    !$acc& this_type%occlp_vr(:,:),&
    !$acc& this_type%primp_vr(:,:),&
    !$acc& this_type%sminp_vr(:,:),&
    !$acc& this_type%solutionp(:),&
    !$acc& this_type%labilep(:),&
    !$acc& this_type%secondp(:),&
    !$acc& this_type%occlp(:),&
    !$acc& this_type%primp(:),&
    !$acc& this_type%cwdp(:),&
    !$acc& this_type%sminp(:),&
    !$acc& this_type%ptrunc(:),&
    !$acc& this_type%seedp(:),&
    !$acc& this_type%prod1p(:),&
    !$acc& this_type%prod10p(:),&
    !$acc& this_type%prod100p(:),&
    !$acc& this_type%totprodp(:),&
    !$acc& this_type%dyn_pbal_adjustments(:),&
    !$acc& this_type%totlitp(:),&
    !$acc& this_type%totsomp(:),&
    !$acc& this_type%totlitp_1m(:),&
    !$acc& this_type%totsomp_1m(:),&
    !$acc& this_type%totecosysp(:),&
    !$acc& this_type%totcolp(:),&
    !$acc& this_type%decomp_ppools(:,:),&
    !$acc& this_type%decomp_ppools_1m(:,:),&
    !$acc& this_type%totpftp(:),&
    !$acc& this_type%totvegp(:),&
    !$acc& this_type%decomp_ppools_vr(:,:,:),&
    !$acc& this_type%begpb(:),&
    !$acc& this_type%endpb(:),&
    !$acc& this_type%errpb(:),&
    !$acc& this_type%solutionp_vr_cur(:,:),&
    !$acc& this_type%solutionp_vr_prev(:,:),&
    !$acc& this_type%labilep_vr_cur(:,:),&
    !$acc& this_type%labilep_vr_prev(:,:),&
    !$acc& this_type%secondp_vr_cur(:,:),&
    !$acc& this_type%secondp_vr_prev(:,:),&
    !$acc& this_type%occlp_vr_cur(:,:),&
    !$acc& this_type%occlp_vr_prev(:,:),&
    !$acc& this_type%primp_vr_cur(:,:),&
    !$acc& this_type%primp_vr_prev(:,:),&
    !$acc& this_type%totpftp_beg(:),&
    !$acc& this_type%solutionp_beg(:),&
    !$acc& this_type%labilep_beg(:),&
    !$acc& this_type%secondp_beg(:),&
    !$acc& this_type%totlitp_beg(:),&
    !$acc& this_type%cwdp_beg(:),&
    !$acc& this_type%totsomp_beg(:),&
    !$acc& this_type%totlitp_end(:),&
    !$acc& this_type%totpftp_end(:),&
    !$acc& this_type%labilep_end(:),&
    !$acc& this_type%secondp_end(:),&
    !$acc& this_type%solutionp_end(:),&
    !$acc& this_type%cwdp_end(:),&
    !$acc& this_type%totsomp_end(:),&
    !$acc& this_type%cropseedp_deficit(:))
  end subroutine deepcopy_column_phosphorus_state
  subroutine deepcopy_column_energy_flux(this_type)
    type(column_energy_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%eflx_h2osfc_to_snow(:),&
    !$acc& this_type%eflx_snomelt(:),&
    !$acc& this_type%eflx_snomelt_r(:),&
    !$acc& this_type%eflx_snomelt_u(:),&
    !$acc& this_type%eflx_bot(:),&
    !$acc& this_type%eflx_fgr12(:),&
    !$acc& this_type%eflx_fgr(:,:),&
    !$acc& this_type%eflx_building_heat(:),&
    !$acc& this_type%eflx_urban_ac(:),&
    !$acc& this_type%eflx_urban_heat(:),&
    !$acc& this_type%eflx_hs_h2osfc(:),&
    !$acc& this_type%eflx_hs_top_snow(:),&
    !$acc& this_type%eflx_hs_soil(:),&
    !$acc& this_type%eflx_sabg_lyr(:,:),&
    !$acc& this_type%eflx_dhsdt(:),&
    !$acc& this_type%htvp(:),&
    !$acc& this_type%xmf(:),&
    !$acc& this_type%xmf_h2osfc(:),&
    !$acc& this_type%imelt(:,:),&
    !$acc& this_type%eflx_soil_grnd(:),&
    !$acc& this_type%eflx_rnet_soil(:),&
    !$acc& this_type%eflx_fgr0_soil(:),&
    !$acc& this_type%eflx_fgr0_snow(:),&
    !$acc& this_type%eflx_fgr0_h2osfc(:),&
    !$acc& this_type%errsoi(:),&
    !$acc& this_type%errseb(:),&
    !$acc& this_type%errsol(:),&
    !$acc& this_type%errlon(:))
  end subroutine deepcopy_column_energy_flux
  subroutine deepcopy_column_water_flux(this_type)
    type(column_water_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%qflx_prec_grnd(:),&
    !$acc& this_type%qflx_rain_grnd(:),&
    !$acc& this_type%qflx_snow_grnd(:),&
    !$acc& this_type%qflx_sub_snow(:),&
    !$acc& this_type%qflx_sub_snow_vol(:),&
    !$acc& this_type%qflx_evap_soi(:),&
    !$acc& this_type%qflx_evap_veg(:),&
    !$acc& this_type%qflx_evap_can(:),&
    !$acc& this_type%qflx_evap_tot(:),&
    !$acc& this_type%qflx_evap_grnd(:),&
    !$acc& this_type%qflx_snwcp_liq(:),&
    !$acc& this_type%qflx_snwcp_ice(:),&
    !$acc& this_type%qflx_tran_veg(:),&
    !$acc& this_type%qflx_dew_snow(:),&
    !$acc& this_type%qflx_dew_grnd(:),&
    !$acc& this_type%qflx_prec_intr(:),&
    !$acc& this_type%qflx_dirct_rain(:),&
    !$acc& this_type%qflx_leafdrip(:),&
    !$acc& this_type%qflx_ev_snow(:),&
    !$acc& this_type%qflx_ev_soil(:),&
    !$acc& this_type%qflx_ev_h2osfc(:),&
    !$acc& this_type%qflx_gross_evap_soil(:),&
    !$acc& this_type%qflx_gross_infl_soil(:),&
    !$acc& this_type%qflx_adv(:,:),&
    !$acc& this_type%qflx_rootsoi(:,:),&
    !$acc& this_type%dwb(:),&
    !$acc& this_type%qflx_infl(:),&
    !$acc& this_type%qflx_surf(:),&
    !$acc& this_type%qflx_drain(:),&
    !$acc& this_type%qflx_totdrain(:),&
    !$acc& this_type%qflx_top_soil(:),&
    !$acc& this_type%qflx_h2osfc_to_ice(:),&
    !$acc& this_type%qflx_h2osfc_surf(:),&
    !$acc& this_type%qflx_snow_h2osfc(:),&
    !$acc& this_type%qflx_drain_perched(:),&
    !$acc& this_type%qflx_deficit(:),&
    !$acc& this_type%qflx_floodc(:),&
    !$acc& this_type%qflx_sl_top_soil(:),&
    !$acc& this_type%qflx_snomelt(:),&
    !$acc& this_type%qflx_snow_melt(:),&
    !$acc& this_type%qflx_qrgwl(:),&
    !$acc& this_type%qflx_runoff(:),&
    !$acc& this_type%qflx_runoff_r(:),&
    !$acc& this_type%qflx_runoff_u(:),&
    !$acc& this_type%qflx_rsub_sat(:),&
    !$acc& this_type%qflx_snofrz_lyr(:,:),&
    !$acc& this_type%qflx_snofrz(:),&
    !$acc& this_type%qflx_glcice(:),&
    !$acc& this_type%qflx_glcice_frz(:),&
    !$acc& this_type%qflx_glcice_melt(:),&
    !$acc& this_type%qflx_drain_vr(:,:),&
    !$acc& this_type%qflx_h2osfc2topsoi(:),&
    !$acc& this_type%qflx_snow2topsoi(:),&
    !$acc& this_type%qflx_lateral(:),&
    !$acc& this_type%snow_sources(:),&
    !$acc& this_type%snow_sinks(:),&
    !$acc& this_type%qflx_irrig(:),&
    !$acc& this_type%qflx_surf_irrig(:),&
    !$acc& this_type%qflx_grnd_irrig(:),&
    !$acc& this_type%qflx_over_supply(:),&
    !$acc& this_type%qflx_irr_demand(:),&
    !$acc& this_type%mflx_infl_1d(:),&
    !$acc& this_type%mflx_dew_1d(:),&
    !$acc& this_type%mflx_snowlyr_1d(:),&
    !$acc& this_type%mflx_sub_snow_1d(:),&
    !$acc& this_type%mflx_neg_snow_1d(:),&
    !$acc& this_type%mflx_et_1d(:),&
    !$acc& this_type%mflx_drain_1d(:),&
    !$acc& this_type%mflx_drain_perched_1d(:),&
    !$acc& this_type%mflx_snowlyr(:),&
    !$acc& this_type%mflx_infl(:),&
    !$acc& this_type%mflx_dew(:),&
    !$acc& this_type%mflx_snowlyr_disp(:),&
    !$acc& this_type%mflx_sub_snow(:),&
    !$acc& this_type%mflx_et(:,:),&
    !$acc& this_type%mflx_drain(:,:),&
    !$acc& this_type%mflx_recharge(:))
  end subroutine deepcopy_column_water_flux
  subroutine deepcopy_column_carbon_flux(this_type)
    type(column_carbon_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%decomp_cpools_sourcesink(:,:,:),&
    !$acc& this_type%decomp_cascade_hr_vr(:,:,:),&
    !$acc& this_type%decomp_cascade_ctransfer_vr(:,:,:),&
    !$acc& this_type%decomp_k(:,:,:),&
    !$acc& this_type%decomp_cpools_transport_tendency(:,:,:),&
    !$acc& this_type%decomp_cpools_yield_vr(:,:,:),&
    !$acc& this_type%decomp_cascade_hr(:,:),&
    !$acc& this_type%decomp_cascade_ctransfer(:,:),&
    !$acc& this_type%o_scalar(:,:),&
    !$acc& this_type%w_scalar(:,:),&
    !$acc& this_type%t_scalar(:,:),&
    !$acc& this_type%decomp_cpools_leached(:,:),&
    !$acc& this_type%phr_vr(:,:),&
    !$acc& this_type%fphr(:,:),&
    !$acc& this_type%som_c_leached(:),&
    !$acc& this_type%phenology_c_to_litr_met_c(:,:),&
    !$acc& this_type%phenology_c_to_litr_cel_c(:,:),&
    !$acc& this_type%phenology_c_to_litr_lig_c(:,:),&
    !$acc& this_type%gap_mortality_c_to_litr_met_c(:,:),&
    !$acc& this_type%gap_mortality_c_to_litr_cel_c(:,:),&
    !$acc& this_type%gap_mortality_c_to_litr_lig_c(:,:),&
    !$acc& this_type%gap_mortality_c_to_cwdc(:,:),&
    !$acc& this_type%m_decomp_cpools_to_fire_vr(:,:,:),&
    !$acc& this_type%m_decomp_cpools_to_fire(:,:),&
    !$acc& this_type%decomp_cpools_erode(:,:),&
    !$acc& this_type%decomp_cpools_deposit(:,:),&
    !$acc& this_type%decomp_cpools_yield(:,:),&
    !$acc& this_type%m_c_to_litr_met_fire(:,:),&
    !$acc& this_type%m_c_to_litr_cel_fire(:,:),&
    !$acc& this_type%m_c_to_litr_lig_fire(:,:),&
    !$acc& this_type%fire_mortality_c_to_cwdc(:,:),&
    !$acc& this_type%somc_fire(:),&
    !$acc& this_type%somc_erode(:),&
    !$acc& this_type%somc_deposit(:),&
    !$acc& this_type%somc_yield(:),&
    !$acc& this_type%harvest_c_to_litr_met_c(:,:),&
    !$acc& this_type%harvest_c_to_litr_cel_c(:,:),&
    !$acc& this_type%harvest_c_to_litr_lig_c(:,:),&
    !$acc& this_type%harvest_c_to_cwdc(:,:),&
    !$acc& this_type%hrv_deadstemc_to_prod10c(:),&
    !$acc& this_type%hrv_deadstemc_to_prod100c(:),&
    !$acc& this_type%hrv_cropc_to_prod1c(:),&
    !$acc& this_type%dwt_frootc_to_litr_met_c(:,:),&
    !$acc& this_type%dwt_frootc_to_litr_cel_c(:,:),&
    !$acc& this_type%dwt_frootc_to_litr_lig_c(:,:),&
    !$acc& this_type%dwt_livecrootc_to_cwdc(:,:),&
    !$acc& this_type%dwt_deadcrootc_to_cwdc(:,:),&
    !$acc& this_type%dwt_slash_cflux(:),&
    !$acc& this_type%dwt_conv_cflux(:),&
    !$acc& this_type%dwt_prod10c_gain(:),&
    !$acc& this_type%dwt_prod100c_gain(:),&
    !$acc& this_type%dwt_crop_productc_gain(:),&
    !$acc& this_type%dwt_closs(:),&
    !$acc& this_type%landuseflux(:),&
    !$acc& this_type%landuptake(:),&
    !$acc& this_type%prod1c_loss(:),&
    !$acc& this_type%prod10c_loss(:),&
    !$acc& this_type%prod100c_loss(:),&
    !$acc& this_type%product_closs(:),&
    !$acc& this_type%hr_vr(:,:),&
    !$acc& this_type%lithr(:),&
    !$acc& this_type%somhr(:),&
    !$acc& this_type%hr(:),&
    !$acc& this_type%sr(:),&
    !$acc& this_type%er(:),&
    !$acc& this_type%litfire(:),&
    !$acc& this_type%somfire(:),&
    !$acc& this_type%totfire(:),&
    !$acc& this_type%nep(:),&
    !$acc& this_type%nbp(:),&
    !$acc& this_type%nee(:),&
    !$acc& this_type%cinputs(:),&
    !$acc& this_type%coutputs(:),&
    !$acc& this_type%bgc_cpool_ext_inputs_vr(:,:,:),&
    !$acc& this_type%bgc_cpool_ext_loss_vr(:,:,:),&
    !$acc& this_type%cwdc_hr(:),&
    !$acc& this_type%cwdc_loss(:),&
    !$acc& this_type%litterc_loss(:),&
    !$acc& this_type%rr(:),&
    !$acc& this_type%ar(:),&
    !$acc& this_type%gpp(:),&
    !$acc& this_type%npp(:),&
    !$acc& this_type%fire_closs_p2c(:),&
    !$acc& this_type%fire_closs(:),&
    !$acc& this_type%fire_decomp_closs(:),&
    !$acc& this_type%litfall(:),&
    !$acc& this_type%vegfire(:),&
    !$acc& this_type%wood_harvestc(:),&
    !$acc& this_type%hrv_xsmrpool_to_atm(:),&
    !$acc& this_type%plant_to_litter_cflux(:),&
    !$acc& this_type%plant_to_cwd_cflux(:),&
    !$acc& this_type%annsum_npp(:),&
    !$acc& this_type%plant_c_to_cwdc(:),&
    !$acc& this_type%plant_p_to_cwdp(:),&
    !$acc& this_type%lag_npp(:),&
    !$acc& this_type%externalc_to_decomp_cpools(:,:,:),&
    !$acc& this_type%externalc_to_decomp_delta(:),&
    !$acc& this_type%f_co2_soil_vr(:,:),&
    !$acc& this_type%f_co2_soil(:))
  end subroutine deepcopy_column_carbon_flux
  subroutine deepcopy_column_nitrogen_flux(this_type)
    type(column_nitrogen_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%ndep_to_sminn(:),&
    !$acc& this_type%nfix_to_sminn(:),&
    !$acc& this_type%nfix_to_ecosysn(:),&
    !$acc& this_type%fert_to_sminn(:),&
    !$acc& this_type%soyfixn_to_sminn(:),&
    !$acc& this_type%hrv_deadstemn_to_prod10n(:),&
    !$acc& this_type%hrv_deadstemn_to_prod100n(:),&
    !$acc& this_type%hrv_cropn_to_prod1n(:),&
    !$acc& this_type%sminn_to_plant(:),&
    !$acc& this_type%potential_immob(:),&
    !$acc& this_type%actual_immob(:),&
    !$acc& this_type%gross_nmin(:),&
    !$acc& this_type%net_nmin(:),&
    !$acc& this_type%denit(:),&
    !$acc& this_type%supplement_to_sminn(:),&
    !$acc& this_type%prod1n_loss(:),&
    !$acc& this_type%prod10n_loss(:),&
    !$acc& this_type%prod100n_loss(:),&
    !$acc& this_type%product_nloss(:),&
    !$acc& this_type%ninputs(:),&
    !$acc& this_type%noutputs(:),&
    !$acc& this_type%fire_nloss(:),&
    !$acc& this_type%fire_decomp_nloss(:),&
    !$acc& this_type%fire_nloss_p2c(:),&
    !$acc& this_type%som_n_leached(:),&
    !$acc& this_type%somn_erode(:),&
    !$acc& this_type%somn_deposit(:),&
    !$acc& this_type%somn_yield(:),&
    !$acc& this_type%m_n_to_litr_met_fire(:,:),&
    !$acc& this_type%m_n_to_litr_cel_fire(:,:),&
    !$acc& this_type%m_n_to_litr_lig_fire(:,:),&
    !$acc& this_type%r_psi(:,:),&
    !$acc& this_type%anaerobic_frac(:,:),&
    !$acc& this_type%potential_immob_vr(:,:),&
    !$acc& this_type%actual_immob_vr(:,:),&
    !$acc& this_type%sminn_to_plant_vr(:,:),&
    !$acc& this_type%supplement_to_sminn_vr(:,:),&
    !$acc& this_type%gross_nmin_vr(:,:),&
    !$acc& this_type%net_nmin_vr(:,:),&
    !$acc& this_type%dwt_slash_nflux(:),&
    !$acc& this_type%dwt_conv_nflux(:),&
    !$acc& this_type%dwt_prod10n_gain(:),&
    !$acc& this_type%dwt_prod100n_gain(:),&
    !$acc& this_type%dwt_crop_productn_gain(:),&
    !$acc& this_type%dwt_nloss(:),&
    !$acc& this_type%wood_harvestn(:),&
    !$acc& this_type%dwt_frootn_to_litr_met_n(:,:),&
    !$acc& this_type%dwt_frootn_to_litr_cel_n(:,:),&
    !$acc& this_type%dwt_frootn_to_litr_lig_n(:,:),&
    !$acc& this_type%dwt_livecrootn_to_cwdn(:,:),&
    !$acc& this_type%dwt_deadcrootn_to_cwdn(:,:),&
    !$acc& this_type%f_nit_vr(:,:),&
    !$acc& this_type%f_denit_vr(:,:),&
    !$acc& this_type%smin_no3_leached_vr(:,:),&
    !$acc& this_type%smin_no3_leached(:),&
    !$acc& this_type%smin_no3_runoff_vr(:,:),&
    !$acc& this_type%smin_no3_runoff(:),&
    !$acc& this_type%pot_f_nit_vr(:,:),&
    !$acc& this_type%pot_f_nit(:),&
    !$acc& this_type%pot_f_denit_vr(:,:),&
    !$acc& this_type%pot_f_denit(:),&
    !$acc& this_type%actual_immob_no3_vr(:,:),&
    !$acc& this_type%actual_immob_nh4_vr(:,:),&
    !$acc& this_type%smin_no3_to_plant_vr(:,:),&
    !$acc& this_type%smin_nh4_to_plant_vr(:,:),&
    !$acc& this_type%smin_no3_to_plant(:),&
    !$acc& this_type%smin_nh4_to_plant(:),&
    !$acc& this_type%f_nit(:),&
    !$acc& this_type%f_denit(:),&
    !$acc& this_type%n2_n2o_ratio_denit_vr(:,:),&
    !$acc& this_type%f_n2o_denit(:),&
    !$acc& this_type%f_n2o_denit_vr(:,:),&
    !$acc& this_type%f_n2o_nit(:),&
    !$acc& this_type%f_n2o_nit_vr(:,:),&
    !$acc& this_type%sminn_no3_input_vr(:,:),&
    !$acc& this_type%sminn_nh4_input_vr(:,:),&
    !$acc& this_type%sminn_nh4_input(:),&
    !$acc& this_type%sminn_no3_input(:),&
    !$acc& this_type%sminn_input(:),&
    !$acc& this_type%bgc_npool_inputs(:,:),&
    !$acc& this_type%smin_no3_massdens_vr(:,:),&
    !$acc& this_type%soil_bulkdensity(:,:),&
    !$acc& this_type%k_nitr_t_vr(:,:),&
    !$acc& this_type%k_nitr_ph_vr(:,:),&
    !$acc& this_type%k_nitr_h2o_vr(:,:),&
    !$acc& this_type%k_nitr_vr(:,:),&
    !$acc& this_type%wfps_vr(:,:),&
    !$acc& this_type%f_denit_base_vr(:,:),&
    !$acc& this_type%diffus(:,:),&
    !$acc& this_type%ratio_k1(:,:),&
    !$acc& this_type%ratio_no3_co2(:,:),&
    !$acc& this_type%soil_co2_prod(:,:),&
    !$acc& this_type%fr_wfps(:,:),&
    !$acc& this_type%fmax_denit_carbonsubstrate_vr(:,:),&
    !$acc& this_type%fmax_denit_nitrate_vr(:,:),&
    !$acc& this_type%phenology_n_to_litr_met_n(:,:),&
    !$acc& this_type%phenology_n_to_litr_cel_n(:,:),&
    !$acc& this_type%phenology_n_to_litr_lig_n(:,:),&
    !$acc& this_type%gap_mortality_n_to_litr_met_n(:,:),&
    !$acc& this_type%gap_mortality_n_to_litr_cel_n(:,:),&
    !$acc& this_type%gap_mortality_n_to_litr_lig_n(:,:),&
    !$acc& this_type%gap_mortality_n_to_cwdn(:,:),&
    !$acc& this_type%fire_mortality_n_to_cwdn(:,:),&
    !$acc& this_type%harvest_n_to_litr_met_n(:,:),&
    !$acc& this_type%harvest_n_to_litr_cel_n(:,:),&
    !$acc& this_type%harvest_n_to_litr_lig_n(:,:),&
    !$acc& this_type%harvest_n_to_cwdn(:,:),&
    !$acc& this_type%plant_ndemand(:),&
    !$acc& this_type%plant_ndemand_vr(:,:),&
    !$acc& this_type%f_ngas_decomp_vr(:,:),&
    !$acc& this_type%f_ngas_nitri_vr(:,:),&
    !$acc& this_type%f_ngas_denit_vr(:,:),&
    !$acc& this_type%f_n2o_soil_vr(:,:),&
    !$acc& this_type%f_n2_soil_vr(:,:),&
    !$acc& this_type%f_ngas_decomp(:),&
    !$acc& this_type%f_ngas_nitri(:),&
    !$acc& this_type%f_ngas_denit(:),&
    !$acc& this_type%f_n2o_soil(:),&
    !$acc& this_type%f_n2_soil(:),&
    !$acc& this_type%externaln_to_decomp_delta(:),&
    !$acc& this_type%no3_net_transport_vr(:,:),&
    !$acc& this_type%nh4_net_transport_vr(:,:),&
    !$acc& this_type%col_plant_ndemand_vr(:,:),&
    !$acc& this_type%col_plant_nh4demand_vr(:,:),&
    !$acc& this_type%col_plant_no3demand_vr(:,:),&
    !$acc& this_type%plant_n_uptake_flux(:),&
    !$acc& this_type%soil_n_immob_flux(:),&
    !$acc& this_type%soil_n_immob_flux_vr(:,:),&
    !$acc& this_type%soil_n_grossmin_flux(:),&
    !$acc& this_type%actual_immob_no3(:),&
    !$acc& this_type%actual_immob_nh4(:),&
    !$acc& this_type%plant_to_litter_nflux(:),&
    !$acc& this_type%plant_to_cwd_nflux(:),&
    !$acc& this_type%plant_n_to_cwdn(:),&
    !$acc& this_type%bgc_npool_ext_inputs_vr(:,:,:),&
    !$acc& this_type%bgc_npool_ext_loss_vr(:,:,:),&
    !$acc& this_type%decomp_cascade_ntransfer_vr(:,:,:),&
    !$acc& this_type%decomp_cascade_sminn_flux_vr(:,:,:),&
    !$acc& this_type%m_decomp_npools_to_fire_vr(:,:,:),&
    !$acc& this_type%decomp_cascade_ntransfer(:,:),&
    !$acc& this_type%decomp_cascade_sminn_flux(:,:),&
    !$acc& this_type%m_decomp_npools_to_fire(:,:),&
    !$acc& this_type%decomp_npools_erode(:,:),&
    !$acc& this_type%decomp_npools_deposit(:,:),&
    !$acc& this_type%decomp_npools_yield(:,:),&
    !$acc& this_type%decomp_npools_yield_vr(:,:,:),&
    !$acc& this_type%sminn_to_denit_decomp_cascade_vr(:,:,:),&
    !$acc& this_type%sminn_to_denit_decomp_cascade(:,:),&
    !$acc& this_type%sminn_to_denit_excess_vr(:,:),&
    !$acc& this_type%sminn_to_denit_excess(:),&
    !$acc& this_type%sminn_leached_vr(:,:),&
    !$acc& this_type%sminn_leached(:),&
    !$acc& this_type%decomp_npools_leached(:,:),&
    !$acc& this_type%decomp_npools_transport_tendency(:,:,:),&
    !$acc& this_type%decomp_npools_sourcesink(:,:,:),&
    !$acc& this_type%externaln_to_decomp_npools(:,:,:),&
    !$acc& this_type%pmnf_decomp_cascade(:,:,:))
  end subroutine deepcopy_column_nitrogen_flux
end module DeepCopyColumnMod
