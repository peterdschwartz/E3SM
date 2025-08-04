module DeepCopyPhysMod
  use aerosoltype,only: aerosol_type
  use canopystatetype,only: canopystate_type
  use photosynthesistype,only: photosyns_type
  use solarabsorbedtype,only: solarabs_type
  use surfacealbedotype,only: surfalb_type
  use urbanparamstype,only: urbanparams_type
  use surfaceradiationmod,only: surfrad_type
  use energyfluxtype,only: energyflux_type
  use soilhydrologytype,only: soilhydrology_type
  use lakestatetype,only: lakestate_type
  use frictionvelocitytype,only: frictionvel_type
  implicit none
  public :: deepcopy_aerosol_type
  public :: deepcopy_canopystate_type
  public :: deepcopy_photosyns_type
  public :: deepcopy_solarabs_type
  public :: deepcopy_surfalb_type
  public :: deepcopy_urbanparams_type
  public :: deepcopy_surfrad_type
  public :: deepcopy_energyflux_type
  public :: deepcopy_soilhydrology_type
  public :: deepcopy_lakestate_type
  public :: deepcopy_frictionvel_type

  public :: deepcopy_biogeophys_types
contains

  subroutine deepcopy_biogeophys_types(aerosol_vars, canopystate_vars, &
                                        photosyns_vars, solarabs_vars,surfalb_vars,&
                                        urbanparams_vars, surfrad_vars, energyflux_vars, &
                                        soilhydrology_vars, lakestate_vars, frictionvel_vars)

    type(aerosol_type)     , intent(inout) :: aerosol_vars
    type(canopystate_type) , intent(inout) :: canopystate_vars
    type(photosyns_type),intent(inout) :: photosyns_vars
    type(solarabs_type),intent(inout) :: solarabs_vars
    type(surfalb_type),intent(inout) :: surfalb_vars
    type(urbanparams_type),intent(inout) :: urbanparams_vars
    type(surfrad_type),intent(inout) :: surfrad_vars
    type(energyflux_type),intent(inout) :: energyflux_vars
    type(soilhydrology_type),intent(inout) :: soilhydrology_vars
    type(lakestate_type),intent(inout) :: lakestate_vars
    type(frictionvel_type),intent(inout) :: frictionvel_vars

    call deepcopy_aerosol_type(aerosol_vars)
    call deepcopy_canopystate_type(canopystate_vars)
    call deepcopy_photosyns_type(photosyns_vars)
    call deepcopy_solarabs_type(solarabs_vars)
    call deepcopy_surfalb_type(surfalb_vars)
    call deepcopy_urbanparams_type(urbanparams_vars)
    call deepcopy_surfrad_type(surfrad_vars)
    call deepcopy_energyflux_type(energyflux_vars)
    call deepcopy_soilhydrology_type(soilhydrology_vars)
    call deepcopy_lakestate_type(lakestate_vars)
    call deepcopy_frictionvel_type(frictionvel_vars)

  end subroutine deepcopy_biogeophys_types

  subroutine deepcopy_aerosol_type(this_type)
    type(aerosol_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%flx_dst_dep_dry1_col(:),&
    !$acc& this_type%flx_dst_dep_wet1_col(:),&
    !$acc& this_type%flx_dst_dep_dry2_col(:),&
    !$acc& this_type%flx_dst_dep_wet2_col(:),&
    !$acc& this_type%flx_dst_dep_dry3_col(:),&
    !$acc& this_type%flx_dst_dep_wet3_col(:),&
    !$acc& this_type%flx_dst_dep_dry4_col(:),&
    !$acc& this_type%flx_dst_dep_wet4_col(:),&
    !$acc& this_type%flx_dst_dep_col(:),&
    !$acc& this_type%flx_bc_dep_dry_col(:),&
    !$acc& this_type%flx_bc_dep_wet_col(:),&
    !$acc& this_type%flx_bc_dep_pho_col(:),&
    !$acc& this_type%flx_bc_dep_phi_col(:),&
    !$acc& this_type%flx_bc_dep_col(:),&
    !$acc& this_type%flx_oc_dep_dry_col(:),&
    !$acc& this_type%flx_oc_dep_wet_col(:),&
    !$acc& this_type%flx_oc_dep_pho_col(:),&
    !$acc& this_type%flx_oc_dep_phi_col(:),&
    !$acc& this_type%flx_oc_dep_col(:),&
    !$acc& this_type%mss_bcpho_col(:,:),&
    !$acc& this_type%mss_bcphi_col(:,:),&
    !$acc& this_type%mss_bctot_col(:,:),&
    !$acc& this_type%mss_bc_col_col(:),&
    !$acc& this_type%mss_bc_top_col(:),&
    !$acc& this_type%mss_ocpho_col(:,:),&
    !$acc& this_type%mss_ocphi_col(:,:),&
    !$acc& this_type%mss_octot_col(:,:),&
    !$acc& this_type%mss_oc_col_col(:),&
    !$acc& this_type%mss_oc_top_col(:),&
    !$acc& this_type%mss_dst1_col(:,:),&
    !$acc& this_type%mss_dst2_col(:,:),&
    !$acc& this_type%mss_dst3_col(:,:),&
    !$acc& this_type%mss_dst4_col(:,:),&
    !$acc& this_type%mss_dsttot_col(:,:),&
    !$acc& this_type%mss_dst_col_col(:),&
    !$acc& this_type%mss_dst_top_col(:),&
    !$acc& this_type%mss_cnc_bcphi_col(:,:),&
    !$acc& this_type%mss_cnc_bcpho_col(:,:),&
    !$acc& this_type%mss_cnc_ocphi_col(:,:),&
    !$acc& this_type%mss_cnc_ocpho_col(:,:),&
    !$acc& this_type%mss_cnc_dst1_col(:,:),&
    !$acc& this_type%mss_cnc_dst2_col(:,:),&
    !$acc& this_type%mss_cnc_dst3_col(:,:),&
    !$acc& this_type%mss_cnc_dst4_col(:,:))
  end subroutine deepcopy_aerosol_type
  subroutine deepcopy_canopystate_type(this_type)
    type(canopystate_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%frac_veg_nosno_patch(:),&
    !$acc& this_type%frac_veg_nosno_alb_patch(:),&
    !$acc& this_type%tlai_patch(:),&
    !$acc& this_type%tsai_patch(:),&
    !$acc& this_type%tlai_hist_patch(:),&
    !$acc& this_type%tsai_hist_patch(:),&
    !$acc& this_type%htop_hist_patch(:),&
    !$acc& this_type%elai_patch(:),&
    !$acc& this_type%elai240_patch(:),&
    !$acc& this_type%esai_patch(:),&
    !$acc& this_type%laisun_patch(:),&
    !$acc& this_type%laisha_patch(:),&
    !$acc& this_type%laisun_z_patch(:,:),&
    !$acc& this_type%laisha_z_patch(:,:),&
    !$acc& this_type%mlaidiff_patch(:),&
    !$acc& this_type%annlai_patch(:,:),&
    !$acc& this_type%htop_patch(:),&
    !$acc& this_type%hbot_patch(:),&
    !$acc& this_type%displa_patch(:),&
    !$acc& this_type%fsun_patch(:),&
    !$acc& this_type%fsun24_patch(:),&
    !$acc& this_type%fsun240_patch(:),&
    !$acc& this_type%alt_col(:),&
    !$acc& this_type%altmax_col(:),&
    !$acc& this_type%altmax_lastyear_col(:),&
    !$acc& this_type%alt_indx_col(:),&
    !$acc& this_type%altmax_indx_col(:),&
    !$acc& this_type%altmax_lastyear_indx_col(:),&
    !$acc& this_type%dewmx_patch(:),&
    !$acc& this_type%dleaf_patch(:),&
    !$acc& this_type%lbl_rsc_h2o_patch(:),&
    !$acc& this_type%vegwp_patch(:,:))
  end subroutine deepcopy_canopystate_type
  subroutine deepcopy_photosyns_type(this_type)
    type(photosyns_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%c3flag_patch(:),&
    !$acc& this_type%ac_patch(:,:),&
    !$acc& this_type%aj_patch(:,:),&
    !$acc& this_type%ap_patch(:,:),&
    !$acc& this_type%ag_patch(:,:),&
    !$acc& this_type%an_patch(:,:),&
    !$acc& this_type%vcmax_z_patch(:,:),&
    !$acc& this_type%cp_patch(:),&
    !$acc& this_type%kc_patch(:),&
    !$acc& this_type%ko_patch(:),&
    !$acc& this_type%qe_patch(:),&
    !$acc& this_type%tpu_z_patch(:,:),&
    !$acc& this_type%kp_z_patch(:,:),&
    !$acc& this_type%theta_cj_patch(:),&
    !$acc& this_type%bbb_patch(:),&
    !$acc& this_type%mbb_patch(:),&
    !$acc& this_type%gb_mol_patch(:),&
    !$acc& this_type%gs_mol_patch(:,:),&
    !$acc& this_type%rh_leaf_patch(:),&
    !$acc& this_type%psnsun_patch(:),&
    !$acc& this_type%psnsha_patch(:),&
    !$acc& this_type%c13_psnsun_patch(:),&
    !$acc& this_type%c13_psnsha_patch(:),&
    !$acc& this_type%c14_psnsun_patch(:),&
    !$acc& this_type%c14_psnsha_patch(:),&
    !$acc& this_type%psnsun_z_patch(:,:),&
    !$acc& this_type%psnsha_z_patch(:,:),&
    !$acc& this_type%psnsun_wc_patch(:),&
    !$acc& this_type%psnsha_wc_patch(:),&
    !$acc& this_type%psnsun_wj_patch(:),&
    !$acc& this_type%psnsha_wj_patch(:),&
    !$acc& this_type%psnsun_wp_patch(:),&
    !$acc& this_type%psnsha_wp_patch(:),&
    !$acc& this_type%fpsn_patch(:),&
    !$acc& this_type%fpsn_wc_patch(:),&
    !$acc& this_type%fpsn_wj_patch(:),&
    !$acc& this_type%fpsn_wp_patch(:),&
    !$acc& this_type%lmrsun_z_patch(:,:),&
    !$acc& this_type%lmrsha_z_patch(:,:),&
    !$acc& this_type%lmrsun_patch(:),&
    !$acc& this_type%lmrsha_patch(:),&
    !$acc& this_type%alphapsnsun_patch(:),&
    !$acc& this_type%alphapsnsha_patch(:),&
    !$acc& this_type%rc13_canair_patch(:),&
    !$acc& this_type%rc13_psnsun_patch(:),&
    !$acc& this_type%rc13_psnsha_patch(:),&
    !$acc& this_type%cisun_z_patch(:,:),&
    !$acc& this_type%cisha_z_patch(:,:),&
    !$acc& this_type%rssun_z_patch(:,:),&
    !$acc& this_type%rssha_z_patch(:,:),&
    !$acc& this_type%rssun_patch(:),&
    !$acc& this_type%rssha_patch(:),&
    !$acc& this_type%psncanopy_patch(:),&
    !$acc& this_type%lmrcanopy_patch(:),&
    !$acc& this_type%ac_phs_patch(:,:,:),&
    !$acc& this_type%aj_phs_patch(:,:,:),&
    !$acc& this_type%ap_phs_patch(:,:,:),&
    !$acc& this_type%ag_phs_patch(:,:,:),&
    !$acc& this_type%an_sun_patch(:,:),&
    !$acc& this_type%an_sha_patch(:,:),&
    !$acc& this_type%vcmax_z_phs_patch(:,:,:),&
    !$acc& this_type%tpu_z_phs_patch(:,:,:),&
    !$acc& this_type%kp_z_phs_patch(:,:,:),&
    !$acc& this_type%gs_mol_sun_patch(:,:),&
    !$acc& this_type%gs_mol_sha_patch(:,:))
  end subroutine deepcopy_photosyns_type
  subroutine deepcopy_solarabs_type(this_type)
    type(solarabs_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%fsa_patch(:),&
    !$acc& this_type%fsa_u_patch(:),&
    !$acc& this_type%fsa_r_patch(:),&
    !$acc& this_type%parsun_z_patch(:,:),&
    !$acc& this_type%parsha_z_patch(:,:),&
    !$acc& this_type%sabv_patch(:),&
    !$acc& this_type%sabg_patch(:),&
    !$acc& this_type%sabg_lyr_patch(:,:),&
    !$acc& this_type%sabg_pen_patch(:),&
    !$acc& this_type%sabg_soil_patch(:),&
    !$acc& this_type%sabg_snow_patch(:),&
    !$acc& this_type%sabg_chk_patch(:),&
    !$acc& this_type%sabs_roof_dir_lun(:,:),&
    !$acc& this_type%sabs_roof_dif_lun(:,:),&
    !$acc& this_type%sabs_sunwall_dir_lun(:,:),&
    !$acc& this_type%sabs_sunwall_dif_lun(:,:),&
    !$acc& this_type%sabs_shadewall_dir_lun(:,:),&
    !$acc& this_type%sabs_shadewall_dif_lun(:,:),&
    !$acc& this_type%sabs_improad_dir_lun(:,:),&
    !$acc& this_type%sabs_improad_dif_lun(:,:),&
    !$acc& this_type%sabs_perroad_dir_lun(:,:),&
    !$acc& this_type%sabs_perroad_dif_lun(:,:),&
    !$acc& this_type%sub_surf_abs_sw_col(:),&
    !$acc& this_type%fsr_patch(:),&
    !$acc& this_type%fsr_nir_d_patch(:),&
    !$acc& this_type%fsr_nir_i_patch(:),&
    !$acc& this_type%fsr_nir_d_ln_patch(:),&
    !$acc& this_type%fsds_nir_d_patch(:),&
    !$acc& this_type%fsds_nir_i_patch(:),&
    !$acc& this_type%fsds_nir_d_ln_patch(:))
  end subroutine deepcopy_solarabs_type
  subroutine deepcopy_surfalb_type(this_type)
    type(surfalb_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%coszen_col(:),&
    !$acc& this_type%albgrd_col(:,:),&
    !$acc& this_type%albgri_col(:,:),&
    !$acc& this_type%albsnd_hst_col(:,:),&
    !$acc& this_type%albsni_hst_col(:,:),&
    !$acc& this_type%albsod_col(:,:),&
    !$acc& this_type%albsoi_col(:,:),&
    !$acc& this_type%albgrd_pur_col(:,:),&
    !$acc& this_type%albgri_pur_col(:,:),&
    !$acc& this_type%albgrd_bc_col(:,:),&
    !$acc& this_type%albgri_bc_col(:,:),&
    !$acc& this_type%albgrd_oc_col(:,:),&
    !$acc& this_type%albgri_oc_col(:,:),&
    !$acc& this_type%albgrd_dst_col(:,:),&
    !$acc& this_type%albgri_dst_col(:,:),&
    !$acc& this_type%albd_patch(:,:),&
    !$acc& this_type%albi_patch(:,:),&
    !$acc& this_type%ftdd_patch(:,:),&
    !$acc& this_type%ftid_patch(:,:),&
    !$acc& this_type%ftii_patch(:,:),&
    !$acc& this_type%fabd_patch(:,:),&
    !$acc& this_type%fabd_sun_patch(:,:),&
    !$acc& this_type%fabd_sha_patch(:,:),&
    !$acc& this_type%fabi_patch(:,:),&
    !$acc& this_type%fabi_sun_patch(:,:),&
    !$acc& this_type%fabi_sha_patch(:,:),&
    !$acc& this_type%fabd_sun_z_patch(:,:),&
    !$acc& this_type%fabd_sha_z_patch(:,:),&
    !$acc& this_type%fabi_sun_z_patch(:,:),&
    !$acc& this_type%fabi_sha_z_patch(:,:),&
    !$acc& this_type%flx_absdv_col(:,:),&
    !$acc& this_type%flx_absdn_col(:,:),&
    !$acc& this_type%flx_absiv_col(:,:),&
    !$acc& this_type%flx_absin_col(:,:),&
    !$acc& this_type%fsun_z_patch(:,:),&
    !$acc& this_type%tlai_z_patch(:,:),&
    !$acc& this_type%tsai_z_patch(:,:),&
    !$acc& this_type%ncan_patch(:),&
    !$acc& this_type%nrad_patch(:),&
    !$acc& this_type%vcmaxcintsun_patch(:),&
    !$acc& this_type%vcmaxcintsha_patch(:))
  end subroutine deepcopy_surfalb_type
  subroutine deepcopy_urbanparams_type(this_type)
    type(urbanparams_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%tk_wall(:,:),&
    !$acc& this_type%tk_roof(:,:),&
    !$acc& this_type%cv_wall(:,:),&
    !$acc& this_type%cv_roof(:,:),&
    !$acc& this_type%t_building_max(:),&
    !$acc& this_type%t_building_min(:),&
    !$acc& this_type%tk_improad(:,:),&
    !$acc& this_type%cv_improad(:,:),&
    !$acc& this_type%thick_wall(:),&
    !$acc& this_type%thick_roof(:),&
    !$acc& this_type%nlev_improad(:),&
    !$acc& this_type%vf_sr(:),&
    !$acc& this_type%vf_wr(:),&
    !$acc& this_type%vf_sw(:),&
    !$acc& this_type%vf_rw(:),&
    !$acc& this_type%vf_ww(:),&
    !$acc& this_type%wind_hgt_canyon(:),&
    !$acc& this_type%em_roof(:),&
    !$acc& this_type%em_improad(:),&
    !$acc& this_type%em_perroad(:),&
    !$acc& this_type%em_wall(:),&
    !$acc& this_type%alb_roof_dir(:,:),&
    !$acc& this_type%alb_roof_dif(:,:),&
    !$acc& this_type%alb_improad_dir(:,:),&
    !$acc& this_type%alb_perroad_dir(:,:),&
    !$acc& this_type%alb_improad_dif(:,:),&
    !$acc& this_type%alb_perroad_dif(:,:),&
    !$acc& this_type%alb_wall_dir(:,:),&
    !$acc& this_type%alb_wall_dif(:,:),&
    !$acc& this_type%eflx_traffic_factor(:))
  end subroutine deepcopy_urbanparams_type
  subroutine deepcopy_surfrad_type(this_type)
    type(surfrad_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%sfc_frc_aer_patch(:),&
    !$acc& this_type%sfc_frc_bc_patch(:),&
    !$acc& this_type%sfc_frc_oc_patch(:),&
    !$acc& this_type%sfc_frc_dst_patch(:),&
    !$acc& this_type%sfc_frc_aer_sno_patch(:),&
    !$acc& this_type%sfc_frc_bc_sno_patch(:),&
    !$acc& this_type%sfc_frc_oc_sno_patch(:),&
    !$acc& this_type%sfc_frc_dst_sno_patch(:),&
    !$acc& this_type%parveg_ln_patch(:),&
    !$acc& this_type%fsr_vis_d_patch(:),&
    !$acc& this_type%fsr_vis_d_ln_patch(:),&
    !$acc& this_type%fsr_vis_i_patch(:),&
    !$acc& this_type%fsr_sno_vd_patch(:),&
    !$acc& this_type%fsr_sno_nd_patch(:),&
    !$acc& this_type%fsr_sno_vi_patch(:),&
    !$acc& this_type%fsr_sno_ni_patch(:),&
    !$acc& this_type%fsds_vis_d_patch(:),&
    !$acc& this_type%fsds_vis_i_patch(:),&
    !$acc& this_type%fsds_vis_d_ln_patch(:),&
    !$acc& this_type%fsds_vis_i_ln_patch(:),&
    !$acc& this_type%fsds_sno_vd_patch(:),&
    !$acc& this_type%fsds_sno_nd_patch(:),&
    !$acc& this_type%fsds_sno_vi_patch(:),&
    !$acc& this_type%fsds_sno_ni_patch(:))
  end subroutine deepcopy_surfrad_type
  subroutine deepcopy_energyflux_type(this_type)
    type(energyflux_type), intent(inout) :: this_type
    !!!$acc enter data copyin(this_type)
    !!!$acc enter data copyin(&
    !!!$acc& this_type%eflx_h2osfc_to_snow_col(:),&
    !!!$acc& this_type%eflx_sh_snow_patch(:),&
    !!!$acc& this_type%eflx_sh_soil_patch(:),&
    !!!$acc& this_type%eflx_sh_h2osfc_patch(:),&
    !!!$acc& this_type%eflx_sh_tot_patch(:),&
    !!!$acc& this_type%eflx_sh_tot_u_patch(:),&
    !!!$acc& this_type%eflx_sh_tot_r_patch(:),&
    !!!$acc& this_type%eflx_sh_grnd_patch(:),&
    !!!$acc& this_type%eflx_sh_veg_patch(:),&
    !!!$acc& this_type%eflx_lh_tot_u_patch(:),&
    !!!$acc& this_type%eflx_lh_tot_patch(:),&
    !!!$acc& this_type%eflx_lh_tot_r_patch(:),&
    !!!$acc& this_type%eflx_lh_grnd_patch(:),&
    !!!$acc& this_type%eflx_lh_vege_patch(:),&
    !!!$acc& this_type%eflx_lh_vegt_patch(:),&
    !!!$acc& this_type%eflx_soil_grnd_patch(:),&
    !!!$acc& this_type%eflx_soil_grnd_u_patch(:),&
    !!!$acc& this_type%eflx_soil_grnd_r_patch(:),&
    !!!$acc& this_type%eflx_lwrad_net_patch(:),&
    !!!$acc& this_type%eflx_lwrad_net_u_patch(:),&
    !!!$acc& this_type%eflx_lwrad_net_r_patch(:),&
    !!!$acc& this_type%eflx_lwrad_out_patch(:),&
    !!!$acc& this_type%eflx_lwrad_out_u_patch(:),&
    !!!$acc& this_type%eflx_lwrad_out_r_patch(:),&
    !!!$acc& this_type%eflx_gnet_patch(:),&
    !!!$acc& this_type%eflx_grnd_lake_patch(:),&
    !!!$acc& this_type%eflx_dynbal_grc(:),&
    !!!$acc& this_type%eflx_bot_col(:),&
    !!!$acc& this_type%eflx_snomelt_col(:),&
    !!!$acc& this_type%eflx_snomelt_r_col(:),&
    !!!$acc& this_type%eflx_snomelt_u_col(:),&
    !!!$acc& this_type%eflx_fgr12_col(:),&
    !!!$acc& this_type%eflx_fgr_col(:,:),&
    !!!$acc& this_type%eflx_building_heat_col(:),&
    !!!$acc& this_type%eflx_urban_ac_col(:),&
    !!!$acc& this_type%eflx_urban_heat_col(:),&
    !!!$acc& this_type%eflx_wasteheat_patch(:),&
    !!!$acc& this_type%eflx_traffic_patch(:),&
    !!!$acc& this_type%eflx_heat_from_ac_patch(:),&
    !!!$acc& this_type%eflx_heat_from_ac_lun(:),&
    !!!$acc& this_type%eflx_traffic_lun(:),&
    !!!$acc& this_type%eflx_wasteheat_lun(:),&
    !!!$acc& this_type%eflx_anthro_patch(:),&
    !!!$acc& this_type%eflx_hs_top_snow_col(:),&
    !!!$acc& this_type%eflx_hs_h2osfc_col(:),&
    !!!$acc& this_type%eflx_hs_soil_col(:),&
    !!!$acc& this_type%eflx_sabg_lyr_col(:,:),&
    !!!$acc& this_type%eflx_dhsdt_col(:),&
    !!!$acc& this_type%dgnetdt_patch(:),&
    !!!$acc& this_type%cgrnd_patch(:),&
    !!!$acc& this_type%cgrndl_patch(:),&
    !!!$acc& this_type%cgrnds_patch(:),&
    !!!$acc& this_type%dlrad_patch(:),&
    !!!$acc& this_type%ulrad_patch(:),&
    !!!$acc& this_type%netrad_patch(:),&
    !!!$acc& this_type%taux_patch(:),&
    !!!$acc& this_type%tauy_patch(:),&
    !!!$acc& this_type%canopy_cond_patch(:),&
    !!!$acc& this_type%htvp_col(:),&
    !!!$acc& this_type%eflx_soil_grnd_col(:),&
    !!!$acc& this_type%eflx_rnet_soil_col(:),&
    !!!$acc& this_type%eflx_fgr0_soil_col(:),&
    !!!$acc& this_type%eflx_fgr0_snow_col(:),&
    !!!$acc& this_type%eflx_fgr0_h2osfc_col(:),&
    !!!$acc& this_type%rresis_patch(:,:),&
    !!!$acc& this_type%btran_patch(:),&
    !!!$acc& this_type%btran2_patch(:),&
    !!!$acc& this_type%bsun_patch(:),&
    !!!$acc& this_type%bsha_patch(:),&
    !!!$acc& this_type%errsoi_patch(:),&
    !!!$acc& this_type%errsoi_col(:),&
    !!!$acc& this_type%errseb_patch(:),&
    !!!$acc& this_type%errseb_col(:),&
    !!!$acc& this_type%errsol_patch(:),&
    !!!$acc& this_type%errsol_col(:),&
    !!!$acc& this_type%errlon_patch(:),&
    !!!$acc& this_type%errlon_col(:))
  end subroutine deepcopy_energyflux_type
  subroutine deepcopy_soilhydrology_type(this_type)
    type(soilhydrology_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%frost_table_col(:),&
    !$acc& this_type%zwt_col(:),&
    !$acc& this_type%qflx_bot_col(:),&
    !$acc& this_type%zwt_perched_col(:),&
    !$acc& this_type%zwts_col(:),&
    !$acc& this_type%wa_col(:),&
    !$acc& this_type%beg_wa_grc(:),&
    !$acc& this_type%end_wa_grc(:),&
    !$acc& this_type%qcharge_col(:),&
    !$acc& this_type%fracice_col(:,:),&
    !$acc& this_type%icefrac_col(:,:),&
    !$acc& this_type%fcov_col(:),&
    !$acc& this_type%fsat_col(:),&
    !$acc& this_type%h2osfc_thresh_col(:),&
    !$acc& this_type%hkdepth_col(:),&
    !$acc& this_type%b_infil_col(:),&
    !$acc& this_type%ds_col(:),&
    !$acc& this_type%dsmax_col(:),&
    !$acc& this_type%wsvic_col(:),&
    !$acc& this_type%depth_col(:,:),&
    !$acc& this_type%porosity_col(:,:),&
    !$acc& this_type%vic_elm_fract_col(:,:,:),&
    !$acc& this_type%c_param_col(:),&
    !$acc& this_type%expt_col(:,:),&
    !$acc& this_type%ksat_col(:,:),&
    !$acc& this_type%phi_s_col(:,:),&
    !$acc& this_type%moist_col(:,:),&
    !$acc& this_type%moist_vol_col(:,:),&
    !$acc& this_type%max_moist_col(:,:),&
    !$acc& this_type%max_infil_col(:),&
    !$acc& this_type%i_0_col(:),&
    !$acc& this_type%ice_col(:,:),&
    !$acc& this_type%h2osfcflag,&
    !$acc& this_type%origflag)
  end subroutine deepcopy_soilhydrology_type
  subroutine deepcopy_lakestate_type(this_type)
    type(lakestate_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%etal_col(:),&
    !$acc& this_type%lakefetch_col(:),&
    !$acc& this_type%lakeresist_col(:),&
    !$acc& this_type%savedtke1_col(:),&
    !$acc& this_type%lake_icefrac_col(:,:),&
    !$acc& this_type%lake_icethick_col(:),&
    !$acc& this_type%ust_lake_col(:),&
    !$acc& this_type%ram1_lake_patch(:),&
    !$acc& this_type%lake_raw_col(:),&
    !$acc& this_type%ks_col(:),&
    !$acc& this_type%ws_col(:),&
    !$acc& this_type%betaprime_col(:))
  end subroutine deepcopy_lakestate_type
  subroutine deepcopy_frictionvel_type(this_type)
    type(frictionvel_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%forc_hgt_u_patch(:),&
    !$acc& this_type%forc_hgt_t_patch(:),&
    !$acc& this_type%forc_hgt_q_patch(:),&
    !$acc& this_type%u10_patch(:),&
    !$acc& this_type%u10_elm_patch(:),&
    !$acc& this_type%va_patch(:),&
    !$acc& this_type%vds_patch(:),&
    !$acc& this_type%fv_patch(:),&
    !$acc& this_type%rb1_patch(:),&
    !$acc& this_type%ram1_patch(:),&
    !$acc& this_type%z0m_patch(:),&
    !$acc& this_type%z0mv_patch(:),&
    !$acc& this_type%z0hv_patch(:),&
    !$acc& this_type%z0qv_patch(:),&
    !$acc& this_type%z0mg_col(:),&
    !$acc& this_type%z0qg_col(:),&
    !$acc& this_type%z0hg_col(:))
  end subroutine deepcopy_frictionvel_type
end module DeepCopyPhysMod
