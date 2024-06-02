module DeepCopyChemMod
  use elm_varctl, only : use_century_decomp, use_lch4, use_crop

  use allocationmod,only: allocparamstype
  use ch4mod,only: ch4paramstype
  use ch4mod,only: ch4_type
  use cndecompcascadecontype,only: decomp_cascade_type
  use croptype,only: crop_type
  use dustmod,only: dust_type
  use decompcascadebgcmod,only: decompbgcparamstype
  use decompcascadecnmod,only: decompcnparamstype
  use drydepvelocity,only: drydepvel_type
  use gapmortalitymod,only: cngapmortparamstype
  use nitrifdenitrifmod,only: nitrifdenitrifparamstype
  use nitrogendynamicsmod,only: cnndynamicsparamstype
  use plantmickineticsmod,only: plantmickinetics_type
  use sharedparamsmod,only: paramssharetype
  use soillittdecompmod,only: cndecompparamstype
  implicit none
  public :: deepcopy_bgc_types

  public :: deepcopy_allocparamstype
  public :: deepcopy_ch4paramstype
  public :: deepcopy_ch4_type
  public :: deepcopy_decomp_cascade_type
  public :: deepcopy_crop_type
  public :: deepcopy_dust_type
  public :: deepcopy_decompbgcparamstype
  public :: deepcopy_decompcnparamstype
  public :: deepcopy_drydepvel_type
  public :: deepcopy_cngapmortparamstype
  public :: deepcopy_nitrifdenitrifparamstype
  public :: deepcopy_cnndynamicsparamstype
  public :: deepcopy_paramssharetype
  public :: deepcopy_cndecompparamstype
contains

  subroutine deepcopy_bgc_types(alloc_inst,ch4_params,ch4_vars,decomp_cascade_inst,&
                                crop_vars, dust_vars, decompbgcparams, &
                                decompcnparams, drydep_vars, CNGapMortParamsInst, &
                                NitrifDenitrifParamsInst, NitrogenParamsInst, &
                                SharedParams, DecompParams)
    implicit none
    type(allocparamstype), intent(inout) :: alloc_inst
    type(CH4ParamsType), intent(inout) :: ch4_params
    type(ch4_type), intent(inout) :: ch4_vars
    type(decomp_cascade_type), intent(inout) :: decomp_cascade_inst
    type(crop_type), intent(inout) :: crop_vars
    type(dust_type), intent(inout) :: dust_vars
    type(DecompBGCParamsType), intent(inout) :: decompbgcparams
    type(DecompCNParamsType), intent(inout) :: decompcnparams
    type(drydepvel_type), intent(inout) :: drydep_vars
    type(CNGapMortParamsType), intent(inout) :: CNGapMortParamsInst
    type(NitrifDenitrifParamsType), intent(inout) :: NitrifDenitrifParamsInst
    type(CNNDynamicsParamsType), intent(inout) :: NitrogenParamsInst
    type(ParamsShareType), intent(inout) :: SharedParams
    type(CNDecompParamsType), intent(inout) :: DecompParams

    call deepcopy_allocparamstype(alloc_inst)
    if(use_lch4) then
      call deepcopy_ch4paramstype(ch4_params)
      call deepcopy_ch4_type(ch4_vars)
    end if 
    call deepcopy_decomp_cascade_type(decomp_cascade_inst)
    if(use_crop) then
      call deepcopy_crop_type(crop_vars)
    end if
    call deepcopy_dust_type(dust_vars)
    if(use_century_decomp) then
      call deepcopy_decompbgcparamstype(decompbgcparams)
    else
      call deepcopy_decompcnparamstype(decompcnparams)
    end if
    call deepcopy_drydepvel_type(drydep_vars)
    call deepcopy_cngapmortparamstype(CNGapMortParamsInst)
    call deepcopy_nitrifdenitrifparamstype(NitrifDenitrifParamsInst)
    call deepcopy_cnndynamicsparamstype(NitrogenParamsInst)
    call deepcopy_paramssharetype(SharedParams)
    call deepcopy_cndecompparamstype(DecompParams)

  end subroutine deepcopy_bgc_types

  subroutine deepcopy_allocparamstype(this_type)
    type(allocparamstype), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%bdnr,&
    !$acc& this_type%dayscrecover,&
    !$acc& this_type%compet_plant_no3,&
    !$acc& this_type%compet_plant_nh4,&
    !$acc& this_type%compet_decomp_no3,&
    !$acc& this_type%compet_decomp_nh4,&
    !$acc& this_type%compet_denit,&
    !$acc& this_type%compet_nit)
  end subroutine deepcopy_allocparamstype
  subroutine deepcopy_ch4paramstype(this_type)
    type(ch4paramstype), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%q10ch4,&
    !$acc& this_type%q10ch4base,&
    !$acc& this_type%f_ch4,&
    !$acc& this_type%rootlitfrac,&
    !$acc& this_type%cnscalefactor,&
    !$acc& this_type%redoxlag,&
    !$acc& this_type%lake_decomp_fact,&
    !$acc& this_type%redoxlag_vertical,&
    !$acc& this_type%phmax,&
    !$acc& this_type%phmin,&
    !$acc& this_type%oxinhib,&
    !$acc& this_type%vmax_ch4_oxid,&
    !$acc& this_type%k_m,&
    !$acc& this_type%q10_ch4oxid,&
    !$acc& this_type%smp_crit,&
    !$acc& this_type%k_m_o2,&
    !$acc& this_type%k_m_unsat,&
    !$acc& this_type%vmax_oxid_unsat,&
    !$acc& this_type%aereoxid,&
    !$acc& this_type%scale_factor_aere,&
    !$acc& this_type%nongrassporosratio,&
    !$acc& this_type%unsat_aere_ratio,&
    !$acc& this_type%porosmin,&
    !$acc& this_type%vgc_max,&
    !$acc& this_type%satpow,&
    !$acc& this_type%scale_factor_gasdiff,&
    !$acc& this_type%scale_factor_liqdiff,&
    !$acc& this_type%capthick,&
    !$acc& this_type%f_sat,&
    !$acc& this_type%qflxlagd,&
    !$acc& this_type%highlatfact,&
    !$acc& this_type%q10lakebase,&
    !$acc& this_type%atmch4,&
    !$acc& this_type%rob)
  end subroutine deepcopy_ch4paramstype
  subroutine deepcopy_ch4_type(this_type)
    type(ch4_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%ch4_prod_depth_sat_col(:,:),&
    !$acc& this_type%ch4_prod_depth_unsat_col(:,:),&
    !$acc& this_type%ch4_prod_depth_lake_col(:,:),&
    !$acc& this_type%ch4_oxid_depth_sat_col(:,:),&
    !$acc& this_type%ch4_oxid_depth_unsat_col(:,:),&
    !$acc& this_type%ch4_oxid_depth_lake_col(:,:),&
    !$acc& this_type%o2_oxid_depth_sat_col(:,:),&
    !$acc& this_type%o2_oxid_depth_unsat_col(:,:),&
    !$acc& this_type%o2_aere_depth_sat_col(:,:),&
    !$acc& this_type%o2_aere_depth_unsat_col(:,:),&
    !$acc& this_type%co2_decomp_depth_sat_col(:,:),&
    !$acc& this_type%co2_decomp_depth_unsat_col(:,:),&
    !$acc& this_type%co2_oxid_depth_sat_col(:,:),&
    !$acc& this_type%co2_oxid_depth_unsat_col(:,:),&
    !$acc& this_type%ch4_aere_depth_sat_col(:,:),&
    !$acc& this_type%ch4_aere_depth_unsat_col(:,:),&
    !$acc& this_type%ch4_tran_depth_sat_col(:,:),&
    !$acc& this_type%ch4_tran_depth_unsat_col(:,:),&
    !$acc& this_type%co2_aere_depth_sat_col(:,:),&
    !$acc& this_type%co2_aere_depth_unsat_col(:,:),&
    !$acc& this_type%ch4_surf_aere_sat_col(:),&
    !$acc& this_type%ch4_surf_aere_unsat_col(:),&
    !$acc& this_type%ch4_ebul_depth_sat_col(:,:),&
    !$acc& this_type%ch4_ebul_depth_unsat_col(:,:),&
    !$acc& this_type%ch4_ebul_total_sat_col(:),&
    !$acc& this_type%ch4_ebul_total_unsat_col(:),&
    !$acc& this_type%ch4_surf_ebul_sat_col(:),&
    !$acc& this_type%ch4_surf_ebul_unsat_col(:),&
    !$acc& this_type%ch4_surf_ebul_lake_col(:),&
    !$acc& this_type%conc_ch4_sat_col(:,:),&
    !$acc& this_type%conc_ch4_unsat_col(:,:),&
    !$acc& this_type%conc_ch4_lake_col(:,:),&
    !$acc& this_type%ch4_surf_diff_sat_col(:),&
    !$acc& this_type%ch4_surf_diff_unsat_col(:),&
    !$acc& this_type%ch4_surf_diff_lake_col(:),&
    !$acc& this_type%conc_o2_lake_col(:,:),&
    !$acc& this_type%ch4_dfsat_flux_col(:),&
    !$acc& this_type%zwt_ch4_unsat_col(:),&
    !$acc& this_type%fsat_bef_col(:),&
    !$acc& this_type%lake_soilc_col(:,:),&
    !$acc& this_type%totcolch4_col(:),&
    !$acc& this_type%annsum_counter_col(:),&
    !$acc& this_type%tempavg_somhr_col(:),&
    !$acc& this_type%annavg_somhr_col(:),&
    !$acc& this_type%tempavg_finrw_col(:),&
    !$acc& this_type%annavg_finrw_col(:),&
    !$acc& this_type%sif_col(:),&
    !$acc& this_type%ch4stress_unsat_col(:,:),&
    !$acc& this_type%ch4stress_sat_col(:,:),&
    !$acc& this_type%qflx_surf_lag_col(:),&
    !$acc& this_type%finundated_lag_col(:),&
    !$acc& this_type%layer_sat_lag_col(:,:),&
    !$acc& this_type%zwt0_col(:),&
    !$acc& this_type%f0_col(:),&
    !$acc& this_type%p3_col(:),&
    !$acc& this_type%ph_col(:),&
    !$acc& this_type%ch4_surf_flux_tot_col(:),&
    !$acc& this_type%c_atm_grc(:,:),&
    !$acc& this_type%ch4co2f_grc(:),&
    !$acc& this_type%ch4prodg_grc(:),&
    !$acc& this_type%finundated_col(:),&
    !$acc& this_type%o2stress_unsat_col(:,:),&
    !$acc& this_type%o2stress_sat_col(:,:),&
    !$acc& this_type%conc_o2_sat_col(:,:),&
    !$acc& this_type%conc_o2_unsat_col(:,:),&
    !$acc& this_type%o2_decomp_depth_sat_col(:,:),&
    !$acc& this_type%o2_decomp_depth_unsat_col(:,:),&
    !$acc& this_type%grnd_ch4_cond_patch(:),&
    !$acc& this_type%grnd_ch4_cond_col(:))
  end subroutine deepcopy_ch4_type
  subroutine deepcopy_decomp_cascade_type(this_type)
    type(decomp_cascade_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%cascade_step_name(:),&
    !$acc& this_type%cascade_donor_pool(:),&
    !$acc& this_type%cascade_receiver_pool(:),&
    !$acc& this_type%floating_cn_ratio_decomp_pools(:),&
    !$acc& this_type%floating_cp_ratio_decomp_pools(:),&
    !$acc& this_type%decomp_pool_name_restart(:),&
    !$acc& this_type%decomp_pool_name_history(:),&
    !$acc& this_type%decomp_pool_name_long(:),&
    !$acc& this_type%decomp_pool_name_short(:),&
    !$acc& this_type%is_litter(:),&
    !$acc& this_type%is_soil(:),&
    !$acc& this_type%is_cwd(:),&
    !$acc& this_type%initial_cn_ratio(:),&
    !$acc& this_type%initial_cp_ratio(:),&
    !$acc& this_type%initial_stock(:),&
    !$acc& this_type%is_metabolic(:),&
    !$acc& this_type%is_cellulose(:),&
    !$acc& this_type%is_lignin(:),&
    !$acc& this_type%spinup_factor(:),&
    !$acc& this_type%decomp_k_pools(:))
  end subroutine deepcopy_decomp_cascade_type
  subroutine deepcopy_crop_type(this_type)
    type(crop_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%nyrs_crop_active_patch(:),&
    !$acc& this_type%croplive_patch(:),&
    !$acc& this_type%cropplant_patch(:),&
    !$acc& this_type%harvdate_patch(:),&
    !$acc& this_type%fertnitro_patch(:),&
    !$acc& this_type%gddplant_patch(:),&
    !$acc& this_type%gddtsoi_patch(:),&
    !$acc& this_type%crpyld_patch(:),&
    !$acc& this_type%dmyield_patch(:),&
    !$acc& this_type%vf_patch(:),&
    !$acc& this_type%cphase_patch(:),&
    !$acc& this_type%latbaset_patch(:),&
    !$acc& this_type%cvt_patch(:),&
    !$acc& this_type%cvp_patch(:),&
    !$acc& this_type%plantmonth_patch(:),&
    !$acc& this_type%plantday_patch(:),&
    !$acc& this_type%harvday_patch(:),&
    !$acc& this_type%xt_patch(:,:),&
    !$acc& this_type%xp_patch(:,:),&
    !$acc& this_type%xt_bar_patch(:,:),&
    !$acc& this_type%xp_bar_patch(:,:),&
    !$acc& this_type%prev_xt_bar_patch(:,:),&
    !$acc& this_type%prev_xp_bar_patch(:,:),&
    !$acc& this_type%p2eto_patch(:,:),&
    !$acc& this_type%p2eto_bar_patch(:,:),&
    !$acc& this_type%prev_p2eto_bar_patch(:,:),&
    !$acc& this_type%p2e_rm_patch(:,:),&
    !$acc& this_type%eto_patch(:,:),&
    !$acc& this_type%baset_mapping,&
    !$acc& this_type%baset_latvary_intercept,&
    !$acc& this_type%baset_latvary_slope)
  end subroutine deepcopy_crop_type
  subroutine deepcopy_dust_type(this_type)
    type(dust_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%flx_mss_vrt_dst_patch(:,:),&
    !$acc& this_type%flx_mss_vrt_dst_tot_patch(:),&
    !$acc& this_type%vlc_trb_patch(:,:),&
    !$acc& this_type%vlc_trb_1_patch(:),&
    !$acc& this_type%vlc_trb_2_patch(:),&
    !$acc& this_type%vlc_trb_3_patch(:),&
    !$acc& this_type%vlc_trb_4_patch(:),&
    !$acc& this_type%mbl_bsn_fct_col(:))
  end subroutine deepcopy_dust_type
  subroutine deepcopy_decompbgcparamstype(this_type)
    type(decompbgcparamstype), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%spinup_vector(:),&
    !$acc& this_type%cn_s1_bgc,&
    !$acc& this_type%cn_s2_bgc,&
    !$acc& this_type%cn_s3_bgc,&
    !$acc& this_type%np_s1_new_bgc,&
    !$acc& this_type%np_s2_new_bgc,&
    !$acc& this_type%np_s3_new_bgc,&
    !$acc& this_type%cp_s1_new_bgc,&
    !$acc& this_type%cp_s2_new_bgc,&
    !$acc& this_type%cp_s3_new_bgc,&
    !$acc& this_type%rf_l1s1_bgc,&
    !$acc& this_type%rf_l2s1_bgc,&
    !$acc& this_type%rf_l3s2_bgc,&
    !$acc& this_type%rf_s2s1_bgc,&
    !$acc& this_type%rf_s2s3_bgc,&
    !$acc& this_type%rf_s3s1_bgc,&
    !$acc& this_type%rf_cwdl2_bgc,&
    !$acc& this_type%rf_cwdl3_bgc,&
    !$acc& this_type%tau_l1_bgc,&
    !$acc& this_type%tau_l2_l3_bgc,&
    !$acc& this_type%tau_s1_bgc,&
    !$acc& this_type%tau_s2_bgc,&
    !$acc& this_type%tau_s3_bgc,&
    !$acc& this_type%tau_cwd_bgc,&
    !$acc& this_type%cwd_fcel_bgc,&
    !$acc& this_type%cwd_flig_bgc,&
    !$acc& this_type%k_frag_bgc,&
    !$acc& this_type%minpsi_bgc,&
    !$acc& this_type%nsompools)
  end subroutine deepcopy_decompbgcparamstype
  subroutine deepcopy_decompcnparamstype(this_type)
    type(decompcnparamstype), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%spinup_vector(:),&
    !$acc& this_type%cn_s1_cn,&
    !$acc& this_type%cn_s2_cn,&
    !$acc& this_type%cn_s3_cn,&
    !$acc& this_type%cn_s4_cn,&
    !$acc& this_type%np_s1_new_cn,&
    !$acc& this_type%np_s2_new_cn,&
    !$acc& this_type%np_s3_new_cn,&
    !$acc& this_type%np_s4_new_cn,&
    !$acc& this_type%cp_s1_new_cn,&
    !$acc& this_type%cp_s2_new_cn,&
    !$acc& this_type%cp_s3_new_cn,&
    !$acc& this_type%cp_s4_new_cn,&
    !$acc& this_type%rf_l1s1_cn,&
    !$acc& this_type%rf_l2s2_cn,&
    !$acc& this_type%rf_l3s3_cn,&
    !$acc& this_type%rf_s1s2_cn,&
    !$acc& this_type%rf_s2s3_cn,&
    !$acc& this_type%rf_s3s4_cn,&
    !$acc& this_type%cwd_fcel_cn,&
    !$acc& this_type%cwd_flig_cn,&
    !$acc& this_type%k_l1_cn,&
    !$acc& this_type%k_l2_cn,&
    !$acc& this_type%k_l3_cn,&
    !$acc& this_type%k_s1_cn,&
    !$acc& this_type%k_s2_cn,&
    !$acc& this_type%k_s3_cn,&
    !$acc& this_type%k_s4_cn,&
    !$acc& this_type%k_frag_cn,&
    !$acc& this_type%minpsi_cn,&
    !$acc& this_type%nsompools,&
    !$acc& this_type%nlitpools,&
    !$acc& this_type%ncwdpools)
  end subroutine deepcopy_decompcnparamstype
  subroutine deepcopy_drydepvel_type(this_type)
    type(drydepvel_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%velocity_patch(:,:))
  end subroutine deepcopy_drydepvel_type
  subroutine deepcopy_cngapmortparamstype(this_type)
    type(cngapmortparamstype), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%am,&
    !$acc& this_type%k_mort)
  end subroutine deepcopy_cngapmortparamstype
  subroutine deepcopy_nitrifdenitrifparamstype(this_type)
    type(nitrifdenitrifparamstype), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%k_nitr_max,&
    !$acc& this_type%surface_tension_water,&
    !$acc& this_type%rij_kro_a,&
    !$acc& this_type%rij_kro_alpha,&
    !$acc& this_type%rij_kro_beta,&
    !$acc& this_type%rij_kro_gamma,&
    !$acc& this_type%rij_kro_delta)
  end subroutine deepcopy_nitrifdenitrifparamstype
  subroutine deepcopy_cnndynamicsparamstype(this_type)
    type(cnndynamicsparamstype), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%sf,&
    !$acc& this_type%sf_no3)
  end subroutine deepcopy_cnndynamicsparamstype
  subroutine deepcopy_paramssharetype(this_type)
    type(paramssharetype), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%q10_mr,&
    !$acc& this_type%q10_hr,&
    !$acc& this_type%minpsi,&
    !$acc& this_type%cwd_fcel,&
    !$acc& this_type%cwd_flig,&
    !$acc& this_type%froz_q10,&
    !$acc& this_type%decomp_depth_efolding,&
    !$acc& this_type%mino2lim,&
    !$acc& this_type%organic_max)
  end subroutine deepcopy_paramssharetype
  subroutine deepcopy_cndecompparamstype(this_type)
    type(cndecompparamstype), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%dnp)
  end subroutine deepcopy_cndecompparamstype
end module DeepCopyChemMod
