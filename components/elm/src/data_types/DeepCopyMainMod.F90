module DeepCopyMainMod
  use elm_varctl, only: create_glacier_mec_landunit
  use domainmod,only: domain_params_type
  use atm2lndtype,only: atm2lnd_type
  use lnd2atmtype,only: lnd2atm_type
  use lnd2glcmod,only: lnd2glc_type
  use soilordercontype,only: soilordercon_type
  implicit none
  !public :: deepcopy_domain_params_type
  public :: deepcopy_atm2lnd_type
  public :: deepcopy_lnd2atm_type
  public :: deepcopy_lnd2glc_type
  public :: deepcopy_soilordercon_type

  public ::  deepcopy_main_types
contains

  subroutine deepcopy_main_types(domain_params, atm2lnd_inst, lnd2atm_vars,&
                                  lnd2glc_inst, soilorder_inst)
    type(domain_params_type), intent(inout) :: domain_params
    type(atm2lnd_type), intent(inout) :: atm2lnd_inst
    type(lnd2atm_type), intent(inout) :: lnd2atm_vars
    type(lnd2glc_type), intent(inout) :: lnd2glc_inst
    type(soilordercon_type), intent(inout) :: soilorder_inst

    call deepcopy_atm2lnd_type(atm2lnd_inst)
    call deepcopy_lnd2atm_type(lnd2atm_vars)
    call deepcopy_domain_params_type(domain_params)
    if (create_glacier_mec_landunit) then 
      call deepcopy_lnd2glc_type(lnd2glc_inst)
    end if 
    call deepcopy_soilordercon_type(soilorder_inst)
  end subroutine deepcopy_main_types

  subroutine deepcopy_domain_params_type(this_type)
    type(domain_params_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%lonc(:),&
    !$acc& this_type%latc(:))
  end subroutine deepcopy_domain_params_type
  subroutine deepcopy_atm2lnd_type(this_type)
    type(atm2lnd_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%forc_hdm(:),&
    !$acc& this_type%forc_lnfm(:),&
    !$acc& this_type%forc_u_grc(:),&
    !$acc& this_type%forc_v_grc(:),&
    !$acc& this_type%forc_wind_grc(:),&
    !$acc& this_type%forc_rh_grc(:),&
    !$acc& this_type%forc_hgt_grc(:),&
    !$acc& this_type%forc_hgt_u_grc(:),&
    !$acc& this_type%forc_hgt_t_grc(:),&
    !$acc& this_type%forc_hgt_q_grc(:),&
    !$acc& this_type%forc_vp_grc(:),&
    !$acc& this_type%forc_pco2_grc(:),&
    !$acc& this_type%forc_solad_grc(:,:),&
    !$acc& this_type%forc_solai_grc(:,:),&
    !$acc& this_type%forc_solar_grc(:),&
    !$acc& this_type%forc_ndep_grc(:),&
    !$acc& this_type%forc_pdep_grc(:),&
    !$acc& this_type%forc_pc13o2_grc(:),&
    !$acc& this_type%forc_po2_grc(:),&
    !$acc& this_type%forc_aer_grc(:,:),&
    !$acc& this_type%forc_pch4_grc(:),&
    !$acc& this_type%forc_t_not_downscaled_grc(:),&
    !$acc& this_type%forc_q_not_downscaled_grc(:),&
    !$acc& this_type%forc_pbot_not_downscaled_grc(:),&
    !$acc& this_type%forc_th_not_downscaled_grc(:),&
    !$acc& this_type%forc_rho_not_downscaled_grc(:),&
    !$acc& this_type%forc_lwrad_not_downscaled_grc(:),&
    !$acc& this_type%forc_rain_not_downscaled_grc(:),&
    !$acc& this_type%forc_snow_not_downscaled_grc(:),&
    !$acc& this_type%forc_t_downscaled_col(:),&
    !$acc& this_type%forc_q_downscaled_col(:),&
    !$acc& this_type%forc_pbot_downscaled_col(:),&
    !$acc& this_type%forc_th_downscaled_col(:),&
    !$acc& this_type%forc_rho_downscaled_col(:),&
    !$acc& this_type%forc_lwrad_downscaled_col(:),&
    !$acc& this_type%forc_rain_downscaled_col(:),&
    !$acc& this_type%forc_snow_downscaled_col(:),&
    !$acc& this_type%forc_flood_grc(:),&
    !$acc& this_type%volr_grc(:),&
    !$acc& this_type%volrmch_grc(:),&
    !$acc& this_type%supply_grc(:),&
    !$acc& this_type%deficit_grc(:),&
    !$acc& this_type%bc_precip_grc(:),&
    !$acc& this_type%af_precip_grc(:),&
    !$acc& this_type%af_uwind_grc(:),&
    !$acc& this_type%af_vwind_grc(:),&
    !$acc& this_type%af_tbot_grc(:),&
    !$acc& this_type%af_pbot_grc(:),&
    !$acc& this_type%af_shum_grc(:),&
    !$acc& this_type%af_swdn_grc(:),&
    !$acc& this_type%af_lwdn_grc(:),&
    !$acc& this_type%fsd24_patch(:),&
    !$acc& this_type%fsd240_patch(:),&
    !$acc& this_type%fsi24_patch(:),&
    !$acc& this_type%fsi240_patch(:),&
    !$acc& this_type%prec10_patch(:),&
    !$acc& this_type%prec60_patch(:),&
    !$acc& this_type%prec365_patch(:),&
    !$acc& this_type%prec24_patch(:),&
    !$acc& this_type%rh24_patch(:),&
    !$acc& this_type%wind24_patch(:))
  end subroutine deepcopy_atm2lnd_type
  subroutine deepcopy_lnd2atm_type(this_type)
    type(lnd2atm_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%t_rad_grc(:),&
    !$acc& this_type%t_ref2m_grc(:),&
    !$acc& this_type%q_ref2m_grc(:),&
    !$acc& this_type%u_ref10m_grc(:),&
    !$acc& this_type%h2osno_grc(:),&
    !$acc& this_type%h2osoi_vol_grc(:,:),&
    !$acc& this_type%albd_grc(:,:),&
    !$acc& this_type%albi_grc(:,:),&
    !$acc& this_type%taux_grc(:),&
    !$acc& this_type%tauy_grc(:),&
    !$acc& this_type%eflx_lwrad_out_grc(:),&
    !$acc& this_type%eflx_sh_tot_grc(:),&
    !$acc& this_type%eflx_lh_tot_grc(:),&
    !$acc& this_type%qflx_evap_tot_grc(:),&
    !$acc& this_type%fsa_grc(:),&
    !$acc& this_type%nee_grc(:),&
    !$acc& this_type%nem_grc(:),&
    !$acc& this_type%ram1_grc(:),&
    !$acc& this_type%fv_grc(:),&
    !$acc& this_type%flxdst_grc(:,:),&
    !$acc& this_type%flux_ch4_grc(:),&
    !$acc& this_type%qflx_rofliq_grc(:),&
    !$acc& this_type%qflx_rofliq_qsur_grc(:),&
    !$acc& this_type%coszen_str(:),&
    !$acc& this_type%qflx_rofliq_qsurp_grc(:),&
    !$acc& this_type%qflx_rofliq_qsub_grc(:),&
    !$acc& this_type%qflx_rofliq_qsubp_grc(:),&
    !$acc& this_type%qflx_rofliq_qgwl_grc(:),&
    !$acc& this_type%qflx_irr_demand_grc(:),&
    !$acc& this_type%qflx_rofice_grc(:),&
    !$acc& this_type%qflx_rofliq_qsur_doc_grc(:),&
    !$acc& this_type%qflx_rofliq_qsur_dic_grc(:),&
    !$acc& this_type%qflx_rofliq_qsub_doc_grc(:),&
    !$acc& this_type%qflx_rofliq_qsub_dic_grc(:),&
    !$acc& this_type%zwt_grc(:),&
    !$acc& this_type%t_grnd_grc(:),&
    !$acc& this_type%t_soisno_grc(:,:),&
    !$acc& this_type%tqsur_grc(:),&
    !$acc& this_type%tqsub_grc(:),&
    !$acc& this_type%wslake_grc(:),&
    !$acc& this_type%flxvoc_grc(:,:),&
    !$acc& this_type%ddvel_grc(:,:))
  end subroutine deepcopy_lnd2atm_type
  subroutine deepcopy_lnd2glc_type(this_type)
    type(lnd2glc_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%tsrf_grc(:,:),&
    !$acc& this_type%topo_grc(:,:),&
    !$acc& this_type%qice_grc(:,:))
  end subroutine deepcopy_lnd2glc_type

  subroutine deepcopy_soilordercon_type(this_type)
    type(soilordercon_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%smax(:),&
    !$acc& this_type%ks_sorption(:),&
    !$acc& this_type%r_weather(:),&
    !$acc& this_type%r_adsorp(:),&
    !$acc& this_type%r_desorp(:),&
    !$acc& this_type%r_occlude(:),&
    !$acc& this_type%k_s1_biochem(:),&
    !$acc& this_type%k_s2_biochem(:),&
    !$acc& this_type%k_s3_biochem(:),&
    !$acc& this_type%k_s4_biochem(:))
  end subroutine deepcopy_soilordercon_type
end module DeepCopyMainMod
