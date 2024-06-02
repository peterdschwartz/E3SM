module DeepCopyLandTopoMod
  use landunittype,only: landunit_physical_properties
  use landunitdatatype,only: landunit_energy_state
  use landunitdatatype,only: landunit_energy_flux
  use landunitdatatype,only: landunit_water_state
  use topounittype,only: topounit_physical_properties
  use topounitdatatype,only: topounit_atmospheric_state
  use topounitdatatype,only: topounit_atmospheric_flux
  use topounitdatatype,only: topounit_energy_state

  implicit none

  public :: deepcopy_landunit_physical_properties
  public :: deepcopy_landunit_energy_state
  public :: deepcopy_landunit_energy_flux
  public :: deepcopy_landunit_water_state
  public :: deepcopy_topounit_physical_properties
  public :: deepcopy_topounit_atmospheric_state
  public :: deepcopy_topounit_atmospheric_flux
  public :: deepcopy_topounit_energy_state
contains

  subroutine deepcopy_LandTopo_types(lun_pp, lun_es, lun_ef, lun_ws,&
    top_pp, top_as, top_af, top_es)

    type(landunit_physical_properties), intent(inout) :: lun_pp
    type(landunit_energy_state), intent(inout) :: lun_es
    type(landunit_energy_flux), intent(inout) :: lun_ef
    type(landunit_water_state), intent(inout) :: lun_ws
    type(topounit_physical_properties), intent(inout) :: top_pp
    type(topounit_atmospheric_state), intent(inout) :: top_as
    type(topounit_atmospheric_flux), intent(inout) :: top_af
    type(topounit_energy_state), intent(inout) :: top_es

    call deepcopy_landunit_physical_properties(lun_pp)
    call deepcopy_landunit_energy_state(lun_es)
    call deepcopy_landunit_energy_flux(lun_ef)
    call deepcopy_landunit_water_state(lun_ws)
    call deepcopy_topounit_physical_properties(top_pp)
    call deepcopy_topounit_atmospheric_state(top_as)
    call deepcopy_topounit_atmospheric_flux(top_af)
    call deepcopy_topounit_energy_state(top_es)

  end subroutine deepcopy_LandTopo_types

  subroutine deepcopy_landunit_physical_properties(this_type)
    type(landunit_physical_properties), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%gridcell(:),&
    !$acc& this_type%wtgcell(:),&
    !$acc& this_type%topounit(:),&
    !$acc& this_type%wttopounit(:),&
    !$acc& this_type%coli(:),&
    !$acc& this_type%colf(:),&
    !$acc& this_type%ncolumns(:),&
    !$acc& this_type%pfti(:),&
    !$acc& this_type%pftf(:),&
    !$acc& this_type%npfts(:),&
    !$acc& this_type%itype(:),&
    !$acc& this_type%ifspecial(:),&
    !$acc& this_type%lakpoi(:),&
    !$acc& this_type%urbpoi(:),&
    !$acc& this_type%glcmecpoi(:),&
    !$acc& this_type%active(:),&
    !$acc& this_type%canyon_hwr(:),&
    !$acc& this_type%wtroad_perv(:),&
    !$acc& this_type%wtlunit_roof(:),&
    !$acc& this_type%ht_roof(:),&
    !$acc& this_type%z_0_town(:),&
    !$acc& this_type%z_d_town(:))
  end subroutine deepcopy_landunit_physical_properties
  subroutine deepcopy_landunit_energy_state(this_type)
    type(landunit_energy_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%t_building(:),&
    !$acc& this_type%taf(:))
  end subroutine deepcopy_landunit_energy_state
  subroutine deepcopy_landunit_energy_flux(this_type)
    type(landunit_energy_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%eflx_heat_from_ac(:),&
    !$acc& this_type%eflx_traffic(:),&
    !$acc& this_type%eflx_wasteheat(:))
  end subroutine deepcopy_landunit_energy_flux
  subroutine deepcopy_landunit_water_state(this_type)
    type(landunit_water_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%qaf(:))
  end subroutine deepcopy_landunit_water_state
  subroutine deepcopy_topounit_physical_properties(this_type)
    type(topounit_physical_properties), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%gridcell(:),&
    !$acc& this_type%topo_grc_ind(:),&
    !$acc& this_type%wtgcell(:),&
    !$acc& this_type%lndi(:),&
    !$acc& this_type%lndf(:),&
    !$acc& this_type%nlandunits(:),&
    !$acc& this_type%coli(:),&
    !$acc& this_type%colf(:),&
    !$acc& this_type%ncolumns(:),&
    !$acc& this_type%pfti(:),&
    !$acc& this_type%pftf(:),&
    !$acc& this_type%npfts(:),&
    !$acc& this_type%landunit_indices(:,:),&
    !$acc& this_type%active(:),&
    !$acc& this_type%area(:),&
    !$acc& this_type%lat(:),&
    !$acc& this_type%lon(:),&
    !$acc& this_type%elevation(:),&
    !$acc& this_type%slope(:),&
    !$acc& this_type%aspect(:),&
    !$acc& this_type%emissivity(:),&
    !$acc& this_type%surfalb_dir(:,:),&
    !$acc& this_type%surfalb_dif(:,:))
  end subroutine deepcopy_topounit_physical_properties
  subroutine deepcopy_topounit_atmospheric_state(this_type)
    type(topounit_atmospheric_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%tbot(:),&
    !$acc& this_type%thbot(:),&
    !$acc& this_type%pbot(:),&
    !$acc& this_type%rhobot(:),&
    !$acc& this_type%qbot(:),&
    !$acc& this_type%rhbot(:),&
    !$acc& this_type%ubot(:),&
    !$acc& this_type%vbot(:),&
    !$acc& this_type%wsresp(:),&
    !$acc& this_type%tau_est(:),&
    !$acc& this_type%ugust(:),&
    !$acc& this_type%windbot(:),&
    !$acc& this_type%zbot(:),&
    !$acc& this_type%po2bot(:),&
    !$acc& this_type%pco2bot(:),&
    !$acc& this_type%pc13o2bot(:),&
    !$acc& this_type%pch4bot(:),&
    !$acc& this_type%rh24h(:),&
    !$acc& this_type%wind24h(:))
  end subroutine deepcopy_topounit_atmospheric_state
  subroutine deepcopy_topounit_atmospheric_flux(this_type)
    type(topounit_atmospheric_flux), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%rain(:),&
    !$acc& this_type%snow(:),&
    !$acc& this_type%solad(:,:),&
    !$acc& this_type%solai(:,:),&
    !$acc& this_type%solar(:),&
    !$acc& this_type%lwrad(:),&
    !$acc& this_type%prec24h(:),&
    !$acc& this_type%prec10d(:),&
    !$acc& this_type%prec60d(:),&
    !$acc& this_type%fsd24h(:),&
    !$acc& this_type%fsd240h(:),&
    !$acc& this_type%fsi24h(:),&
    !$acc& this_type%fsi240h(:))
  end subroutine deepcopy_topounit_atmospheric_flux
  subroutine deepcopy_topounit_energy_state(this_type)
    type(topounit_energy_state), intent(inout) :: this_type
    !$acc enter data copyin(this_type)
    !$acc enter data copyin(&
    !$acc& this_type%t_rad(:),&
    !$acc& this_type%eflx_lwrad_out_topo(:),&
    !$acc& this_type%t_grnd(:))
  end subroutine deepcopy_topounit_energy_state
end module DeepCopyLandTopoMod
