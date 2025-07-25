#include "dynamics/homme/homme_grids_manager.hpp"
#include "dynamics/homme/interface/eamxx_homme_interface.hpp"
#include "dynamics/homme/physics_dynamics_remapper.hpp"
#include "dynamics/homme/homme_dynamics_helpers.hpp"

#include "share/util/eamxx_fv_phys_rrtmgp_active_gases_workaround.hpp"

#ifndef NDEBUG
#include "share/property_checks/field_nan_check.hpp"
#include "share/property_checks/field_lower_bound_check.hpp"
#include "share/property_checks/field_within_interval_check.hpp"
#endif

#include "share/io/scorpio_input.hpp"
#include "share/grid/se_grid.hpp"
#include "share/grid/point_grid.hpp"
#include "share/grid/remap/inverse_remapper.hpp"

// Get all Homme's compile-time dims and constants
#include "homme_dimensions.hpp"
#include "PhysicalConstants.hpp"

#include "ekat/std_meta/ekat_std_utils.hpp"

namespace scream
{

HommeGridsManager::
HommeGridsManager (const ekat::Comm& comm,
                   const ekat::ParameterList& p)
 : m_comm (comm)
 , m_params(p)
{
  if (!is_parallel_inited_f90()) {
    // While we're here, we can init homme's parallel session
    auto fcomm = MPI_Comm_c2f(comm.mpi_comm());
    init_parallel_f90 (fcomm);
  }

  // This class needs Homme's context, so register as a user
  HommeContextUser::singleton().add_user();

  if (!is_params_inited_f90()) {
    // While we're here, we can init homme's parameters
    auto nlname = m_params.get<std::string>("dynamics_namelist_file_name").c_str();
    init_params_f90 (nlname);
  }

  // Create the grid integer codes map (i.e., int->string
  build_pg_codes ();
}

HommeGridsManager::
~HommeGridsManager () {
  // Cleanup the grids stuff
  finalize_geometry_f90 ();

  // This class is done with Homme. Remove from its users list
  HommeContextUser::singleton().remove_user();
}

HommeGridsManager::remapper_ptr_type
HommeGridsManager::do_create_remapper (const grid_ptr_type from_grid,
                                       const grid_ptr_type to_grid) const {
  const auto from = from_grid->name();
  const auto to   = to_grid->name();

  EKAT_REQUIRE_MSG ( from=="dynamics" || to=="dynamics",
    "Error! Either source or target grid must be 'dynamics'.\n");

  const bool p2d = to=="dynamics";

  if (from=="physics_gll" || to=="physics_gll") {
    using PDR = PhysicsDynamicsRemapper;

    auto dyn_grid = get_grid("dynamics");
    auto phys_grid = get_grid("physics_gll");

    auto pd_remapper = std::make_shared<PDR>(phys_grid,dyn_grid);
    if (p2d) {
      return pd_remapper;
    } else {
      return std::make_shared<InverseRemapper>(pd_remapper);
    }
  } else {
    ekat::error::runtime_abort("Error! P-D remapping only implemented for 'physics_gll' phys grid.\n");
  }
  return nullptr;
}

void HommeGridsManager::
build_grids ()
{
  // Get the physics grid specs
  const ci_string pg_type      = m_params.get<std::string>("physics_grid_type");
  const ci_string pg_rebalance = m_params.get<std::string>("physics_grid_rebalance","none");

  // Get the physics grid code
  std::vector<int> pg_codes {
    m_pg_codes["gll"]["none"],  // We always need this to read/write dyn grid stuff
    m_pg_codes[pg_type][pg_rebalance]
  };
  // In case the two pg codes are the same...
  auto it = std::unique(pg_codes.begin(),pg_codes.end());
  const int* codes_ptr = pg_codes.data();
  init_grids_f90 (codes_ptr,std::distance(pg_codes.begin(),it));

  // Check that the global number of 2d elements is no less than the number of MPI ranks
  EKAT_REQUIRE_MSG (get_homme_param<int>("nelem") >= m_comm.size(),
      "Error! We do not yet support running EAMxx with a number of MPI ranks\n"
      "       larger than the number of 2d elements in Homme.\n"
      "  - num MPI ranks: " + std::to_string(m_comm.size()) + "\n"
      "  - num 2d elems : " + std::to_string(get_homme_param<int>("nelem")) + "\n");

  // We know we need the dyn grid, so build it
  build_dynamics_grid ();

  // Also the GLL grid with no rebalance is needed for sure
  build_physics_grid("gll","none");

  // If (pg type,rebalance) is (gll,none), this will be a no op
  build_physics_grid(pg_type,pg_rebalance);

  // Make "physics" be an alias to whatever the pair (pg_type,rebalance) refers to
  std::string pg_name = "physics_" + pg_type;
  if (pg_rebalance!="none") {
    pg_name += " " + pg_rebalance;
  }

  this->alias_grid(pg_name,"physics");

  // Clean up temporaries used during grid initialization
  cleanup_grid_init_data_f90 ();
}

void HommeGridsManager::build_dynamics_grid () {
  const std::string name = "dynamics";
  if (has_grid(name)) {
    return;
  }

  using gid_type = AbstractGrid::gid_type;
  using namespace ekat::units;

  // Get dimensions and create "empty" grid
  const int nlelem = get_num_local_elems_f90();
  const int nlev   = get_nlev_f90();

  auto dyn_grid = std::make_shared<SEGrid>("dynamics",nlelem,HOMMEXX_NP,nlev,m_comm);
  dyn_grid->setSelfPointer(dyn_grid);

  const auto layout2d = dyn_grid->get_2d_scalar_layout();
  const Units rad (Units::nondimensional(),"rad");

  // Filling the cg/dg gids, elgpgp, coords, lat/lon views
  auto dg_dofs = dyn_grid->get_dofs_gids();
  auto cg_dofs = dyn_grid->get_cg_dofs_gids();
  auto elgpgp  = dyn_grid->get_lid_to_idx_map();
  auto elgids  = dyn_grid->get_partitioned_dim_gids ();
  auto lat     = dyn_grid->create_geometry_data("lat",layout2d,rad);
  auto lon     = dyn_grid->create_geometry_data("lon",layout2d,rad);

  auto dg_dofs_h = dg_dofs.get_view<gid_type*,Host>();
  auto cg_dofs_h = cg_dofs.get_view<gid_type*,Host>();
  auto elgpgp_h  = elgpgp.get_view<int**,Host>();
  auto elgids_h  = elgids.get_view<int*,Host>();
  auto lat_h     = lat.get_view<Real***,Host>();
  auto lon_h     = lon.get_view<Real***,Host>();

  // Get (ie,igp,jgp,gid) data for each dof
  get_dyn_grid_data_f90 (dg_dofs_h.data(),cg_dofs_h.data(),elgpgp_h.data(),elgids_h.data(), lat_h.data(), lon_h.data());

  dg_dofs.sync_to_dev();
  cg_dofs.sync_to_dev();
  elgpgp.sync_to_dev();
  elgids.sync_to_dev();
  lat.sync_to_dev();
  lon.sync_to_dev();

#ifndef NDEBUG
  for (auto f : {lat, lon}) {
    auto nan_check = std::make_shared<FieldNaNCheck>(f,dyn_grid)->check();
    EKAT_REQUIRE_MSG (nan_check.result==CheckResult::Pass,
        "ERROR! NaN values detected in " + f.name() + " field.\n" + nan_check.msg);
  }
#endif

  initialize_vertical_coordinates(dyn_grid);

  dyn_grid->m_disambiguation_suffix = "_d";
  add_nonconst_grid(dyn_grid);
}

void HommeGridsManager::
build_physics_grid (const ci_string& type, const ci_string& rebalance) {
  std::string name = "physics_" + type;
  if (rebalance != "none") {
    name += " " + rebalance;
  }

  // Build only if not built yet
  if (has_grid(name)) {
    return;
  }

  if (type=="pg2") {
    fvphyshack = true;
  }

  // Get the grid pg_type
  const int pg_code = m_pg_codes.at(type).at(rebalance);

  // Get dimensions and create "empty" grid
  const int nlev  = get_nlev_f90();
  const int nlcols = get_num_local_columns_f90 (pg_code % 10);

  auto phys_grid = std::make_shared<PointGrid>(name,nlcols,nlev,m_comm);
  phys_grid->setSelfPointer(phys_grid);

  // Create the gids, coords, area views
  using namespace ShortFieldTagsNames;
  using namespace ekat::units;
  const auto layout2d = phys_grid->get_2d_scalar_layout();
  const Units rad (Units::nondimensional(),"rad");

  auto dofs = phys_grid->get_dofs_gids();
  auto lat  = phys_grid->create_geometry_data("lat",layout2d,rad);
  auto lon  = phys_grid->create_geometry_data("lon",layout2d,rad);
  auto area = phys_grid->create_geometry_data("area",layout2d,rad*rad);

  using gid_type = AbstractGrid::gid_type;

  auto dofs_h = dofs.get_view<gid_type*,Host>();
  auto lat_h  = lat.get_view<Real*,Host>();
  auto lon_h  = lon.get_view<Real*,Host>();
  auto area_h = area.get_view<Real*,Host>();

  // Get all specs of phys grid cols (gids, coords, area)
  get_phys_grid_data_f90 (pg_code, dofs_h.data(), lat_h.data(), lon_h.data(), area_h.data());

  dofs.sync_to_dev();
  lat.sync_to_dev();
  lon.sync_to_dev();
  area.sync_to_dev();

#ifndef NDEBUG
  for (auto f : {lat, lon, area}) {
    auto nan_check = std::make_shared<FieldNaNCheck>(f,phys_grid)->check();
    EKAT_REQUIRE_MSG (nan_check.result==CheckResult::Pass,
        "ERROR! NaN values detected in " + f.name() + " field.\n" + nan_check.msg);
  }

  // Also check area for non-negativity
  const auto eps = std::numeric_limits<Real>::epsilon();
  auto area_check = std::make_shared<FieldLowerBoundCheck>(area,phys_grid,eps)->check();
  EKAT_REQUIRE_MSG (area_check.result==CheckResult::Pass,
      "ERROR! NaN values detected in area field.\n" + area_check.msg);
#endif

  // If one of the hybrid vcoord arrays is there, they all are
  // NOTE: we may have none in some unit tests that don't need them (e.g. pd remap)
  if (get_grid("dynamics")->has_geometry_data("hyam")) {
    auto layout_mid = phys_grid->get_vertical_layout(true);
    auto layout_int = phys_grid->get_vertical_layout(false);
    using namespace ekat::units;
    Units nondim = Units::nondimensional();
    Units mbar(bar/1000,"mb");

    auto hyai = phys_grid->create_geometry_data("hyai",layout_int,nondim);
    auto hybi = phys_grid->create_geometry_data("hybi",layout_int,nondim);
    auto hyam = phys_grid->create_geometry_data("hyam",layout_mid,nondim);
    auto hybm = phys_grid->create_geometry_data("hybm",layout_mid,nondim);
    auto lev  = phys_grid->create_geometry_data("lev", layout_mid,mbar);
    auto ilev = phys_grid->create_geometry_data("ilev",layout_int,mbar);

    for (auto f : {hyai, hybi, hyam, hybm}) {
      auto f_d = get_grid("dynamics")->get_geometry_data(f.name());
      f.deep_copy(f_d);
      f.sync_to_host();
    }
  
    // Build lev from hyam and hybm
    const Real ps0        = 100000.0;
  
    auto hyam_v = hyam.get_view<const Real*,Host>();
    auto hybm_v = hybm.get_view<const Real*,Host>();
    auto hyai_v = hyai.get_view<const Real*,Host>();
    auto hybi_v = hybi.get_view<const Real*,Host>();
    auto lev_v  = lev.get_view<Real*,Host>();
    auto ilev_v = ilev.get_view<Real*,Host>();
    auto num_v_levs = phys_grid->get_num_vertical_levels();
    for (int ii=0;ii<num_v_levs;ii++) {
      lev_v(ii)  = 0.01*ps0*(hyam_v(ii)+hybm_v(ii));
      ilev_v(ii) = 0.01*ps0*(hyai_v(ii)+hybi_v(ii));
    }
    ilev_v(num_v_levs) = 0.01*ps0*(hyai_v(num_v_levs)+hybi_v(num_v_levs));
    lev.sync_to_dev();
    ilev.sync_to_dev();
  }

  if (is_planar_geometry_f90()) {
    // If running with IOP, store grid length size
    FieldLayout scalar0d({},{});
    auto dx_short_f = phys_grid->create_geometry_data("dx_short",scalar0d,rad);
    dx_short_f.get_view<Real,Host>()() = get_dx_short_f90(0);
    dx_short_f.sync_to_dev();
  }

  phys_grid->m_disambiguation_suffix = type;
  add_nonconst_grid(phys_grid);
}

void HommeGridsManager::
initialize_vertical_coordinates (const nonconstgrid_ptr_type& dyn_grid) {
  using namespace ShortFieldTagsNames;

  // If we put vcoords in the IC file, we open the ic file, whose name
  // was set by the AD in the param list. This allows users to change
  // nc files only once in the input file.
  const auto& vcoord_filename = m_params.get<std::string>("vertical_coordinate_filename");
  if (vcoord_filename=="NONE") {
    return;
  }

  std::string filename = vcoord_filename;
  if (filename=="IC_FILE") {
    filename =  m_params.get<std::string>("ic_filename");
  }

  // Create vcoords fields
  auto layout_mid = dyn_grid->get_vertical_layout(true);
  auto layout_int = dyn_grid->get_vertical_layout(false);
  constexpr auto nondim = ekat::units::Units::nondimensional();

  auto hyai = dyn_grid->create_geometry_data("hyai",layout_int,nondim);
  auto hybi = dyn_grid->create_geometry_data("hybi",layout_int,nondim);
  auto hyam = dyn_grid->create_geometry_data("hyam",layout_mid,nondim);
  auto hybm = dyn_grid->create_geometry_data("hybm",layout_mid,nondim);

  std::vector<Field> fields = {hyai, hybi, hyam, hybm};
  AtmosphereInput vcoord_reader(filename,dyn_grid,fields);
  vcoord_reader.read_variables();
  vcoord_reader.finalize();

  // Set vcoords in f90
  // NOTE: homme does the check for these arrays, so no need to do any property check here
  const auto ps0 = Homme::PhysicalConstants::p0;
  prim_set_hvcoords_f90 (ps0,
                         hyai.get_internal_view_data<Real,Host>(),
                         hybi.get_internal_view_data<Real,Host>(),
                         hyam.get_internal_view_data<Real,Host>(),
                         hybm.get_internal_view_data<Real,Host>());
}

void HommeGridsManager::
build_pg_codes () {

  // Codes for the physics grids supported
  // Rules: a code has two digits, X and Y
  //  - X denotes the column rebalance choice:
  //    - 0: no rebalance
  //    - 1: twin columns rebalance
  //  - Y denotes the type of physics grid:
  //    - 0: GLL grid
  //    - N: FV phys grid, with NxN points

  m_pg_codes["gll"]["none"] =  0;
  m_pg_codes["gll"]["twin"] = 10;
  m_pg_codes["pg2"]["none"] =  2;
  m_pg_codes["pg2"]["twin"] = 12;
}

} // namespace scream
