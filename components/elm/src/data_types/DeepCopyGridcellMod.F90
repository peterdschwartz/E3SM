module DeepCopyGridcellMod
  use gridcelltype,only: gridcell_physical_properties_type
  use gridcelldatatype,only: gridcell_energy_state
  use gridcelldatatype,only: gridcell_energy_flux
  use gridcelldatatype,only: gridcell_water_state
  use gridcelldatatype,only: gridcell_water_flux
  use gridcelldatatype,only: gridcell_carbon_state
  use gridcelldatatype,only: gridcell_carbon_flux
  use gridcelldatatype,only: gridcell_nitrogen_state
  use gridcelldatatype,only: gridcell_nitrogen_flux
  use gridcelldatatype,only: gridcell_phosphorus_state
  use gridcelldatatype,only: gridcell_phosphorus_flux
  implicit none
  public :: deepcopy_gridcell_physical_properties_type
  public :: deepcopy_gridcell_energy_state
  public :: deepcopy_gridcell_energy_flux
  public :: deepcopy_gridcell_water_state
  public :: deepcopy_gridcell_water_flux
  public :: deepcopy_gridcell_carbon_state
  public :: deepcopy_gridcell_carbon_flux
  public :: deepcopy_gridcell_nitrogen_state
  public :: deepcopy_gridcell_nitrogen_flux
  public :: deepcopy_gridcell_phosphorus_state
  public :: deepcopy_gridcell_phosphorus_flux
contains
  
  subroutine deepcopy_gridcell_types(grc_pp, grc_es, grc_ef, grc_ws, grc_wf, &
    grc_cs, grc_cf, grc_ns, grc_nf, grc_ps, grc_pf)

    type(gridcell_physical_properties_type), intent(inout) :: grc_pp
    type(gridcell_energy_state), intent(inout) :: grc_es
    type(gridcell_energy_flux), intent(inout) :: grc_ef
    type(gridcell_water_state), intent(inout) :: grc_ws
    type(gridcell_water_flux), intent(inout) :: grc_wf
    type(gridcell_carbon_state), intent(inout) :: grc_cs
    type(gridcell_carbon_flux), intent(inout) :: grc_cf
    type(gridcell_nitrogen_state), intent(inout) :: grc_ns
    type(gridcell_nitrogen_flux), intent(inout) :: grc_nf
    type(gridcell_phosphorus_state), intent(inout) :: grc_ps
    type(gridcell_phosphorus_flux), intent(inout) :: grc_pf

    call deepcopy_gridcell_physical_properties_type(grc_pp)
    call deepcopy_gridcell_energy_state(grc_es)
    call deepcopy_gridcell_energy_flux(grc_ef)
    call deepcopy_gridcell_water_state(grc_ws)
    call deepcopy_gridcell_water_flux(grc_wf)
    call deepcopy_gridcell_carbon_state(grc_cs)
    call deepcopy_gridcell_carbon_flux(grc_cf)
    call deepcopy_gridcell_nitrogen_state(grc_ns)
    call deepcopy_gridcell_nitrogen_flux(grc_nf)
    call deepcopy_gridcell_phosphorus_state(grc_ps)
    call deepcopy_gridcell_phosphorus_flux(grc_pf)

  end subroutine deepcopy_gridcell_types

  subroutine deepcopy_gridcell_physical_properties_type(this_type)
    type(gridcell_physical_properties_type), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%gindex(:),&
    !$acc& this_type%area(:),&
    !$acc& this_type%lat(:),&
    !$acc& this_type%lon(:),&
    !$acc& this_type%latdeg(:),&
    !$acc& this_type%londeg(:),&
    !$acc& this_type%topi(:),&
    !$acc& this_type%topf(:),&
    !$acc& this_type%ntopounits(:),&
    !$acc& this_type%lndi(:),&
    !$acc& this_type%lndf(:),&
    !$acc& this_type%nlandunits(:),&
    !$acc& this_type%coli(:),&
    !$acc& this_type%colf(:),&
    !$acc& this_type%ncolumns(:),&
    !$acc& this_type%pfti(:),&
    !$acc& this_type%pftf(:),&
    !$acc& this_type%npfts(:),&
    !$acc& this_type%max_dayl(:),&
    !$acc& this_type%dayl(:),&
    !$acc& this_type%prev_dayl(:),&
    !$acc& this_type%elevation(:),&
    !$acc& this_type%froudenum(:),&
    !$acc& this_type%maxelevation(:),&
    !$acc& this_type%landunit_indices(:,:))
  end subroutine deepcopy_gridcell_physical_properties_type
  subroutine deepcopy_gridcell_energy_state(this_type)
    type(gridcell_energy_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%heat1(:),&
    !$acc& this_type%heat2(:),&
    !$acc& this_type%liquid_water_temp1(:),&
    !$acc& this_type%liquid_water_temp2(:))
  end subroutine deepcopy_gridcell_energy_state
  subroutine deepcopy_gridcell_energy_flux(this_type)
    type(gridcell_energy_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%eflx_dynbal(:))
  end subroutine deepcopy_gridcell_energy_flux
  subroutine deepcopy_gridcell_water_state(this_type)
    type(gridcell_water_state), intent(inout) :: this_type
    !!!$acc enter data copyin(this_type)
    !!!$acc enter data copyin(&
    !!!$acc& this_type%liq1(:),&
    !!!$acc& this_type%liq2(:),&
    !!!$acc& this_type%ice1(:),&
    !!!$acc& this_type%ice2(:),&
    !!!$acc& this_type%tws(:),&
    !!!$acc& this_type%tws_month_beg(:),&
    !!!$acc& this_type%tws_month_end(:),&
    !!!$acc& this_type%begwb(:),&
    !!!$acc& this_type%endwb(:),&
    !!!$acc& this_type%errh2o(:),&
    !!!$acc& this_type%beg_h2ocan(:),&
    !!!$acc& this_type%beg_h2osno(:),&
    !!!$acc& this_type%beg_h2osfc(:),&
    !!!$acc& this_type%beg_h2osoi_liq(:),&
    !!!$acc& this_type%beg_h2osoi_ice(:),&
    !!!$acc& this_type%end_h2ocan(:),&
    !!!$acc& this_type%end_h2osno(:),&
    !!!$acc& this_type%end_h2osfc(:),&
    !!!$acc& this_type%end_h2osoi_liq(:),&
    !!!$acc& this_type%end_h2osoi_ice(:))
  end subroutine deepcopy_gridcell_water_state
  subroutine deepcopy_gridcell_water_flux(this_type)
    type(gridcell_water_flux), intent(inout) :: this_type
    !!!$acc enter data copyin(this_type)
    !!!$acc enter data copyin(&
    !!!$acc& this_type%qflx_liq_dynbal(:),&
    !!!$acc& this_type%qflx_ice_dynbal(:))
  end subroutine deepcopy_gridcell_water_flux
  subroutine deepcopy_gridcell_carbon_state(this_type)
    type(gridcell_carbon_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%seedc(:),&
    !$acc& this_type%tcs_month_beg(:),&
    !$acc& this_type%tcs_month_end(:),&
    !$acc& this_type%begcb(:),&
    !$acc& this_type%endcb(:),&
    !$acc& this_type%errcb(:),&
    !$acc& this_type%beg_totc(:),&
    !$acc& this_type%beg_totpftc(:),&
    !$acc& this_type%beg_cwdc(:),&
    !$acc& this_type%beg_totsomc(:),&
    !$acc& this_type%beg_totlitc(:),&
    !$acc& this_type%beg_totprodc(:),&
    !$acc& this_type%beg_ctrunc(:),&
    !$acc& this_type%beg_cropseedc_deficit(:),&
    !$acc& this_type%end_totc(:),&
    !$acc& this_type%end_totpftc(:),&
    !$acc& this_type%end_cwdc(:),&
    !$acc& this_type%end_totsomc(:),&
    !$acc& this_type%end_totlitc(:),&
    !$acc& this_type%end_totprodc(:),&
    !$acc& this_type%end_ctrunc(:),&
    !$acc& this_type%end_cropseedc_deficit(:))
  end subroutine deepcopy_gridcell_carbon_state
  subroutine deepcopy_gridcell_carbon_flux(this_type)
    type(gridcell_carbon_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%dwt_seedc_to_leaf(:),&
    !$acc& this_type%dwt_seedc_to_deadstem(:),&
    !$acc& this_type%dwt_conv_cflux(:),&
    !$acc& this_type%dwt_conv_cflux_dribbled(:),&
    !$acc& this_type%dwt_prod10c_gain(:),&
    !$acc& this_type%dwt_prod100c_gain(:),&
    !$acc& this_type%hrv_deadstemc_to_prod10c(:),&
    !$acc& this_type%hrv_deadstemc_to_prod100c(:),&
    !$acc& this_type%cinputs(:),&
    !$acc& this_type%coutputs(:),&
    !$acc& this_type%gpp(:),&
    !$acc& this_type%er(:),&
    !$acc& this_type%fire_closs(:),&
    !$acc& this_type%prod1_loss(:),&
    !$acc& this_type%prod10_loss(:),&
    !$acc& this_type%prod100_loss(:),&
    !$acc& this_type%hrv_xsmrpool_to_atm(:),&
    !$acc& this_type%som_c_leached(:),&
    !$acc& this_type%somc_yield(:))
  end subroutine deepcopy_gridcell_carbon_flux
  subroutine deepcopy_gridcell_nitrogen_state(this_type)
    type(gridcell_nitrogen_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%seedn(:),&
    !$acc& this_type%begnb(:),&
    !$acc& this_type%endnb(:),&
    !$acc& this_type%errnb(:))
  end subroutine deepcopy_gridcell_nitrogen_state
  subroutine deepcopy_gridcell_nitrogen_flux(this_type)
    type(gridcell_nitrogen_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%dwt_seedn_to_leaf(:),&
    !$acc& this_type%dwt_seedn_to_deadstem(:),&
    !$acc& this_type%dwt_conv_nflux(:),&
    !$acc& this_type%dwt_seedn_to_npool(:),&
    !$acc& this_type%dwt_prod10n_gain(:),&
    !$acc& this_type%dwt_prod100n_gain(:),&
    !$acc& this_type%ninputs(:),&
    !$acc& this_type%noutputs(:))
  end subroutine deepcopy_gridcell_nitrogen_flux
  subroutine deepcopy_gridcell_phosphorus_state(this_type)
    type(gridcell_phosphorus_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%seedp(:),&
    !$acc& this_type%begpb(:),&
    !$acc& this_type%endpb(:),&
    !$acc& this_type%errpb(:))
  end subroutine deepcopy_gridcell_phosphorus_state
  subroutine deepcopy_gridcell_phosphorus_flux(this_type)
    type(gridcell_phosphorus_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%dwt_seedp_to_leaf(:),&
    !$acc& this_type%dwt_seedp_to_deadstem(:),&
    !$acc& this_type%dwt_conv_pflux(:),&
    !$acc& this_type%dwt_seedp_to_ppool(:),&
    !$acc& this_type%dwt_prod10p_gain(:),&
    !$acc& this_type%dwt_prod100p_gain(:),&
    !$acc& this_type%pinputs(:),&
    !$acc& this_type%poutputs(:))
  end subroutine deepcopy_gridcell_phosphorus_flux
end module DeepCopyGridcellMod
