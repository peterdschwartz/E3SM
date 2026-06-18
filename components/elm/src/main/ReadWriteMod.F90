module ReadWriteMod
  !!! Auto-generated Fortran code for netcdf-fortran I/O
  use netcdf
  use nc_io
  use nc_allocMod
  use photosynthesistype, only: photosyns_type
  use cnstatetype, only: cnstate_type
  use columntype, only : col_pp
  use solarabsorbedtype, only: solarabs_type
  use vegetationdatatype, only : veg_ws
  use columndatatype, only : col_ws
  use canopystatetype, only: canopystate_type
  use vegetationdatatype, only : veg_ef
  use topounitdatatype, only : top_as
  use decompmod, only : bounds_type
  use vegetationdatatype, only : veg_es
  use vegetationdatatype, only : veg_wf
  use surfacealbedotype, only: surfalb_type
  use frictionvelocitytype, only: frictionvel_type
  use soilstatetype, only: soilstate_type
  use topounitdatatype, only : top_af
  use gridcelltype, only : grc_pp
  use landunittype, only : lun_pp
  use vegetationtype, only : veg_pp
  use columndatatype, only : col_es
  use vegetationdatatype, only : veg_ps
  use energyfluxtype, only: energyflux_type
  use sharedparamsmod, only : paramsshareinst
  use atm2lndtype, only: atm2lnd_type
  use ch4mod, only: ch4_type
  use photosynthesismod, only : params_inst
  use columndatatype, only : col_ef
  use topounittype, only : top_pp
  use vegetationpropertiestype, only : veg_vp
  use vegetationdatatype, only : veg_ns
  implicit none
  public :: read_elmtypes, write_elmtypes, define_vars
  logical, parameter :: verbose = .False.
contains
  subroutine define_vars(ncid,bounds, atm2lnd_vars, canopystate_vars, cnstate_vars, energyflux_vars, frictionvel_vars, soilstate_vars, solarabs_vars, surfalb_vars, ch4_vars, photosyns_vars)
    integer, intent(in) :: ncid
    type(bounds_type), intent(in) :: bounds
    type(atm2lnd_type), intent(in) :: atm2lnd_vars
    type(canopystate_type), intent(in) :: canopystate_vars
    type(cnstate_type), intent(in) :: cnstate_vars
    type(energyflux_type), intent(in) :: energyflux_vars
    type(frictionvel_type), intent(in) :: frictionvel_vars
    type(soilstate_type), intent(in) :: soilstate_vars
    type(solarabs_type), intent(in) :: solarabs_vars
    type(surfalb_type), intent(in) :: surfalb_vars
    type(ch4_type), intent(in) :: ch4_vars
    type(photosyns_type), intent(in) :: photosyns_vars
    integer :: varid, time_id
    character(len=32), dimension(5) :: dim_names
    call check(nf90_def_dim(ncid, 'time', NF90_UNLIMITED, time_id))
    call nc_define_var(ncid, 0, [0], dim_names, 'bounds__begg', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'bounds__endg', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'bounds__begt', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'bounds__endt', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'bounds__begl', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'bounds__endl', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'bounds__begc', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'bounds__endc', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'bounds__begp', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'bounds__endp', nf90_int, varid, .false.)
    dim_names(1:1) = [character(len=32) :: 'landunit']
    call nc_define_var(ncid, 1, shape(lun_pp%gridcell), dim_names, 'lun_pp__gridcell', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(lun_pp%gridcell))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(lun_pp%gridcell)));
    dim_names(1:1) = [character(len=32) :: 'landunit']
    call nc_define_var(ncid, 1, shape(lun_pp%topounit), dim_names, 'lun_pp__topounit', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(lun_pp%topounit))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(lun_pp%topounit)));
    dim_names(1:1) = [character(len=32) :: 'landunit']
    call nc_define_var(ncid, 1, shape(lun_pp%pfti), dim_names, 'lun_pp__pfti', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(lun_pp%pfti))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(lun_pp%pfti)));
    dim_names(1:1) = [character(len=32) :: 'landunit']
    call nc_define_var(ncid, 1, shape(lun_pp%pftf), dim_names, 'lun_pp__pftf', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(lun_pp%pftf))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(lun_pp%pftf)));
    dim_names(1:1) = [character(len=32) :: 'landunit']
    call nc_define_var(ncid, 1, shape(lun_pp%itype), dim_names, 'lun_pp__itype', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(lun_pp%itype))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(lun_pp%itype)));
    dim_names(1:1) = [character(len=32) :: 'landunit']
    call nc_define_var(ncid, 1, shape(lun_pp%lakpoi), dim_names, 'lun_pp__lakpoi', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(lun_pp%lakpoi))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(lun_pp%lakpoi)));
    dim_names(1:1) = [character(len=32) :: 'landunit']
    call nc_define_var(ncid, 1, shape(lun_pp%urbpoi), dim_names, 'lun_pp__urbpoi', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(lun_pp%urbpoi))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(lun_pp%urbpoi)));
    dim_names(1:1) = [character(len=32) :: 'landunit']
    call nc_define_var(ncid, 1, shape(lun_pp%active), dim_names, 'lun_pp__active', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(lun_pp%active))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(lun_pp%active)));
    call nc_define_var(ncid, 0, [0], dim_names, 'paramsshareinst__q10_mr', nf90_double, varid, .false.)
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%smpso), dim_names, 'veg_vp__smpso', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%smpso))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%smpso)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%smpsc), dim_names, 'veg_vp__smpsc', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%smpsc))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%smpsc)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%fnitr), dim_names, 'veg_vp__fnitr', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%fnitr))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%fnitr)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%dleaf), dim_names, 'veg_vp__dleaf', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%dleaf))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%dleaf)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%c3psn), dim_names, 'veg_vp__c3psn', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%c3psn))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%c3psn)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%slatop), dim_names, 'veg_vp__slatop', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%slatop))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%slatop)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%root_radius), dim_names, 'veg_vp__root_radius', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%root_radius))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%root_radius)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%root_density), dim_names, 'veg_vp__root_density', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%root_density))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%root_density)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%leafcn), dim_names, 'veg_vp__leafcn', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%leafcn))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%leafcn)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%flnr), dim_names, 'veg_vp__flnr', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%flnr))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%flnr)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%froot_leaf), dim_names, 'veg_vp__froot_leaf', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%froot_leaf))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%froot_leaf)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%stem_leaf), dim_names, 'veg_vp__stem_leaf', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%stem_leaf))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%stem_leaf)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%croot_stem), dim_names, 'veg_vp__croot_stem', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%croot_stem))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%croot_stem)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%i_vc), dim_names, 'veg_vp__i_vc', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%i_vc))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%i_vc)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%s_vc), dim_names, 'veg_vp__s_vc', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%s_vc))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%s_vc)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%fnr), dim_names, 'veg_vp__fnr', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%fnr))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%fnr)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%act25), dim_names, 'veg_vp__act25', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%act25))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%act25)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%kcha), dim_names, 'veg_vp__kcha', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%kcha))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%kcha)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%koha), dim_names, 'veg_vp__koha', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%koha))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%koha)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%cpha), dim_names, 'veg_vp__cpha', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%cpha))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%cpha)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%vcmaxha), dim_names, 'veg_vp__vcmaxha', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%vcmaxha))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%vcmaxha)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%jmaxha), dim_names, 'veg_vp__jmaxha', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%jmaxha))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%jmaxha)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%tpuha), dim_names, 'veg_vp__tpuha', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%tpuha))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%tpuha)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%lmrha), dim_names, 'veg_vp__lmrha', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%lmrha))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%lmrha)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%vcmaxhd), dim_names, 'veg_vp__vcmaxhd', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%vcmaxhd))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%vcmaxhd)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%jmaxhd), dim_names, 'veg_vp__jmaxhd', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%jmaxhd))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%jmaxhd)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%tpuhd), dim_names, 'veg_vp__tpuhd', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%tpuhd))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%tpuhd)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%lmrhd), dim_names, 'veg_vp__lmrhd', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%lmrhd))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%lmrhd)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%lmrse), dim_names, 'veg_vp__lmrse', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%lmrse))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%lmrse)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%qe), dim_names, 'veg_vp__qe', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%qe))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%qe)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%theta_cj), dim_names, 'veg_vp__theta_cj', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%theta_cj))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%theta_cj)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%bbbopt), dim_names, 'veg_vp__bbbopt', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%bbbopt))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%bbbopt)));
    dim_names(1:1) = [character(len=32) :: '_0_numpft']
    call nc_define_var(ncid, 1, shape(veg_vp%mbbopt), dim_names, 'veg_vp__mbbopt', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_vp%mbbopt))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_vp%mbbopt)));
    call nc_define_var(ncid, 0, [0], dim_names, 'veg_vp__tc_stress', nf90_double, varid, .false.)
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%frac_veg_nosno_patch), dim_names, 'canopystate_vars__frac_veg_nosno_patch', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%frac_veg_nosno_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%frac_veg_nosno_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%tlai_patch), dim_names, 'canopystate_vars__tlai_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%tlai_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%tlai_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%tsai_patch), dim_names, 'canopystate_vars__tsai_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%tsai_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%tsai_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%elai_patch), dim_names, 'canopystate_vars__elai_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%elai_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%elai_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%esai_patch), dim_names, 'canopystate_vars__esai_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%esai_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%esai_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%laisun_patch), dim_names, 'canopystate_vars__laisun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%laisun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%laisun_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%laisha_patch), dim_names, 'canopystate_vars__laisha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%laisha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%laisha_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(canopystate_vars%laisun_z_patch), dim_names, 'canopystate_vars__laisun_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%laisun_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%laisun_z_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(canopystate_vars%laisha_z_patch), dim_names, 'canopystate_vars__laisha_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%laisha_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%laisha_z_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%htop_patch), dim_names, 'canopystate_vars__htop_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%htop_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%htop_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%displa_patch), dim_names, 'canopystate_vars__displa_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%displa_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%displa_patch)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(canopystate_vars%altmax_indx_col), dim_names, 'canopystate_vars__altmax_indx_col', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%altmax_indx_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%altmax_indx_col)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(canopystate_vars%altmax_lastyear_indx_col), dim_names, 'canopystate_vars__altmax_lastyear_indx_col', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%altmax_lastyear_indx_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%altmax_lastyear_indx_col)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%dleaf_patch), dim_names, 'canopystate_vars__dleaf_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%dleaf_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%dleaf_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(canopystate_vars%lbl_rsc_h2o_patch), dim_names, 'canopystate_vars__lbl_rsc_h2o_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%lbl_rsc_h2o_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%lbl_rsc_h2o_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nvegwcs']
    call nc_define_var(ncid, 2, shape(canopystate_vars%vegwp_patch), dim_names, 'canopystate_vars__vegwp_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(canopystate_vars%vegwp_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(canopystate_vars%vegwp_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(cnstate_vars%downreg_patch), dim_names, 'cnstate_vars__downreg_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(cnstate_vars%downreg_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(cnstate_vars%downreg_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(cnstate_vars%rc14_atm_patch), dim_names, 'cnstate_vars__rc14_atm_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(cnstate_vars%rc14_atm_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(cnstate_vars%rc14_atm_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(energyflux_vars%canopy_cond_patch), dim_names, 'energyflux_vars__canopy_cond_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(energyflux_vars%canopy_cond_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(energyflux_vars%canopy_cond_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(energyflux_vars%btran_patch), dim_names, 'energyflux_vars__btran_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(energyflux_vars%btran_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(energyflux_vars%btran_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(energyflux_vars%bsun_patch), dim_names, 'energyflux_vars__bsun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(energyflux_vars%bsun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(energyflux_vars%bsun_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(energyflux_vars%bsha_patch), dim_names, 'energyflux_vars__bsha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(energyflux_vars%bsha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(energyflux_vars%bsha_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(energyflux_vars%btran2_patch), dim_names, 'energyflux_vars__btran2_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(energyflux_vars%btran2_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(energyflux_vars%btran2_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevgrnd']
    call nc_define_var(ncid, 2, shape(energyflux_vars%rresis_patch), dim_names, 'energyflux_vars__rresis_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(energyflux_vars%rresis_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(energyflux_vars%rresis_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%forc_hgt_u_patch), dim_names, 'frictionvel_vars__forc_hgt_u_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%forc_hgt_u_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%forc_hgt_u_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%forc_hgt_t_patch), dim_names, 'frictionvel_vars__forc_hgt_t_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%forc_hgt_t_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%forc_hgt_t_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%forc_hgt_q_patch), dim_names, 'frictionvel_vars__forc_hgt_q_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%forc_hgt_q_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%forc_hgt_q_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%u10_patch), dim_names, 'frictionvel_vars__u10_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%u10_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%u10_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%u10_elm_patch), dim_names, 'frictionvel_vars__u10_elm_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%u10_elm_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%u10_elm_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%u10_with_gusts_elm_patch), dim_names, 'frictionvel_vars__u10_with_gusts_elm_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%u10_with_gusts_elm_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%u10_with_gusts_elm_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%va_patch), dim_names, 'frictionvel_vars__va_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%va_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%va_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%vds_patch), dim_names, 'frictionvel_vars__vds_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%vds_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%vds_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%fv_patch), dim_names, 'frictionvel_vars__fv_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%fv_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%fv_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%rb1_patch), dim_names, 'frictionvel_vars__rb1_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%rb1_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%rb1_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%ram1_patch), dim_names, 'frictionvel_vars__ram1_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%ram1_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%ram1_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%z0mv_patch), dim_names, 'frictionvel_vars__z0mv_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%z0mv_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%z0mv_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%z0hv_patch), dim_names, 'frictionvel_vars__z0hv_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%z0hv_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%z0hv_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%z0qv_patch), dim_names, 'frictionvel_vars__z0qv_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%z0qv_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%z0qv_patch)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%z0mg_col), dim_names, 'frictionvel_vars__z0mg_col', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%z0mg_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%z0mg_col)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%num_iter_patch), dim_names, 'frictionvel_vars__num_iter_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%num_iter_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%num_iter_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%rah_above_patch), dim_names, 'frictionvel_vars__rah_above_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%rah_above_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%rah_above_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%raw_below_patch), dim_names, 'frictionvel_vars__raw_below_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%raw_below_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%raw_below_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%ustar_patch), dim_names, 'frictionvel_vars__ustar_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%ustar_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%ustar_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%um_patch), dim_names, 'frictionvel_vars__um_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%um_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%um_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%uaf_patch), dim_names, 'frictionvel_vars__uaf_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%uaf_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%uaf_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%taf_patch), dim_names, 'frictionvel_vars__taf_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%taf_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%taf_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%qaf_patch), dim_names, 'frictionvel_vars__qaf_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%qaf_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%qaf_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%obu_patch), dim_names, 'frictionvel_vars__obu_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%obu_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%obu_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%zeta_patch), dim_names, 'frictionvel_vars__zeta_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%zeta_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%zeta_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(frictionvel_vars%vpd_patch), dim_names, 'frictionvel_vars__vpd_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(frictionvel_vars%vpd_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(frictionvel_vars%vpd_patch)));
    dim_names(1:2) = [character(len=32) :: 'column','nlevgrnd']
    call nc_define_var(ncid, 2, shape(soilstate_vars%hksat_col), dim_names, 'soilstate_vars__hksat_col', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%hksat_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%hksat_col)));
    dim_names(1:2) = [character(len=32) :: 'column','nlevgrnd']
    call nc_define_var(ncid, 2, shape(soilstate_vars%hk_l_col), dim_names, 'soilstate_vars__hk_l_col', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%hk_l_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%hk_l_col)));
    dim_names(1:2) = [character(len=32) :: 'column','nlevgrnd']
    call nc_define_var(ncid, 2, shape(soilstate_vars%smp_l_col), dim_names, 'soilstate_vars__smp_l_col', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%smp_l_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%smp_l_col)));
    dim_names(1:2) = [character(len=32) :: 'column','nlevgrnd']
    call nc_define_var(ncid, 2, shape(soilstate_vars%bsw_col), dim_names, 'soilstate_vars__bsw_col', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%bsw_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%bsw_col)));
    dim_names(1:2) = [character(len=32) :: 'column','nlevgrnd']
    call nc_define_var(ncid, 2, shape(soilstate_vars%watsat_col), dim_names, 'soilstate_vars__watsat_col', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%watsat_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%watsat_col)));
    dim_names(1:2) = [character(len=32) :: 'column','nlevgrnd']
    call nc_define_var(ncid, 2, shape(soilstate_vars%sucsat_col), dim_names, 'soilstate_vars__sucsat_col', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%sucsat_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%sucsat_col)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(soilstate_vars%soilbeta_col), dim_names, 'soilstate_vars__soilbeta_col', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%soilbeta_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%soilbeta_col)));
    dim_names(1:2) = [character(len=32) :: 'column','nlevgrnd']
    call nc_define_var(ncid, 2, shape(soilstate_vars%eff_porosity_col), dim_names, 'soilstate_vars__eff_porosity_col', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%eff_porosity_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%eff_porosity_col)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevgrnd']
    call nc_define_var(ncid, 2, shape(soilstate_vars%rootr_patch), dim_names, 'soilstate_vars__rootr_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%rootr_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%rootr_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevgrnd']
    call nc_define_var(ncid, 2, shape(soilstate_vars%rootfr_patch), dim_names, 'soilstate_vars__rootfr_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%rootfr_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%rootfr_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevsoi']
    call nc_define_var(ncid, 2, shape(soilstate_vars%k_soil_root_patch), dim_names, 'soilstate_vars__k_soil_root_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%k_soil_root_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%k_soil_root_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevsoi']
    call nc_define_var(ncid, 2, shape(soilstate_vars%root_conductance_patch), dim_names, 'soilstate_vars__root_conductance_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%root_conductance_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%root_conductance_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevsoi']
    call nc_define_var(ncid, 2, shape(soilstate_vars%soil_conductance_patch), dim_names, 'soilstate_vars__soil_conductance_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(soilstate_vars%soil_conductance_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(soilstate_vars%soil_conductance_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(solarabs_vars%parsun_z_patch), dim_names, 'solarabs_vars__parsun_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(solarabs_vars%parsun_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(solarabs_vars%parsun_z_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(solarabs_vars%parsha_z_patch), dim_names, 'solarabs_vars__parsha_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(solarabs_vars%parsha_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(solarabs_vars%parsha_z_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(solarabs_vars%sabv_patch), dim_names, 'solarabs_vars__sabv_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(solarabs_vars%sabv_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(solarabs_vars%sabv_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','nlevcan']
    call nc_define_var(ncid, 2, shape(surfalb_vars%tlai_z_patch), dim_names, 'surfalb_vars__tlai_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(surfalb_vars%tlai_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(surfalb_vars%tlai_z_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(surfalb_vars%nrad_patch), dim_names, 'surfalb_vars__nrad_patch', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(surfalb_vars%nrad_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(surfalb_vars%nrad_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(surfalb_vars%vcmaxcintsun_patch), dim_names, 'surfalb_vars__vcmaxcintsun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(surfalb_vars%vcmaxcintsun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(surfalb_vars%vcmaxcintsun_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(surfalb_vars%vcmaxcintsha_patch), dim_names, 'surfalb_vars__vcmaxcintsha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(surfalb_vars%vcmaxcintsha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(surfalb_vars%vcmaxcintsha_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(ch4_vars%grnd_ch4_cond_patch), dim_names, 'ch4_vars__grnd_ch4_cond_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(ch4_vars%grnd_ch4_cond_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(ch4_vars%grnd_ch4_cond_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%c3flag_patch), dim_names, 'photosyns_vars__c3flag_patch', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%c3flag_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%c3flag_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%ac_patch), dim_names, 'photosyns_vars__ac_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%ac_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%ac_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%aj_patch), dim_names, 'photosyns_vars__aj_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%aj_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%aj_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%ap_patch), dim_names, 'photosyns_vars__ap_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%ap_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%ap_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%ag_patch), dim_names, 'photosyns_vars__ag_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%ag_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%ag_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%an_patch), dim_names, 'photosyns_vars__an_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%an_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%an_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%vcmax_z_patch), dim_names, 'photosyns_vars__vcmax_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%vcmax_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%vcmax_z_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%vcmax25_top_patch), dim_names, 'photosyns_vars__vcmax25_top_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%vcmax25_top_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%vcmax25_top_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%cp_patch), dim_names, 'photosyns_vars__cp_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%cp_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%cp_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%kc_patch), dim_names, 'photosyns_vars__kc_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%kc_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%kc_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%ko_patch), dim_names, 'photosyns_vars__ko_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%ko_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%ko_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%qe_patch), dim_names, 'photosyns_vars__qe_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%qe_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%qe_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%tpu_z_patch), dim_names, 'photosyns_vars__tpu_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%tpu_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%tpu_z_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%kp_z_patch), dim_names, 'photosyns_vars__kp_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%kp_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%kp_z_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%theta_cj_patch), dim_names, 'photosyns_vars__theta_cj_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%theta_cj_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%theta_cj_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%bbb_patch), dim_names, 'photosyns_vars__bbb_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%bbb_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%bbb_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%mbb_patch), dim_names, 'photosyns_vars__mbb_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%mbb_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%mbb_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%gs_mol_patch), dim_names, 'photosyns_vars__gs_mol_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%gs_mol_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%gs_mol_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%gb_mol_patch), dim_names, 'photosyns_vars__gb_mol_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%gb_mol_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%gb_mol_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%rh_leaf_patch), dim_names, 'photosyns_vars__rh_leaf_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%rh_leaf_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%rh_leaf_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%alphapsnsun_patch), dim_names, 'photosyns_vars__alphapsnsun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%alphapsnsun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%alphapsnsun_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%alphapsnsha_patch), dim_names, 'photosyns_vars__alphapsnsha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%alphapsnsha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%alphapsnsha_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%rc13_canair_patch), dim_names, 'photosyns_vars__rc13_canair_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%rc13_canair_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%rc13_canair_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%rc13_psnsun_patch), dim_names, 'photosyns_vars__rc13_psnsun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%rc13_psnsun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%rc13_psnsun_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%rc13_psnsha_patch), dim_names, 'photosyns_vars__rc13_psnsha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%rc13_psnsha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%rc13_psnsha_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%psnsun_patch), dim_names, 'photosyns_vars__psnsun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%psnsun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%psnsun_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%psnsha_patch), dim_names, 'photosyns_vars__psnsha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%psnsha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%psnsha_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%c13_psnsun_patch), dim_names, 'photosyns_vars__c13_psnsun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%c13_psnsun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%c13_psnsun_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%c13_psnsha_patch), dim_names, 'photosyns_vars__c13_psnsha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%c13_psnsha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%c13_psnsha_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%c14_psnsun_patch), dim_names, 'photosyns_vars__c14_psnsun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%c14_psnsun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%c14_psnsun_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%c14_psnsha_patch), dim_names, 'photosyns_vars__c14_psnsha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%c14_psnsha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%c14_psnsha_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%psnsun_z_patch), dim_names, 'photosyns_vars__psnsun_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%psnsun_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%psnsun_z_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%psnsha_z_patch), dim_names, 'photosyns_vars__psnsha_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%psnsha_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%psnsha_z_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%psnsun_wc_patch), dim_names, 'photosyns_vars__psnsun_wc_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%psnsun_wc_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%psnsun_wc_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%psnsha_wc_patch), dim_names, 'photosyns_vars__psnsha_wc_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%psnsha_wc_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%psnsha_wc_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%psnsun_wj_patch), dim_names, 'photosyns_vars__psnsun_wj_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%psnsun_wj_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%psnsun_wj_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%psnsha_wj_patch), dim_names, 'photosyns_vars__psnsha_wj_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%psnsha_wj_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%psnsha_wj_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%psnsun_wp_patch), dim_names, 'photosyns_vars__psnsun_wp_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%psnsun_wp_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%psnsun_wp_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%psnsha_wp_patch), dim_names, 'photosyns_vars__psnsha_wp_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%psnsha_wp_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%psnsha_wp_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%fpsn_patch), dim_names, 'photosyns_vars__fpsn_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%fpsn_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%fpsn_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%fpsn_wc_patch), dim_names, 'photosyns_vars__fpsn_wc_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%fpsn_wc_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%fpsn_wc_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%fpsn_wj_patch), dim_names, 'photosyns_vars__fpsn_wj_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%fpsn_wj_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%fpsn_wj_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%fpsn_wp_patch), dim_names, 'photosyns_vars__fpsn_wp_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%fpsn_wp_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%fpsn_wp_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%lmrsun_patch), dim_names, 'photosyns_vars__lmrsun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%lmrsun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%lmrsun_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%lmrsha_patch), dim_names, 'photosyns_vars__lmrsha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%lmrsha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%lmrsha_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%lmrsun_z_patch), dim_names, 'photosyns_vars__lmrsun_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%lmrsun_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%lmrsun_z_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%lmrsha_z_patch), dim_names, 'photosyns_vars__lmrsha_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%lmrsha_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%lmrsha_z_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%cisun_z_patch), dim_names, 'photosyns_vars__cisun_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%cisun_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%cisun_z_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%cisha_z_patch), dim_names, 'photosyns_vars__cisha_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%cisha_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%cisha_z_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%rssun_z_patch), dim_names, 'photosyns_vars__rssun_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%rssun_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%rssun_z_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%rssha_z_patch), dim_names, 'photosyns_vars__rssha_z_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%rssha_z_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%rssha_z_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%rssun_patch), dim_names, 'photosyns_vars__rssun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%rssun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%rssun_patch)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(photosyns_vars%rssha_patch), dim_names, 'photosyns_vars__rssha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%rssha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%rssha_patch)));
    dim_names(1:3) = [character(len=32) :: 'patch','_2','_1_nlevcan']
    call nc_define_var(ncid, 3, shape(photosyns_vars%ac_phs_patch), dim_names, 'photosyns_vars__ac_phs_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%ac_phs_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%ac_phs_patch)));
    dim_names(1:3) = [character(len=32) :: 'patch','_2','_1_nlevcan']
    call nc_define_var(ncid, 3, shape(photosyns_vars%aj_phs_patch), dim_names, 'photosyns_vars__aj_phs_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%aj_phs_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%aj_phs_patch)));
    dim_names(1:3) = [character(len=32) :: 'patch','_2','_1_nlevcan']
    call nc_define_var(ncid, 3, shape(photosyns_vars%ap_phs_patch), dim_names, 'photosyns_vars__ap_phs_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%ap_phs_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%ap_phs_patch)));
    dim_names(1:3) = [character(len=32) :: 'patch','_2','_1_nlevcan']
    call nc_define_var(ncid, 3, shape(photosyns_vars%ag_phs_patch), dim_names, 'photosyns_vars__ag_phs_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%ag_phs_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%ag_phs_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%an_sun_patch), dim_names, 'photosyns_vars__an_sun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%an_sun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%an_sun_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%an_sha_patch), dim_names, 'photosyns_vars__an_sha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%an_sha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%an_sha_patch)));
    dim_names(1:3) = [character(len=32) :: 'patch','_2','_1_nlevcan']
    call nc_define_var(ncid, 3, shape(photosyns_vars%vcmax_z_phs_patch), dim_names, 'photosyns_vars__vcmax_z_phs_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%vcmax_z_phs_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%vcmax_z_phs_patch)));
    dim_names(1:3) = [character(len=32) :: 'patch','_2','_1_nlevcan']
    call nc_define_var(ncid, 3, shape(photosyns_vars%kp_z_phs_patch), dim_names, 'photosyns_vars__kp_z_phs_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%kp_z_phs_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%kp_z_phs_patch)));
    dim_names(1:3) = [character(len=32) :: 'patch','_2','_1_nlevcan']
    call nc_define_var(ncid, 3, shape(photosyns_vars%tpu_z_phs_patch), dim_names, 'photosyns_vars__tpu_z_phs_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%tpu_z_phs_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%tpu_z_phs_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%gs_mol_sun_patch), dim_names, 'photosyns_vars__gs_mol_sun_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%gs_mol_sun_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%gs_mol_sun_patch)));
    dim_names(1:2) = [character(len=32) :: 'patch','_1_nlevcan']
    call nc_define_var(ncid, 2, shape(photosyns_vars%gs_mol_sha_patch), dim_names, 'photosyns_vars__gs_mol_sha_patch', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(photosyns_vars%gs_mol_sha_patch))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(photosyns_vars%gs_mol_sha_patch)));
    dim_names(1:1) = [character(len=32) :: 'gridcell']
    call nc_define_var(ncid, 1, shape(grc_pp%londeg), dim_names, 'grc_pp__londeg', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(grc_pp%londeg))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(grc_pp%londeg)));
    dim_names(1:1) = [character(len=32) :: 'gridcell']
    call nc_define_var(ncid, 1, shape(grc_pp%slope_deg), dim_names, 'grc_pp__slope_deg', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(grc_pp%slope_deg))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(grc_pp%slope_deg)));
    dim_names(1:1) = [character(len=32) :: 'gridcell']
    call nc_define_var(ncid, 1, shape(grc_pp%max_dayl), dim_names, 'grc_pp__max_dayl', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(grc_pp%max_dayl))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(grc_pp%max_dayl)));
    dim_names(1:1) = [character(len=32) :: 'gridcell']
    call nc_define_var(ncid, 1, shape(grc_pp%dayl), dim_names, 'grc_pp__dayl', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(grc_pp%dayl))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(grc_pp%dayl)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%tbot), dim_names, 'top_as__tbot', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%tbot))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%tbot)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%thbot), dim_names, 'top_as__thbot', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%thbot))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%thbot)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%pbot), dim_names, 'top_as__pbot', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%pbot))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%pbot)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%rhobot), dim_names, 'top_as__rhobot', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%rhobot))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%rhobot)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%qbot), dim_names, 'top_as__qbot', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%qbot))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%qbot)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%ubot), dim_names, 'top_as__ubot', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%ubot))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%ubot)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%vbot), dim_names, 'top_as__vbot', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%vbot))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%vbot)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%wsresp), dim_names, 'top_as__wsresp', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%wsresp))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%wsresp)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%tau_est), dim_names, 'top_as__tau_est', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%tau_est))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%tau_est)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%ugust), dim_names, 'top_as__ugust', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%ugust))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%ugust)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%po2bot), dim_names, 'top_as__po2bot', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%po2bot))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%po2bot)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%pco2bot), dim_names, 'top_as__pco2bot', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%pco2bot))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%pco2bot)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_as%pc13o2bot), dim_names, 'top_as__pc13o2bot', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_as%pc13o2bot))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_as%pc13o2bot)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_af%lwrad), dim_names, 'top_af__lwrad', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_af%lwrad))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_af%lwrad)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_pp%gridcell), dim_names, 'col_pp__gridcell', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_pp%gridcell))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_pp%gridcell)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_pp%topounit), dim_names, 'col_pp__topounit', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_pp%topounit))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_pp%topounit)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_pp%landunit), dim_names, 'col_pp__landunit', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_pp%landunit))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_pp%landunit)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_pp%itype), dim_names, 'col_pp__itype', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_pp%itype))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_pp%itype)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_pp%active), dim_names, 'col_pp__active', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_pp%active))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_pp%active)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_pp%snl), dim_names, 'col_pp__snl', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_pp%snl))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_pp%snl)));
    dim_names(1:2) = [character(len=32) :: 'column','_nlevsno_1_nlevgrnd']
    call nc_define_var(ncid, 2, shape(col_pp%dz), dim_names, 'col_pp__dz', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_pp%dz))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_pp%dz)));
    dim_names(1:2) = [character(len=32) :: 'column','_nlevsno_1_nlevgrnd']
    call nc_define_var(ncid, 2, shape(col_pp%z), dim_names, 'col_pp__z', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_pp%z))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_pp%z)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_pp%is_soil), dim_names, 'col_pp__is_soil', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_pp%is_soil))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_pp%is_soil)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_pp%is_crop), dim_names, 'col_pp__is_crop', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_pp%is_crop))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_pp%is_crop)));
    dim_names(1:2) = [character(len=32) :: 'column','_nlevsno_1_nlevgrnd']
    call nc_define_var(ncid, 2, shape(col_es%t_soisno), dim_names, 'col_es__t_soisno', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_es%t_soisno))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_es%t_soisno)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_es%t_h2osfc), dim_names, 'col_es__t_h2osfc', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_es%t_h2osfc))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_es%t_h2osfc)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_es%t_grnd), dim_names, 'col_es__t_grnd', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_es%t_grnd))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_es%t_grnd)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_es%thv), dim_names, 'col_es__thv', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_es%thv))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_es%thv)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_es%emg), dim_names, 'col_es__emg', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_es%emg))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_es%emg)));
    dim_names(1:2) = [character(len=32) :: 'column','_nlevsno_1_nlevgrnd']
    call nc_define_var(ncid, 2, shape(col_ws%h2osoi_liq), dim_names, 'col_ws__h2osoi_liq', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%h2osoi_liq))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%h2osoi_liq)));
    dim_names(1:2) = [character(len=32) :: 'column','_nlevsno_1_nlevgrnd']
    call nc_define_var(ncid, 2, shape(col_ws%h2osoi_ice), dim_names, 'col_ws__h2osoi_ice', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%h2osoi_ice))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%h2osoi_ice)));
    dim_names(1:2) = [character(len=32) :: 'column','_1_nlevgrnd']
    call nc_define_var(ncid, 2, shape(col_ws%h2osoi_vol), dim_names, 'col_ws__h2osoi_vol', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%h2osoi_vol))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%h2osoi_vol)));
    dim_names(1:2) = [character(len=32) :: 'column','_nlevsno_1_nlevgrnd']
    call nc_define_var(ncid, 2, shape(col_ws%h2osoi_liqvol), dim_names, 'col_ws__h2osoi_liqvol', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%h2osoi_liqvol))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%h2osoi_liqvol)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_ws%qg_snow), dim_names, 'col_ws__qg_snow', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%qg_snow))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%qg_snow)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_ws%qg_soil), dim_names, 'col_ws__qg_soil', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%qg_soil))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%qg_soil)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_ws%qg_h2osfc), dim_names, 'col_ws__qg_h2osfc', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%qg_h2osfc))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%qg_h2osfc)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_ws%qg), dim_names, 'col_ws__qg', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%qg))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%qg)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_ws%dqgdt), dim_names, 'col_ws__dqgdt', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%dqgdt))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%dqgdt)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_ws%snow_depth), dim_names, 'col_ws__snow_depth', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%snow_depth))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%snow_depth)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_ws%frac_sno_eff), dim_names, 'col_ws__frac_sno_eff', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%frac_sno_eff))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%frac_sno_eff)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_ws%frac_h2osfc), dim_names, 'col_ws__frac_h2osfc', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ws%frac_h2osfc))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ws%frac_h2osfc)));
    dim_names(1:1) = [character(len=32) :: 'column']
    call nc_define_var(ncid, 1, shape(col_ef%htvp), dim_names, 'col_ef__htvp', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(col_ef%htvp))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(col_ef%htvp)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_pp%gridcell), dim_names, 'veg_pp__gridcell', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_pp%gridcell))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_pp%gridcell)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_pp%topounit), dim_names, 'veg_pp__topounit', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_pp%topounit))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_pp%topounit)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_pp%landunit), dim_names, 'veg_pp__landunit', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_pp%landunit))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_pp%landunit)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_pp%column), dim_names, 'veg_pp__column', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_pp%column))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_pp%column)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_pp%itype), dim_names, 'veg_pp__itype', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_pp%itype))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_pp%itype)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_pp%active), dim_names, 'veg_pp__active', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_pp%active))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_pp%active)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_pp%is_on_soil_col), dim_names, 'veg_pp__is_on_soil_col', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_pp%is_on_soil_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_pp%is_on_soil_col)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_pp%is_on_crop_col), dim_names, 'veg_pp__is_on_crop_col', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_pp%is_on_crop_col))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_pp%is_on_crop_col)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_pp%is_fates), dim_names, 'veg_pp__is_fates', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_pp%is_fates))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_pp%is_fates)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_es%t_veg), dim_names, 'veg_es__t_veg', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_es%t_veg))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_es%t_veg)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_es%t_ref2m), dim_names, 'veg_es__t_ref2m', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_es%t_ref2m))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_es%t_ref2m)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_es%t_ref2m_r), dim_names, 'veg_es__t_ref2m_r', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_es%t_ref2m_r))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_es%t_ref2m_r)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_es%t_a10), dim_names, 'veg_es__t_a10', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_es%t_a10))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_es%t_a10)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_es%thm), dim_names, 'veg_es__thm', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_es%thm))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_es%thm)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_es%emv), dim_names, 'veg_es__emv', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_es%emv))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_es%emv)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ws%h2ocan), dim_names, 'veg_ws__h2ocan', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ws%h2ocan))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ws%h2ocan)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ws%q_ref2m), dim_names, 'veg_ws__q_ref2m', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ws%q_ref2m))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ws%q_ref2m)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ws%rh_ref2m), dim_names, 'veg_ws__rh_ref2m', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ws%rh_ref2m))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ws%rh_ref2m)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ws%rh_ref2m_r), dim_names, 'veg_ws__rh_ref2m_r', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ws%rh_ref2m_r))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ws%rh_ref2m_r)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ws%rh_af), dim_names, 'veg_ws__rh_af', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ws%rh_af))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ws%rh_af)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ws%fwet), dim_names, 'veg_ws__fwet', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ws%fwet))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ws%fwet)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ws%fdry), dim_names, 'veg_ws__fdry', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ws%fdry))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ws%fdry)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ns%leafn), dim_names, 'veg_ns__leafn', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ns%leafn))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ns%leafn)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ps%leafp), dim_names, 'veg_ps__leafp', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ps%leafp))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ps%leafp)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%eflx_sh_grnd), dim_names, 'veg_ef__eflx_sh_grnd', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%eflx_sh_grnd))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%eflx_sh_grnd)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%eflx_sh_veg), dim_names, 'veg_ef__eflx_sh_veg', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%eflx_sh_veg))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%eflx_sh_veg)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%eflx_sh_snow), dim_names, 'veg_ef__eflx_sh_snow', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%eflx_sh_snow))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%eflx_sh_snow)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%eflx_sh_soil), dim_names, 'veg_ef__eflx_sh_soil', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%eflx_sh_soil))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%eflx_sh_soil)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%eflx_sh_h2osfc), dim_names, 'veg_ef__eflx_sh_h2osfc', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%eflx_sh_h2osfc))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%eflx_sh_h2osfc)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%dlrad), dim_names, 'veg_ef__dlrad', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%dlrad))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%dlrad)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%ulrad), dim_names, 'veg_ef__ulrad', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%ulrad))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%ulrad)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%taux), dim_names, 'veg_ef__taux', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%taux))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%taux)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%tauy), dim_names, 'veg_ef__tauy', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%tauy))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%tauy)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%cgrnd), dim_names, 'veg_ef__cgrnd', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%cgrnd))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%cgrnd)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%cgrndl), dim_names, 'veg_ef__cgrndl', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%cgrndl))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%cgrndl)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_ef%cgrnds), dim_names, 'veg_ef__cgrnds', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_ef%cgrnds))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_ef%cgrnds)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_wf%qflx_evap_soi), dim_names, 'veg_wf__qflx_evap_soi', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_wf%qflx_evap_soi))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_wf%qflx_evap_soi)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_wf%qflx_evap_veg), dim_names, 'veg_wf__qflx_evap_veg', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_wf%qflx_evap_veg))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_wf%qflx_evap_veg)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_wf%qflx_tran_veg), dim_names, 'veg_wf__qflx_tran_veg', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_wf%qflx_tran_veg))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_wf%qflx_tran_veg)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_wf%qflx_ev_snow), dim_names, 'veg_wf__qflx_ev_snow', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_wf%qflx_ev_snow))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_wf%qflx_ev_snow)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_wf%qflx_ev_soil), dim_names, 'veg_wf__qflx_ev_soil', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_wf%qflx_ev_soil))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_wf%qflx_ev_soil)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_wf%qflx_ev_h2osfc), dim_names, 'veg_wf__qflx_ev_h2osfc', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_wf%qflx_ev_h2osfc))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_wf%qflx_ev_h2osfc)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_wf%irrig_rate), dim_names, 'veg_wf__irrig_rate', nf90_double, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_wf%irrig_rate))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_wf%irrig_rate)));
    dim_names(1:1) = [character(len=32) :: 'patch']
    call nc_define_var(ncid, 1, shape(veg_wf%n_irrig_steps_left), dim_names, 'veg_wf__n_irrig_steps_left', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(veg_wf%n_irrig_steps_left))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(veg_wf%n_irrig_steps_left)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_pp%topo_grc_ind), dim_names, 'top_pp__topo_grc_ind', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_pp%topo_grc_ind))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_pp%topo_grc_ind)));
    dim_names(1:1) = [character(len=32) :: 'topo']
    call nc_define_var(ncid, 1, shape(top_pp%active), dim_names, 'top_pp__active', nf90_int, varid, .true.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(top_pp%active))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(top_pp%active)));
  end subroutine define_vars
  subroutine read_elmtypes(io_inst, bounds, atm2lnd_vars, canopystate_vars, cnstate_vars, energyflux_vars, frictionvel_vars, soilstate_vars, solarabs_vars, surfalb_vars, ch4_vars, photosyns_vars)
    type(atm2lnd_type), intent(inout) :: atm2lnd_vars
    type(canopystate_type), intent(inout) :: canopystate_vars
    type(cnstate_type), intent(inout) :: cnstate_vars
    type(energyflux_type), intent(inout) :: energyflux_vars
    type(frictionvel_type), intent(inout) :: frictionvel_vars
    type(soilstate_type), intent(inout) :: soilstate_vars
    type(solarabs_type), intent(inout) :: solarabs_vars
    type(surfalb_type), intent(inout) :: surfalb_vars
    type(ch4_type), intent(inout) :: ch4_vars
    type(photosyns_type), intent(inout) :: photosyns_vars
    type(spel_io_type), intent(inout) :: io_inst
    type(bounds_type), intent(inout) :: bounds
    integer :: ncid, timestep
    character(len=256) :: new_fn
    new_fn = trim(io_inst%get_fn())
    if(io_inst%end_run) return
    if(io_inst%dt_in_file == 99999) io_inst%dt_in_file = nc_read_timeslices(new_fn)
    timestep = io_inst%timestep
    ncid = nc_create_or_open_file(trim(new_fn), read_file)
    call nc_read_var(ncid, 'bounds__begg', bounds%begg, timestep)
    call nc_read_var(ncid, 'bounds__endg', bounds%endg, timestep)
    call nc_read_var(ncid, 'bounds__begt', bounds%begt, timestep)
    call nc_read_var(ncid, 'bounds__endt', bounds%endt, timestep)
    call nc_read_var(ncid, 'bounds__begl', bounds%begl, timestep)
    call nc_read_var(ncid, 'bounds__endl', bounds%endl, timestep)
    call nc_read_var(ncid, 'bounds__begc', bounds%begc, timestep)
    call nc_read_var(ncid, 'bounds__endc', bounds%endc, timestep)
    call nc_read_var(ncid, 'bounds__begp', bounds%begp, timestep)
    call nc_read_var(ncid, 'bounds__endp', bounds%endp, timestep)
    allocate(paramsshareinst%q10_mr)
    call nc_read_var(ncid, 'paramsshareinst__q10_mr', paramsshareinst%q10_mr, timestep)
    allocate(veg_vp%tc_stress)
    call nc_read_var(ncid, 'veg_vp__tc_stress', veg_vp%tc_stress, timestep)
    call nc_alloc(ncid, "lun_pp__gridcell", 1, lun_pp%gridcell)
    call nc_read_var(ncid,'lun_pp__gridcell', 1, lun_pp%gridcell, timestep)
    call nc_alloc(ncid, "lun_pp__topounit", 1, lun_pp%topounit)
    call nc_read_var(ncid,'lun_pp__topounit', 1, lun_pp%topounit, timestep)
    call nc_alloc(ncid, "lun_pp__pfti", 1, lun_pp%pfti)
    call nc_read_var(ncid,'lun_pp__pfti', 1, lun_pp%pfti, timestep)
    call nc_alloc(ncid, "lun_pp__pftf", 1, lun_pp%pftf)
    call nc_read_var(ncid,'lun_pp__pftf', 1, lun_pp%pftf, timestep)
    call nc_alloc(ncid, "lun_pp__itype", 1, lun_pp%itype)
    call nc_read_var(ncid,'lun_pp__itype', 1, lun_pp%itype, timestep)
    call nc_alloc(ncid, "lun_pp__lakpoi", 1, lun_pp%lakpoi)
    call nc_read_var(ncid,'lun_pp__lakpoi', 1, lun_pp%lakpoi, timestep)
    call nc_alloc(ncid, "lun_pp__urbpoi", 1, lun_pp%urbpoi)
    call nc_read_var(ncid,'lun_pp__urbpoi', 1, lun_pp%urbpoi, timestep)
    call nc_alloc(ncid, "lun_pp__active", 1, lun_pp%active)
    call nc_read_var(ncid,'lun_pp__active', 1, lun_pp%active, timestep)
    call nc_alloc(ncid, "veg_vp__smpso", 1, veg_vp%smpso)
    call nc_read_var(ncid,'veg_vp__smpso', 1, veg_vp%smpso, timestep)
    call nc_alloc(ncid, "veg_vp__smpsc", 1, veg_vp%smpsc)
    call nc_read_var(ncid,'veg_vp__smpsc', 1, veg_vp%smpsc, timestep)
    call nc_alloc(ncid, "veg_vp__fnitr", 1, veg_vp%fnitr)
    call nc_read_var(ncid,'veg_vp__fnitr', 1, veg_vp%fnitr, timestep)
    call nc_alloc(ncid, "veg_vp__dleaf", 1, veg_vp%dleaf)
    call nc_read_var(ncid,'veg_vp__dleaf', 1, veg_vp%dleaf, timestep)
    call nc_alloc(ncid, "veg_vp__c3psn", 1, veg_vp%c3psn)
    call nc_read_var(ncid,'veg_vp__c3psn', 1, veg_vp%c3psn, timestep)
    call nc_alloc(ncid, "veg_vp__slatop", 1, veg_vp%slatop)
    call nc_read_var(ncid,'veg_vp__slatop', 1, veg_vp%slatop, timestep)
    call nc_alloc(ncid, "veg_vp__root_radius", 1, veg_vp%root_radius)
    call nc_read_var(ncid,'veg_vp__root_radius', 1, veg_vp%root_radius, timestep)
    call nc_alloc(ncid, "veg_vp__root_density", 1, veg_vp%root_density)
    call nc_read_var(ncid,'veg_vp__root_density', 1, veg_vp%root_density, timestep)
    call nc_alloc(ncid, "veg_vp__leafcn", 1, veg_vp%leafcn)
    call nc_read_var(ncid,'veg_vp__leafcn', 1, veg_vp%leafcn, timestep)
    call nc_alloc(ncid, "veg_vp__flnr", 1, veg_vp%flnr)
    call nc_read_var(ncid,'veg_vp__flnr', 1, veg_vp%flnr, timestep)
    call nc_alloc(ncid, "veg_vp__froot_leaf", 1, veg_vp%froot_leaf)
    call nc_read_var(ncid,'veg_vp__froot_leaf', 1, veg_vp%froot_leaf, timestep)
    call nc_alloc(ncid, "veg_vp__stem_leaf", 1, veg_vp%stem_leaf)
    call nc_read_var(ncid,'veg_vp__stem_leaf', 1, veg_vp%stem_leaf, timestep)
    call nc_alloc(ncid, "veg_vp__croot_stem", 1, veg_vp%croot_stem)
    call nc_read_var(ncid,'veg_vp__croot_stem', 1, veg_vp%croot_stem, timestep)
    call nc_alloc(ncid, "veg_vp__i_vc", 1, veg_vp%i_vc)
    call nc_read_var(ncid,'veg_vp__i_vc', 1, veg_vp%i_vc, timestep)
    call nc_alloc(ncid, "veg_vp__s_vc", 1, veg_vp%s_vc)
    call nc_read_var(ncid,'veg_vp__s_vc', 1, veg_vp%s_vc, timestep)
    call nc_alloc(ncid, "veg_vp__fnr", 1, veg_vp%fnr)
    call nc_read_var(ncid,'veg_vp__fnr', 1, veg_vp%fnr, timestep)
    call nc_alloc(ncid, "veg_vp__act25", 1, veg_vp%act25)
    call nc_read_var(ncid,'veg_vp__act25', 1, veg_vp%act25, timestep)
    call nc_alloc(ncid, "veg_vp__kcha", 1, veg_vp%kcha)
    call nc_read_var(ncid,'veg_vp__kcha', 1, veg_vp%kcha, timestep)
    call nc_alloc(ncid, "veg_vp__koha", 1, veg_vp%koha)
    call nc_read_var(ncid,'veg_vp__koha', 1, veg_vp%koha, timestep)
    call nc_alloc(ncid, "veg_vp__cpha", 1, veg_vp%cpha)
    call nc_read_var(ncid,'veg_vp__cpha', 1, veg_vp%cpha, timestep)
    call nc_alloc(ncid, "veg_vp__vcmaxha", 1, veg_vp%vcmaxha)
    call nc_read_var(ncid,'veg_vp__vcmaxha', 1, veg_vp%vcmaxha, timestep)
    call nc_alloc(ncid, "veg_vp__jmaxha", 1, veg_vp%jmaxha)
    call nc_read_var(ncid,'veg_vp__jmaxha', 1, veg_vp%jmaxha, timestep)
    call nc_alloc(ncid, "veg_vp__tpuha", 1, veg_vp%tpuha)
    call nc_read_var(ncid,'veg_vp__tpuha', 1, veg_vp%tpuha, timestep)
    call nc_alloc(ncid, "veg_vp__lmrha", 1, veg_vp%lmrha)
    call nc_read_var(ncid,'veg_vp__lmrha', 1, veg_vp%lmrha, timestep)
    call nc_alloc(ncid, "veg_vp__vcmaxhd", 1, veg_vp%vcmaxhd)
    call nc_read_var(ncid,'veg_vp__vcmaxhd', 1, veg_vp%vcmaxhd, timestep)
    call nc_alloc(ncid, "veg_vp__jmaxhd", 1, veg_vp%jmaxhd)
    call nc_read_var(ncid,'veg_vp__jmaxhd', 1, veg_vp%jmaxhd, timestep)
    call nc_alloc(ncid, "veg_vp__tpuhd", 1, veg_vp%tpuhd)
    call nc_read_var(ncid,'veg_vp__tpuhd', 1, veg_vp%tpuhd, timestep)
    call nc_alloc(ncid, "veg_vp__lmrhd", 1, veg_vp%lmrhd)
    call nc_read_var(ncid,'veg_vp__lmrhd', 1, veg_vp%lmrhd, timestep)
    call nc_alloc(ncid, "veg_vp__lmrse", 1, veg_vp%lmrse)
    call nc_read_var(ncid,'veg_vp__lmrse', 1, veg_vp%lmrse, timestep)
    call nc_alloc(ncid, "veg_vp__qe", 1, veg_vp%qe)
    call nc_read_var(ncid,'veg_vp__qe', 1, veg_vp%qe, timestep)
    call nc_alloc(ncid, "veg_vp__theta_cj", 1, veg_vp%theta_cj)
    call nc_read_var(ncid,'veg_vp__theta_cj', 1, veg_vp%theta_cj, timestep)
    call nc_alloc(ncid, "veg_vp__bbbopt", 1, veg_vp%bbbopt)
    call nc_read_var(ncid,'veg_vp__bbbopt', 1, veg_vp%bbbopt, timestep)
    call nc_alloc(ncid, "veg_vp__mbbopt", 1, veg_vp%mbbopt)
    call nc_read_var(ncid,'veg_vp__mbbopt', 1, veg_vp%mbbopt, timestep)
    call nc_alloc(ncid, "canopystate_vars__frac_veg_nosno_patch", 1, canopystate_vars%frac_veg_nosno_patch)
    call nc_read_var(ncid,'canopystate_vars__frac_veg_nosno_patch', 1, canopystate_vars%frac_veg_nosno_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__tlai_patch", 1, canopystate_vars%tlai_patch)
    call nc_read_var(ncid,'canopystate_vars__tlai_patch', 1, canopystate_vars%tlai_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__tsai_patch", 1, canopystate_vars%tsai_patch)
    call nc_read_var(ncid,'canopystate_vars__tsai_patch', 1, canopystate_vars%tsai_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__elai_patch", 1, canopystate_vars%elai_patch)
    call nc_read_var(ncid,'canopystate_vars__elai_patch', 1, canopystate_vars%elai_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__esai_patch", 1, canopystate_vars%esai_patch)
    call nc_read_var(ncid,'canopystate_vars__esai_patch', 1, canopystate_vars%esai_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__laisun_patch", 1, canopystate_vars%laisun_patch)
    call nc_read_var(ncid,'canopystate_vars__laisun_patch', 1, canopystate_vars%laisun_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__laisha_patch", 1, canopystate_vars%laisha_patch)
    call nc_read_var(ncid,'canopystate_vars__laisha_patch', 1, canopystate_vars%laisha_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__laisun_z_patch", 2, canopystate_vars%laisun_z_patch)
    call nc_read_var(ncid,'canopystate_vars__laisun_z_patch', 2, canopystate_vars%laisun_z_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__laisha_z_patch", 2, canopystate_vars%laisha_z_patch)
    call nc_read_var(ncid,'canopystate_vars__laisha_z_patch', 2, canopystate_vars%laisha_z_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__htop_patch", 1, canopystate_vars%htop_patch)
    call nc_read_var(ncid,'canopystate_vars__htop_patch', 1, canopystate_vars%htop_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__displa_patch", 1, canopystate_vars%displa_patch)
    call nc_read_var(ncid,'canopystate_vars__displa_patch', 1, canopystate_vars%displa_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__altmax_indx_col", 1, canopystate_vars%altmax_indx_col)
    call nc_read_var(ncid,'canopystate_vars__altmax_indx_col', 1, canopystate_vars%altmax_indx_col, timestep)
    call nc_alloc(ncid, "canopystate_vars__altmax_lastyear_indx_col", 1, canopystate_vars%altmax_lastyear_indx_col)
    call nc_read_var(ncid,'canopystate_vars__altmax_lastyear_indx_col', 1, canopystate_vars%altmax_lastyear_indx_col, timestep)
    call nc_alloc(ncid, "canopystate_vars__dleaf_patch", 1, canopystate_vars%dleaf_patch)
    call nc_read_var(ncid,'canopystate_vars__dleaf_patch', 1, canopystate_vars%dleaf_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__lbl_rsc_h2o_patch", 1, canopystate_vars%lbl_rsc_h2o_patch)
    call nc_read_var(ncid,'canopystate_vars__lbl_rsc_h2o_patch', 1, canopystate_vars%lbl_rsc_h2o_patch, timestep)
    call nc_alloc(ncid, "canopystate_vars__vegwp_patch", 2, canopystate_vars%vegwp_patch)
    call nc_read_var(ncid,'canopystate_vars__vegwp_patch', 2, canopystate_vars%vegwp_patch, timestep)
    call nc_alloc(ncid, "cnstate_vars__downreg_patch", 1, cnstate_vars%downreg_patch)
    call nc_read_var(ncid,'cnstate_vars__downreg_patch', 1, cnstate_vars%downreg_patch, timestep)
    call nc_alloc(ncid, "cnstate_vars__rc14_atm_patch", 1, cnstate_vars%rc14_atm_patch)
    call nc_read_var(ncid,'cnstate_vars__rc14_atm_patch', 1, cnstate_vars%rc14_atm_patch, timestep)
    call nc_alloc(ncid, "energyflux_vars__canopy_cond_patch", 1, energyflux_vars%canopy_cond_patch)
    call nc_read_var(ncid,'energyflux_vars__canopy_cond_patch', 1, energyflux_vars%canopy_cond_patch, timestep)
    call nc_alloc(ncid, "energyflux_vars__btran_patch", 1, energyflux_vars%btran_patch)
    call nc_read_var(ncid,'energyflux_vars__btran_patch', 1, energyflux_vars%btran_patch, timestep)
    call nc_alloc(ncid, "energyflux_vars__bsun_patch", 1, energyflux_vars%bsun_patch)
    call nc_read_var(ncid,'energyflux_vars__bsun_patch', 1, energyflux_vars%bsun_patch, timestep)
    call nc_alloc(ncid, "energyflux_vars__bsha_patch", 1, energyflux_vars%bsha_patch)
    call nc_read_var(ncid,'energyflux_vars__bsha_patch', 1, energyflux_vars%bsha_patch, timestep)
    call nc_alloc(ncid, "energyflux_vars__btran2_patch", 1, energyflux_vars%btran2_patch)
    call nc_read_var(ncid,'energyflux_vars__btran2_patch', 1, energyflux_vars%btran2_patch, timestep)
    call nc_alloc(ncid, "energyflux_vars__rresis_patch", 2, energyflux_vars%rresis_patch)
    call nc_read_var(ncid,'energyflux_vars__rresis_patch', 2, energyflux_vars%rresis_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__forc_hgt_u_patch", 1, frictionvel_vars%forc_hgt_u_patch)
    call nc_read_var(ncid,'frictionvel_vars__forc_hgt_u_patch', 1, frictionvel_vars%forc_hgt_u_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__forc_hgt_t_patch", 1, frictionvel_vars%forc_hgt_t_patch)
    call nc_read_var(ncid,'frictionvel_vars__forc_hgt_t_patch', 1, frictionvel_vars%forc_hgt_t_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__forc_hgt_q_patch", 1, frictionvel_vars%forc_hgt_q_patch)
    call nc_read_var(ncid,'frictionvel_vars__forc_hgt_q_patch', 1, frictionvel_vars%forc_hgt_q_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__u10_patch", 1, frictionvel_vars%u10_patch)
    call nc_read_var(ncid,'frictionvel_vars__u10_patch', 1, frictionvel_vars%u10_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__u10_elm_patch", 1, frictionvel_vars%u10_elm_patch)
    call nc_read_var(ncid,'frictionvel_vars__u10_elm_patch', 1, frictionvel_vars%u10_elm_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__u10_with_gusts_elm_patch", 1, frictionvel_vars%u10_with_gusts_elm_patch)
    call nc_read_var(ncid,'frictionvel_vars__u10_with_gusts_elm_patch', 1, frictionvel_vars%u10_with_gusts_elm_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__va_patch", 1, frictionvel_vars%va_patch)
    call nc_read_var(ncid,'frictionvel_vars__va_patch', 1, frictionvel_vars%va_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__vds_patch", 1, frictionvel_vars%vds_patch)
    call nc_read_var(ncid,'frictionvel_vars__vds_patch', 1, frictionvel_vars%vds_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__fv_patch", 1, frictionvel_vars%fv_patch)
    call nc_read_var(ncid,'frictionvel_vars__fv_patch', 1, frictionvel_vars%fv_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__rb1_patch", 1, frictionvel_vars%rb1_patch)
    call nc_read_var(ncid,'frictionvel_vars__rb1_patch', 1, frictionvel_vars%rb1_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__ram1_patch", 1, frictionvel_vars%ram1_patch)
    call nc_read_var(ncid,'frictionvel_vars__ram1_patch', 1, frictionvel_vars%ram1_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__z0mv_patch", 1, frictionvel_vars%z0mv_patch)
    call nc_read_var(ncid,'frictionvel_vars__z0mv_patch', 1, frictionvel_vars%z0mv_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__z0hv_patch", 1, frictionvel_vars%z0hv_patch)
    call nc_read_var(ncid,'frictionvel_vars__z0hv_patch', 1, frictionvel_vars%z0hv_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__z0qv_patch", 1, frictionvel_vars%z0qv_patch)
    call nc_read_var(ncid,'frictionvel_vars__z0qv_patch', 1, frictionvel_vars%z0qv_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__z0mg_col", 1, frictionvel_vars%z0mg_col)
    call nc_read_var(ncid,'frictionvel_vars__z0mg_col', 1, frictionvel_vars%z0mg_col, timestep)
    call nc_alloc(ncid, "frictionvel_vars__num_iter_patch", 1, frictionvel_vars%num_iter_patch)
    call nc_read_var(ncid,'frictionvel_vars__num_iter_patch', 1, frictionvel_vars%num_iter_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__rah_above_patch", 1, frictionvel_vars%rah_above_patch)
    call nc_read_var(ncid,'frictionvel_vars__rah_above_patch', 1, frictionvel_vars%rah_above_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__raw_below_patch", 1, frictionvel_vars%raw_below_patch)
    call nc_read_var(ncid,'frictionvel_vars__raw_below_patch', 1, frictionvel_vars%raw_below_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__ustar_patch", 1, frictionvel_vars%ustar_patch)
    call nc_read_var(ncid,'frictionvel_vars__ustar_patch', 1, frictionvel_vars%ustar_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__um_patch", 1, frictionvel_vars%um_patch)
    call nc_read_var(ncid,'frictionvel_vars__um_patch', 1, frictionvel_vars%um_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__uaf_patch", 1, frictionvel_vars%uaf_patch)
    call nc_read_var(ncid,'frictionvel_vars__uaf_patch', 1, frictionvel_vars%uaf_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__taf_patch", 1, frictionvel_vars%taf_patch)
    call nc_read_var(ncid,'frictionvel_vars__taf_patch', 1, frictionvel_vars%taf_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__qaf_patch", 1, frictionvel_vars%qaf_patch)
    call nc_read_var(ncid,'frictionvel_vars__qaf_patch', 1, frictionvel_vars%qaf_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__obu_patch", 1, frictionvel_vars%obu_patch)
    call nc_read_var(ncid,'frictionvel_vars__obu_patch', 1, frictionvel_vars%obu_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__zeta_patch", 1, frictionvel_vars%zeta_patch)
    call nc_read_var(ncid,'frictionvel_vars__zeta_patch', 1, frictionvel_vars%zeta_patch, timestep)
    call nc_alloc(ncid, "frictionvel_vars__vpd_patch", 1, frictionvel_vars%vpd_patch)
    call nc_read_var(ncid,'frictionvel_vars__vpd_patch', 1, frictionvel_vars%vpd_patch, timestep)
    call nc_alloc(ncid, "soilstate_vars__hksat_col", 2, soilstate_vars%hksat_col)
    call nc_read_var(ncid,'soilstate_vars__hksat_col', 2, soilstate_vars%hksat_col, timestep)
    call nc_alloc(ncid, "soilstate_vars__hk_l_col", 2, soilstate_vars%hk_l_col)
    call nc_read_var(ncid,'soilstate_vars__hk_l_col', 2, soilstate_vars%hk_l_col, timestep)
    call nc_alloc(ncid, "soilstate_vars__smp_l_col", 2, soilstate_vars%smp_l_col)
    call nc_read_var(ncid,'soilstate_vars__smp_l_col', 2, soilstate_vars%smp_l_col, timestep)
    call nc_alloc(ncid, "soilstate_vars__bsw_col", 2, soilstate_vars%bsw_col)
    call nc_read_var(ncid,'soilstate_vars__bsw_col', 2, soilstate_vars%bsw_col, timestep)
    call nc_alloc(ncid, "soilstate_vars__watsat_col", 2, soilstate_vars%watsat_col)
    call nc_read_var(ncid,'soilstate_vars__watsat_col', 2, soilstate_vars%watsat_col, timestep)
    call nc_alloc(ncid, "soilstate_vars__sucsat_col", 2, soilstate_vars%sucsat_col)
    call nc_read_var(ncid,'soilstate_vars__sucsat_col', 2, soilstate_vars%sucsat_col, timestep)
    call nc_alloc(ncid, "soilstate_vars__soilbeta_col", 1, soilstate_vars%soilbeta_col)
    call nc_read_var(ncid,'soilstate_vars__soilbeta_col', 1, soilstate_vars%soilbeta_col, timestep)
    call nc_alloc(ncid, "soilstate_vars__eff_porosity_col", 2, soilstate_vars%eff_porosity_col)
    call nc_read_var(ncid,'soilstate_vars__eff_porosity_col', 2, soilstate_vars%eff_porosity_col, timestep)
    call nc_alloc(ncid, "soilstate_vars__rootr_patch", 2, soilstate_vars%rootr_patch)
    call nc_read_var(ncid,'soilstate_vars__rootr_patch', 2, soilstate_vars%rootr_patch, timestep)
    call nc_alloc(ncid, "soilstate_vars__rootfr_patch", 2, soilstate_vars%rootfr_patch)
    call nc_read_var(ncid,'soilstate_vars__rootfr_patch', 2, soilstate_vars%rootfr_patch, timestep)
    call nc_alloc(ncid, "soilstate_vars__k_soil_root_patch", 2, soilstate_vars%k_soil_root_patch)
    call nc_read_var(ncid,'soilstate_vars__k_soil_root_patch', 2, soilstate_vars%k_soil_root_patch, timestep)
    call nc_alloc(ncid, "soilstate_vars__root_conductance_patch", 2, soilstate_vars%root_conductance_patch)
    call nc_read_var(ncid,'soilstate_vars__root_conductance_patch', 2, soilstate_vars%root_conductance_patch, timestep)
    call nc_alloc(ncid, "soilstate_vars__soil_conductance_patch", 2, soilstate_vars%soil_conductance_patch)
    call nc_read_var(ncid,'soilstate_vars__soil_conductance_patch', 2, soilstate_vars%soil_conductance_patch, timestep)
    call nc_alloc(ncid, "solarabs_vars__parsun_z_patch", 2, solarabs_vars%parsun_z_patch)
    call nc_read_var(ncid,'solarabs_vars__parsun_z_patch', 2, solarabs_vars%parsun_z_patch, timestep)
    call nc_alloc(ncid, "solarabs_vars__parsha_z_patch", 2, solarabs_vars%parsha_z_patch)
    call nc_read_var(ncid,'solarabs_vars__parsha_z_patch', 2, solarabs_vars%parsha_z_patch, timestep)
    call nc_alloc(ncid, "solarabs_vars__sabv_patch", 1, solarabs_vars%sabv_patch)
    call nc_read_var(ncid,'solarabs_vars__sabv_patch', 1, solarabs_vars%sabv_patch, timestep)
    call nc_alloc(ncid, "surfalb_vars__tlai_z_patch", 2, surfalb_vars%tlai_z_patch)
    call nc_read_var(ncid,'surfalb_vars__tlai_z_patch', 2, surfalb_vars%tlai_z_patch, timestep)
    call nc_alloc(ncid, "surfalb_vars__nrad_patch", 1, surfalb_vars%nrad_patch)
    call nc_read_var(ncid,'surfalb_vars__nrad_patch', 1, surfalb_vars%nrad_patch, timestep)
    call nc_alloc(ncid, "surfalb_vars__vcmaxcintsun_patch", 1, surfalb_vars%vcmaxcintsun_patch)
    call nc_read_var(ncid,'surfalb_vars__vcmaxcintsun_patch', 1, surfalb_vars%vcmaxcintsun_patch, timestep)
    call nc_alloc(ncid, "surfalb_vars__vcmaxcintsha_patch", 1, surfalb_vars%vcmaxcintsha_patch)
    call nc_read_var(ncid,'surfalb_vars__vcmaxcintsha_patch', 1, surfalb_vars%vcmaxcintsha_patch, timestep)
    call nc_alloc(ncid, "ch4_vars__grnd_ch4_cond_patch", 1, ch4_vars%grnd_ch4_cond_patch)
    call nc_read_var(ncid,'ch4_vars__grnd_ch4_cond_patch', 1, ch4_vars%grnd_ch4_cond_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__c3flag_patch", 1, photosyns_vars%c3flag_patch)
    call nc_read_var(ncid,'photosyns_vars__c3flag_patch', 1, photosyns_vars%c3flag_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__ac_patch", 2, photosyns_vars%ac_patch)
    call nc_read_var(ncid,'photosyns_vars__ac_patch', 2, photosyns_vars%ac_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__aj_patch", 2, photosyns_vars%aj_patch)
    call nc_read_var(ncid,'photosyns_vars__aj_patch', 2, photosyns_vars%aj_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__ap_patch", 2, photosyns_vars%ap_patch)
    call nc_read_var(ncid,'photosyns_vars__ap_patch', 2, photosyns_vars%ap_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__ag_patch", 2, photosyns_vars%ag_patch)
    call nc_read_var(ncid,'photosyns_vars__ag_patch', 2, photosyns_vars%ag_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__an_patch", 2, photosyns_vars%an_patch)
    call nc_read_var(ncid,'photosyns_vars__an_patch', 2, photosyns_vars%an_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__vcmax_z_patch", 2, photosyns_vars%vcmax_z_patch)
    call nc_read_var(ncid,'photosyns_vars__vcmax_z_patch', 2, photosyns_vars%vcmax_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__vcmax25_top_patch", 1, photosyns_vars%vcmax25_top_patch)
    call nc_read_var(ncid,'photosyns_vars__vcmax25_top_patch', 1, photosyns_vars%vcmax25_top_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__cp_patch", 1, photosyns_vars%cp_patch)
    call nc_read_var(ncid,'photosyns_vars__cp_patch', 1, photosyns_vars%cp_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__kc_patch", 1, photosyns_vars%kc_patch)
    call nc_read_var(ncid,'photosyns_vars__kc_patch', 1, photosyns_vars%kc_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__ko_patch", 1, photosyns_vars%ko_patch)
    call nc_read_var(ncid,'photosyns_vars__ko_patch', 1, photosyns_vars%ko_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__qe_patch", 1, photosyns_vars%qe_patch)
    call nc_read_var(ncid,'photosyns_vars__qe_patch', 1, photosyns_vars%qe_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__tpu_z_patch", 2, photosyns_vars%tpu_z_patch)
    call nc_read_var(ncid,'photosyns_vars__tpu_z_patch', 2, photosyns_vars%tpu_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__kp_z_patch", 2, photosyns_vars%kp_z_patch)
    call nc_read_var(ncid,'photosyns_vars__kp_z_patch', 2, photosyns_vars%kp_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__theta_cj_patch", 1, photosyns_vars%theta_cj_patch)
    call nc_read_var(ncid,'photosyns_vars__theta_cj_patch', 1, photosyns_vars%theta_cj_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__bbb_patch", 1, photosyns_vars%bbb_patch)
    call nc_read_var(ncid,'photosyns_vars__bbb_patch', 1, photosyns_vars%bbb_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__mbb_patch", 1, photosyns_vars%mbb_patch)
    call nc_read_var(ncid,'photosyns_vars__mbb_patch', 1, photosyns_vars%mbb_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__gs_mol_patch", 2, photosyns_vars%gs_mol_patch)
    call nc_read_var(ncid,'photosyns_vars__gs_mol_patch', 2, photosyns_vars%gs_mol_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__gb_mol_patch", 1, photosyns_vars%gb_mol_patch)
    call nc_read_var(ncid,'photosyns_vars__gb_mol_patch', 1, photosyns_vars%gb_mol_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__rh_leaf_patch", 1, photosyns_vars%rh_leaf_patch)
    call nc_read_var(ncid,'photosyns_vars__rh_leaf_patch', 1, photosyns_vars%rh_leaf_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__alphapsnsun_patch", 1, photosyns_vars%alphapsnsun_patch)
    call nc_read_var(ncid,'photosyns_vars__alphapsnsun_patch', 1, photosyns_vars%alphapsnsun_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__alphapsnsha_patch", 1, photosyns_vars%alphapsnsha_patch)
    call nc_read_var(ncid,'photosyns_vars__alphapsnsha_patch', 1, photosyns_vars%alphapsnsha_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__rc13_canair_patch", 1, photosyns_vars%rc13_canair_patch)
    call nc_read_var(ncid,'photosyns_vars__rc13_canair_patch', 1, photosyns_vars%rc13_canair_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__rc13_psnsun_patch", 1, photosyns_vars%rc13_psnsun_patch)
    call nc_read_var(ncid,'photosyns_vars__rc13_psnsun_patch', 1, photosyns_vars%rc13_psnsun_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__rc13_psnsha_patch", 1, photosyns_vars%rc13_psnsha_patch)
    call nc_read_var(ncid,'photosyns_vars__rc13_psnsha_patch', 1, photosyns_vars%rc13_psnsha_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__psnsun_patch", 1, photosyns_vars%psnsun_patch)
    call nc_read_var(ncid,'photosyns_vars__psnsun_patch', 1, photosyns_vars%psnsun_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__psnsha_patch", 1, photosyns_vars%psnsha_patch)
    call nc_read_var(ncid,'photosyns_vars__psnsha_patch', 1, photosyns_vars%psnsha_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__c13_psnsun_patch", 1, photosyns_vars%c13_psnsun_patch)
    call nc_read_var(ncid,'photosyns_vars__c13_psnsun_patch', 1, photosyns_vars%c13_psnsun_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__c13_psnsha_patch", 1, photosyns_vars%c13_psnsha_patch)
    call nc_read_var(ncid,'photosyns_vars__c13_psnsha_patch', 1, photosyns_vars%c13_psnsha_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__c14_psnsun_patch", 1, photosyns_vars%c14_psnsun_patch)
    call nc_read_var(ncid,'photosyns_vars__c14_psnsun_patch', 1, photosyns_vars%c14_psnsun_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__c14_psnsha_patch", 1, photosyns_vars%c14_psnsha_patch)
    call nc_read_var(ncid,'photosyns_vars__c14_psnsha_patch', 1, photosyns_vars%c14_psnsha_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__psnsun_z_patch", 2, photosyns_vars%psnsun_z_patch)
    call nc_read_var(ncid,'photosyns_vars__psnsun_z_patch', 2, photosyns_vars%psnsun_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__psnsha_z_patch", 2, photosyns_vars%psnsha_z_patch)
    call nc_read_var(ncid,'photosyns_vars__psnsha_z_patch', 2, photosyns_vars%psnsha_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__psnsun_wc_patch", 1, photosyns_vars%psnsun_wc_patch)
    call nc_read_var(ncid,'photosyns_vars__psnsun_wc_patch', 1, photosyns_vars%psnsun_wc_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__psnsha_wc_patch", 1, photosyns_vars%psnsha_wc_patch)
    call nc_read_var(ncid,'photosyns_vars__psnsha_wc_patch', 1, photosyns_vars%psnsha_wc_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__psnsun_wj_patch", 1, photosyns_vars%psnsun_wj_patch)
    call nc_read_var(ncid,'photosyns_vars__psnsun_wj_patch', 1, photosyns_vars%psnsun_wj_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__psnsha_wj_patch", 1, photosyns_vars%psnsha_wj_patch)
    call nc_read_var(ncid,'photosyns_vars__psnsha_wj_patch', 1, photosyns_vars%psnsha_wj_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__psnsun_wp_patch", 1, photosyns_vars%psnsun_wp_patch)
    call nc_read_var(ncid,'photosyns_vars__psnsun_wp_patch', 1, photosyns_vars%psnsun_wp_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__psnsha_wp_patch", 1, photosyns_vars%psnsha_wp_patch)
    call nc_read_var(ncid,'photosyns_vars__psnsha_wp_patch', 1, photosyns_vars%psnsha_wp_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__fpsn_patch", 1, photosyns_vars%fpsn_patch)
    call nc_read_var(ncid,'photosyns_vars__fpsn_patch', 1, photosyns_vars%fpsn_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__fpsn_wc_patch", 1, photosyns_vars%fpsn_wc_patch)
    call nc_read_var(ncid,'photosyns_vars__fpsn_wc_patch', 1, photosyns_vars%fpsn_wc_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__fpsn_wj_patch", 1, photosyns_vars%fpsn_wj_patch)
    call nc_read_var(ncid,'photosyns_vars__fpsn_wj_patch', 1, photosyns_vars%fpsn_wj_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__fpsn_wp_patch", 1, photosyns_vars%fpsn_wp_patch)
    call nc_read_var(ncid,'photosyns_vars__fpsn_wp_patch', 1, photosyns_vars%fpsn_wp_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__lmrsun_patch", 1, photosyns_vars%lmrsun_patch)
    call nc_read_var(ncid,'photosyns_vars__lmrsun_patch', 1, photosyns_vars%lmrsun_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__lmrsha_patch", 1, photosyns_vars%lmrsha_patch)
    call nc_read_var(ncid,'photosyns_vars__lmrsha_patch', 1, photosyns_vars%lmrsha_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__lmrsun_z_patch", 2, photosyns_vars%lmrsun_z_patch)
    call nc_read_var(ncid,'photosyns_vars__lmrsun_z_patch', 2, photosyns_vars%lmrsun_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__lmrsha_z_patch", 2, photosyns_vars%lmrsha_z_patch)
    call nc_read_var(ncid,'photosyns_vars__lmrsha_z_patch', 2, photosyns_vars%lmrsha_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__cisun_z_patch", 2, photosyns_vars%cisun_z_patch)
    call nc_read_var(ncid,'photosyns_vars__cisun_z_patch', 2, photosyns_vars%cisun_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__cisha_z_patch", 2, photosyns_vars%cisha_z_patch)
    call nc_read_var(ncid,'photosyns_vars__cisha_z_patch', 2, photosyns_vars%cisha_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__rssun_z_patch", 2, photosyns_vars%rssun_z_patch)
    call nc_read_var(ncid,'photosyns_vars__rssun_z_patch', 2, photosyns_vars%rssun_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__rssha_z_patch", 2, photosyns_vars%rssha_z_patch)
    call nc_read_var(ncid,'photosyns_vars__rssha_z_patch', 2, photosyns_vars%rssha_z_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__rssun_patch", 1, photosyns_vars%rssun_patch)
    call nc_read_var(ncid,'photosyns_vars__rssun_patch', 1, photosyns_vars%rssun_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__rssha_patch", 1, photosyns_vars%rssha_patch)
    call nc_read_var(ncid,'photosyns_vars__rssha_patch', 1, photosyns_vars%rssha_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__ac_phs_patch", 3, photosyns_vars%ac_phs_patch)
    call nc_read_var(ncid,'photosyns_vars__ac_phs_patch', 3, photosyns_vars%ac_phs_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__aj_phs_patch", 3, photosyns_vars%aj_phs_patch)
    call nc_read_var(ncid,'photosyns_vars__aj_phs_patch', 3, photosyns_vars%aj_phs_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__ap_phs_patch", 3, photosyns_vars%ap_phs_patch)
    call nc_read_var(ncid,'photosyns_vars__ap_phs_patch', 3, photosyns_vars%ap_phs_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__ag_phs_patch", 3, photosyns_vars%ag_phs_patch)
    call nc_read_var(ncid,'photosyns_vars__ag_phs_patch', 3, photosyns_vars%ag_phs_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__an_sun_patch", 2, photosyns_vars%an_sun_patch)
    call nc_read_var(ncid,'photosyns_vars__an_sun_patch', 2, photosyns_vars%an_sun_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__an_sha_patch", 2, photosyns_vars%an_sha_patch)
    call nc_read_var(ncid,'photosyns_vars__an_sha_patch', 2, photosyns_vars%an_sha_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__vcmax_z_phs_patch", 3, photosyns_vars%vcmax_z_phs_patch)
    call nc_read_var(ncid,'photosyns_vars__vcmax_z_phs_patch', 3, photosyns_vars%vcmax_z_phs_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__kp_z_phs_patch", 3, photosyns_vars%kp_z_phs_patch)
    call nc_read_var(ncid,'photosyns_vars__kp_z_phs_patch', 3, photosyns_vars%kp_z_phs_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__tpu_z_phs_patch", 3, photosyns_vars%tpu_z_phs_patch)
    call nc_read_var(ncid,'photosyns_vars__tpu_z_phs_patch', 3, photosyns_vars%tpu_z_phs_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__gs_mol_sun_patch", 2, photosyns_vars%gs_mol_sun_patch)
    call nc_read_var(ncid,'photosyns_vars__gs_mol_sun_patch', 2, photosyns_vars%gs_mol_sun_patch, timestep)
    call nc_alloc(ncid, "photosyns_vars__gs_mol_sha_patch", 2, photosyns_vars%gs_mol_sha_patch)
    call nc_read_var(ncid,'photosyns_vars__gs_mol_sha_patch', 2, photosyns_vars%gs_mol_sha_patch, timestep)
    call nc_alloc(ncid, "grc_pp__londeg", 1, grc_pp%londeg)
    call nc_read_var(ncid,'grc_pp__londeg', 1, grc_pp%londeg, timestep)
    call nc_alloc(ncid, "grc_pp__slope_deg", 1, grc_pp%slope_deg)
    call nc_read_var(ncid,'grc_pp__slope_deg', 1, grc_pp%slope_deg, timestep)
    call nc_alloc(ncid, "grc_pp__max_dayl", 1, grc_pp%max_dayl)
    call nc_read_var(ncid,'grc_pp__max_dayl', 1, grc_pp%max_dayl, timestep)
    call nc_alloc(ncid, "grc_pp__dayl", 1, grc_pp%dayl)
    call nc_read_var(ncid,'grc_pp__dayl', 1, grc_pp%dayl, timestep)
    call nc_alloc(ncid, "top_as__tbot", 1, top_as%tbot)
    call nc_read_var(ncid,'top_as__tbot', 1, top_as%tbot, timestep)
    call nc_alloc(ncid, "top_as__thbot", 1, top_as%thbot)
    call nc_read_var(ncid,'top_as__thbot', 1, top_as%thbot, timestep)
    call nc_alloc(ncid, "top_as__pbot", 1, top_as%pbot)
    call nc_read_var(ncid,'top_as__pbot', 1, top_as%pbot, timestep)
    call nc_alloc(ncid, "top_as__rhobot", 1, top_as%rhobot)
    call nc_read_var(ncid,'top_as__rhobot', 1, top_as%rhobot, timestep)
    call nc_alloc(ncid, "top_as__qbot", 1, top_as%qbot)
    call nc_read_var(ncid,'top_as__qbot', 1, top_as%qbot, timestep)
    call nc_alloc(ncid, "top_as__ubot", 1, top_as%ubot)
    call nc_read_var(ncid,'top_as__ubot', 1, top_as%ubot, timestep)
    call nc_alloc(ncid, "top_as__vbot", 1, top_as%vbot)
    call nc_read_var(ncid,'top_as__vbot', 1, top_as%vbot, timestep)
    call nc_alloc(ncid, "top_as__wsresp", 1, top_as%wsresp)
    call nc_read_var(ncid,'top_as__wsresp', 1, top_as%wsresp, timestep)
    call nc_alloc(ncid, "top_as__tau_est", 1, top_as%tau_est)
    call nc_read_var(ncid,'top_as__tau_est', 1, top_as%tau_est, timestep)
    call nc_alloc(ncid, "top_as__ugust", 1, top_as%ugust)
    call nc_read_var(ncid,'top_as__ugust', 1, top_as%ugust, timestep)
    call nc_alloc(ncid, "top_as__po2bot", 1, top_as%po2bot)
    call nc_read_var(ncid,'top_as__po2bot', 1, top_as%po2bot, timestep)
    call nc_alloc(ncid, "top_as__pco2bot", 1, top_as%pco2bot)
    call nc_read_var(ncid,'top_as__pco2bot', 1, top_as%pco2bot, timestep)
    call nc_alloc(ncid, "top_as__pc13o2bot", 1, top_as%pc13o2bot)
    call nc_read_var(ncid,'top_as__pc13o2bot', 1, top_as%pc13o2bot, timestep)
    call nc_alloc(ncid, "top_af__lwrad", 1, top_af%lwrad)
    call nc_read_var(ncid,'top_af__lwrad', 1, top_af%lwrad, timestep)
    call nc_alloc(ncid, "col_pp__gridcell", 1, col_pp%gridcell)
    call nc_read_var(ncid,'col_pp__gridcell', 1, col_pp%gridcell, timestep)
    call nc_alloc(ncid, "col_pp__topounit", 1, col_pp%topounit)
    call nc_read_var(ncid,'col_pp__topounit', 1, col_pp%topounit, timestep)
    call nc_alloc(ncid, "col_pp__landunit", 1, col_pp%landunit)
    call nc_read_var(ncid,'col_pp__landunit', 1, col_pp%landunit, timestep)
    call nc_alloc(ncid, "col_pp__itype", 1, col_pp%itype)
    call nc_read_var(ncid,'col_pp__itype', 1, col_pp%itype, timestep)
    call nc_alloc(ncid, "col_pp__active", 1, col_pp%active)
    call nc_read_var(ncid,'col_pp__active', 1, col_pp%active, timestep)
    call nc_alloc(ncid, "col_pp__snl", 1, col_pp%snl)
    call nc_read_var(ncid,'col_pp__snl', 1, col_pp%snl, timestep)
    call nc_alloc(ncid, "col_pp__dz", 2, col_pp%dz)
    call nc_read_var(ncid,'col_pp__dz', 2, col_pp%dz, timestep)
    call nc_alloc(ncid, "col_pp__z", 2, col_pp%z)
    call nc_read_var(ncid,'col_pp__z', 2, col_pp%z, timestep)
    call nc_alloc(ncid, "col_pp__is_soil", 1, col_pp%is_soil)
    call nc_read_var(ncid,'col_pp__is_soil', 1, col_pp%is_soil, timestep)
    call nc_alloc(ncid, "col_pp__is_crop", 1, col_pp%is_crop)
    call nc_read_var(ncid,'col_pp__is_crop', 1, col_pp%is_crop, timestep)
    call nc_alloc(ncid, "col_es__t_soisno", 2, col_es%t_soisno)
    call nc_read_var(ncid,'col_es__t_soisno', 2, col_es%t_soisno, timestep)
    call nc_alloc(ncid, "col_es__t_h2osfc", 1, col_es%t_h2osfc)
    call nc_read_var(ncid,'col_es__t_h2osfc', 1, col_es%t_h2osfc, timestep)
    call nc_alloc(ncid, "col_es__t_grnd", 1, col_es%t_grnd)
    call nc_read_var(ncid,'col_es__t_grnd', 1, col_es%t_grnd, timestep)
    call nc_alloc(ncid, "col_es__thv", 1, col_es%thv)
    call nc_read_var(ncid,'col_es__thv', 1, col_es%thv, timestep)
    call nc_alloc(ncid, "col_es__emg", 1, col_es%emg)
    call nc_read_var(ncid,'col_es__emg', 1, col_es%emg, timestep)
    call nc_alloc(ncid, "col_ws__h2osoi_liq", 2, col_ws%h2osoi_liq)
    call nc_read_var(ncid,'col_ws__h2osoi_liq', 2, col_ws%h2osoi_liq, timestep)
    call nc_alloc(ncid, "col_ws__h2osoi_ice", 2, col_ws%h2osoi_ice)
    call nc_read_var(ncid,'col_ws__h2osoi_ice', 2, col_ws%h2osoi_ice, timestep)
    call nc_alloc(ncid, "col_ws__h2osoi_vol", 2, col_ws%h2osoi_vol)
    call nc_read_var(ncid,'col_ws__h2osoi_vol', 2, col_ws%h2osoi_vol, timestep)
    call nc_alloc(ncid, "col_ws__h2osoi_liqvol", 2, col_ws%h2osoi_liqvol)
    call nc_read_var(ncid,'col_ws__h2osoi_liqvol', 2, col_ws%h2osoi_liqvol, timestep)
    call nc_alloc(ncid, "col_ws__qg_snow", 1, col_ws%qg_snow)
    call nc_read_var(ncid,'col_ws__qg_snow', 1, col_ws%qg_snow, timestep)
    call nc_alloc(ncid, "col_ws__qg_soil", 1, col_ws%qg_soil)
    call nc_read_var(ncid,'col_ws__qg_soil', 1, col_ws%qg_soil, timestep)
    call nc_alloc(ncid, "col_ws__qg_h2osfc", 1, col_ws%qg_h2osfc)
    call nc_read_var(ncid,'col_ws__qg_h2osfc', 1, col_ws%qg_h2osfc, timestep)
    call nc_alloc(ncid, "col_ws__qg", 1, col_ws%qg)
    call nc_read_var(ncid,'col_ws__qg', 1, col_ws%qg, timestep)
    call nc_alloc(ncid, "col_ws__dqgdt", 1, col_ws%dqgdt)
    call nc_read_var(ncid,'col_ws__dqgdt', 1, col_ws%dqgdt, timestep)
    call nc_alloc(ncid, "col_ws__snow_depth", 1, col_ws%snow_depth)
    call nc_read_var(ncid,'col_ws__snow_depth', 1, col_ws%snow_depth, timestep)
    call nc_alloc(ncid, "col_ws__frac_sno_eff", 1, col_ws%frac_sno_eff)
    call nc_read_var(ncid,'col_ws__frac_sno_eff', 1, col_ws%frac_sno_eff, timestep)
    call nc_alloc(ncid, "col_ws__frac_h2osfc", 1, col_ws%frac_h2osfc)
    call nc_read_var(ncid,'col_ws__frac_h2osfc', 1, col_ws%frac_h2osfc, timestep)
    call nc_alloc(ncid, "col_ef__htvp", 1, col_ef%htvp)
    call nc_read_var(ncid,'col_ef__htvp', 1, col_ef%htvp, timestep)
    call nc_alloc(ncid, "veg_pp__gridcell", 1, veg_pp%gridcell)
    call nc_read_var(ncid,'veg_pp__gridcell', 1, veg_pp%gridcell, timestep)
    call nc_alloc(ncid, "veg_pp__topounit", 1, veg_pp%topounit)
    call nc_read_var(ncid,'veg_pp__topounit', 1, veg_pp%topounit, timestep)
    call nc_alloc(ncid, "veg_pp__landunit", 1, veg_pp%landunit)
    call nc_read_var(ncid,'veg_pp__landunit', 1, veg_pp%landunit, timestep)
    call nc_alloc(ncid, "veg_pp__column", 1, veg_pp%column)
    call nc_read_var(ncid,'veg_pp__column', 1, veg_pp%column, timestep)
    call nc_alloc(ncid, "veg_pp__itype", 1, veg_pp%itype)
    call nc_read_var(ncid,'veg_pp__itype', 1, veg_pp%itype, timestep)
    call nc_alloc(ncid, "veg_pp__active", 1, veg_pp%active)
    call nc_read_var(ncid,'veg_pp__active', 1, veg_pp%active, timestep)
    call nc_alloc(ncid, "veg_pp__is_on_soil_col", 1, veg_pp%is_on_soil_col)
    call nc_read_var(ncid,'veg_pp__is_on_soil_col', 1, veg_pp%is_on_soil_col, timestep)
    call nc_alloc(ncid, "veg_pp__is_on_crop_col", 1, veg_pp%is_on_crop_col)
    call nc_read_var(ncid,'veg_pp__is_on_crop_col', 1, veg_pp%is_on_crop_col, timestep)
    call nc_alloc(ncid, "veg_pp__is_fates", 1, veg_pp%is_fates)
    call nc_read_var(ncid,'veg_pp__is_fates', 1, veg_pp%is_fates, timestep)
    call nc_alloc(ncid, "veg_es__t_veg", 1, veg_es%t_veg)
    call nc_read_var(ncid,'veg_es__t_veg', 1, veg_es%t_veg, timestep)
    call nc_alloc(ncid, "veg_es__t_ref2m", 1, veg_es%t_ref2m)
    call nc_read_var(ncid,'veg_es__t_ref2m', 1, veg_es%t_ref2m, timestep)
    call nc_alloc(ncid, "veg_es__t_ref2m_r", 1, veg_es%t_ref2m_r)
    call nc_read_var(ncid,'veg_es__t_ref2m_r', 1, veg_es%t_ref2m_r, timestep)
    call nc_alloc(ncid, "veg_es__t_a10", 1, veg_es%t_a10)
    call nc_read_var(ncid,'veg_es__t_a10', 1, veg_es%t_a10, timestep)
    call nc_alloc(ncid, "veg_es__thm", 1, veg_es%thm)
    call nc_read_var(ncid,'veg_es__thm', 1, veg_es%thm, timestep)
    call nc_alloc(ncid, "veg_es__emv", 1, veg_es%emv)
    call nc_read_var(ncid,'veg_es__emv', 1, veg_es%emv, timestep)
    call nc_alloc(ncid, "veg_ws__h2ocan", 1, veg_ws%h2ocan)
    call nc_read_var(ncid,'veg_ws__h2ocan', 1, veg_ws%h2ocan, timestep)
    call nc_alloc(ncid, "veg_ws__q_ref2m", 1, veg_ws%q_ref2m)
    call nc_read_var(ncid,'veg_ws__q_ref2m', 1, veg_ws%q_ref2m, timestep)
    call nc_alloc(ncid, "veg_ws__rh_ref2m", 1, veg_ws%rh_ref2m)
    call nc_read_var(ncid,'veg_ws__rh_ref2m', 1, veg_ws%rh_ref2m, timestep)
    call nc_alloc(ncid, "veg_ws__rh_ref2m_r", 1, veg_ws%rh_ref2m_r)
    call nc_read_var(ncid,'veg_ws__rh_ref2m_r', 1, veg_ws%rh_ref2m_r, timestep)
    call nc_alloc(ncid, "veg_ws__rh_af", 1, veg_ws%rh_af)
    call nc_read_var(ncid,'veg_ws__rh_af', 1, veg_ws%rh_af, timestep)
    call nc_alloc(ncid, "veg_ws__fwet", 1, veg_ws%fwet)
    call nc_read_var(ncid,'veg_ws__fwet', 1, veg_ws%fwet, timestep)
    call nc_alloc(ncid, "veg_ws__fdry", 1, veg_ws%fdry)
    call nc_read_var(ncid,'veg_ws__fdry', 1, veg_ws%fdry, timestep)
    call nc_alloc(ncid, "veg_ns__leafn", 1, veg_ns%leafn)
    call nc_read_var(ncid,'veg_ns__leafn', 1, veg_ns%leafn, timestep)
    call nc_alloc(ncid, "veg_ps__leafp", 1, veg_ps%leafp)
    call nc_read_var(ncid,'veg_ps__leafp', 1, veg_ps%leafp, timestep)
    call nc_alloc(ncid, "veg_ef__eflx_sh_grnd", 1, veg_ef%eflx_sh_grnd)
    call nc_read_var(ncid,'veg_ef__eflx_sh_grnd', 1, veg_ef%eflx_sh_grnd, timestep)
    call nc_alloc(ncid, "veg_ef__eflx_sh_veg", 1, veg_ef%eflx_sh_veg)
    call nc_read_var(ncid,'veg_ef__eflx_sh_veg', 1, veg_ef%eflx_sh_veg, timestep)
    call nc_alloc(ncid, "veg_ef__eflx_sh_snow", 1, veg_ef%eflx_sh_snow)
    call nc_read_var(ncid,'veg_ef__eflx_sh_snow', 1, veg_ef%eflx_sh_snow, timestep)
    call nc_alloc(ncid, "veg_ef__eflx_sh_soil", 1, veg_ef%eflx_sh_soil)
    call nc_read_var(ncid,'veg_ef__eflx_sh_soil', 1, veg_ef%eflx_sh_soil, timestep)
    call nc_alloc(ncid, "veg_ef__eflx_sh_h2osfc", 1, veg_ef%eflx_sh_h2osfc)
    call nc_read_var(ncid,'veg_ef__eflx_sh_h2osfc', 1, veg_ef%eflx_sh_h2osfc, timestep)
    call nc_alloc(ncid, "veg_ef__dlrad", 1, veg_ef%dlrad)
    call nc_read_var(ncid,'veg_ef__dlrad', 1, veg_ef%dlrad, timestep)
    call nc_alloc(ncid, "veg_ef__ulrad", 1, veg_ef%ulrad)
    call nc_read_var(ncid,'veg_ef__ulrad', 1, veg_ef%ulrad, timestep)
    call nc_alloc(ncid, "veg_ef__taux", 1, veg_ef%taux)
    call nc_read_var(ncid,'veg_ef__taux', 1, veg_ef%taux, timestep)
    call nc_alloc(ncid, "veg_ef__tauy", 1, veg_ef%tauy)
    call nc_read_var(ncid,'veg_ef__tauy', 1, veg_ef%tauy, timestep)
    call nc_alloc(ncid, "veg_ef__cgrnd", 1, veg_ef%cgrnd)
    call nc_read_var(ncid,'veg_ef__cgrnd', 1, veg_ef%cgrnd, timestep)
    call nc_alloc(ncid, "veg_ef__cgrndl", 1, veg_ef%cgrndl)
    call nc_read_var(ncid,'veg_ef__cgrndl', 1, veg_ef%cgrndl, timestep)
    call nc_alloc(ncid, "veg_ef__cgrnds", 1, veg_ef%cgrnds)
    call nc_read_var(ncid,'veg_ef__cgrnds', 1, veg_ef%cgrnds, timestep)
    call nc_alloc(ncid, "veg_wf__qflx_evap_soi", 1, veg_wf%qflx_evap_soi)
    call nc_read_var(ncid,'veg_wf__qflx_evap_soi', 1, veg_wf%qflx_evap_soi, timestep)
    call nc_alloc(ncid, "veg_wf__qflx_evap_veg", 1, veg_wf%qflx_evap_veg)
    call nc_read_var(ncid,'veg_wf__qflx_evap_veg', 1, veg_wf%qflx_evap_veg, timestep)
    call nc_alloc(ncid, "veg_wf__qflx_tran_veg", 1, veg_wf%qflx_tran_veg)
    call nc_read_var(ncid,'veg_wf__qflx_tran_veg', 1, veg_wf%qflx_tran_veg, timestep)
    call nc_alloc(ncid, "veg_wf__qflx_ev_snow", 1, veg_wf%qflx_ev_snow)
    call nc_read_var(ncid,'veg_wf__qflx_ev_snow', 1, veg_wf%qflx_ev_snow, timestep)
    call nc_alloc(ncid, "veg_wf__qflx_ev_soil", 1, veg_wf%qflx_ev_soil)
    call nc_read_var(ncid,'veg_wf__qflx_ev_soil', 1, veg_wf%qflx_ev_soil, timestep)
    call nc_alloc(ncid, "veg_wf__qflx_ev_h2osfc", 1, veg_wf%qflx_ev_h2osfc)
    call nc_read_var(ncid,'veg_wf__qflx_ev_h2osfc', 1, veg_wf%qflx_ev_h2osfc, timestep)
    call nc_alloc(ncid, "veg_wf__irrig_rate", 1, veg_wf%irrig_rate)
    call nc_read_var(ncid,'veg_wf__irrig_rate', 1, veg_wf%irrig_rate, timestep)
    call nc_alloc(ncid, "veg_wf__n_irrig_steps_left", 1, veg_wf%n_irrig_steps_left)
    call nc_read_var(ncid,'veg_wf__n_irrig_steps_left', 1, veg_wf%n_irrig_steps_left, timestep)
    call nc_alloc(ncid, "top_pp__topo_grc_ind", 1, top_pp%topo_grc_ind)
    call nc_read_var(ncid,'top_pp__topo_grc_ind', 1, top_pp%topo_grc_ind, timestep)
    call nc_alloc(ncid, "top_pp__active", 1, top_pp%active)
    call nc_read_var(ncid,'top_pp__active', 1, top_pp%active, timestep)
    call check(nf90_close(ncid))
  end subroutine read_elmtypes
  subroutine write_elmtypes(io_inst, bounds, atm2lnd_vars, canopystate_vars, cnstate_vars, energyflux_vars, frictionvel_vars, soilstate_vars, solarabs_vars, surfalb_vars, ch4_vars, photosyns_vars)
    type(atm2lnd_type), intent(in) :: atm2lnd_vars
    type(canopystate_type), intent(in) :: canopystate_vars
    type(cnstate_type), intent(in) :: cnstate_vars
    type(energyflux_type), intent(in) :: energyflux_vars
    type(frictionvel_type), intent(in) :: frictionvel_vars
    type(soilstate_type), intent(in) :: soilstate_vars
    type(solarabs_type), intent(in) :: solarabs_vars
    type(surfalb_type), intent(in) :: surfalb_vars
    type(ch4_type), intent(in) :: ch4_vars
    type(photosyns_type), intent(in) :: photosyns_vars
    type(spel_io_type), intent(inout) :: io_inst
    type(bounds_type), intent(in) :: bounds
    integer :: ncid, timestep
    character(len=256) :: new_fn
    new_fn = trim(io_inst%get_fn())
    if( io_inst%new_file) then
        print *, 'creating file: ', trim(new_fn)
        ncid = nc_create_or_open_file(trim(new_fn), create_file)
        io_inst%new_file = .false.
        call define_vars(ncid, bounds, atm2lnd_vars, canopystate_vars, cnstate_vars, energyflux_vars, frictionvel_vars, soilstate_vars, solarabs_vars, surfalb_vars, ch4_vars, photosyns_vars)
        call check(nf90_enddef(ncid))
    else
        ncid = nc_create_or_open_file(trim(new_fn), append_file)
    end if
    timestep = io_inst%timestep
     if(verbose) print *, 'bounds__begg'
    call nc_write_var_scalar(ncid, bounds%begg, 'bounds__begg')
     if(verbose) print *, 'bounds__endg'
    call nc_write_var_scalar(ncid, bounds%endg, 'bounds__endg')
     if(verbose) print *, 'bounds__begt'
    call nc_write_var_scalar(ncid, bounds%begt, 'bounds__begt')
     if(verbose) print *, 'bounds__endt'
    call nc_write_var_scalar(ncid, bounds%endt, 'bounds__endt')
     if(verbose) print *, 'bounds__begl'
    call nc_write_var_scalar(ncid, bounds%begl, 'bounds__begl')
     if(verbose) print *, 'bounds__endl'
    call nc_write_var_scalar(ncid, bounds%endl, 'bounds__endl')
     if(verbose) print *, 'bounds__begc'
    call nc_write_var_scalar(ncid, bounds%begc, 'bounds__begc')
     if(verbose) print *, 'bounds__endc'
    call nc_write_var_scalar(ncid, bounds%endc, 'bounds__endc')
     if(verbose) print *, 'bounds__begp'
    call nc_write_var_scalar(ncid, bounds%begp, 'bounds__begp')
     if(verbose) print *, 'bounds__endp'
    call nc_write_var_scalar(ncid, bounds%endp, 'bounds__endp')
     if(verbose) print *, 'paramsshareinst__q10_mr'
    call nc_write_var_scalar(ncid, paramsshareinst%q10_mr, 'paramsshareinst__q10_mr')
     if(verbose) print *, 'veg_vp__tc_stress'
    call nc_write_var_scalar(ncid, veg_vp%tc_stress, 'veg_vp__tc_stress')
     if(verbose) print *, 'lun_pp__gridcell'
    call nc_write_var_array(ncid,1, shape(lun_pp%gridcell), [character(len=32) :: 'landunit'], reshape(lun_pp%gridcell, [product(shape(lun_pp%gridcell))]), 'lun_pp__gridcell', timestep)
     if(verbose) print *, 'lun_pp__topounit'
    call nc_write_var_array(ncid,1, shape(lun_pp%topounit), [character(len=32) :: 'landunit'], reshape(lun_pp%topounit, [product(shape(lun_pp%topounit))]), 'lun_pp__topounit', timestep)
     if(verbose) print *, 'lun_pp__pfti'
    call nc_write_var_array(ncid,1, shape(lun_pp%pfti), [character(len=32) :: 'landunit'], reshape(lun_pp%pfti, [product(shape(lun_pp%pfti))]), 'lun_pp__pfti', timestep)
     if(verbose) print *, 'lun_pp__pftf'
    call nc_write_var_array(ncid,1, shape(lun_pp%pftf), [character(len=32) :: 'landunit'], reshape(lun_pp%pftf, [product(shape(lun_pp%pftf))]), 'lun_pp__pftf', timestep)
     if(verbose) print *, 'lun_pp__itype'
    call nc_write_var_array(ncid,1, shape(lun_pp%itype), [character(len=32) :: 'landunit'], reshape(lun_pp%itype, [product(shape(lun_pp%itype))]), 'lun_pp__itype', timestep)
     if(verbose) print *, 'lun_pp__lakpoi'
    call nc_write_var_array(ncid,1, shape(lun_pp%lakpoi), [character(len=32) :: 'landunit'], reshape(lun_pp%lakpoi, [product(shape(lun_pp%lakpoi))]), 'lun_pp__lakpoi', timestep)
     if(verbose) print *, 'lun_pp__urbpoi'
    call nc_write_var_array(ncid,1, shape(lun_pp%urbpoi), [character(len=32) :: 'landunit'], reshape(lun_pp%urbpoi, [product(shape(lun_pp%urbpoi))]), 'lun_pp__urbpoi', timestep)
     if(verbose) print *, 'lun_pp__active'
    call nc_write_var_array(ncid,1, shape(lun_pp%active), [character(len=32) :: 'landunit'], reshape(lun_pp%active, [product(shape(lun_pp%active))]), 'lun_pp__active', timestep)
     if(verbose) print *, 'veg_vp__smpso'
    call nc_write_var_array(ncid,1, shape(veg_vp%smpso), [character(len=32) :: '_0_numpft'], reshape(veg_vp%smpso, [product(shape(veg_vp%smpso))]), 'veg_vp__smpso', timestep)
     if(verbose) print *, 'veg_vp__smpsc'
    call nc_write_var_array(ncid,1, shape(veg_vp%smpsc), [character(len=32) :: '_0_numpft'], reshape(veg_vp%smpsc, [product(shape(veg_vp%smpsc))]), 'veg_vp__smpsc', timestep)
     if(verbose) print *, 'veg_vp__fnitr'
    call nc_write_var_array(ncid,1, shape(veg_vp%fnitr), [character(len=32) :: '_0_numpft'], reshape(veg_vp%fnitr, [product(shape(veg_vp%fnitr))]), 'veg_vp__fnitr', timestep)
     if(verbose) print *, 'veg_vp__dleaf'
    call nc_write_var_array(ncid,1, shape(veg_vp%dleaf), [character(len=32) :: '_0_numpft'], reshape(veg_vp%dleaf, [product(shape(veg_vp%dleaf))]), 'veg_vp__dleaf', timestep)
     if(verbose) print *, 'veg_vp__c3psn'
    call nc_write_var_array(ncid,1, shape(veg_vp%c3psn), [character(len=32) :: '_0_numpft'], reshape(veg_vp%c3psn, [product(shape(veg_vp%c3psn))]), 'veg_vp__c3psn', timestep)
     if(verbose) print *, 'veg_vp__slatop'
    call nc_write_var_array(ncid,1, shape(veg_vp%slatop), [character(len=32) :: '_0_numpft'], reshape(veg_vp%slatop, [product(shape(veg_vp%slatop))]), 'veg_vp__slatop', timestep)
     if(verbose) print *, 'veg_vp__root_radius'
    call nc_write_var_array(ncid,1, shape(veg_vp%root_radius), [character(len=32) :: '_0_numpft'], reshape(veg_vp%root_radius, [product(shape(veg_vp%root_radius))]), 'veg_vp__root_radius', timestep)
     if(verbose) print *, 'veg_vp__root_density'
    call nc_write_var_array(ncid,1, shape(veg_vp%root_density), [character(len=32) :: '_0_numpft'], reshape(veg_vp%root_density, [product(shape(veg_vp%root_density))]), 'veg_vp__root_density', timestep)
     if(verbose) print *, 'veg_vp__leafcn'
    call nc_write_var_array(ncid,1, shape(veg_vp%leafcn), [character(len=32) :: '_0_numpft'], reshape(veg_vp%leafcn, [product(shape(veg_vp%leafcn))]), 'veg_vp__leafcn', timestep)
     if(verbose) print *, 'veg_vp__flnr'
    call nc_write_var_array(ncid,1, shape(veg_vp%flnr), [character(len=32) :: '_0_numpft'], reshape(veg_vp%flnr, [product(shape(veg_vp%flnr))]), 'veg_vp__flnr', timestep)
     if(verbose) print *, 'veg_vp__froot_leaf'
    call nc_write_var_array(ncid,1, shape(veg_vp%froot_leaf), [character(len=32) :: '_0_numpft'], reshape(veg_vp%froot_leaf, [product(shape(veg_vp%froot_leaf))]), 'veg_vp__froot_leaf', timestep)
     if(verbose) print *, 'veg_vp__stem_leaf'
    call nc_write_var_array(ncid,1, shape(veg_vp%stem_leaf), [character(len=32) :: '_0_numpft'], reshape(veg_vp%stem_leaf, [product(shape(veg_vp%stem_leaf))]), 'veg_vp__stem_leaf', timestep)
     if(verbose) print *, 'veg_vp__croot_stem'
    call nc_write_var_array(ncid,1, shape(veg_vp%croot_stem), [character(len=32) :: '_0_numpft'], reshape(veg_vp%croot_stem, [product(shape(veg_vp%croot_stem))]), 'veg_vp__croot_stem', timestep)
     if(verbose) print *, 'veg_vp__i_vc'
    call nc_write_var_array(ncid,1, shape(veg_vp%i_vc), [character(len=32) :: '_0_numpft'], reshape(veg_vp%i_vc, [product(shape(veg_vp%i_vc))]), 'veg_vp__i_vc', timestep)
     if(verbose) print *, 'veg_vp__s_vc'
    call nc_write_var_array(ncid,1, shape(veg_vp%s_vc), [character(len=32) :: '_0_numpft'], reshape(veg_vp%s_vc, [product(shape(veg_vp%s_vc))]), 'veg_vp__s_vc', timestep)
     if(verbose) print *, 'veg_vp__fnr'
    call nc_write_var_array(ncid,1, shape(veg_vp%fnr), [character(len=32) :: '_0_numpft'], reshape(veg_vp%fnr, [product(shape(veg_vp%fnr))]), 'veg_vp__fnr', timestep)
     if(verbose) print *, 'veg_vp__act25'
    call nc_write_var_array(ncid,1, shape(veg_vp%act25), [character(len=32) :: '_0_numpft'], reshape(veg_vp%act25, [product(shape(veg_vp%act25))]), 'veg_vp__act25', timestep)
     if(verbose) print *, 'veg_vp__kcha'
    call nc_write_var_array(ncid,1, shape(veg_vp%kcha), [character(len=32) :: '_0_numpft'], reshape(veg_vp%kcha, [product(shape(veg_vp%kcha))]), 'veg_vp__kcha', timestep)
     if(verbose) print *, 'veg_vp__koha'
    call nc_write_var_array(ncid,1, shape(veg_vp%koha), [character(len=32) :: '_0_numpft'], reshape(veg_vp%koha, [product(shape(veg_vp%koha))]), 'veg_vp__koha', timestep)
     if(verbose) print *, 'veg_vp__cpha'
    call nc_write_var_array(ncid,1, shape(veg_vp%cpha), [character(len=32) :: '_0_numpft'], reshape(veg_vp%cpha, [product(shape(veg_vp%cpha))]), 'veg_vp__cpha', timestep)
     if(verbose) print *, 'veg_vp__vcmaxha'
    call nc_write_var_array(ncid,1, shape(veg_vp%vcmaxha), [character(len=32) :: '_0_numpft'], reshape(veg_vp%vcmaxha, [product(shape(veg_vp%vcmaxha))]), 'veg_vp__vcmaxha', timestep)
     if(verbose) print *, 'veg_vp__jmaxha'
    call nc_write_var_array(ncid,1, shape(veg_vp%jmaxha), [character(len=32) :: '_0_numpft'], reshape(veg_vp%jmaxha, [product(shape(veg_vp%jmaxha))]), 'veg_vp__jmaxha', timestep)
     if(verbose) print *, 'veg_vp__tpuha'
    call nc_write_var_array(ncid,1, shape(veg_vp%tpuha), [character(len=32) :: '_0_numpft'], reshape(veg_vp%tpuha, [product(shape(veg_vp%tpuha))]), 'veg_vp__tpuha', timestep)
     if(verbose) print *, 'veg_vp__lmrha'
    call nc_write_var_array(ncid,1, shape(veg_vp%lmrha), [character(len=32) :: '_0_numpft'], reshape(veg_vp%lmrha, [product(shape(veg_vp%lmrha))]), 'veg_vp__lmrha', timestep)
     if(verbose) print *, 'veg_vp__vcmaxhd'
    call nc_write_var_array(ncid,1, shape(veg_vp%vcmaxhd), [character(len=32) :: '_0_numpft'], reshape(veg_vp%vcmaxhd, [product(shape(veg_vp%vcmaxhd))]), 'veg_vp__vcmaxhd', timestep)
     if(verbose) print *, 'veg_vp__jmaxhd'
    call nc_write_var_array(ncid,1, shape(veg_vp%jmaxhd), [character(len=32) :: '_0_numpft'], reshape(veg_vp%jmaxhd, [product(shape(veg_vp%jmaxhd))]), 'veg_vp__jmaxhd', timestep)
     if(verbose) print *, 'veg_vp__tpuhd'
    call nc_write_var_array(ncid,1, shape(veg_vp%tpuhd), [character(len=32) :: '_0_numpft'], reshape(veg_vp%tpuhd, [product(shape(veg_vp%tpuhd))]), 'veg_vp__tpuhd', timestep)
     if(verbose) print *, 'veg_vp__lmrhd'
    call nc_write_var_array(ncid,1, shape(veg_vp%lmrhd), [character(len=32) :: '_0_numpft'], reshape(veg_vp%lmrhd, [product(shape(veg_vp%lmrhd))]), 'veg_vp__lmrhd', timestep)
     if(verbose) print *, 'veg_vp__lmrse'
    call nc_write_var_array(ncid,1, shape(veg_vp%lmrse), [character(len=32) :: '_0_numpft'], reshape(veg_vp%lmrse, [product(shape(veg_vp%lmrse))]), 'veg_vp__lmrse', timestep)
     if(verbose) print *, 'veg_vp__qe'
    call nc_write_var_array(ncid,1, shape(veg_vp%qe), [character(len=32) :: '_0_numpft'], reshape(veg_vp%qe, [product(shape(veg_vp%qe))]), 'veg_vp__qe', timestep)
     if(verbose) print *, 'veg_vp__theta_cj'
    call nc_write_var_array(ncid,1, shape(veg_vp%theta_cj), [character(len=32) :: '_0_numpft'], reshape(veg_vp%theta_cj, [product(shape(veg_vp%theta_cj))]), 'veg_vp__theta_cj', timestep)
     if(verbose) print *, 'veg_vp__bbbopt'
    call nc_write_var_array(ncid,1, shape(veg_vp%bbbopt), [character(len=32) :: '_0_numpft'], reshape(veg_vp%bbbopt, [product(shape(veg_vp%bbbopt))]), 'veg_vp__bbbopt', timestep)
     if(verbose) print *, 'veg_vp__mbbopt'
    call nc_write_var_array(ncid,1, shape(veg_vp%mbbopt), [character(len=32) :: '_0_numpft'], reshape(veg_vp%mbbopt, [product(shape(veg_vp%mbbopt))]), 'veg_vp__mbbopt', timestep)
     if(verbose) print *, 'canopystate_vars__frac_veg_nosno_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%frac_veg_nosno_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%frac_veg_nosno_patch, [product(shape(canopystate_vars%frac_veg_nosno_patch))]), 'canopystate_vars__frac_veg_nosno_patch', timestep)
     if(verbose) print *, 'canopystate_vars__tlai_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%tlai_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%tlai_patch, [product(shape(canopystate_vars%tlai_patch))]), 'canopystate_vars__tlai_patch', timestep)
     if(verbose) print *, 'canopystate_vars__tsai_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%tsai_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%tsai_patch, [product(shape(canopystate_vars%tsai_patch))]), 'canopystate_vars__tsai_patch', timestep)
     if(verbose) print *, 'canopystate_vars__elai_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%elai_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%elai_patch, [product(shape(canopystate_vars%elai_patch))]), 'canopystate_vars__elai_patch', timestep)
     if(verbose) print *, 'canopystate_vars__esai_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%esai_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%esai_patch, [product(shape(canopystate_vars%esai_patch))]), 'canopystate_vars__esai_patch', timestep)
     if(verbose) print *, 'canopystate_vars__laisun_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%laisun_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%laisun_patch, [product(shape(canopystate_vars%laisun_patch))]), 'canopystate_vars__laisun_patch', timestep)
     if(verbose) print *, 'canopystate_vars__laisha_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%laisha_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%laisha_patch, [product(shape(canopystate_vars%laisha_patch))]), 'canopystate_vars__laisha_patch', timestep)
     if(verbose) print *, 'canopystate_vars__laisun_z_patch'
    call nc_write_var_array(ncid,2, shape(canopystate_vars%laisun_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(canopystate_vars%laisun_z_patch, [product(shape(canopystate_vars%laisun_z_patch))]), 'canopystate_vars__laisun_z_patch', timestep)
     if(verbose) print *, 'canopystate_vars__laisha_z_patch'
    call nc_write_var_array(ncid,2, shape(canopystate_vars%laisha_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(canopystate_vars%laisha_z_patch, [product(shape(canopystate_vars%laisha_z_patch))]), 'canopystate_vars__laisha_z_patch', timestep)
     if(verbose) print *, 'canopystate_vars__htop_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%htop_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%htop_patch, [product(shape(canopystate_vars%htop_patch))]), 'canopystate_vars__htop_patch', timestep)
     if(verbose) print *, 'canopystate_vars__displa_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%displa_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%displa_patch, [product(shape(canopystate_vars%displa_patch))]), 'canopystate_vars__displa_patch', timestep)
     if(verbose) print *, 'canopystate_vars__altmax_indx_col'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%altmax_indx_col), [character(len=32) :: 'column'], reshape(canopystate_vars%altmax_indx_col, [product(shape(canopystate_vars%altmax_indx_col))]), 'canopystate_vars__altmax_indx_col', timestep)
     if(verbose) print *, 'canopystate_vars__altmax_lastyear_indx_col'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%altmax_lastyear_indx_col), [character(len=32) :: 'column'], reshape(canopystate_vars%altmax_lastyear_indx_col, [product(shape(canopystate_vars%altmax_lastyear_indx_col))]), 'canopystate_vars__altmax_lastyear_indx_col', timestep)
     if(verbose) print *, 'canopystate_vars__dleaf_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%dleaf_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%dleaf_patch, [product(shape(canopystate_vars%dleaf_patch))]), 'canopystate_vars__dleaf_patch', timestep)
     if(verbose) print *, 'canopystate_vars__lbl_rsc_h2o_patch'
    call nc_write_var_array(ncid,1, shape(canopystate_vars%lbl_rsc_h2o_patch), [character(len=32) :: 'patch'], reshape(canopystate_vars%lbl_rsc_h2o_patch, [product(shape(canopystate_vars%lbl_rsc_h2o_patch))]), 'canopystate_vars__lbl_rsc_h2o_patch', timestep)
     if(verbose) print *, 'canopystate_vars__vegwp_patch'
    call nc_write_var_array(ncid,2, shape(canopystate_vars%vegwp_patch), [character(len=32) :: 'patch','_1_nvegwcs'], reshape(canopystate_vars%vegwp_patch, [product(shape(canopystate_vars%vegwp_patch))]), 'canopystate_vars__vegwp_patch', timestep)
     if(verbose) print *, 'cnstate_vars__downreg_patch'
    call nc_write_var_array(ncid,1, shape(cnstate_vars%downreg_patch), [character(len=32) :: 'patch'], reshape(cnstate_vars%downreg_patch, [product(shape(cnstate_vars%downreg_patch))]), 'cnstate_vars__downreg_patch', timestep)
     if(verbose) print *, 'cnstate_vars__rc14_atm_patch'
    call nc_write_var_array(ncid,1, shape(cnstate_vars%rc14_atm_patch), [character(len=32) :: 'patch'], reshape(cnstate_vars%rc14_atm_patch, [product(shape(cnstate_vars%rc14_atm_patch))]), 'cnstate_vars__rc14_atm_patch', timestep)
     if(verbose) print *, 'energyflux_vars__canopy_cond_patch'
    call nc_write_var_array(ncid,1, shape(energyflux_vars%canopy_cond_patch), [character(len=32) :: 'patch'], reshape(energyflux_vars%canopy_cond_patch, [product(shape(energyflux_vars%canopy_cond_patch))]), 'energyflux_vars__canopy_cond_patch', timestep)
     if(verbose) print *, 'energyflux_vars__btran_patch'
    call nc_write_var_array(ncid,1, shape(energyflux_vars%btran_patch), [character(len=32) :: 'patch'], reshape(energyflux_vars%btran_patch, [product(shape(energyflux_vars%btran_patch))]), 'energyflux_vars__btran_patch', timestep)
     if(verbose) print *, 'energyflux_vars__bsun_patch'
    call nc_write_var_array(ncid,1, shape(energyflux_vars%bsun_patch), [character(len=32) :: 'patch'], reshape(energyflux_vars%bsun_patch, [product(shape(energyflux_vars%bsun_patch))]), 'energyflux_vars__bsun_patch', timestep)
     if(verbose) print *, 'energyflux_vars__bsha_patch'
    call nc_write_var_array(ncid,1, shape(energyflux_vars%bsha_patch), [character(len=32) :: 'patch'], reshape(energyflux_vars%bsha_patch, [product(shape(energyflux_vars%bsha_patch))]), 'energyflux_vars__bsha_patch', timestep)
     if(verbose) print *, 'energyflux_vars__btran2_patch'
    call nc_write_var_array(ncid,1, shape(energyflux_vars%btran2_patch), [character(len=32) :: 'patch'], reshape(energyflux_vars%btran2_patch, [product(shape(energyflux_vars%btran2_patch))]), 'energyflux_vars__btran2_patch', timestep)
     if(verbose) print *, 'energyflux_vars__rresis_patch'
    call nc_write_var_array(ncid,2, shape(energyflux_vars%rresis_patch), [character(len=32) :: 'patch','_1_nlevgrnd'], reshape(energyflux_vars%rresis_patch, [product(shape(energyflux_vars%rresis_patch))]), 'energyflux_vars__rresis_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__forc_hgt_u_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%forc_hgt_u_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%forc_hgt_u_patch, [product(shape(frictionvel_vars%forc_hgt_u_patch))]), 'frictionvel_vars__forc_hgt_u_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__forc_hgt_t_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%forc_hgt_t_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%forc_hgt_t_patch, [product(shape(frictionvel_vars%forc_hgt_t_patch))]), 'frictionvel_vars__forc_hgt_t_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__forc_hgt_q_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%forc_hgt_q_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%forc_hgt_q_patch, [product(shape(frictionvel_vars%forc_hgt_q_patch))]), 'frictionvel_vars__forc_hgt_q_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__u10_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%u10_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%u10_patch, [product(shape(frictionvel_vars%u10_patch))]), 'frictionvel_vars__u10_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__u10_elm_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%u10_elm_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%u10_elm_patch, [product(shape(frictionvel_vars%u10_elm_patch))]), 'frictionvel_vars__u10_elm_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__u10_with_gusts_elm_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%u10_with_gusts_elm_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%u10_with_gusts_elm_patch, [product(shape(frictionvel_vars%u10_with_gusts_elm_patch))]), 'frictionvel_vars__u10_with_gusts_elm_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__va_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%va_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%va_patch, [product(shape(frictionvel_vars%va_patch))]), 'frictionvel_vars__va_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__vds_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%vds_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%vds_patch, [product(shape(frictionvel_vars%vds_patch))]), 'frictionvel_vars__vds_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__fv_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%fv_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%fv_patch, [product(shape(frictionvel_vars%fv_patch))]), 'frictionvel_vars__fv_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__rb1_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%rb1_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%rb1_patch, [product(shape(frictionvel_vars%rb1_patch))]), 'frictionvel_vars__rb1_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__ram1_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%ram1_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%ram1_patch, [product(shape(frictionvel_vars%ram1_patch))]), 'frictionvel_vars__ram1_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__z0mv_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%z0mv_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%z0mv_patch, [product(shape(frictionvel_vars%z0mv_patch))]), 'frictionvel_vars__z0mv_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__z0hv_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%z0hv_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%z0hv_patch, [product(shape(frictionvel_vars%z0hv_patch))]), 'frictionvel_vars__z0hv_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__z0qv_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%z0qv_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%z0qv_patch, [product(shape(frictionvel_vars%z0qv_patch))]), 'frictionvel_vars__z0qv_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__z0mg_col'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%z0mg_col), [character(len=32) :: 'column'], reshape(frictionvel_vars%z0mg_col, [product(shape(frictionvel_vars%z0mg_col))]), 'frictionvel_vars__z0mg_col', timestep)
     if(verbose) print *, 'frictionvel_vars__num_iter_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%num_iter_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%num_iter_patch, [product(shape(frictionvel_vars%num_iter_patch))]), 'frictionvel_vars__num_iter_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__rah_above_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%rah_above_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%rah_above_patch, [product(shape(frictionvel_vars%rah_above_patch))]), 'frictionvel_vars__rah_above_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__raw_below_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%raw_below_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%raw_below_patch, [product(shape(frictionvel_vars%raw_below_patch))]), 'frictionvel_vars__raw_below_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__ustar_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%ustar_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%ustar_patch, [product(shape(frictionvel_vars%ustar_patch))]), 'frictionvel_vars__ustar_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__um_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%um_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%um_patch, [product(shape(frictionvel_vars%um_patch))]), 'frictionvel_vars__um_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__uaf_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%uaf_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%uaf_patch, [product(shape(frictionvel_vars%uaf_patch))]), 'frictionvel_vars__uaf_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__taf_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%taf_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%taf_patch, [product(shape(frictionvel_vars%taf_patch))]), 'frictionvel_vars__taf_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__qaf_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%qaf_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%qaf_patch, [product(shape(frictionvel_vars%qaf_patch))]), 'frictionvel_vars__qaf_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__obu_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%obu_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%obu_patch, [product(shape(frictionvel_vars%obu_patch))]), 'frictionvel_vars__obu_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__zeta_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%zeta_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%zeta_patch, [product(shape(frictionvel_vars%zeta_patch))]), 'frictionvel_vars__zeta_patch', timestep)
     if(verbose) print *, 'frictionvel_vars__vpd_patch'
    call nc_write_var_array(ncid,1, shape(frictionvel_vars%vpd_patch), [character(len=32) :: 'patch'], reshape(frictionvel_vars%vpd_patch, [product(shape(frictionvel_vars%vpd_patch))]), 'frictionvel_vars__vpd_patch', timestep)
     if(verbose) print *, 'soilstate_vars__hksat_col'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%hksat_col), [character(len=32) :: 'column','nlevgrnd'], reshape(soilstate_vars%hksat_col, [product(shape(soilstate_vars%hksat_col))]), 'soilstate_vars__hksat_col', timestep)
     if(verbose) print *, 'soilstate_vars__hk_l_col'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%hk_l_col), [character(len=32) :: 'column','nlevgrnd'], reshape(soilstate_vars%hk_l_col, [product(shape(soilstate_vars%hk_l_col))]), 'soilstate_vars__hk_l_col', timestep)
     if(verbose) print *, 'soilstate_vars__smp_l_col'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%smp_l_col), [character(len=32) :: 'column','nlevgrnd'], reshape(soilstate_vars%smp_l_col, [product(shape(soilstate_vars%smp_l_col))]), 'soilstate_vars__smp_l_col', timestep)
     if(verbose) print *, 'soilstate_vars__bsw_col'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%bsw_col), [character(len=32) :: 'column','nlevgrnd'], reshape(soilstate_vars%bsw_col, [product(shape(soilstate_vars%bsw_col))]), 'soilstate_vars__bsw_col', timestep)
     if(verbose) print *, 'soilstate_vars__watsat_col'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%watsat_col), [character(len=32) :: 'column','nlevgrnd'], reshape(soilstate_vars%watsat_col, [product(shape(soilstate_vars%watsat_col))]), 'soilstate_vars__watsat_col', timestep)
     if(verbose) print *, 'soilstate_vars__sucsat_col'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%sucsat_col), [character(len=32) :: 'column','nlevgrnd'], reshape(soilstate_vars%sucsat_col, [product(shape(soilstate_vars%sucsat_col))]), 'soilstate_vars__sucsat_col', timestep)
     if(verbose) print *, 'soilstate_vars__soilbeta_col'
    call nc_write_var_array(ncid,1, shape(soilstate_vars%soilbeta_col), [character(len=32) :: 'column'], reshape(soilstate_vars%soilbeta_col, [product(shape(soilstate_vars%soilbeta_col))]), 'soilstate_vars__soilbeta_col', timestep)
     if(verbose) print *, 'soilstate_vars__eff_porosity_col'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%eff_porosity_col), [character(len=32) :: 'column','nlevgrnd'], reshape(soilstate_vars%eff_porosity_col, [product(shape(soilstate_vars%eff_porosity_col))]), 'soilstate_vars__eff_porosity_col', timestep)
     if(verbose) print *, 'soilstate_vars__rootr_patch'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%rootr_patch), [character(len=32) :: 'patch','_1_nlevgrnd'], reshape(soilstate_vars%rootr_patch, [product(shape(soilstate_vars%rootr_patch))]), 'soilstate_vars__rootr_patch', timestep)
     if(verbose) print *, 'soilstate_vars__rootfr_patch'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%rootfr_patch), [character(len=32) :: 'patch','_1_nlevgrnd'], reshape(soilstate_vars%rootfr_patch, [product(shape(soilstate_vars%rootfr_patch))]), 'soilstate_vars__rootfr_patch', timestep)
     if(verbose) print *, 'soilstate_vars__k_soil_root_patch'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%k_soil_root_patch), [character(len=32) :: 'patch','_1_nlevsoi'], reshape(soilstate_vars%k_soil_root_patch, [product(shape(soilstate_vars%k_soil_root_patch))]), 'soilstate_vars__k_soil_root_patch', timestep)
     if(verbose) print *, 'soilstate_vars__root_conductance_patch'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%root_conductance_patch), [character(len=32) :: 'patch','_1_nlevsoi'], reshape(soilstate_vars%root_conductance_patch, [product(shape(soilstate_vars%root_conductance_patch))]), 'soilstate_vars__root_conductance_patch', timestep)
     if(verbose) print *, 'soilstate_vars__soil_conductance_patch'
    call nc_write_var_array(ncid,2, shape(soilstate_vars%soil_conductance_patch), [character(len=32) :: 'patch','_1_nlevsoi'], reshape(soilstate_vars%soil_conductance_patch, [product(shape(soilstate_vars%soil_conductance_patch))]), 'soilstate_vars__soil_conductance_patch', timestep)
     if(verbose) print *, 'solarabs_vars__parsun_z_patch'
    call nc_write_var_array(ncid,2, shape(solarabs_vars%parsun_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(solarabs_vars%parsun_z_patch, [product(shape(solarabs_vars%parsun_z_patch))]), 'solarabs_vars__parsun_z_patch', timestep)
     if(verbose) print *, 'solarabs_vars__parsha_z_patch'
    call nc_write_var_array(ncid,2, shape(solarabs_vars%parsha_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(solarabs_vars%parsha_z_patch, [product(shape(solarabs_vars%parsha_z_patch))]), 'solarabs_vars__parsha_z_patch', timestep)
     if(verbose) print *, 'solarabs_vars__sabv_patch'
    call nc_write_var_array(ncid,1, shape(solarabs_vars%sabv_patch), [character(len=32) :: 'patch'], reshape(solarabs_vars%sabv_patch, [product(shape(solarabs_vars%sabv_patch))]), 'solarabs_vars__sabv_patch', timestep)
     if(verbose) print *, 'surfalb_vars__tlai_z_patch'
    call nc_write_var_array(ncid,2, shape(surfalb_vars%tlai_z_patch), [character(len=32) :: 'patch','nlevcan'], reshape(surfalb_vars%tlai_z_patch, [product(shape(surfalb_vars%tlai_z_patch))]), 'surfalb_vars__tlai_z_patch', timestep)
     if(verbose) print *, 'surfalb_vars__nrad_patch'
    call nc_write_var_array(ncid,1, shape(surfalb_vars%nrad_patch), [character(len=32) :: 'patch'], reshape(surfalb_vars%nrad_patch, [product(shape(surfalb_vars%nrad_patch))]), 'surfalb_vars__nrad_patch', timestep)
     if(verbose) print *, 'surfalb_vars__vcmaxcintsun_patch'
    call nc_write_var_array(ncid,1, shape(surfalb_vars%vcmaxcintsun_patch), [character(len=32) :: 'patch'], reshape(surfalb_vars%vcmaxcintsun_patch, [product(shape(surfalb_vars%vcmaxcintsun_patch))]), 'surfalb_vars__vcmaxcintsun_patch', timestep)
     if(verbose) print *, 'surfalb_vars__vcmaxcintsha_patch'
    call nc_write_var_array(ncid,1, shape(surfalb_vars%vcmaxcintsha_patch), [character(len=32) :: 'patch'], reshape(surfalb_vars%vcmaxcintsha_patch, [product(shape(surfalb_vars%vcmaxcintsha_patch))]), 'surfalb_vars__vcmaxcintsha_patch', timestep)
     if(verbose) print *, 'ch4_vars__grnd_ch4_cond_patch'
    call nc_write_var_array(ncid,1, shape(ch4_vars%grnd_ch4_cond_patch), [character(len=32) :: 'patch'], reshape(ch4_vars%grnd_ch4_cond_patch, [product(shape(ch4_vars%grnd_ch4_cond_patch))]), 'ch4_vars__grnd_ch4_cond_patch', timestep)
     if(verbose) print *, 'photosyns_vars__c3flag_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%c3flag_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%c3flag_patch, [product(shape(photosyns_vars%c3flag_patch))]), 'photosyns_vars__c3flag_patch', timestep)
     if(verbose) print *, 'photosyns_vars__ac_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%ac_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%ac_patch, [product(shape(photosyns_vars%ac_patch))]), 'photosyns_vars__ac_patch', timestep)
     if(verbose) print *, 'photosyns_vars__aj_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%aj_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%aj_patch, [product(shape(photosyns_vars%aj_patch))]), 'photosyns_vars__aj_patch', timestep)
     if(verbose) print *, 'photosyns_vars__ap_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%ap_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%ap_patch, [product(shape(photosyns_vars%ap_patch))]), 'photosyns_vars__ap_patch', timestep)
     if(verbose) print *, 'photosyns_vars__ag_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%ag_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%ag_patch, [product(shape(photosyns_vars%ag_patch))]), 'photosyns_vars__ag_patch', timestep)
     if(verbose) print *, 'photosyns_vars__an_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%an_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%an_patch, [product(shape(photosyns_vars%an_patch))]), 'photosyns_vars__an_patch', timestep)
     if(verbose) print *, 'photosyns_vars__vcmax_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%vcmax_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%vcmax_z_patch, [product(shape(photosyns_vars%vcmax_z_patch))]), 'photosyns_vars__vcmax_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__vcmax25_top_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%vcmax25_top_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%vcmax25_top_patch, [product(shape(photosyns_vars%vcmax25_top_patch))]), 'photosyns_vars__vcmax25_top_patch', timestep)
     if(verbose) print *, 'photosyns_vars__cp_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%cp_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%cp_patch, [product(shape(photosyns_vars%cp_patch))]), 'photosyns_vars__cp_patch', timestep)
     if(verbose) print *, 'photosyns_vars__kc_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%kc_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%kc_patch, [product(shape(photosyns_vars%kc_patch))]), 'photosyns_vars__kc_patch', timestep)
     if(verbose) print *, 'photosyns_vars__ko_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%ko_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%ko_patch, [product(shape(photosyns_vars%ko_patch))]), 'photosyns_vars__ko_patch', timestep)
     if(verbose) print *, 'photosyns_vars__qe_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%qe_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%qe_patch, [product(shape(photosyns_vars%qe_patch))]), 'photosyns_vars__qe_patch', timestep)
     if(verbose) print *, 'photosyns_vars__tpu_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%tpu_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%tpu_z_patch, [product(shape(photosyns_vars%tpu_z_patch))]), 'photosyns_vars__tpu_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__kp_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%kp_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%kp_z_patch, [product(shape(photosyns_vars%kp_z_patch))]), 'photosyns_vars__kp_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__theta_cj_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%theta_cj_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%theta_cj_patch, [product(shape(photosyns_vars%theta_cj_patch))]), 'photosyns_vars__theta_cj_patch', timestep)
     if(verbose) print *, 'photosyns_vars__bbb_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%bbb_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%bbb_patch, [product(shape(photosyns_vars%bbb_patch))]), 'photosyns_vars__bbb_patch', timestep)
     if(verbose) print *, 'photosyns_vars__mbb_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%mbb_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%mbb_patch, [product(shape(photosyns_vars%mbb_patch))]), 'photosyns_vars__mbb_patch', timestep)
     if(verbose) print *, 'photosyns_vars__gs_mol_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%gs_mol_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%gs_mol_patch, [product(shape(photosyns_vars%gs_mol_patch))]), 'photosyns_vars__gs_mol_patch', timestep)
     if(verbose) print *, 'photosyns_vars__gb_mol_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%gb_mol_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%gb_mol_patch, [product(shape(photosyns_vars%gb_mol_patch))]), 'photosyns_vars__gb_mol_patch', timestep)
     if(verbose) print *, 'photosyns_vars__rh_leaf_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%rh_leaf_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%rh_leaf_patch, [product(shape(photosyns_vars%rh_leaf_patch))]), 'photosyns_vars__rh_leaf_patch', timestep)
     if(verbose) print *, 'photosyns_vars__alphapsnsun_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%alphapsnsun_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%alphapsnsun_patch, [product(shape(photosyns_vars%alphapsnsun_patch))]), 'photosyns_vars__alphapsnsun_patch', timestep)
     if(verbose) print *, 'photosyns_vars__alphapsnsha_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%alphapsnsha_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%alphapsnsha_patch, [product(shape(photosyns_vars%alphapsnsha_patch))]), 'photosyns_vars__alphapsnsha_patch', timestep)
     if(verbose) print *, 'photosyns_vars__rc13_canair_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%rc13_canair_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%rc13_canair_patch, [product(shape(photosyns_vars%rc13_canair_patch))]), 'photosyns_vars__rc13_canair_patch', timestep)
     if(verbose) print *, 'photosyns_vars__rc13_psnsun_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%rc13_psnsun_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%rc13_psnsun_patch, [product(shape(photosyns_vars%rc13_psnsun_patch))]), 'photosyns_vars__rc13_psnsun_patch', timestep)
     if(verbose) print *, 'photosyns_vars__rc13_psnsha_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%rc13_psnsha_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%rc13_psnsha_patch, [product(shape(photosyns_vars%rc13_psnsha_patch))]), 'photosyns_vars__rc13_psnsha_patch', timestep)
     if(verbose) print *, 'photosyns_vars__psnsun_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%psnsun_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%psnsun_patch, [product(shape(photosyns_vars%psnsun_patch))]), 'photosyns_vars__psnsun_patch', timestep)
     if(verbose) print *, 'photosyns_vars__psnsha_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%psnsha_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%psnsha_patch, [product(shape(photosyns_vars%psnsha_patch))]), 'photosyns_vars__psnsha_patch', timestep)
     if(verbose) print *, 'photosyns_vars__c13_psnsun_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%c13_psnsun_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%c13_psnsun_patch, [product(shape(photosyns_vars%c13_psnsun_patch))]), 'photosyns_vars__c13_psnsun_patch', timestep)
     if(verbose) print *, 'photosyns_vars__c13_psnsha_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%c13_psnsha_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%c13_psnsha_patch, [product(shape(photosyns_vars%c13_psnsha_patch))]), 'photosyns_vars__c13_psnsha_patch', timestep)
     if(verbose) print *, 'photosyns_vars__c14_psnsun_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%c14_psnsun_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%c14_psnsun_patch, [product(shape(photosyns_vars%c14_psnsun_patch))]), 'photosyns_vars__c14_psnsun_patch', timestep)
     if(verbose) print *, 'photosyns_vars__c14_psnsha_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%c14_psnsha_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%c14_psnsha_patch, [product(shape(photosyns_vars%c14_psnsha_patch))]), 'photosyns_vars__c14_psnsha_patch', timestep)
     if(verbose) print *, 'photosyns_vars__psnsun_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%psnsun_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%psnsun_z_patch, [product(shape(photosyns_vars%psnsun_z_patch))]), 'photosyns_vars__psnsun_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__psnsha_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%psnsha_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%psnsha_z_patch, [product(shape(photosyns_vars%psnsha_z_patch))]), 'photosyns_vars__psnsha_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__psnsun_wc_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%psnsun_wc_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%psnsun_wc_patch, [product(shape(photosyns_vars%psnsun_wc_patch))]), 'photosyns_vars__psnsun_wc_patch', timestep)
     if(verbose) print *, 'photosyns_vars__psnsha_wc_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%psnsha_wc_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%psnsha_wc_patch, [product(shape(photosyns_vars%psnsha_wc_patch))]), 'photosyns_vars__psnsha_wc_patch', timestep)
     if(verbose) print *, 'photosyns_vars__psnsun_wj_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%psnsun_wj_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%psnsun_wj_patch, [product(shape(photosyns_vars%psnsun_wj_patch))]), 'photosyns_vars__psnsun_wj_patch', timestep)
     if(verbose) print *, 'photosyns_vars__psnsha_wj_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%psnsha_wj_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%psnsha_wj_patch, [product(shape(photosyns_vars%psnsha_wj_patch))]), 'photosyns_vars__psnsha_wj_patch', timestep)
     if(verbose) print *, 'photosyns_vars__psnsun_wp_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%psnsun_wp_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%psnsun_wp_patch, [product(shape(photosyns_vars%psnsun_wp_patch))]), 'photosyns_vars__psnsun_wp_patch', timestep)
     if(verbose) print *, 'photosyns_vars__psnsha_wp_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%psnsha_wp_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%psnsha_wp_patch, [product(shape(photosyns_vars%psnsha_wp_patch))]), 'photosyns_vars__psnsha_wp_patch', timestep)
     if(verbose) print *, 'photosyns_vars__fpsn_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%fpsn_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%fpsn_patch, [product(shape(photosyns_vars%fpsn_patch))]), 'photosyns_vars__fpsn_patch', timestep)
     if(verbose) print *, 'photosyns_vars__fpsn_wc_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%fpsn_wc_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%fpsn_wc_patch, [product(shape(photosyns_vars%fpsn_wc_patch))]), 'photosyns_vars__fpsn_wc_patch', timestep)
     if(verbose) print *, 'photosyns_vars__fpsn_wj_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%fpsn_wj_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%fpsn_wj_patch, [product(shape(photosyns_vars%fpsn_wj_patch))]), 'photosyns_vars__fpsn_wj_patch', timestep)
     if(verbose) print *, 'photosyns_vars__fpsn_wp_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%fpsn_wp_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%fpsn_wp_patch, [product(shape(photosyns_vars%fpsn_wp_patch))]), 'photosyns_vars__fpsn_wp_patch', timestep)
     if(verbose) print *, 'photosyns_vars__lmrsun_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%lmrsun_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%lmrsun_patch, [product(shape(photosyns_vars%lmrsun_patch))]), 'photosyns_vars__lmrsun_patch', timestep)
     if(verbose) print *, 'photosyns_vars__lmrsha_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%lmrsha_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%lmrsha_patch, [product(shape(photosyns_vars%lmrsha_patch))]), 'photosyns_vars__lmrsha_patch', timestep)
     if(verbose) print *, 'photosyns_vars__lmrsun_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%lmrsun_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%lmrsun_z_patch, [product(shape(photosyns_vars%lmrsun_z_patch))]), 'photosyns_vars__lmrsun_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__lmrsha_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%lmrsha_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%lmrsha_z_patch, [product(shape(photosyns_vars%lmrsha_z_patch))]), 'photosyns_vars__lmrsha_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__cisun_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%cisun_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%cisun_z_patch, [product(shape(photosyns_vars%cisun_z_patch))]), 'photosyns_vars__cisun_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__cisha_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%cisha_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%cisha_z_patch, [product(shape(photosyns_vars%cisha_z_patch))]), 'photosyns_vars__cisha_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__rssun_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%rssun_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%rssun_z_patch, [product(shape(photosyns_vars%rssun_z_patch))]), 'photosyns_vars__rssun_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__rssha_z_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%rssha_z_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%rssha_z_patch, [product(shape(photosyns_vars%rssha_z_patch))]), 'photosyns_vars__rssha_z_patch', timestep)
     if(verbose) print *, 'photosyns_vars__rssun_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%rssun_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%rssun_patch, [product(shape(photosyns_vars%rssun_patch))]), 'photosyns_vars__rssun_patch', timestep)
     if(verbose) print *, 'photosyns_vars__rssha_patch'
    call nc_write_var_array(ncid,1, shape(photosyns_vars%rssha_patch), [character(len=32) :: 'patch'], reshape(photosyns_vars%rssha_patch, [product(shape(photosyns_vars%rssha_patch))]), 'photosyns_vars__rssha_patch', timestep)
     if(verbose) print *, 'photosyns_vars__ac_phs_patch'
    call nc_write_var_array(ncid,3, shape(photosyns_vars%ac_phs_patch), [character(len=32) :: 'patch','_2','_1_nlevcan'], reshape(photosyns_vars%ac_phs_patch, [product(shape(photosyns_vars%ac_phs_patch))]), 'photosyns_vars__ac_phs_patch', timestep)
     if(verbose) print *, 'photosyns_vars__aj_phs_patch'
    call nc_write_var_array(ncid,3, shape(photosyns_vars%aj_phs_patch), [character(len=32) :: 'patch','_2','_1_nlevcan'], reshape(photosyns_vars%aj_phs_patch, [product(shape(photosyns_vars%aj_phs_patch))]), 'photosyns_vars__aj_phs_patch', timestep)
     if(verbose) print *, 'photosyns_vars__ap_phs_patch'
    call nc_write_var_array(ncid,3, shape(photosyns_vars%ap_phs_patch), [character(len=32) :: 'patch','_2','_1_nlevcan'], reshape(photosyns_vars%ap_phs_patch, [product(shape(photosyns_vars%ap_phs_patch))]), 'photosyns_vars__ap_phs_patch', timestep)
     if(verbose) print *, 'photosyns_vars__ag_phs_patch'
    call nc_write_var_array(ncid,3, shape(photosyns_vars%ag_phs_patch), [character(len=32) :: 'patch','_2','_1_nlevcan'], reshape(photosyns_vars%ag_phs_patch, [product(shape(photosyns_vars%ag_phs_patch))]), 'photosyns_vars__ag_phs_patch', timestep)
     if(verbose) print *, 'photosyns_vars__an_sun_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%an_sun_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%an_sun_patch, [product(shape(photosyns_vars%an_sun_patch))]), 'photosyns_vars__an_sun_patch', timestep)
     if(verbose) print *, 'photosyns_vars__an_sha_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%an_sha_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%an_sha_patch, [product(shape(photosyns_vars%an_sha_patch))]), 'photosyns_vars__an_sha_patch', timestep)
     if(verbose) print *, 'photosyns_vars__vcmax_z_phs_patch'
    call nc_write_var_array(ncid,3, shape(photosyns_vars%vcmax_z_phs_patch), [character(len=32) :: 'patch','_2','_1_nlevcan'], reshape(photosyns_vars%vcmax_z_phs_patch, [product(shape(photosyns_vars%vcmax_z_phs_patch))]), 'photosyns_vars__vcmax_z_phs_patch', timestep)
     if(verbose) print *, 'photosyns_vars__kp_z_phs_patch'
    call nc_write_var_array(ncid,3, shape(photosyns_vars%kp_z_phs_patch), [character(len=32) :: 'patch','_2','_1_nlevcan'], reshape(photosyns_vars%kp_z_phs_patch, [product(shape(photosyns_vars%kp_z_phs_patch))]), 'photosyns_vars__kp_z_phs_patch', timestep)
     if(verbose) print *, 'photosyns_vars__tpu_z_phs_patch'
    call nc_write_var_array(ncid,3, shape(photosyns_vars%tpu_z_phs_patch), [character(len=32) :: 'patch','_2','_1_nlevcan'], reshape(photosyns_vars%tpu_z_phs_patch, [product(shape(photosyns_vars%tpu_z_phs_patch))]), 'photosyns_vars__tpu_z_phs_patch', timestep)
     if(verbose) print *, 'photosyns_vars__gs_mol_sun_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%gs_mol_sun_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%gs_mol_sun_patch, [product(shape(photosyns_vars%gs_mol_sun_patch))]), 'photosyns_vars__gs_mol_sun_patch', timestep)
     if(verbose) print *, 'photosyns_vars__gs_mol_sha_patch'
    call nc_write_var_array(ncid,2, shape(photosyns_vars%gs_mol_sha_patch), [character(len=32) :: 'patch','_1_nlevcan'], reshape(photosyns_vars%gs_mol_sha_patch, [product(shape(photosyns_vars%gs_mol_sha_patch))]), 'photosyns_vars__gs_mol_sha_patch', timestep)
     if(verbose) print *, 'grc_pp__londeg'
    call nc_write_var_array(ncid,1, shape(grc_pp%londeg), [character(len=32) :: 'gridcell'], reshape(grc_pp%londeg, [product(shape(grc_pp%londeg))]), 'grc_pp__londeg', timestep)
     if(verbose) print *, 'grc_pp__slope_deg'
    call nc_write_var_array(ncid,1, shape(grc_pp%slope_deg), [character(len=32) :: 'gridcell'], reshape(grc_pp%slope_deg, [product(shape(grc_pp%slope_deg))]), 'grc_pp__slope_deg', timestep)
     if(verbose) print *, 'grc_pp__max_dayl'
    call nc_write_var_array(ncid,1, shape(grc_pp%max_dayl), [character(len=32) :: 'gridcell'], reshape(grc_pp%max_dayl, [product(shape(grc_pp%max_dayl))]), 'grc_pp__max_dayl', timestep)
     if(verbose) print *, 'grc_pp__dayl'
    call nc_write_var_array(ncid,1, shape(grc_pp%dayl), [character(len=32) :: 'gridcell'], reshape(grc_pp%dayl, [product(shape(grc_pp%dayl))]), 'grc_pp__dayl', timestep)
     if(verbose) print *, 'top_as__tbot'
    call nc_write_var_array(ncid,1, shape(top_as%tbot), [character(len=32) :: 'topo'], reshape(top_as%tbot, [product(shape(top_as%tbot))]), 'top_as__tbot', timestep)
     if(verbose) print *, 'top_as__thbot'
    call nc_write_var_array(ncid,1, shape(top_as%thbot), [character(len=32) :: 'topo'], reshape(top_as%thbot, [product(shape(top_as%thbot))]), 'top_as__thbot', timestep)
     if(verbose) print *, 'top_as__pbot'
    call nc_write_var_array(ncid,1, shape(top_as%pbot), [character(len=32) :: 'topo'], reshape(top_as%pbot, [product(shape(top_as%pbot))]), 'top_as__pbot', timestep)
     if(verbose) print *, 'top_as__rhobot'
    call nc_write_var_array(ncid,1, shape(top_as%rhobot), [character(len=32) :: 'topo'], reshape(top_as%rhobot, [product(shape(top_as%rhobot))]), 'top_as__rhobot', timestep)
     if(verbose) print *, 'top_as__qbot'
    call nc_write_var_array(ncid,1, shape(top_as%qbot), [character(len=32) :: 'topo'], reshape(top_as%qbot, [product(shape(top_as%qbot))]), 'top_as__qbot', timestep)
     if(verbose) print *, 'top_as__ubot'
    call nc_write_var_array(ncid,1, shape(top_as%ubot), [character(len=32) :: 'topo'], reshape(top_as%ubot, [product(shape(top_as%ubot))]), 'top_as__ubot', timestep)
     if(verbose) print *, 'top_as__vbot'
    call nc_write_var_array(ncid,1, shape(top_as%vbot), [character(len=32) :: 'topo'], reshape(top_as%vbot, [product(shape(top_as%vbot))]), 'top_as__vbot', timestep)
     if(verbose) print *, 'top_as__wsresp'
    call nc_write_var_array(ncid,1, shape(top_as%wsresp), [character(len=32) :: 'topo'], reshape(top_as%wsresp, [product(shape(top_as%wsresp))]), 'top_as__wsresp', timestep)
     if(verbose) print *, 'top_as__tau_est'
    call nc_write_var_array(ncid,1, shape(top_as%tau_est), [character(len=32) :: 'topo'], reshape(top_as%tau_est, [product(shape(top_as%tau_est))]), 'top_as__tau_est', timestep)
     if(verbose) print *, 'top_as__ugust'
    call nc_write_var_array(ncid,1, shape(top_as%ugust), [character(len=32) :: 'topo'], reshape(top_as%ugust, [product(shape(top_as%ugust))]), 'top_as__ugust', timestep)
     if(verbose) print *, 'top_as__po2bot'
    call nc_write_var_array(ncid,1, shape(top_as%po2bot), [character(len=32) :: 'topo'], reshape(top_as%po2bot, [product(shape(top_as%po2bot))]), 'top_as__po2bot', timestep)
     if(verbose) print *, 'top_as__pco2bot'
    call nc_write_var_array(ncid,1, shape(top_as%pco2bot), [character(len=32) :: 'topo'], reshape(top_as%pco2bot, [product(shape(top_as%pco2bot))]), 'top_as__pco2bot', timestep)
     if(verbose) print *, 'top_as__pc13o2bot'
    call nc_write_var_array(ncid,1, shape(top_as%pc13o2bot), [character(len=32) :: 'topo'], reshape(top_as%pc13o2bot, [product(shape(top_as%pc13o2bot))]), 'top_as__pc13o2bot', timestep)
     if(verbose) print *, 'top_af__lwrad'
    call nc_write_var_array(ncid,1, shape(top_af%lwrad), [character(len=32) :: 'topo'], reshape(top_af%lwrad, [product(shape(top_af%lwrad))]), 'top_af__lwrad', timestep)
     if(verbose) print *, 'col_pp__gridcell'
    call nc_write_var_array(ncid,1, shape(col_pp%gridcell), [character(len=32) :: 'column'], reshape(col_pp%gridcell, [product(shape(col_pp%gridcell))]), 'col_pp__gridcell', timestep)
     if(verbose) print *, 'col_pp__topounit'
    call nc_write_var_array(ncid,1, shape(col_pp%topounit), [character(len=32) :: 'column'], reshape(col_pp%topounit, [product(shape(col_pp%topounit))]), 'col_pp__topounit', timestep)
     if(verbose) print *, 'col_pp__landunit'
    call nc_write_var_array(ncid,1, shape(col_pp%landunit), [character(len=32) :: 'column'], reshape(col_pp%landunit, [product(shape(col_pp%landunit))]), 'col_pp__landunit', timestep)
     if(verbose) print *, 'col_pp__itype'
    call nc_write_var_array(ncid,1, shape(col_pp%itype), [character(len=32) :: 'column'], reshape(col_pp%itype, [product(shape(col_pp%itype))]), 'col_pp__itype', timestep)
     if(verbose) print *, 'col_pp__active'
    call nc_write_var_array(ncid,1, shape(col_pp%active), [character(len=32) :: 'column'], reshape(col_pp%active, [product(shape(col_pp%active))]), 'col_pp__active', timestep)
     if(verbose) print *, 'col_pp__snl'
    call nc_write_var_array(ncid,1, shape(col_pp%snl), [character(len=32) :: 'column'], reshape(col_pp%snl, [product(shape(col_pp%snl))]), 'col_pp__snl', timestep)
     if(verbose) print *, 'col_pp__dz'
    call nc_write_var_array(ncid,2, shape(col_pp%dz), [character(len=32) :: 'column','_nlevsno_1_nlevgrnd'], reshape(col_pp%dz, [product(shape(col_pp%dz))]), 'col_pp__dz', timestep)
     if(verbose) print *, 'col_pp__z'
    call nc_write_var_array(ncid,2, shape(col_pp%z), [character(len=32) :: 'column','_nlevsno_1_nlevgrnd'], reshape(col_pp%z, [product(shape(col_pp%z))]), 'col_pp__z', timestep)
     if(verbose) print *, 'col_pp__is_soil'
    call nc_write_var_array(ncid,1, shape(col_pp%is_soil), [character(len=32) :: 'column'], reshape(col_pp%is_soil, [product(shape(col_pp%is_soil))]), 'col_pp__is_soil', timestep)
     if(verbose) print *, 'col_pp__is_crop'
    call nc_write_var_array(ncid,1, shape(col_pp%is_crop), [character(len=32) :: 'column'], reshape(col_pp%is_crop, [product(shape(col_pp%is_crop))]), 'col_pp__is_crop', timestep)
     if(verbose) print *, 'col_es__t_soisno'
    call nc_write_var_array(ncid,2, shape(col_es%t_soisno), [character(len=32) :: 'column','_nlevsno_1_nlevgrnd'], reshape(col_es%t_soisno, [product(shape(col_es%t_soisno))]), 'col_es__t_soisno', timestep)
     if(verbose) print *, 'col_es__t_h2osfc'
    call nc_write_var_array(ncid,1, shape(col_es%t_h2osfc), [character(len=32) :: 'column'], reshape(col_es%t_h2osfc, [product(shape(col_es%t_h2osfc))]), 'col_es__t_h2osfc', timestep)
     if(verbose) print *, 'col_es__t_grnd'
    call nc_write_var_array(ncid,1, shape(col_es%t_grnd), [character(len=32) :: 'column'], reshape(col_es%t_grnd, [product(shape(col_es%t_grnd))]), 'col_es__t_grnd', timestep)
     if(verbose) print *, 'col_es__thv'
    call nc_write_var_array(ncid,1, shape(col_es%thv), [character(len=32) :: 'column'], reshape(col_es%thv, [product(shape(col_es%thv))]), 'col_es__thv', timestep)
     if(verbose) print *, 'col_es__emg'
    call nc_write_var_array(ncid,1, shape(col_es%emg), [character(len=32) :: 'column'], reshape(col_es%emg, [product(shape(col_es%emg))]), 'col_es__emg', timestep)
     if(verbose) print *, 'col_ws__h2osoi_liq'
    call nc_write_var_array(ncid,2, shape(col_ws%h2osoi_liq), [character(len=32) :: 'column','_nlevsno_1_nlevgrnd'], reshape(col_ws%h2osoi_liq, [product(shape(col_ws%h2osoi_liq))]), 'col_ws__h2osoi_liq', timestep)
     if(verbose) print *, 'col_ws__h2osoi_ice'
    call nc_write_var_array(ncid,2, shape(col_ws%h2osoi_ice), [character(len=32) :: 'column','_nlevsno_1_nlevgrnd'], reshape(col_ws%h2osoi_ice, [product(shape(col_ws%h2osoi_ice))]), 'col_ws__h2osoi_ice', timestep)
     if(verbose) print *, 'col_ws__h2osoi_vol'
    call nc_write_var_array(ncid,2, shape(col_ws%h2osoi_vol), [character(len=32) :: 'column','_1_nlevgrnd'], reshape(col_ws%h2osoi_vol, [product(shape(col_ws%h2osoi_vol))]), 'col_ws__h2osoi_vol', timestep)
     if(verbose) print *, 'col_ws__h2osoi_liqvol'
    call nc_write_var_array(ncid,2, shape(col_ws%h2osoi_liqvol), [character(len=32) :: 'column','_nlevsno_1_nlevgrnd'], reshape(col_ws%h2osoi_liqvol, [product(shape(col_ws%h2osoi_liqvol))]), 'col_ws__h2osoi_liqvol', timestep)
     if(verbose) print *, 'col_ws__qg_snow'
    call nc_write_var_array(ncid,1, shape(col_ws%qg_snow), [character(len=32) :: 'column'], reshape(col_ws%qg_snow, [product(shape(col_ws%qg_snow))]), 'col_ws__qg_snow', timestep)
     if(verbose) print *, 'col_ws__qg_soil'
    call nc_write_var_array(ncid,1, shape(col_ws%qg_soil), [character(len=32) :: 'column'], reshape(col_ws%qg_soil, [product(shape(col_ws%qg_soil))]), 'col_ws__qg_soil', timestep)
     if(verbose) print *, 'col_ws__qg_h2osfc'
    call nc_write_var_array(ncid,1, shape(col_ws%qg_h2osfc), [character(len=32) :: 'column'], reshape(col_ws%qg_h2osfc, [product(shape(col_ws%qg_h2osfc))]), 'col_ws__qg_h2osfc', timestep)
     if(verbose) print *, 'col_ws__qg'
    call nc_write_var_array(ncid,1, shape(col_ws%qg), [character(len=32) :: 'column'], reshape(col_ws%qg, [product(shape(col_ws%qg))]), 'col_ws__qg', timestep)
     if(verbose) print *, 'col_ws__dqgdt'
    call nc_write_var_array(ncid,1, shape(col_ws%dqgdt), [character(len=32) :: 'column'], reshape(col_ws%dqgdt, [product(shape(col_ws%dqgdt))]), 'col_ws__dqgdt', timestep)
     if(verbose) print *, 'col_ws__snow_depth'
    call nc_write_var_array(ncid,1, shape(col_ws%snow_depth), [character(len=32) :: 'column'], reshape(col_ws%snow_depth, [product(shape(col_ws%snow_depth))]), 'col_ws__snow_depth', timestep)
     if(verbose) print *, 'col_ws__frac_sno_eff'
    call nc_write_var_array(ncid,1, shape(col_ws%frac_sno_eff), [character(len=32) :: 'column'], reshape(col_ws%frac_sno_eff, [product(shape(col_ws%frac_sno_eff))]), 'col_ws__frac_sno_eff', timestep)
     if(verbose) print *, 'col_ws__frac_h2osfc'
    call nc_write_var_array(ncid,1, shape(col_ws%frac_h2osfc), [character(len=32) :: 'column'], reshape(col_ws%frac_h2osfc, [product(shape(col_ws%frac_h2osfc))]), 'col_ws__frac_h2osfc', timestep)
     if(verbose) print *, 'col_ef__htvp'
    call nc_write_var_array(ncid,1, shape(col_ef%htvp), [character(len=32) :: 'column'], reshape(col_ef%htvp, [product(shape(col_ef%htvp))]), 'col_ef__htvp', timestep)
     if(verbose) print *, 'veg_pp__gridcell'
    call nc_write_var_array(ncid,1, shape(veg_pp%gridcell), [character(len=32) :: 'patch'], reshape(veg_pp%gridcell, [product(shape(veg_pp%gridcell))]), 'veg_pp__gridcell', timestep)
     if(verbose) print *, 'veg_pp__topounit'
    call nc_write_var_array(ncid,1, shape(veg_pp%topounit), [character(len=32) :: 'patch'], reshape(veg_pp%topounit, [product(shape(veg_pp%topounit))]), 'veg_pp__topounit', timestep)
     if(verbose) print *, 'veg_pp__landunit'
    call nc_write_var_array(ncid,1, shape(veg_pp%landunit), [character(len=32) :: 'patch'], reshape(veg_pp%landunit, [product(shape(veg_pp%landunit))]), 'veg_pp__landunit', timestep)
     if(verbose) print *, 'veg_pp__column'
    call nc_write_var_array(ncid,1, shape(veg_pp%column), [character(len=32) :: 'patch'], reshape(veg_pp%column, [product(shape(veg_pp%column))]), 'veg_pp__column', timestep)
     if(verbose) print *, 'veg_pp__itype'
    call nc_write_var_array(ncid,1, shape(veg_pp%itype), [character(len=32) :: 'patch'], reshape(veg_pp%itype, [product(shape(veg_pp%itype))]), 'veg_pp__itype', timestep)
     if(verbose) print *, 'veg_pp__active'
    call nc_write_var_array(ncid,1, shape(veg_pp%active), [character(len=32) :: 'patch'], reshape(veg_pp%active, [product(shape(veg_pp%active))]), 'veg_pp__active', timestep)
     if(verbose) print *, 'veg_pp__is_on_soil_col'
    call nc_write_var_array(ncid,1, shape(veg_pp%is_on_soil_col), [character(len=32) :: 'patch'], reshape(veg_pp%is_on_soil_col, [product(shape(veg_pp%is_on_soil_col))]), 'veg_pp__is_on_soil_col', timestep)
     if(verbose) print *, 'veg_pp__is_on_crop_col'
    call nc_write_var_array(ncid,1, shape(veg_pp%is_on_crop_col), [character(len=32) :: 'patch'], reshape(veg_pp%is_on_crop_col, [product(shape(veg_pp%is_on_crop_col))]), 'veg_pp__is_on_crop_col', timestep)
     if(verbose) print *, 'veg_pp__is_fates'
    call nc_write_var_array(ncid,1, shape(veg_pp%is_fates), [character(len=32) :: 'patch'], reshape(veg_pp%is_fates, [product(shape(veg_pp%is_fates))]), 'veg_pp__is_fates', timestep)
     if(verbose) print *, 'veg_es__t_veg'
    call nc_write_var_array(ncid,1, shape(veg_es%t_veg), [character(len=32) :: 'patch'], reshape(veg_es%t_veg, [product(shape(veg_es%t_veg))]), 'veg_es__t_veg', timestep)
     if(verbose) print *, 'veg_es__t_ref2m'
    call nc_write_var_array(ncid,1, shape(veg_es%t_ref2m), [character(len=32) :: 'patch'], reshape(veg_es%t_ref2m, [product(shape(veg_es%t_ref2m))]), 'veg_es__t_ref2m', timestep)
     if(verbose) print *, 'veg_es__t_ref2m_r'
    call nc_write_var_array(ncid,1, shape(veg_es%t_ref2m_r), [character(len=32) :: 'patch'], reshape(veg_es%t_ref2m_r, [product(shape(veg_es%t_ref2m_r))]), 'veg_es__t_ref2m_r', timestep)
     if(verbose) print *, 'veg_es__t_a10'
    call nc_write_var_array(ncid,1, shape(veg_es%t_a10), [character(len=32) :: 'patch'], reshape(veg_es%t_a10, [product(shape(veg_es%t_a10))]), 'veg_es__t_a10', timestep)
     if(verbose) print *, 'veg_es__thm'
    call nc_write_var_array(ncid,1, shape(veg_es%thm), [character(len=32) :: 'patch'], reshape(veg_es%thm, [product(shape(veg_es%thm))]), 'veg_es__thm', timestep)
     if(verbose) print *, 'veg_es__emv'
    call nc_write_var_array(ncid,1, shape(veg_es%emv), [character(len=32) :: 'patch'], reshape(veg_es%emv, [product(shape(veg_es%emv))]), 'veg_es__emv', timestep)
     if(verbose) print *, 'veg_ws__h2ocan'
    call nc_write_var_array(ncid,1, shape(veg_ws%h2ocan), [character(len=32) :: 'patch'], reshape(veg_ws%h2ocan, [product(shape(veg_ws%h2ocan))]), 'veg_ws__h2ocan', timestep)
     if(verbose) print *, 'veg_ws__q_ref2m'
    call nc_write_var_array(ncid,1, shape(veg_ws%q_ref2m), [character(len=32) :: 'patch'], reshape(veg_ws%q_ref2m, [product(shape(veg_ws%q_ref2m))]), 'veg_ws__q_ref2m', timestep)
     if(verbose) print *, 'veg_ws__rh_ref2m'
    call nc_write_var_array(ncid,1, shape(veg_ws%rh_ref2m), [character(len=32) :: 'patch'], reshape(veg_ws%rh_ref2m, [product(shape(veg_ws%rh_ref2m))]), 'veg_ws__rh_ref2m', timestep)
     if(verbose) print *, 'veg_ws__rh_ref2m_r'
    call nc_write_var_array(ncid,1, shape(veg_ws%rh_ref2m_r), [character(len=32) :: 'patch'], reshape(veg_ws%rh_ref2m_r, [product(shape(veg_ws%rh_ref2m_r))]), 'veg_ws__rh_ref2m_r', timestep)
     if(verbose) print *, 'veg_ws__rh_af'
    call nc_write_var_array(ncid,1, shape(veg_ws%rh_af), [character(len=32) :: 'patch'], reshape(veg_ws%rh_af, [product(shape(veg_ws%rh_af))]), 'veg_ws__rh_af', timestep)
     if(verbose) print *, 'veg_ws__fwet'
    call nc_write_var_array(ncid,1, shape(veg_ws%fwet), [character(len=32) :: 'patch'], reshape(veg_ws%fwet, [product(shape(veg_ws%fwet))]), 'veg_ws__fwet', timestep)
     if(verbose) print *, 'veg_ws__fdry'
    call nc_write_var_array(ncid,1, shape(veg_ws%fdry), [character(len=32) :: 'patch'], reshape(veg_ws%fdry, [product(shape(veg_ws%fdry))]), 'veg_ws__fdry', timestep)
     if(verbose) print *, 'veg_ns__leafn'
    call nc_write_var_array(ncid,1, shape(veg_ns%leafn), [character(len=32) :: 'patch'], reshape(veg_ns%leafn, [product(shape(veg_ns%leafn))]), 'veg_ns__leafn', timestep)
     if(verbose) print *, 'veg_ps__leafp'
    call nc_write_var_array(ncid,1, shape(veg_ps%leafp), [character(len=32) :: 'patch'], reshape(veg_ps%leafp, [product(shape(veg_ps%leafp))]), 'veg_ps__leafp', timestep)
     if(verbose) print *, 'veg_ef__eflx_sh_grnd'
    call nc_write_var_array(ncid,1, shape(veg_ef%eflx_sh_grnd), [character(len=32) :: 'patch'], reshape(veg_ef%eflx_sh_grnd, [product(shape(veg_ef%eflx_sh_grnd))]), 'veg_ef__eflx_sh_grnd', timestep)
     if(verbose) print *, 'veg_ef__eflx_sh_veg'
    call nc_write_var_array(ncid,1, shape(veg_ef%eflx_sh_veg), [character(len=32) :: 'patch'], reshape(veg_ef%eflx_sh_veg, [product(shape(veg_ef%eflx_sh_veg))]), 'veg_ef__eflx_sh_veg', timestep)
     if(verbose) print *, 'veg_ef__eflx_sh_snow'
    call nc_write_var_array(ncid,1, shape(veg_ef%eflx_sh_snow), [character(len=32) :: 'patch'], reshape(veg_ef%eflx_sh_snow, [product(shape(veg_ef%eflx_sh_snow))]), 'veg_ef__eflx_sh_snow', timestep)
     if(verbose) print *, 'veg_ef__eflx_sh_soil'
    call nc_write_var_array(ncid,1, shape(veg_ef%eflx_sh_soil), [character(len=32) :: 'patch'], reshape(veg_ef%eflx_sh_soil, [product(shape(veg_ef%eflx_sh_soil))]), 'veg_ef__eflx_sh_soil', timestep)
     if(verbose) print *, 'veg_ef__eflx_sh_h2osfc'
    call nc_write_var_array(ncid,1, shape(veg_ef%eflx_sh_h2osfc), [character(len=32) :: 'patch'], reshape(veg_ef%eflx_sh_h2osfc, [product(shape(veg_ef%eflx_sh_h2osfc))]), 'veg_ef__eflx_sh_h2osfc', timestep)
     if(verbose) print *, 'veg_ef__dlrad'
    call nc_write_var_array(ncid,1, shape(veg_ef%dlrad), [character(len=32) :: 'patch'], reshape(veg_ef%dlrad, [product(shape(veg_ef%dlrad))]), 'veg_ef__dlrad', timestep)
     if(verbose) print *, 'veg_ef__ulrad'
    call nc_write_var_array(ncid,1, shape(veg_ef%ulrad), [character(len=32) :: 'patch'], reshape(veg_ef%ulrad, [product(shape(veg_ef%ulrad))]), 'veg_ef__ulrad', timestep)
     if(verbose) print *, 'veg_ef__taux'
    call nc_write_var_array(ncid,1, shape(veg_ef%taux), [character(len=32) :: 'patch'], reshape(veg_ef%taux, [product(shape(veg_ef%taux))]), 'veg_ef__taux', timestep)
     if(verbose) print *, 'veg_ef__tauy'
    call nc_write_var_array(ncid,1, shape(veg_ef%tauy), [character(len=32) :: 'patch'], reshape(veg_ef%tauy, [product(shape(veg_ef%tauy))]), 'veg_ef__tauy', timestep)
     if(verbose) print *, 'veg_ef__cgrnd'
    call nc_write_var_array(ncid,1, shape(veg_ef%cgrnd), [character(len=32) :: 'patch'], reshape(veg_ef%cgrnd, [product(shape(veg_ef%cgrnd))]), 'veg_ef__cgrnd', timestep)
     if(verbose) print *, 'veg_ef__cgrndl'
    call nc_write_var_array(ncid,1, shape(veg_ef%cgrndl), [character(len=32) :: 'patch'], reshape(veg_ef%cgrndl, [product(shape(veg_ef%cgrndl))]), 'veg_ef__cgrndl', timestep)
     if(verbose) print *, 'veg_ef__cgrnds'
    call nc_write_var_array(ncid,1, shape(veg_ef%cgrnds), [character(len=32) :: 'patch'], reshape(veg_ef%cgrnds, [product(shape(veg_ef%cgrnds))]), 'veg_ef__cgrnds', timestep)
     if(verbose) print *, 'veg_wf__qflx_evap_soi'
    call nc_write_var_array(ncid,1, shape(veg_wf%qflx_evap_soi), [character(len=32) :: 'patch'], reshape(veg_wf%qflx_evap_soi, [product(shape(veg_wf%qflx_evap_soi))]), 'veg_wf__qflx_evap_soi', timestep)
     if(verbose) print *, 'veg_wf__qflx_evap_veg'
    call nc_write_var_array(ncid,1, shape(veg_wf%qflx_evap_veg), [character(len=32) :: 'patch'], reshape(veg_wf%qflx_evap_veg, [product(shape(veg_wf%qflx_evap_veg))]), 'veg_wf__qflx_evap_veg', timestep)
     if(verbose) print *, 'veg_wf__qflx_tran_veg'
    call nc_write_var_array(ncid,1, shape(veg_wf%qflx_tran_veg), [character(len=32) :: 'patch'], reshape(veg_wf%qflx_tran_veg, [product(shape(veg_wf%qflx_tran_veg))]), 'veg_wf__qflx_tran_veg', timestep)
     if(verbose) print *, 'veg_wf__qflx_ev_snow'
    call nc_write_var_array(ncid,1, shape(veg_wf%qflx_ev_snow), [character(len=32) :: 'patch'], reshape(veg_wf%qflx_ev_snow, [product(shape(veg_wf%qflx_ev_snow))]), 'veg_wf__qflx_ev_snow', timestep)
     if(verbose) print *, 'veg_wf__qflx_ev_soil'
    call nc_write_var_array(ncid,1, shape(veg_wf%qflx_ev_soil), [character(len=32) :: 'patch'], reshape(veg_wf%qflx_ev_soil, [product(shape(veg_wf%qflx_ev_soil))]), 'veg_wf__qflx_ev_soil', timestep)
     if(verbose) print *, 'veg_wf__qflx_ev_h2osfc'
    call nc_write_var_array(ncid,1, shape(veg_wf%qflx_ev_h2osfc), [character(len=32) :: 'patch'], reshape(veg_wf%qflx_ev_h2osfc, [product(shape(veg_wf%qflx_ev_h2osfc))]), 'veg_wf__qflx_ev_h2osfc', timestep)
     if(verbose) print *, 'veg_wf__irrig_rate'
    call nc_write_var_array(ncid,1, shape(veg_wf%irrig_rate), [character(len=32) :: 'patch'], reshape(veg_wf%irrig_rate, [product(shape(veg_wf%irrig_rate))]), 'veg_wf__irrig_rate', timestep)
     if(verbose) print *, 'veg_wf__n_irrig_steps_left'
    call nc_write_var_array(ncid,1, shape(veg_wf%n_irrig_steps_left), [character(len=32) :: 'patch'], reshape(veg_wf%n_irrig_steps_left, [product(shape(veg_wf%n_irrig_steps_left))]), 'veg_wf__n_irrig_steps_left', timestep)
     if(verbose) print *, 'top_pp__topo_grc_ind'
    call nc_write_var_array(ncid,1, shape(top_pp%topo_grc_ind), [character(len=32) :: 'topo'], reshape(top_pp%topo_grc_ind, [product(shape(top_pp%topo_grc_ind))]), 'top_pp__topo_grc_ind', timestep)
     if(verbose) print *, 'top_pp__active'
    call nc_write_var_array(ncid,1, shape(top_pp%active), [character(len=32) :: 'topo'], reshape(top_pp%active, [product(shape(top_pp%active))]), 'top_pp__active', timestep)
    call check(nf90_close(ncid))
  end subroutine write_elmtypes
end module ReadWriteMod
