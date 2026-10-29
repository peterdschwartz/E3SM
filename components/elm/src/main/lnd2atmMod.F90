module lnd2atmMod

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! Handle lnd2atm mapping
  !
  ! !USES:
  use shr_kind_mod         , only : r8 => shr_kind_r8
  use shr_log_mod            , only : errMsg => shr_log_errMsg
  use abortutils             , only : endrun
  use shr_megan_mod        , only : shr_megan_mechcomps_n
  use shr_fan_mod          , only : shr_fan_to_atm
  use elm_varpar           , only : numrad, ndst, nlevgrnd, nlevsno, nlevsoi !ndst = number of dust bins.
  use elm_varcon           , only : rair, grav, cpair, hfus, tfrz, spval
  use elm_varctl           , only : iulog, use_c13, use_cn, use_lch4, use_voc, use_fates, use_atm_downscaling_to_topunit, use_fan
  use elm_varctl           , only : use_lnd_rof_two_way, use_finetop_rad, elm_device_ready
  use seq_drydep_mod   , only : n_drydep, drydep_method, DD_XLND
  use decompMod            , only : bounds_type
  use subgridAveMod        , only : p2t, unity, urbanf, urbans, elm_subgrid_view
  use lnd2atmAvgMod        , only : l2a_add, l2a_built, l2a_finish_group, l2a_average, l2a_patch, l2a_column, &
       l2a_minimal, l2a_full
  use lnd2atmType          , only : lnd2atm_type
  use atm2lndType          , only : atm2lnd_type
  use Ch4TypeMod               , only : ch4_type
  use DUSTMod              , only : dust_type
  use DryDepVelocity       , only : drydepvel_type
  use VocEmissionMod       , only : vocemis_type
  use EnergyFluxType       , only : energyflux_type
  use FrictionVelocityType , only : frictionvel_type
  use SolarAbsorbedType    , only : solarabs_type
  use SurfaceAlbedoType    , only : surfalb_type
  use GridcellType         , only : grc_pp
  use TopounitDataType     , only : top_es, top_af                 ! To calculate t_rad at topounit level needed in downscaling
  use GridcellDataType     , only : grc_ef, grc_ws, grc_wf
  use ColumnDataType       , only : col_ws, col_wf, col_cf, col_es, col_nf
  use VegetationDataType   , only : veg_es, veg_ef, veg_ws, veg_wf
  use SoilHydrologyType    , only : soilhydrology_type 
  use SedFluxType          , only : sedflux_type
  use spmdmod          , only: masterproc
  use elm_varctl     , only : iulog
  !
  ! !PUBLIC TYPES:
  implicit none
  private
  save
  !
  ! !PUBLIC MEMBER FUNCTIONS:
  public :: lnd2atm
  public :: lnd2atm_minimal

  !------------------------------------------------------------------------

contains

  !------------------------------------------------------------------------
  ! The gridcell averages of both routines are entries of one table (lnd2atmAvgMod), added
  ! on the first call from the configuration (the namelist decides which fields exist) and
  ! averaged in one kernel per call; the conversions after the averages are small device loops.

  subroutine lnd2atm_minimal(bounds, &
      surfalb_vars, solarabs_vars, energyflux_vars, atm2lnd_vars, lnd2atm_vars)
    !
    ! !DESCRIPTION:
    ! Compute elm_l2a_vars component of gridcell derived type. This routine computes
    ! the bare minimum of components necessary to get the first step of a
    ! run started.
    !
    ! !USES:
    use elm_varcon, only : sb
    !
    ! !ARGUMENTS:
    type(bounds_type)     , intent(in)    :: bounds
    type(surfalb_type)    , intent(in)    :: surfalb_vars
    type(solarabs_type)   , intent(in)    :: solarabs_vars
    type(energyflux_type) , intent(in)    :: energyflux_vars
    type(atm2lnd_type)    , intent(in)    :: atm2lnd_vars
    type(lnd2atm_type)    , intent(inout) :: lnd2atm_vars
    !
    ! !LOCAL VARIABLES:
    integer :: g, t, ib                                  ! index
    !------------------------------------------------------------------------

    if (.not. l2a_built(l2a_minimal)) then
       call add_c(l2a_minimal, col_ws%h2osno, bounds%begc, lnd2atm_vars%h2osno_grc, bounds%begg, urbanf, unity)
       call add_c2(l2a_minimal, col_ws%h2osoi_vol, bounds%begc, lnd2atm_vars%h2osoi_vol_grc, bounds%begg, nlevgrnd, &
            urbanf, unity)
       call add_p2(l2a_minimal, surfalb_vars%albd_patch, bounds%begp, lnd2atm_vars%albd_grc, bounds%begg, numrad, &
            urbanf, unity)
       call add_p2(l2a_minimal, surfalb_vars%albi_patch, bounds%begp, lnd2atm_vars%albi_grc, bounds%begg, numrad, &
            urbanf, unity)
       call add_p(l2a_minimal, veg_ef%eflx_lwrad_out, bounds%begp, lnd2atm_vars%eflx_lwrad_out_grc, bounds%begg, &
            urbanf, unity)
       if (use_finetop_rad) then
          call add_p(l2a_minimal, solarabs_vars%fsr_vis_d_patch, bounds%begp, lnd2atm_vars%fsr_vis_d_grc, bounds%begg, &
               urbanf, unity)
          call add_p(l2a_minimal, solarabs_vars%fsr_vis_i_patch, bounds%begp, lnd2atm_vars%fsr_vis_i_grc, bounds%begg, &
               urbanf, unity)
          call add_p(l2a_minimal, solarabs_vars%fsr_nir_d_patch, bounds%begp, lnd2atm_vars%fsr_nir_d_grc, bounds%begg, &
               urbanf, unity)
          call add_p(l2a_minimal, solarabs_vars%fsr_nir_i_patch, bounds%begp, lnd2atm_vars%fsr_nir_i_grc, bounds%begg, &
               urbanf, unity)
       end if
       call l2a_finish_group(l2a_minimal)
    end if
    call l2a_average(l2a_minimal, elm_subgrid_view, bounds%begg, bounds%endg, elm_device_ready)

    associate( &
      h2osno_grc         => lnd2atm_vars%h2osno_grc           , &
      apparent_albd_grc  => lnd2atm_vars%apparent_albd_grc    , &
      apparent_albi_grc  => lnd2atm_vars%apparent_albi_grc    , &
      eflx_lwrad_out_grc => lnd2atm_vars%eflx_lwrad_out_grc   , &
      t_rad_grc          => lnd2atm_vars%t_rad_grc            , &
      forc_solad_pp_grc  => atm2lnd_vars%forc_solad_pp_grc    , &
      forc_solai_pp_grc  => atm2lnd_vars%forc_solai_pp_grc    , &
      fsr_vis_d_grc      => lnd2atm_vars%fsr_vis_d_grc        , &
      fsr_vis_i_grc      => lnd2atm_vars%fsr_vis_i_grc        , &
      fsr_nir_d_grc      => lnd2atm_vars%fsr_nir_d_grc        , &
      fsr_nir_i_grc      => lnd2atm_vars%fsr_nir_i_grc        , &
      sky_view_factor    => grc_pp%sky_view_factor              &
      )

    !$acc parallel loop gang vector default(present) if(elm_device_ready) copyin(bounds)
    do g = bounds%begg,bounds%endg
       h2osno_grc(g) = h2osno_grc(g)/1000._r8
       if (use_finetop_rad) then
          eflx_lwrad_out_grc(g) = eflx_lwrad_out_grc(g)*sky_view_factor(g)
       end if
       t_rad_grc(g) = sqrt(sqrt(eflx_lwrad_out_grc(g)/sb))
    end do

    if (use_atm_downscaling_to_topunit) then
       call p2t(bounds, &
            veg_ef%eflx_lwrad_out (bounds%begp:bounds%endp), &
            top_es%eflx_lwrad_out_topo      (bounds%begt:bounds%endt), &
            p2c_scale_type='unity', c2l_scale_type= 'urbanf', l2t_scale_type='unity')
       !$acc parallel loop gang vector default(present) if(elm_device_ready) copyin(bounds)
       do t = bounds%begt,bounds%endt
          top_es%t_rad(t) = sqrt(sqrt(top_es%eflx_lwrad_out_topo(t)/sb))
       end do
    end if

    ! the apparent albedos for the coupling (fine topographic radiation)
    if (use_finetop_rad) then
       !$acc parallel loop gang vector default(present) private(ib) if(elm_device_ready) copyin(bounds)
       do g = bounds%begg,bounds%endg
           !$acc loop seq
           do ib = 1, numrad
               apparent_albd_grc(g,ib) = 1._r8
               apparent_albi_grc(g,ib) = 1._r8
           end do
           ib = 1
           if (forc_solad_pp_grc(g,ib) > 0._r8) then
               apparent_albd_grc(g,ib) = fsr_vis_d_grc(g)/forc_solad_pp_grc(g,ib)*sky_view_factor(g)
           end if
           ib = 2
           if (forc_solad_pp_grc(g,ib) > 0._r8) then
               apparent_albd_grc(g,ib) = fsr_nir_d_grc(g)/forc_solad_pp_grc(g,ib)*sky_view_factor(g)
           end if
           ib = 1
           if (forc_solai_pp_grc(g,ib) > 0._r8) then
               apparent_albi_grc(g,ib) = fsr_vis_i_grc(g)/forc_solai_pp_grc(g,ib)*sky_view_factor(g)
           end if
           ib = 2
           if (forc_solai_pp_grc(g,ib) > 0._r8) then
               apparent_albi_grc(g,ib) = fsr_nir_i_grc(g)/forc_solai_pp_grc(g,ib)*sky_view_factor(g)
           end if
           !$acc loop seq
           do ib = 1, numrad
               if (apparent_albd_grc(g,ib) > 1._r8) then
                   apparent_albd_grc(g,ib) = 1._r8
               end if
               if (apparent_albi_grc(g,ib) > 1._r8) then
                   apparent_albi_grc(g,ib) = 1._r8
               end if
           end do
        end do
     end if

    end associate
  end subroutine lnd2atm_minimal

  !------------------------------------------------------------------------
  subroutine lnd2atm(bounds, &
       atm2lnd_vars, surfalb_vars, frictionvel_vars, &
       energyflux_vars, &
       solarabs_vars, drydepvel_vars, &
       vocemis_vars, dust_vars, ch4_vars, soilhydrology_vars, &
       sedflux_vars, lnd2atm_vars)
    !
    ! !DESCRIPTION:
    ! Compute lnd2atm_vars component of gridcell derived type
    !
    ! !USES:
    use CH4varcon  , only : ch4offline
    !
    ! !ARGUMENTS:
    type(bounds_type)      , intent(in)     :: bounds
    type(atm2lnd_type)     , intent(in)     :: atm2lnd_vars
    type(surfalb_type)     , intent(in)     :: surfalb_vars
    type(frictionvel_type) , intent(in)     :: frictionvel_vars
    type(energyflux_type)  , intent(in)     :: energyflux_vars
    type(solarabs_type)    , intent(in)     :: solarabs_vars
    type(drydepvel_type)   , intent(in)     :: drydepvel_vars
    type(vocemis_type)     , intent(in)     :: vocemis_vars
    type(dust_type)        , intent(in)     :: dust_vars
    type(ch4_type)         , intent(in)     :: ch4_vars
    type(soilhydrology_type), intent(in)    :: soilhydrology_vars
    type(sedflux_type)     , intent(in)     :: sedflux_vars
    type(lnd2atm_type)     , intent(inout)  :: lnd2atm_vars
    !
    ! !LOCAL VARIABLES:
    integer :: g, c, nhot, begg       ! indices, gridcells over 400 K
    logical :: add_nem                ! methane emissions go into nee
    real(r8), parameter :: amC   = 12.0_r8 ! Atomic mass number for Carbon
    real(r8), parameter :: amO   = 16.0_r8 ! Atomic mass number for Oxygen
    real(r8), parameter :: amCO2 = amC + 2.0_r8*amO ! Atomic mass number for CO2
    ! The following converts g of C to kg of CO2
    real(r8), parameter :: convertgC2kgCO2 = 1.0e-3_r8 * (amCO2/amC)
    !------------------------------------------------------------------------

    ! lnd2atm_minimal's fields first
    call lnd2atm_minimal(bounds, &
         surfalb_vars, solarabs_vars, energyflux_vars, atm2lnd_vars, lnd2atm_vars)

    if (.not. l2a_built(l2a_full)) then
       call add_p(l2a_full, veg_es%t_ref2m, bounds%begp, lnd2atm_vars%t_ref2m_grc, bounds%begg, unity, unity)
       call add_p(l2a_full, veg_ws%q_ref2m, bounds%begp, lnd2atm_vars%q_ref2m_grc, bounds%begg, unity, unity)
       call add_p(l2a_full, frictionvel_vars%u10_elm_patch, bounds%begp, lnd2atm_vars%u_ref10m_grc, bounds%begg, &
            unity, unity)
       call add_p(l2a_full, frictionvel_vars%u10_with_gusts_elm_patch, bounds%begp, &
            lnd2atm_vars%u_ref10m_with_gusts_grc, bounds%begg, unity, unity)
       call add_p(l2a_full, veg_ef%taux, bounds%begp, lnd2atm_vars%taux_grc, bounds%begg, unity, unity)
       call add_p(l2a_full, veg_ef%tauy, bounds%begp, lnd2atm_vars%tauy_grc, bounds%begg, unity, unity)
       call add_p(l2a_full, veg_wf%qflx_evap_tot, bounds%begp, lnd2atm_vars%qflx_evap_tot_grc, bounds%begg, &
            urbanf, unity)
       call add_p(l2a_full, solarabs_vars%fsa_patch, bounds%begp, lnd2atm_vars%fsa_grc, bounds%begg, urbanf, unity)
       call add_p(l2a_full, frictionvel_vars%fv_patch, bounds%begp, lnd2atm_vars%fv_grc, bounds%begg, unity, unity)
       call add_p(l2a_full, frictionvel_vars%ram1_patch, bounds%begp, lnd2atm_vars%ram1_grc, bounds%begg, unity, unity)
       call add_p(l2a_full, veg_ef%eflx_sh_tot, bounds%begp, lnd2atm_vars%eflx_sh_tot_grc, bounds%begg, urbanf, unity)
       call add_p(l2a_full, veg_ef%eflx_lh_tot, bounds%begp, lnd2atm_vars%eflx_lh_tot_grc, bounds%begg, urbanf, unity)
       if (use_cn .or. use_fates) then
          call add_c(l2a_full, col_cf%nee, bounds%begc, lnd2atm_vars%nee_grc, bounds%begg, unity, unity)
       end if
       if (n_drydep > 0 .and. drydep_method == DD_XLND) then
          call add_p2(l2a_full, drydepvel_vars%velocity_patch, bounds%begp, lnd2atm_vars%ddvel_grc, bounds%begg, &
               n_drydep, unity, unity)
       end if
       if (use_voc .and. shr_megan_mechcomps_n > 0) then
          call add_p2(l2a_full, vocemis_vars%vocflx_patch, bounds%begp, lnd2atm_vars%flxvoc_grc, bounds%begg, &
               shr_megan_mechcomps_n, unity, unity)
       end if
       call add_p2(l2a_full, dust_vars%flx_mss_vrt_dst_patch, bounds%begp, lnd2atm_vars%flxdst_grc, bounds%begg, &
            ndst, unity, unity)
       if (use_lch4) then
          call add_c(l2a_full, ch4_vars%ch4_surf_flux_tot_col, bounds%begc, lnd2atm_vars%flux_ch4_grc, bounds%begg, &
               unity, unity)
       end if
       if (shr_fan_to_atm) then
          call add_c(l2a_full, col_nf%nh3_total, bounds%begc, lnd2atm_vars%flux_nh3_grc, bounds%begg, unity, unity)
       end if
       call add_c(l2a_full, col_wf%qflx_runoff, bounds%begc, lnd2atm_vars%qflx_rofliq_grc, bounds%begg, urbanf, unity)
       call add_c(l2a_full, col_wf%qflx_surf, bounds%begc, lnd2atm_vars%qflx_rofliq_qsur_grc, bounds%begg, urbanf, unity)
       call add_c(l2a_full, col_wf%qflx_h2osfc_surf, bounds%begc, lnd2atm_vars%qflx_rofliq_qsurp_grc, bounds%begg, &
            urbanf, unity)
       call add_c(l2a_full, col_wf%qflx_irr_demand, bounds%begc, lnd2atm_vars%qflx_irr_demand_grc, bounds%begg, &
            urbanf, unity)
       call add_c(l2a_full, col_wf%qflx_drain, bounds%begc, lnd2atm_vars%qflx_rofliq_qsub_grc, bounds%begg, urbanf, unity)
       call add_c(l2a_full, col_wf%qflx_drain_perched, bounds%begc, lnd2atm_vars%qflx_rofliq_qsubp_grc, bounds%begg, &
            urbanf, unity)
       call add_c(l2a_full, col_wf%qflx_qrgwl, bounds%begc, lnd2atm_vars%qflx_rofliq_qgwl_grc, bounds%begg, urbanf, unity)
       ! qflx_snwcp_ice includes qflx_ice_runoff_xs (added before the averages, below)
       call add_c(l2a_full, col_wf%qflx_snwcp_ice, bounds%begc, lnd2atm_vars%qflx_rofice_grc, bounds%begg, urbanf, unity)
       call add_c(l2a_full, surfalb_vars%coszen_col, bounds%begc, lnd2atm_vars%coszen_str, bounds%begg, urbanf, unity)
       if (use_lnd_rof_two_way) then
          call add_c(l2a_full, col_wf%qflx_h2orof_drain, bounds%begc, lnd2atm_vars%qflx_h2orof_drain_grc, bounds%begg, &
               unity, unity)
       end if
       call add_c(l2a_full, col_ws%wslake_col, bounds%begc, lnd2atm_vars%wslake_grc, bounds%begg, urbanf, unity)
       call add_c(l2a_full, col_ws%endwb, bounds%begc, grc_ws%tws, bounds%begg, urbanf, unity)
       call add_c(l2a_full, col_es%t_grnd, bounds%begc, lnd2atm_vars%t_grnd_grc, bounds%begg, urbans, unity)
       call add_c2(l2a_full, col_es%t_soisno, bounds%begc, lnd2atm_vars%t_soisno_grc, bounds%begg, nlevgrnd+nlevsno, &
            urbans, unity)
       call add_c(l2a_full, soilhydrology_vars%zwt_col, bounds%begc, lnd2atm_vars%zwt_grc, bounds%begg, urbans, unity)
       call add_c(l2a_full, sedflux_vars%sed_yld_col, bounds%begc, lnd2atm_vars%qflx_rofmud_grc, bounds%begg, &
            urbanf, unity)
       call l2a_finish_group(l2a_full)
    end if

    ! ice runoff includes the excess ice of capped snow
    !$acc parallel loop gang vector default(present) if(elm_device_ready) copyin(bounds)
    do c = bounds%begc, bounds%endc
       col_wf%qflx_snwcp_ice(c) = col_wf%qflx_snwcp_ice(c) + col_wf%qflx_ice_runoff_xs(c)
    end do

    call l2a_average(l2a_full, elm_subgrid_view, bounds%begg, bounds%endg, elm_device_ready)

    ! conversions after the averages
    add_nem = use_lch4 .and. .not. ch4offline
    begg = bounds%begg
    nhot = 0
    associate( &
      nee_grc         => lnd2atm_vars%nee_grc         , &
      t_soisno_grc    => lnd2atm_vars%t_soisno_grc    , &
      zwt_grc         => lnd2atm_vars%zwt_grc           &
      )
    !$acc parallel loop gang vector default(present) reduction(+:nhot) if(elm_device_ready) copyin(bounds)
    do g = bounds%begg, bounds%endg
       lnd2atm_vars%eflx_sh_tot_grc(g) = lnd2atm_vars%eflx_sh_tot_grc(g) - grc_ef%eflx_dynbal(g)
       if (use_cn .or. use_fates) then
          if (add_nem) nee_grc(g) = nee_grc(g) + lnd2atm_vars%nem_grc(g)
          nee_grc(g) = nee_grc(g)*convertgC2kgCO2
       else
          nee_grc(g) = 0._r8
       end if
       lnd2atm_vars%qflx_rofliq_grc(g) = lnd2atm_vars%qflx_rofliq_grc(g) - grc_wf%qflx_liq_dynbal(g)
       lnd2atm_vars%qflx_rofice_grc(g) = lnd2atm_vars%qflx_rofice_grc(g) - grc_wf%qflx_ice_dynbal(g)
       grc_ws%tws(g) = grc_ws%tws(g) + atm2lnd_vars%volr_grc(g) / grc_pp%area(g) * 1.e-3_r8
       if (t_soisno_grc(g, 1) > 400._r8) nhot = nhot + 1
       lnd2atm_vars%Tqsur_grc(g) = avg_tsoil_surf(t_soisno_grc, begg, g)
       lnd2atm_vars%Tqsub_grc(g) = avg_tsoil(zwt_grc(g), t_soisno_grc, begg, g)
    end do
    if (nhot > 0) then
       !$acc update self(t_soisno_grc) if(elm_device_ready)
       do g = bounds%begg, bounds%endg
          if (t_soisno_grc(g, 1) > 400._r8) then
             write(iulog,*)'lnd2atm_vars%t_soisno_grc(g, 1) is',t_soisno_grc(g, 1)
             call endrun( msg=' lnd2atm ERROR: lnd2atm_vars%t_soisno_grc >  400 Kelvin degree.'//errMsg(__FILE__, __LINE__))
          end if
       end do
    end if
    end associate

  end subroutine lnd2atm

  !------------------------------------------------------------------------
  ! table entries: one per field, one per level of a 2d field (levels counted from the
  ! arrays' own lower bounds, as subgridAveMod's p2g/c2g 2d do)

  subroutine add_p(group, parr, begp, garr, begg, c2l_scale_type, l2g_scale_type)
    integer , intent(in) :: group, begp, begg, c2l_scale_type, l2g_scale_type
    real(r8), intent(in), target :: parr(:), garr(:)
    call l2a_add(group, l2a_patch, parr, begp, garr, begg, c2l_scale_type, l2g_scale_type)
  end subroutine add_p

  subroutine add_c(group, carr, begc, garr, begg, c2l_scale_type, l2g_scale_type)
    integer , intent(in) :: group, begc, begg, c2l_scale_type, l2g_scale_type
    real(r8), intent(in), target :: carr(:), garr(:)
    call l2a_add(group, l2a_column, carr, begc, garr, begg, c2l_scale_type, l2g_scale_type)
  end subroutine add_c

  subroutine add_p2(group, parr, begp, garr, begg, nlev, c2l_scale_type, l2g_scale_type)
    integer , intent(in) :: group, begp, begg, nlev, c2l_scale_type, l2g_scale_type
    real(r8), intent(in), target :: parr(:,:), garr(:,:)
    integer :: j
    do j = 1, nlev
       call l2a_add(group, l2a_patch, parr(:,j), begp, garr(:,j), begg, c2l_scale_type, l2g_scale_type)
    end do
  end subroutine add_p2

  subroutine add_c2(group, carr, begc, garr, begg, nlev, c2l_scale_type, l2g_scale_type)
    integer , intent(in) :: group, begc, begg, nlev, c2l_scale_type, l2g_scale_type
    real(r8), intent(in), target :: carr(:,:), garr(:,:)
    integer :: j
    do j = 1, nlev
       call l2a_add(group, l2a_column, carr(:,j), begc, garr(:,j), begg, c2l_scale_type, l2g_scale_type)
    end do
  end subroutine add_c2

  !------------------------------------------------------------------------
  ! average soil temperatures of lnd2atm (Tqsur, Tqsub): the soil layer thicknesses of
  ! Eqn. (6.5) and (6.6) in the CLM4.0 tech note, computed per layer (no work arrays, so they
  ! run inside the gridcell kernel; the arithmetic of the earlier array versions)

  real(r8) function soil_depth(ilvl)
    !$acc routine seq
    integer, intent(in) :: ilvl
    soil_depth = 0.025_r8*(EXP(0.5_r8*(REAL(ilvl)-0.5_r8))-1._r8)
  end function soil_depth

  real(r8) function soil_h_layer(ilvl)
    !$acc routine seq
    integer, intent(in) :: ilvl
    if (ilvl == 1) then
       soil_h_layer = 0.5_r8*(soil_depth(1)+soil_depth(2))
    else if (ilvl == nlevsoi) then
       soil_h_layer = soil_depth(nlevsoi) - soil_depth(nlevsoi-1)
    else
       soil_h_layer = 0.5_r8*(soil_depth(ilvl+1)-soil_depth(ilvl-1))
    end if
  end function soil_h_layer

  real(r8) function avg_tsoil_surf(Tsoil_, begg, g) result(avgT_)
    ! average soil temperature within the top few layers (which closely interact with surface runoff)
    !$acc routine seq
    integer , intent(in) :: begg, g
    real(r8), intent(in) :: Tsoil_(begg:,-nlevsno+1:)  ! gridcell soil temperatures
    integer :: ilvl
    real(r8) :: sum_h, sum_ht
    sum_h = 0._r8
    sum_ht = 0._r8
    do ilvl = 1, 3
       sum_h = sum_h + soil_h_layer(ilvl)
       sum_ht = sum_ht + soil_h_layer(ilvl)*Tsoil_(g,ilvl)
    enddo
    avgT_ = sum_ht/sum_h
  end function avg_tsoil_surf

  real(r8) function avg_tsoil(zwt_, Tsoil_, begg, g) result(avgT_)
    ! average soil temperature within the saturated soil zone (which produces subsurface runoff)
    !$acc routine seq
    real(r8), intent(in) :: zwt_                       ! water table depth
    integer , intent(in) :: begg, g
    real(r8), intent(in) :: Tsoil_(begg:,-nlevsno+1:)  ! gridcell soil temperatures
    integer :: ilvl, izwt
    real(r8) :: sum_h, sum_ht
    if(zwt_ <= 0._r8) then ! water table close to ground surface, average over the whole soil column
       sum_h = 0._r8
       sum_ht = 0._r8
       do ilvl = 1, nlevsoi
          sum_h = sum_h + soil_h_layer(ilvl)
          sum_ht = sum_ht + soil_h_layer(ilvl)*Tsoil_(g,ilvl)
       enddo
       avgT_ = sum_ht/sum_h
    else if(zwt_ >= soil_depth(nlevsoi)) then ! water table deeper than the total soil depth
       avgT_ = Tsoil_(g,nlevsoi)
    else
       sum_h = 0._r8
       sum_ht = 0._r8
       izwt = nlevsoi
       ! find out which soil layer the water table is located
       do ilvl = 1, nlevsoi
          if(zwt_ <= soil_depth(ilvl)) then
             izwt = ilvl
             sum_h = soil_depth(ilvl) - zwt_
             sum_ht = (soil_depth(ilvl) - zwt_)*Tsoil_(g,ilvl)
             exit
          end if
       enddo
       ! calculate mean soil temperature of the total saturated soil zone
       do ilvl = izwt + 1, nlevsoi
          sum_h = sum_h + soil_h_layer(ilvl)
          sum_ht = sum_ht + soil_h_layer(ilvl)*Tsoil_(g,ilvl)
       enddo
       avgT_ = sum_ht/sum_h
    end if
  end function avg_tsoil

end module lnd2atmMod
