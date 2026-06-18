module FUTConstantsMod
  !!! Auto-generated Fortran code for netcdf-fortran I/O
  use netcdf
  use nc_io
  use nc_allocMod
  use elm_varcon, only : cpair
  use pftvarcon, only : vcmax_np4
  use pftvarcon, only : iscft
  use timeinfomod, only : secs_curr
  use elm_varctl, only : use_c14
  use elm_varcon, only : grav
  use allocationmod, only : nu_com_leaf_physiology
  use elm_varcon, only : sb
  use elm_varctl, only : use_finetop_rad
  use pftvarcon, only : jmax_np1
  use elm_varcon, only : rpi
  use frictionvelocitymod, only : atm_gustiness
  use pftvarcon, only : vcmax_np1
  use elm_varcon, only : tlsai_crit
  use pftvarcon, only : nfixer
  use elm_varctl, only : iulog
  use soilmoiststressmod, only : root_moist_stress_method
  use elm_varpar, only : nlevsoi
  use pftvarcon, only : vcmax_np3
  use pftvarcon, only : noveg
  use elm_varctl, only : use_fates
  use pftvarcon, only : percrop
  use pftvarcon, only : vcmax_np2
  use soilmoiststressmod, only : perchroot_alt
  use frictionvelocitymod, only : force_land_gustiness
  use elm_varpar, only : nlevgrnd
  use timeinfomod, only : nstep_mod
  use elm_varctl, only : use_c13
  use pftvarcon, only : jmax_np3
  use elm_varctl, only : carbonnitrogen_only
  use timeinfomod, only : dtime_mod
  use elm_varctl, only : use_cn
  use elm_varcon, only : rgas
  use elm_varcon, only : denh2o
  use pftvarcon, only : crop
  use elm_varcon, only : alpha_aero
  use soilmoiststressmod, only : perchroot
  use elm_varctl, only : carbon_only
  use pftvarcon, only : jmax_np2
  use pftvarcon, only : irrigated
  use elm_varcon, only : csoilc
  use elm_varctl, only : use_lch4
  use elm_varcon, only : vkc
  use elm_varcon, only : denice
  use elm_varsur, only : firrig
  use frictionvelocitymod, only : implicit_stress
  use elm_varcon, only : hvap
  use elm_varctl, only : use_hydrstress
  use elm_varctl, only : carbonphosphorus_only
  implicit none
  public :: read_constants, write_constants, define_vars
  logical, parameter :: verbose=.False.
contains
  subroutine define_vars(ncid)
    integer, intent(in) :: ncid
    integer :: varid, time_id
    character(len=32), dimension(5) :: dim_names
    dim_names(1:1) = [character(len=32) :: 'unk_0_percrop']
    call nc_define_var(ncid, 1, shape(percrop), dim_names, 'percrop', nf90_double, varid, .false.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(percrop))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(percrop)));
    dim_names(1:1) = [character(len=32) :: 'unk_0_crop']
    call nc_define_var(ncid, 1, shape(crop), dim_names, 'crop', nf90_double, varid, .false.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(crop))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(crop)));
    dim_names(1:1) = [character(len=32) :: 'unk_0_iscft']
    call nc_define_var(ncid, 1, shape(iscft), dim_names, 'iscft', nf90_int, varid, .false.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(iscft))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(iscft)));
    call nc_define_var(ncid, 0, [0], dim_names, 'dtime_mod', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'tlsai_crit', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'force_land_gustiness', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'denh2o', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'secs_curr', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'implicit_stress', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'cpair', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'sb', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'iulog', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'hvap', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'nlevgrnd', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'denice', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'alpha_aero', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'atm_gustiness', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'grav', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'perchroot_alt', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'use_finetop_rad', nf90_int, varid, .false.)
    dim_names(1:2) = [character(len=32) :: 'unk_0_firrig','unk_1_firrig']
    call nc_define_var(ncid, 2, shape(firrig), dim_names, 'firrig', nf90_double, varid, .false.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(firrig))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(firrig)));
    call nc_define_var(ncid, 0, [0], dim_names, 'use_c13', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'nstep_mod', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'csoilc', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'use_lch4', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'use_hydrstress', nf90_int, varid, .false.)
    dim_names(1:1) = [character(len=32) :: 'unk_0_nfixer']
    call nc_define_var(ncid, 1, shape(nfixer), dim_names, 'nfixer', nf90_double, varid, .false.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(nfixer))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(nfixer)));
    call nc_define_var(ncid, 0, [0], dim_names, 'perchroot', nf90_int, varid, .false.)
    dim_names(1:1) = [character(len=32) :: 'unk_0_irrigated']
    call nc_define_var(ncid, 1, shape(irrigated), dim_names, 'irrigated', nf90_double, varid, .false.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(irrigated))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(irrigated)));
    call nc_define_var(ncid, 0, [0], dim_names, 'vkc', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'use_fates', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'use_c14', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'root_moist_stress_method', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'carbonnitrogen_only', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'carbon_only', nf90_int, varid, .false.)
    dim_names(1:1) = [character(len=32) :: 'unk_0_vcmax_np2']
    call nc_define_var(ncid, 1, shape(vcmax_np2), dim_names, 'vcmax_np2', nf90_double, varid, .false.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(vcmax_np2))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(vcmax_np2)));
    call nc_define_var(ncid, 0, [0], dim_names, 'jmax_np1', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'jmax_np2', nf90_double, varid, .false.)
    dim_names(1:1) = [character(len=32) :: 'unk_0_vcmax_np4']
    call nc_define_var(ncid, 1, shape(vcmax_np4), dim_names, 'vcmax_np4', nf90_double, varid, .false.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(vcmax_np4))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(vcmax_np4)));
    call nc_define_var(ncid, 0, [0], dim_names, 'carbonphosphorus_only', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'use_cn', nf90_int, varid, .false.)
    dim_names(1:1) = [character(len=32) :: 'unk_0_vcmax_np3']
    call nc_define_var(ncid, 1, shape(vcmax_np3), dim_names, 'vcmax_np3', nf90_double, varid, .false.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(vcmax_np3))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(vcmax_np3)));
    dim_names(1:1) = [character(len=32) :: 'unk_0_vcmax_np1']
    call nc_define_var(ncid, 1, shape(vcmax_np1), dim_names, 'vcmax_np1', nf90_double, varid, .false.)
    call check(nf90_put_att(ncid, varid, 'lbounds', lbound(vcmax_np1))); call check(nf90_put_att(ncid, varid, 'ubounds', ubound(vcmax_np1)));
    call nc_define_var(ncid, 0, [0], dim_names, 'noveg', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'jmax_np3', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'nlevsoi', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'rpi', nf90_double, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'nu_com_leaf_physiology', nf90_int, varid, .false.)
    call nc_define_var(ncid, 0, [0], dim_names, 'rgas', nf90_double, varid, .false.)
  end subroutine define_vars
  subroutine read_constants(io_inst)
    type(spel_io_type), intent(inout) :: io_inst
    integer :: ncid, timestep
    character(len=256) :: new_fn
    new_fn = trim(io_inst%get_fn())
    if(io_inst%end_run) return
    timestep = io_inst%timestep
    ncid = nc_create_or_open_file(trim(new_fn), read_file)
    call nc_read_var(ncid, 'dtime_mod', dtime_mod, -1)
    call nc_read_var(ncid, 'tlsai_crit', tlsai_crit, -1)
    call nc_read_var(ncid, 'force_land_gustiness', force_land_gustiness, -1)
    call nc_read_var(ncid, 'denh2o', denh2o, -1)
    call nc_read_var(ncid, 'secs_curr', secs_curr, -1)
    call nc_read_var(ncid, 'implicit_stress', implicit_stress, -1)
    call nc_read_var(ncid, 'cpair', cpair, -1)
    call nc_read_var(ncid, 'sb', sb, -1)
    call nc_read_var(ncid, 'iulog', iulog, -1)
    call nc_read_var(ncid, 'hvap', hvap, -1)
    call nc_read_var(ncid, 'nlevgrnd', nlevgrnd, -1)
    call nc_read_var(ncid, 'denice', denice, -1)
    call nc_read_var(ncid, 'alpha_aero', alpha_aero, -1)
    call nc_read_var(ncid, 'atm_gustiness', atm_gustiness, -1)
    call nc_read_var(ncid, 'grav', grav, -1)
    call nc_read_var(ncid, 'perchroot_alt', perchroot_alt, -1)
    call nc_read_var(ncid, 'use_finetop_rad', use_finetop_rad, -1)
    call nc_read_var(ncid, 'use_c13', use_c13, -1)
    call nc_read_var(ncid, 'nstep_mod', nstep_mod, -1)
    call nc_read_var(ncid, 'csoilc', csoilc, -1)
    call nc_read_var(ncid, 'use_lch4', use_lch4, -1)
    call nc_read_var(ncid, 'use_hydrstress', use_hydrstress, -1)
    call nc_read_var(ncid, 'perchroot', perchroot, -1)
    call nc_read_var(ncid, 'vkc', vkc, -1)
    call nc_read_var(ncid, 'use_fates', use_fates, -1)
    call nc_read_var(ncid, 'use_c14', use_c14, -1)
    call nc_read_var(ncid, 'root_moist_stress_method', root_moist_stress_method, -1)
    call nc_read_var(ncid, 'carbonnitrogen_only', carbonnitrogen_only, -1)
    call nc_read_var(ncid, 'carbon_only', carbon_only, -1)
    call nc_read_var(ncid, 'jmax_np1', jmax_np1, -1)
    call nc_read_var(ncid, 'jmax_np2', jmax_np2, -1)
    call nc_read_var(ncid, 'carbonphosphorus_only', carbonphosphorus_only, -1)
    call nc_read_var(ncid, 'use_cn', use_cn, -1)
    call nc_read_var(ncid, 'noveg', noveg, -1)
    call nc_read_var(ncid, 'jmax_np3', jmax_np3, -1)
    call nc_read_var(ncid, 'nlevsoi', nlevsoi, -1)
    call nc_read_var(ncid, 'rpi', rpi, -1)
    call nc_read_var(ncid, 'nu_com_leaf_physiology', nu_com_leaf_physiology, -1)
    call nc_read_var(ncid, 'rgas', rgas, -1)
    call nc_alloc(ncid, "percrop", 1, percrop)
    call nc_read_var(ncid,'percrop', 1, percrop, -1)
    call nc_alloc(ncid, "crop", 1, crop)
    call nc_read_var(ncid,'crop', 1, crop, -1)
    call nc_alloc(ncid, "iscft", 1, iscft)
    call nc_read_var(ncid,'iscft', 1, iscft, -1)
    call nc_alloc(ncid, "firrig", 2, firrig)
    call nc_read_var(ncid,'firrig', 2, firrig, -1)
    call nc_alloc(ncid, "nfixer", 1, nfixer)
    call nc_read_var(ncid,'nfixer', 1, nfixer, -1)
    call nc_alloc(ncid, "irrigated", 1, irrigated)
    call nc_read_var(ncid,'irrigated', 1, irrigated, -1)
    call nc_alloc(ncid, "vcmax_np2", 1, vcmax_np2)
    call nc_read_var(ncid,'vcmax_np2', 1, vcmax_np2, -1)
    call nc_alloc(ncid, "vcmax_np4", 1, vcmax_np4)
    call nc_read_var(ncid,'vcmax_np4', 1, vcmax_np4, -1)
    call nc_alloc(ncid, "vcmax_np3", 1, vcmax_np3)
    call nc_read_var(ncid,'vcmax_np3', 1, vcmax_np3, -1)
    call nc_alloc(ncid, "vcmax_np1", 1, vcmax_np1)
    call nc_read_var(ncid,'vcmax_np1', 1, vcmax_np1, -1)
    call check(nf90_close(ncid))
  end subroutine read_constants
  subroutine write_constants(io_inst)
    type(spel_io_type), intent(inout) :: io_inst
    integer :: ncid, timestep
    character(len=256) :: new_fn
    new_fn = trim(io_inst%get_fn())
    print *, 'creating file: ', trim(new_fn)
    ncid = nc_create_or_open_file(trim(new_fn), create_file)
    call define_vars(ncid)
    call check(nf90_enddef(ncid))
     if(verbose) print *, 'dtime_mod'
    call nc_write_var_scalar(ncid, dtime_mod, 'dtime_mod')
     if(verbose) print *, 'tlsai_crit'
    call nc_write_var_scalar(ncid, tlsai_crit, 'tlsai_crit')
     if(verbose) print *, 'force_land_gustiness'
    call nc_write_var_scalar(ncid, force_land_gustiness, 'force_land_gustiness')
     if(verbose) print *, 'denh2o'
    call nc_write_var_scalar(ncid, denh2o, 'denh2o')
     if(verbose) print *, 'secs_curr'
    call nc_write_var_scalar(ncid, secs_curr, 'secs_curr')
     if(verbose) print *, 'implicit_stress'
    call nc_write_var_scalar(ncid, implicit_stress, 'implicit_stress')
     if(verbose) print *, 'cpair'
    call nc_write_var_scalar(ncid, cpair, 'cpair')
     if(verbose) print *, 'sb'
    call nc_write_var_scalar(ncid, sb, 'sb')
     if(verbose) print *, 'iulog'
    call nc_write_var_scalar(ncid, iulog, 'iulog')
     if(verbose) print *, 'hvap'
    call nc_write_var_scalar(ncid, hvap, 'hvap')
     if(verbose) print *, 'nlevgrnd'
    call nc_write_var_scalar(ncid, nlevgrnd, 'nlevgrnd')
     if(verbose) print *, 'denice'
    call nc_write_var_scalar(ncid, denice, 'denice')
     if(verbose) print *, 'alpha_aero'
    call nc_write_var_scalar(ncid, alpha_aero, 'alpha_aero')
     if(verbose) print *, 'atm_gustiness'
    call nc_write_var_scalar(ncid, atm_gustiness, 'atm_gustiness')
     if(verbose) print *, 'grav'
    call nc_write_var_scalar(ncid, grav, 'grav')
     if(verbose) print *, 'perchroot_alt'
    call nc_write_var_scalar(ncid, perchroot_alt, 'perchroot_alt')
     if(verbose) print *, 'use_finetop_rad'
    call nc_write_var_scalar(ncid, use_finetop_rad, 'use_finetop_rad')
     if(verbose) print *, 'use_c13'
    call nc_write_var_scalar(ncid, use_c13, 'use_c13')
     if(verbose) print *, 'nstep_mod'
    call nc_write_var_scalar(ncid, nstep_mod, 'nstep_mod')
     if(verbose) print *, 'csoilc'
    call nc_write_var_scalar(ncid, csoilc, 'csoilc')
     if(verbose) print *, 'use_lch4'
    call nc_write_var_scalar(ncid, use_lch4, 'use_lch4')
     if(verbose) print *, 'use_hydrstress'
    call nc_write_var_scalar(ncid, use_hydrstress, 'use_hydrstress')
     if(verbose) print *, 'perchroot'
    call nc_write_var_scalar(ncid, perchroot, 'perchroot')
     if(verbose) print *, 'vkc'
    call nc_write_var_scalar(ncid, vkc, 'vkc')
     if(verbose) print *, 'use_fates'
    call nc_write_var_scalar(ncid, use_fates, 'use_fates')
     if(verbose) print *, 'use_c14'
    call nc_write_var_scalar(ncid, use_c14, 'use_c14')
     if(verbose) print *, 'root_moist_stress_method'
    call nc_write_var_scalar(ncid, root_moist_stress_method, 'root_moist_stress_method')
     if(verbose) print *, 'carbonnitrogen_only'
    call nc_write_var_scalar(ncid, carbonnitrogen_only, 'carbonnitrogen_only')
     if(verbose) print *, 'carbon_only'
    call nc_write_var_scalar(ncid, carbon_only, 'carbon_only')
     if(verbose) print *, 'jmax_np1'
    call nc_write_var_scalar(ncid, jmax_np1, 'jmax_np1')
     if(verbose) print *, 'jmax_np2'
    call nc_write_var_scalar(ncid, jmax_np2, 'jmax_np2')
     if(verbose) print *, 'carbonphosphorus_only'
    call nc_write_var_scalar(ncid, carbonphosphorus_only, 'carbonphosphorus_only')
     if(verbose) print *, 'use_cn'
    call nc_write_var_scalar(ncid, use_cn, 'use_cn')
     if(verbose) print *, 'noveg'
    call nc_write_var_scalar(ncid, noveg, 'noveg')
     if(verbose) print *, 'jmax_np3'
    call nc_write_var_scalar(ncid, jmax_np3, 'jmax_np3')
     if(verbose) print *, 'nlevsoi'
    call nc_write_var_scalar(ncid, nlevsoi, 'nlevsoi')
     if(verbose) print *, 'rpi'
    call nc_write_var_scalar(ncid, rpi, 'rpi')
     if(verbose) print *, 'nu_com_leaf_physiology'
    call nc_write_var_scalar(ncid, nu_com_leaf_physiology, 'nu_com_leaf_physiology')
     if(verbose) print *, 'rgas'
    call nc_write_var_scalar(ncid, rgas, 'rgas')
     if(verbose) print *, 'percrop'
    call nc_write_var_array(ncid,1, shape(percrop), [character(len=32) :: 'unk_0_percrop'], reshape(percrop, [product(shape(percrop))]), 'percrop', -1)
     if(verbose) print *, 'crop'
    call nc_write_var_array(ncid,1, shape(crop), [character(len=32) :: 'unk_0_crop'], reshape(crop, [product(shape(crop))]), 'crop', -1)
     if(verbose) print *, 'iscft'
    call nc_write_var_array(ncid,1, shape(iscft), [character(len=32) :: 'unk_0_iscft'], reshape(iscft, [product(shape(iscft))]), 'iscft', -1)
     if(verbose) print *, 'firrig'
    call nc_write_var_array(ncid,2, shape(firrig), [character(len=32) :: 'unk_0_firrig','unk_1_firrig'], reshape(firrig, [product(shape(firrig))]), 'firrig', -1)
     if(verbose) print *, 'nfixer'
    call nc_write_var_array(ncid,1, shape(nfixer), [character(len=32) :: 'unk_0_nfixer'], reshape(nfixer, [product(shape(nfixer))]), 'nfixer', -1)
     if(verbose) print *, 'irrigated'
    call nc_write_var_array(ncid,1, shape(irrigated), [character(len=32) :: 'unk_0_irrigated'], reshape(irrigated, [product(shape(irrigated))]), 'irrigated', -1)
     if(verbose) print *, 'vcmax_np2'
    call nc_write_var_array(ncid,1, shape(vcmax_np2), [character(len=32) :: 'unk_0_vcmax_np2'], reshape(vcmax_np2, [product(shape(vcmax_np2))]), 'vcmax_np2', -1)
     if(verbose) print *, 'vcmax_np4'
    call nc_write_var_array(ncid,1, shape(vcmax_np4), [character(len=32) :: 'unk_0_vcmax_np4'], reshape(vcmax_np4, [product(shape(vcmax_np4))]), 'vcmax_np4', -1)
     if(verbose) print *, 'vcmax_np3'
    call nc_write_var_array(ncid,1, shape(vcmax_np3), [character(len=32) :: 'unk_0_vcmax_np3'], reshape(vcmax_np3, [product(shape(vcmax_np3))]), 'vcmax_np3', -1)
     if(verbose) print *, 'vcmax_np1'
    call nc_write_var_array(ncid,1, shape(vcmax_np1), [character(len=32) :: 'unk_0_vcmax_np1'], reshape(vcmax_np1, [product(shape(vcmax_np1))]), 'vcmax_np1', -1)
    call check(nf90_close(ncid))
  end subroutine write_constants
end module FUTConstantsMod
