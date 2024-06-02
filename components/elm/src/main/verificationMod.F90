module verificationMod 
contains 
subroutine update_vars_surfacealbedo(gpu,desc)
  use gridcelltype, only : grc_pp
  use columntype, only : col_pp
  use vegetationtype, only : veg_pp
  use columndatatype, only : col_ws
  use elm_instmod, only : aerosol_vars
  use landunittype, only : lun_pp
  use elm_instmod, only : canopystate_vars
  use vegetationpropertiestype, only : veg_vp
  use domainmod, only : ldomain
  use topounittype, only : top_pp
  use columndatatype, only : col_es
  use elm_instmod, only : lakestate_vars
  use vegetationdatatype, only : veg_es
  use vegetationdatatype, only : veg_ws
  use elm_instmod, only : surfalb_vars
  implicit none
  integer, intent(in) :: gpu
  character(len=*), optional, intent(in) :: desc
  character(len=256) :: fn
  if(gpu) then
    fn="gpu_surfacealbedo"
  else
    fn='cpu_surfacealbedo'
  end if
  if(present(desc)) then
    fn = trim(fn) // desc
  end if
  fn = trim(fn) // ".txt"
  print *, "Verfication File is :",fn
  open(UNIT=10, STATUS='REPLACE', FILE=fn)
  if(gpu) then
  !$acc update self(&
  !$acc grc_pp%lon, &
  !$acc grc_pp%lat, &
  !$acc grc_pp%gindex, &
  !$acc grc_pp%latdeg, &
  !$acc grc_pp%londeg )
  !$acc update self(&
  !$acc col_pp%gridcell, &
  !$acc col_pp%landunit, &
  !$acc col_pp%topounit, &
  !$acc col_pp%snl )
  !$acc update self(&
  !$acc veg_pp%gridcell, &
  !$acc veg_pp%landunit, &
  !$acc veg_pp%itype, &
  !$acc veg_pp%column )
  !$acc update self(&
  !$acc col_ws%h2osoi_liq, &
  !$acc col_ws%h2osoi_ice, &
  !$acc col_ws%snw_rds, &
  !$acc col_ws%frac_sno, &
  !$acc col_ws%h2osoi_vol, &
  !$acc col_ws%h2osno )
  !$acc update self(&
  !$acc aerosol_vars%mss_cnc_bcphi_col, &
  !$acc aerosol_vars%mss_cnc_bcpho_col, &
  !$acc aerosol_vars%mss_cnc_ocphi_col, &
  !$acc aerosol_vars%mss_cnc_ocpho_col, &
  !$acc aerosol_vars%mss_cnc_dst1_col, &
  !$acc aerosol_vars%mss_cnc_dst2_col, &
  !$acc aerosol_vars%mss_cnc_dst3_col, &
  !$acc aerosol_vars%mss_cnc_dst4_col )
  !$acc update self(&
  !$acc lun_pp%itype )
  !$acc update self(&
  !$acc canopystate_vars%elai_patch, &
  !$acc canopystate_vars%esai_patch, &
  !$acc canopystate_vars%tlai_patch, &
  !$acc canopystate_vars%tsai_patch )
  !$acc update self(&
  !$acc veg_vp%rhol, &
  !$acc veg_vp%rhos, &
  !$acc veg_vp%taul, &
  !$acc veg_vp%taus, &
  !$acc veg_vp%xl )
  !$acc update self(&
  !$acc ldomain%mask, &
  !$acc ldomain%pftm )
  !$acc update self(&
  !$acc top_pp%active )
  !$acc update self(&
  !$acc col_es%t_grnd )
  !$acc update self(&
  !$acc lakestate_vars%lake_icefrac_col )
  !$acc update self(&
  !$acc veg_es%t_veg )
  !$acc update self(&
  !$acc veg_ws%fwet )
  !$acc update self(&
  !$acc surfalb_vars%tlai_z_patch, &
  !$acc surfalb_vars%tsai_z_patch, &
  !$acc surfalb_vars%flx_absdv_col, &
  !$acc surfalb_vars%flx_absdn_col, &
  !$acc surfalb_vars%flx_absiv_col, &
  !$acc surfalb_vars%flx_absin_col, &
  !$acc surfalb_vars%albsnd_hst_col, &
  !$acc surfalb_vars%albsni_hst_col, &
  !$acc surfalb_vars%coszen_col, &
  !$acc surfalb_vars%albsod_col, &
  !$acc surfalb_vars%albsoi_col, &
  !$acc surfalb_vars%albgrd_col, &
  !$acc surfalb_vars%albgri_col, &
  !$acc surfalb_vars%nrad_patch, &
  !$acc surfalb_vars%ncan_patch, &
  !$acc surfalb_vars%vcmaxcintsha_patch, &
  !$acc surfalb_vars%albd_patch, &
  !$acc surfalb_vars%ftid_patch, &
  !$acc surfalb_vars%ftdd_patch, &
  !$acc surfalb_vars%fabd_patch, &
  !$acc surfalb_vars%albi_patch, &
  !$acc surfalb_vars%ftii_patch, &
  !$acc surfalb_vars%fabi_patch, &
  !$acc surfalb_vars%fsun_z_patch, &
  !$acc surfalb_vars%fabd_sun_z_patch, &
  !$acc surfalb_vars%fabi_sun_z_patch, &
  !$acc surfalb_vars%fabd_sha_z_patch, &
  !$acc surfalb_vars%fabi_sha_z_patch, &
  !$acc surfalb_vars%vcmaxcintsun_patch )
  end if
  !! CPU print statements !!
  write(10,*) 'grc_pp%lon',shape(grc_pp%lon)
  write(10,*) grc_pp%lon
  write(10,*) 'grc_pp%lat',shape(grc_pp%lat)
  write(10,*) grc_pp%lat
  write(10,*) 'grc_pp%gindex',shape(grc_pp%gindex)
  write(10,*) grc_pp%gindex
  write(10,*) 'grc_pp%latdeg',shape(grc_pp%latdeg)
  write(10,*) grc_pp%latdeg
  write(10,*) 'grc_pp%londeg',shape(grc_pp%londeg)
  write(10,*) grc_pp%londeg
  write(10,*) 'col_pp%gridcell',shape(col_pp%gridcell)
  write(10,*) col_pp%gridcell
  write(10,*) 'col_pp%landunit',shape(col_pp%landunit)
  write(10,*) col_pp%landunit
  write(10,*) 'col_pp%topounit',shape(col_pp%topounit)
  write(10,*) col_pp%topounit
  write(10,*) 'col_pp%snl',shape(col_pp%snl)
  write(10,*) col_pp%snl
  write(10,*) 'veg_pp%gridcell',shape(veg_pp%gridcell)
  write(10,*) veg_pp%gridcell
  write(10,*) 'veg_pp%landunit',shape(veg_pp%landunit)
  write(10,*) veg_pp%landunit
  write(10,*) 'veg_pp%itype',shape(veg_pp%itype)
  write(10,*) veg_pp%itype
  write(10,*) 'veg_pp%column',shape(veg_pp%column)
  write(10,*) veg_pp%column
  write(10,*) 'col_ws%h2osoi_liq',shape(col_ws%h2osoi_liq)
  write(10,*) col_ws%h2osoi_liq
  write(10,*) 'col_ws%h2osoi_ice',shape(col_ws%h2osoi_ice)
  write(10,*) col_ws%h2osoi_ice
  write(10,*) 'col_ws%snw_rds',shape(col_ws%snw_rds)
  write(10,*) col_ws%snw_rds
  write(10,*) 'col_ws%frac_sno',shape(col_ws%frac_sno)
  write(10,*) col_ws%frac_sno
  write(10,*) 'col_ws%h2osoi_vol',shape(col_ws%h2osoi_vol)
  write(10,*) col_ws%h2osoi_vol
  write(10,*) 'col_ws%h2osno',shape(col_ws%h2osno)
  write(10,*) col_ws%h2osno
  write(10,*) 'aerosol_vars%mss_cnc_bcphi_col',shape(aerosol_vars%mss_cnc_bcphi_col)
  write(10,*) aerosol_vars%mss_cnc_bcphi_col
  write(10,*) 'aerosol_vars%mss_cnc_bcpho_col',shape(aerosol_vars%mss_cnc_bcpho_col)
  write(10,*) aerosol_vars%mss_cnc_bcpho_col
  write(10,*) 'aerosol_vars%mss_cnc_ocphi_col',shape(aerosol_vars%mss_cnc_ocphi_col)
  write(10,*) aerosol_vars%mss_cnc_ocphi_col
  write(10,*) 'aerosol_vars%mss_cnc_ocpho_col',shape(aerosol_vars%mss_cnc_ocpho_col)
  write(10,*) aerosol_vars%mss_cnc_ocpho_col
  write(10,*) 'aerosol_vars%mss_cnc_dst1_col',shape(aerosol_vars%mss_cnc_dst1_col)
  write(10,*) aerosol_vars%mss_cnc_dst1_col
  write(10,*) 'aerosol_vars%mss_cnc_dst2_col',shape(aerosol_vars%mss_cnc_dst2_col)
  write(10,*) aerosol_vars%mss_cnc_dst2_col
  write(10,*) 'aerosol_vars%mss_cnc_dst3_col',shape(aerosol_vars%mss_cnc_dst3_col)
  write(10,*) aerosol_vars%mss_cnc_dst3_col
  write(10,*) 'aerosol_vars%mss_cnc_dst4_col',shape(aerosol_vars%mss_cnc_dst4_col)
  write(10,*) aerosol_vars%mss_cnc_dst4_col
  write(10,*) 'lun_pp%itype',shape(lun_pp%itype)
  write(10,*) lun_pp%itype
  write(10,*) 'canopystate_vars%elai_patch',shape(canopystate_vars%elai_patch)
  write(10,*) canopystate_vars%elai_patch
  write(10,*) 'canopystate_vars%esai_patch',shape(canopystate_vars%esai_patch)
  write(10,*) canopystate_vars%esai_patch
  write(10,*) 'canopystate_vars%tlai_patch',shape(canopystate_vars%tlai_patch)
  write(10,*) canopystate_vars%tlai_patch
  write(10,*) 'canopystate_vars%tsai_patch',shape(canopystate_vars%tsai_patch)
  write(10,*) canopystate_vars%tsai_patch
  write(10,*) 'veg_vp%rhol',shape(veg_vp%rhol)
  write(10,*) veg_vp%rhol
  write(10,*) 'veg_vp%rhos',shape(veg_vp%rhos)
  write(10,*) veg_vp%rhos
  write(10,*) 'veg_vp%taul',shape(veg_vp%taul)
  write(10,*) veg_vp%taul
  write(10,*) 'veg_vp%taus',shape(veg_vp%taus)
  write(10,*) veg_vp%taus
  write(10,*) 'veg_vp%xl',shape(veg_vp%xl)
  write(10,*) veg_vp%xl
  write(10,*) 'ldomain%mask',shape(ldomain%mask)
  write(10,*) ldomain%mask
  write(10,*) 'ldomain%pftm',shape(ldomain%pftm)
  write(10,*) ldomain%pftm
  write(10,*) 'top_pp%active',shape(top_pp%active)
  write(10,*) top_pp%active
  write(10,*) 'col_es%t_grnd',shape(col_es%t_grnd)
  write(10,*) col_es%t_grnd
  write(10,*) 'lakestate_vars%lake_icefrac_col',shape(lakestate_vars%lake_icefrac_col)
  write(10,*) lakestate_vars%lake_icefrac_col
  write(10,*) 'veg_es%t_veg',shape(veg_es%t_veg)
  write(10,*) veg_es%t_veg
  write(10,*) 'veg_ws%fwet',shape(veg_ws%fwet)
  write(10,*) veg_ws%fwet
  write(10,*) 'surfalb_vars%tlai_z_patch',shape(surfalb_vars%tlai_z_patch)
  write(10,*) surfalb_vars%tlai_z_patch
  write(10,*) 'surfalb_vars%tsai_z_patch',shape(surfalb_vars%tsai_z_patch)
  write(10,*) surfalb_vars%tsai_z_patch
  write(10,*) 'surfalb_vars%flx_absdv_col',shape(surfalb_vars%flx_absdv_col)
  write(10,*) surfalb_vars%flx_absdv_col
  write(10,*) 'surfalb_vars%flx_absdn_col',shape(surfalb_vars%flx_absdn_col)
  write(10,*) surfalb_vars%flx_absdn_col
  write(10,*) 'surfalb_vars%flx_absiv_col',shape(surfalb_vars%flx_absiv_col)
  write(10,*) surfalb_vars%flx_absiv_col
  write(10,*) 'surfalb_vars%flx_absin_col',shape(surfalb_vars%flx_absin_col)
  write(10,*) surfalb_vars%flx_absin_col
  write(10,*) 'surfalb_vars%albsnd_hst_col',shape(surfalb_vars%albsnd_hst_col)
  write(10,*) surfalb_vars%albsnd_hst_col
  write(10,*) 'surfalb_vars%albsni_hst_col',shape(surfalb_vars%albsni_hst_col)
  write(10,*) surfalb_vars%albsni_hst_col
  write(10,*) 'surfalb_vars%coszen_col',shape(surfalb_vars%coszen_col)
  write(10,*) surfalb_vars%coszen_col
  write(10,*) 'surfalb_vars%albsod_col',shape(surfalb_vars%albsod_col)
  write(10,*) surfalb_vars%albsod_col
  write(10,*) 'surfalb_vars%albsoi_col',shape(surfalb_vars%albsoi_col)
  write(10,*) surfalb_vars%albsoi_col
  write(10,*) 'surfalb_vars%albgrd_col',shape(surfalb_vars%albgrd_col)
  write(10,*) surfalb_vars%albgrd_col
  write(10,*) 'surfalb_vars%albgri_col',shape(surfalb_vars%albgri_col)
  write(10,*) surfalb_vars%albgri_col
  write(10,*) 'surfalb_vars%nrad_patch',shape(surfalb_vars%nrad_patch)
  write(10,*) surfalb_vars%nrad_patch
  write(10,*) 'surfalb_vars%ncan_patch',shape(surfalb_vars%ncan_patch)
  write(10,*) surfalb_vars%ncan_patch
  write(10,*) 'surfalb_vars%vcmaxcintsha_patch',shape(surfalb_vars%vcmaxcintsha_patch)
  write(10,*) surfalb_vars%vcmaxcintsha_patch
  write(10,*) 'surfalb_vars%albd_patch',shape(surfalb_vars%albd_patch)
  write(10,*) surfalb_vars%albd_patch
  write(10,*) 'surfalb_vars%ftid_patch',shape(surfalb_vars%ftid_patch)
  write(10,*) surfalb_vars%ftid_patch
  write(10,*) 'surfalb_vars%ftdd_patch',shape(surfalb_vars%ftdd_patch)
  write(10,*) surfalb_vars%ftdd_patch
  write(10,*) 'surfalb_vars%fabd_patch',shape(surfalb_vars%fabd_patch)
  write(10,*) surfalb_vars%fabd_patch
  write(10,*) 'surfalb_vars%albi_patch',shape(surfalb_vars%albi_patch)
  write(10,*) surfalb_vars%albi_patch
  write(10,*) 'surfalb_vars%ftii_patch',shape(surfalb_vars%ftii_patch)
  write(10,*) surfalb_vars%ftii_patch
  write(10,*) 'surfalb_vars%fabi_patch',shape(surfalb_vars%fabi_patch)
  write(10,*) surfalb_vars%fabi_patch
  write(10,*) 'surfalb_vars%fsun_z_patch',shape(surfalb_vars%fsun_z_patch)
  write(10,*) surfalb_vars%fsun_z_patch
  write(10,*) 'surfalb_vars%fabd_sun_z_patch',shape(surfalb_vars%fabd_sun_z_patch)
  write(10,*) surfalb_vars%fabd_sun_z_patch
  write(10,*) 'surfalb_vars%fabi_sun_z_patch',shape(surfalb_vars%fabi_sun_z_patch)
  write(10,*) surfalb_vars%fabi_sun_z_patch
  write(10,*) 'surfalb_vars%fabd_sha_z_patch',shape(surfalb_vars%fabd_sha_z_patch)
  write(10,*) surfalb_vars%fabd_sha_z_patch
  write(10,*) 'surfalb_vars%fabi_sha_z_patch',shape(surfalb_vars%fabi_sha_z_patch)
  write(10,*) surfalb_vars%fabi_sha_z_patch
  write(10,*) 'surfalb_vars%vcmaxcintsun_patch',shape(surfalb_vars%vcmaxcintsun_patch)
  write(10,*) surfalb_vars%vcmaxcintsun_patch
  close(10)
end subroutine 
end module verificationMod
