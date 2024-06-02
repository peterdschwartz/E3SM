module writeMod
contains
subroutine write_vars()
  use fileio_mod, only : fio_open, fio_close
  use elm_varsur, only : wt_lunit, urban_valid
  use vegetationpropertiestype, only : veg_vp
  use elm_instmod, only : aerosol_vars
  use elm_instmod, only : canopystate_vars
  use elm_instmod, only : lakestate_vars
  use elm_instmod, only : surfalb_vars
  use gridcelltype, only : grc_pp
  use landunittype, only : lun_pp
  use columntype, only : col_pp
  use columndatatype, only : col_es
  use columndatatype, only : col_ws
  use vegetationtype, only : veg_pp
  use vegetationdatatype, only : veg_es
  use vegetationdatatype, only : veg_ws
  use topounittype, only : top_pp
  use domainmod, only : ldomain
  implicit none
  integer :: fid
  character(len=64) :: ofile = "Albedo_vars.txt"
  fid = 23
  
  call fio_open(fid,ofile, 2)

  write(fid,"(A)") "wt_lunit"
  write(fid,*) wt_lunit
  write(fid,"(A)") "urban_valid"
  write(fid,*) urban_valid

  
  !====================== grc_pp ======================!
  
  write (fid, "(A)") "grc_pp%gindex" 
  write (fid, *) grc_pp%gindex
  write (fid, "(A)") "grc_pp%area" 
  write (fid, *) grc_pp%area
  write (fid, "(A)") "grc_pp%lat" 
  write (fid, *) grc_pp%lat
  write (fid, "(A)") "grc_pp%lon" 
  write (fid, *) grc_pp%lon
  write (fid, "(A)") "grc_pp%latdeg" 
  write (fid, *) grc_pp%latdeg
  write (fid, "(A)") "grc_pp%londeg" 
  write (fid, *) grc_pp%londeg
  write (fid, "(A)") "grc_pp%topi" 
  write (fid, *) grc_pp%topi
  write (fid, "(A)") "grc_pp%topf" 
  write (fid, *) grc_pp%topf
  write (fid, "(A)") "grc_pp%ntopounits" 
  write (fid, *) grc_pp%ntopounits
  write (fid, "(A)") "grc_pp%lndi" 
  write (fid, *) grc_pp%lndi
  write (fid, "(A)") "grc_pp%lndf" 
  write (fid, *) grc_pp%lndf
  write (fid, "(A)") "grc_pp%nlandunits" 
  write (fid, *) grc_pp%nlandunits
  write (fid, "(A)") "grc_pp%coli" 
  write (fid, *) grc_pp%coli
  write (fid, "(A)") "grc_pp%colf" 
  write (fid, *) grc_pp%colf
  write (fid, "(A)") "grc_pp%ncolumns" 
  write (fid, *) grc_pp%ncolumns
  write (fid, "(A)") "grc_pp%pfti" 
  write (fid, *) grc_pp%pfti
  write (fid, "(A)") "grc_pp%pftf" 
  write (fid, *) grc_pp%pftf
  write (fid, "(A)") "grc_pp%npfts" 
  write (fid, *) grc_pp%npfts
  write (fid, "(A)") "grc_pp%max_dayl" 
  write (fid, *) grc_pp%max_dayl
  write (fid, "(A)") "grc_pp%dayl" 
  write (fid, *) grc_pp%dayl
  write (fid, "(A)") "grc_pp%prev_dayl" 
  write (fid, *) grc_pp%prev_dayl
  write (fid, "(A)") "grc_pp%elevation" 
  write (fid, *) grc_pp%elevation
  write (fid, "(A)") "grc_pp%froudenum" 
  write (fid, *) grc_pp%froudenum
  write (fid, "(A)") "grc_pp%landunit_indices" 
  write (fid, *) grc_pp%landunit_indices
  
  !====================== lun_pp ======================!
  
  write (fid, "(A)") "lun_pp%gridcell" 
  write (fid, *) lun_pp%gridcell
  write (fid, "(A)") "lun_pp%wtgcell" 
  write (fid, *) lun_pp%wtgcell
  write (fid, "(A)") "lun_pp%topounit" 
  write (fid, *) lun_pp%topounit
  write (fid, "(A)") "lun_pp%wttopounit" 
  write (fid, *) lun_pp%wttopounit
  write (fid, "(A)") "lun_pp%coli" 
  write (fid, *) lun_pp%coli
  write (fid, "(A)") "lun_pp%colf" 
  write (fid, *) lun_pp%colf
  write (fid, "(A)") "lun_pp%ncolumns" 
  write (fid, *) lun_pp%ncolumns
  write (fid, "(A)") "lun_pp%pfti" 
  write (fid, *) lun_pp%pfti
  write (fid, "(A)") "lun_pp%pftf" 
  write (fid, *) lun_pp%pftf
  write (fid, "(A)") "lun_pp%npfts" 
  write (fid, *) lun_pp%npfts
  write (fid, "(A)") "lun_pp%itype" 
  write (fid, *) lun_pp%itype
  write (fid, "(A)") "lun_pp%ifspecial" 
  write (fid, *) lun_pp%ifspecial
  write (fid, "(A)") "lun_pp%lakpoi" 
  write (fid, *) lun_pp%lakpoi
  write (fid, "(A)") "lun_pp%urbpoi" 
  write (fid, *) lun_pp%urbpoi
  write (fid, "(A)") "lun_pp%glcmecpoi" 
  write (fid, *) lun_pp%glcmecpoi
  write (fid, "(A)") "lun_pp%active" 
  write (fid, *) lun_pp%active
  write (fid, "(A)") "lun_pp%canyon_hwr" 
  write (fid, *) lun_pp%canyon_hwr
  write (fid, "(A)") "lun_pp%wtroad_perv" 
  write (fid, *) lun_pp%wtroad_perv
  write (fid, "(A)") "lun_pp%wtlunit_roof" 
  write (fid, *) lun_pp%wtlunit_roof
  write (fid, "(A)") "lun_pp%ht_roof" 
  write (fid, *) lun_pp%ht_roof
  write (fid, "(A)") "lun_pp%z_0_town" 
  write (fid, *) lun_pp%z_0_town
  write (fid, "(A)") "lun_pp%z_d_town" 
  write (fid, *) lun_pp%z_d_town
  
  !====================== col_pp ======================!
  
  write (fid, "(A)") "col_pp%gridcell" 
  write (fid, *) col_pp%gridcell
  write (fid, "(A)") "col_pp%wtgcell" 
  write (fid, *) col_pp%wtgcell
  write (fid, "(A)") "col_pp%topounit" 
  write (fid, *) col_pp%topounit
  write (fid, "(A)") "col_pp%wttopounit" 
  write (fid, *) col_pp%wttopounit
  write (fid, "(A)") "col_pp%landunit" 
  write (fid, *) col_pp%landunit
  write (fid, "(A)") "col_pp%wtlunit" 
  write (fid, *) col_pp%wtlunit
  write (fid, "(A)") "col_pp%pfti" 
  write (fid, *) col_pp%pfti
  write (fid, "(A)") "col_pp%pftf" 
  write (fid, *) col_pp%pftf
  write (fid, "(A)") "col_pp%npfts" 
  write (fid, *) col_pp%npfts
  write (fid, "(A)") "col_pp%itype" 
  write (fid, *) col_pp%itype
  write (fid, "(A)") "col_pp%active" 
  write (fid, *) col_pp%active
  write (fid, "(A)") "col_pp%glc_topo" 
  write (fid, *) col_pp%glc_topo
  write (fid, "(A)") "col_pp%micro_sigma" 
  write (fid, *) col_pp%micro_sigma
  write (fid, "(A)") "col_pp%n_melt" 
  write (fid, *) col_pp%n_melt
  write (fid, "(A)") "col_pp%topo_slope" 
  write (fid, *) col_pp%topo_slope
  write (fid, "(A)") "col_pp%topo_std" 
  write (fid, *) col_pp%topo_std
  write (fid, "(A)") "col_pp%hslp_p10" 
  write (fid, *) col_pp%hslp_p10
  write (fid, "(A)") "col_pp%nlevbed" 
  write (fid, *) col_pp%nlevbed
  write (fid, "(A)") "col_pp%zibed" 
  write (fid, *) col_pp%zibed
  write (fid, "(A)") "col_pp%snl" 
  write (fid, *) col_pp%snl
  write (fid, "(A)") "col_pp%dz" 
  write (fid, *) col_pp%dz
  write (fid, "(A)") "col_pp%z" 
  write (fid, *) col_pp%z
  write (fid, "(A)") "col_pp%zi" 
  write (fid, *) col_pp%zi
  write (fid, "(A)") "col_pp%zii" 
  write (fid, *) col_pp%zii
  write (fid, "(A)") "col_pp%dz_lake" 
  write (fid, *) col_pp%dz_lake
  write (fid, "(A)") "col_pp%z_lake" 
  write (fid, *) col_pp%z_lake
  write (fid, "(A)") "col_pp%lakedepth" 
  write (fid, *) col_pp%lakedepth
  write (fid, "(A)") "col_pp%hydrologically_active" 
  write (fid, *) col_pp%hydrologically_active
  write (fid, "(A)") "col_pp%is_fates" 
  write (fid, *) col_pp%is_fates
  
  !====================== veg_pp ======================!
  
  write (fid, "(A)") "veg_pp%gridcell" 
  write (fid, *) veg_pp%gridcell
  write (fid, "(A)") "veg_pp%wtgcell" 
  write (fid, *) veg_pp%wtgcell
  write (fid, "(A)") "veg_pp%topounit" 
  write (fid, *) veg_pp%topounit
  write (fid, "(A)") "veg_pp%wttopounit" 
  write (fid, *) veg_pp%wttopounit
  write (fid, "(A)") "veg_pp%landunit" 
  write (fid, *) veg_pp%landunit
  write (fid, "(A)") "veg_pp%wtlunit" 
  write (fid, *) veg_pp%wtlunit
  write (fid, "(A)") "veg_pp%column" 
  write (fid, *) veg_pp%column
  write (fid, "(A)") "veg_pp%wtcol" 
  write (fid, *) veg_pp%wtcol
  write (fid, "(A)") "veg_pp%itype" 
  write (fid, *) veg_pp%itype
  write (fid, "(A)") "veg_pp%mxy" 
  write (fid, *) veg_pp%mxy
  write (fid, "(A)") "veg_pp%active" 
  write (fid, *) veg_pp%active
  write (fid, "(A)") "veg_pp%sp_pftorder_index" 
  write (fid, *) veg_pp%sp_pftorder_index
  write (fid, "(A)") "veg_pp%is_fates" 
  write (fid, *) veg_pp%is_fates
  
  !====================== top_pp ======================!
  
  write (fid, "(A)") "top_pp%gridcell" 
  write (fid, *) top_pp%gridcell
  write (fid, "(A)") "top_pp%topo_grc_ind" 
  write (fid, *) top_pp%topo_grc_ind
  write (fid, "(A)") "top_pp%wtgcell" 
  write (fid, *) top_pp%wtgcell
  write (fid, "(A)") "top_pp%lndi" 
  write (fid, *) top_pp%lndi
  write (fid, "(A)") "top_pp%lndf" 
  write (fid, *) top_pp%lndf
  write (fid, "(A)") "top_pp%nlandunits" 
  write (fid, *) top_pp%nlandunits
  write (fid, "(A)") "top_pp%coli" 
  write (fid, *) top_pp%coli
  write (fid, "(A)") "top_pp%colf" 
  write (fid, *) top_pp%colf
  write (fid, "(A)") "top_pp%ncolumns" 
  write (fid, *) top_pp%ncolumns
  write (fid, "(A)") "top_pp%pfti" 
  write (fid, *) top_pp%pfti
  write (fid, "(A)") "top_pp%pftf" 
  write (fid, *) top_pp%pftf
  write (fid, "(A)") "top_pp%npfts" 
  write (fid, *) top_pp%npfts
  write (fid, "(A)") "top_pp%landunit_indices" 
  write (fid, *) top_pp%landunit_indices
  write (fid, "(A)") "top_pp%active" 
  write (fid, *) top_pp%active
  write (fid, "(A)") "top_pp%area" 
  write (fid, *) top_pp%area
  write (fid, "(A)") "top_pp%lat" 
  write (fid, *) top_pp%lat
  write (fid, "(A)") "top_pp%lon" 
  write (fid, *) top_pp%lon
  write (fid, "(A)") "top_pp%elevation" 
  write (fid, *) top_pp%elevation
  write (fid, "(A)") "top_pp%slope" 
  write (fid, *) top_pp%slope
  write (fid, "(A)") "top_pp%aspect" 
  write (fid, *) top_pp%aspect
  write (fid, "(A)") "top_pp%emissivity" 
  write (fid, *) top_pp%emissivity
  write (fid, "(A)") "top_pp%surfalb_dir" 
  write (fid, *) top_pp%surfalb_dir
  write (fid, "(A)") "top_pp%surfalb_dif" 
  write (fid, *) top_pp%surfalb_dif
  
  !====================== veg_vp ======================!
  
  write (fid, "(A)") "veg_vp%xl" 
  write (fid, *) veg_vp%xl
  write (fid, "(A)") "veg_vp%rhol" 
  write (fid, *) veg_vp%rhol
  write (fid, "(A)") "veg_vp%rhos" 
  write (fid, *) veg_vp%rhos
  write (fid, "(A)") "veg_vp%taul" 
  write (fid, *) veg_vp%taul
  write (fid, "(A)") "veg_vp%taus" 
  write (fid, *) veg_vp%taus
  
  !====================== aerosol_vars ======================!
  
  write (fid, "(A)") "aerosol_vars%mss_cnc_bcphi_col" 
  write (fid, *) aerosol_vars%mss_cnc_bcphi_col
  write (fid, "(A)") "aerosol_vars%mss_cnc_bcpho_col" 
  write (fid, *) aerosol_vars%mss_cnc_bcpho_col
  write (fid, "(A)") "aerosol_vars%mss_cnc_ocphi_col" 
  write (fid, *) aerosol_vars%mss_cnc_ocphi_col
  write (fid, "(A)") "aerosol_vars%mss_cnc_ocpho_col" 
  write (fid, *) aerosol_vars%mss_cnc_ocpho_col
  write (fid, "(A)") "aerosol_vars%mss_cnc_dst1_col" 
  write (fid, *) aerosol_vars%mss_cnc_dst1_col
  write (fid, "(A)") "aerosol_vars%mss_cnc_dst2_col" 
  write (fid, *) aerosol_vars%mss_cnc_dst2_col
  write (fid, "(A)") "aerosol_vars%mss_cnc_dst3_col" 
  write (fid, *) aerosol_vars%mss_cnc_dst3_col
  write (fid, "(A)") "aerosol_vars%mss_cnc_dst4_col" 
  write (fid, *) aerosol_vars%mss_cnc_dst4_col
  
  !====================== canopystate_vars ======================!
  
  write (fid, "(A)") "canopystate_vars%tlai_patch" 
  write (fid, *) canopystate_vars%tlai_patch
  write (fid, "(A)") "canopystate_vars%tsai_patch" 
  write (fid, *) canopystate_vars%tsai_patch
  write (fid, "(A)") "canopystate_vars%elai_patch" 
  write (fid, *) canopystate_vars%elai_patch
  write (fid, "(A)") "canopystate_vars%esai_patch" 
  write (fid, *) canopystate_vars%esai_patch
  
  !====================== lakestate_vars ======================!
  
  write (fid, "(A)") "lakestate_vars%lake_icefrac_col" 
  write (fid, *) lakestate_vars%lake_icefrac_col
  
  !====================== surfalb_vars ======================!
  
  write (fid, "(A)") "surfalb_vars%coszen_col" 
  write (fid, *) surfalb_vars%coszen_col
  write (fid, "(A)") "surfalb_vars%albd_patch" 
  write (fid, *) surfalb_vars%albd_patch
  write (fid, "(A)") "surfalb_vars%albi_patch" 
  write (fid, *) surfalb_vars%albi_patch
  write (fid, "(A)") "surfalb_vars%albgrd_col" 
  write (fid, *) surfalb_vars%albgrd_col
  write (fid, "(A)") "surfalb_vars%albgri_col" 
  write (fid, *) surfalb_vars%albgri_col
  write (fid, "(A)") "surfalb_vars%albsod_col" 
  write (fid, *) surfalb_vars%albsod_col
  write (fid, "(A)") "surfalb_vars%albsoi_col" 
  write (fid, *) surfalb_vars%albsoi_col
  write (fid, "(A)") "surfalb_vars%albsnd_hst_col" 
  write (fid, *) surfalb_vars%albsnd_hst_col
  write (fid, "(A)") "surfalb_vars%albsni_hst_col" 
  write (fid, *) surfalb_vars%albsni_hst_col
  write (fid, "(A)") "surfalb_vars%ftdd_patch" 
  write (fid, *) surfalb_vars%ftdd_patch
  write (fid, "(A)") "surfalb_vars%ftid_patch" 
  write (fid, *) surfalb_vars%ftid_patch
  write (fid, "(A)") "surfalb_vars%ftii_patch" 
  write (fid, *) surfalb_vars%ftii_patch
  write (fid, "(A)") "surfalb_vars%fabd_patch" 
  write (fid, *) surfalb_vars%fabd_patch
  write (fid, "(A)") "surfalb_vars%fabi_patch" 
  write (fid, *) surfalb_vars%fabi_patch
  write (fid, "(A)") "surfalb_vars%fabd_sun_z_patch" 
  write (fid, *) surfalb_vars%fabd_sun_z_patch
  write (fid, "(A)") "surfalb_vars%fabd_sha_z_patch" 
  write (fid, *) surfalb_vars%fabd_sha_z_patch
  write (fid, "(A)") "surfalb_vars%fabi_sun_z_patch" 
  write (fid, *) surfalb_vars%fabi_sun_z_patch
  write (fid, "(A)") "surfalb_vars%fabi_sha_z_patch" 
  write (fid, *) surfalb_vars%fabi_sha_z_patch
  write (fid, "(A)") "surfalb_vars%flx_absdv_col" 
  write (fid, *) surfalb_vars%flx_absdv_col
  write (fid, "(A)") "surfalb_vars%flx_absdn_col" 
  write (fid, *) surfalb_vars%flx_absdn_col
  write (fid, "(A)") "surfalb_vars%flx_absiv_col" 
  write (fid, *) surfalb_vars%flx_absiv_col
  write (fid, "(A)") "surfalb_vars%flx_absin_col" 
  write (fid, *) surfalb_vars%flx_absin_col
  write (fid, "(A)") "surfalb_vars%fsun_z_patch" 
  write (fid, *) surfalb_vars%fsun_z_patch
  write (fid, "(A)") "surfalb_vars%tlai_z_patch" 
  write (fid, *) surfalb_vars%tlai_z_patch
  write (fid, "(A)") "surfalb_vars%tsai_z_patch" 
  write (fid, *) surfalb_vars%tsai_z_patch
  write (fid, "(A)") "surfalb_vars%ncan_patch" 
  write (fid, *) surfalb_vars%ncan_patch
  write (fid, "(A)") "surfalb_vars%nrad_patch" 
  write (fid, *) surfalb_vars%nrad_patch
  write (fid, "(A)") "surfalb_vars%vcmaxcintsun_patch" 
  write (fid, *) surfalb_vars%vcmaxcintsun_patch
  write (fid, "(A)") "surfalb_vars%vcmaxcintsha_patch" 
  write (fid, *) surfalb_vars%vcmaxcintsha_patch
  
  !====================== col_es ======================!
  
  write (fid, "(A)") "col_es%t_grnd" 
  write (fid, *) col_es%t_grnd
  
  !====================== col_ws ======================!
  
  write (fid, "(A)") "col_ws%h2osoi_liq" 
  write (fid, *) col_ws%h2osoi_liq
  write (fid, "(A)") "col_ws%h2osoi_ice" 
  write (fid, *) col_ws%h2osoi_ice
  write (fid, "(A)") "col_ws%h2osoi_vol" 
  write (fid, *) col_ws%h2osoi_vol
  write (fid, "(A)") "col_ws%snw_rds" 
  write (fid, *) col_ws%snw_rds
  write (fid, "(A)") "col_ws%h2osno" 
  write (fid, *) col_ws%h2osno
  write (fid, "(A)") "col_ws%frac_sno" 
  write (fid, *) col_ws%frac_sno
  
  !====================== veg_es ======================!
  
  write (fid, "(A)") "veg_es%t_veg" 
  write (fid, *) veg_es%t_veg
  
  !====================== veg_ws ======================!
  
  write (fid, "(A)") "veg_ws%fwet" 
  write (fid, *) veg_ws%fwet
  
  !====================== ldomain ======================!
  
  write (fid, "(A)") "ldomain%mask" 
  write (fid, *) ldomain%mask
  call fio_close(fid)
end subroutine write_vars
end module writeMod
