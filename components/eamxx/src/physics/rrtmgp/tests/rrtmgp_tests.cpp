#include "physics/rrtmgp/eamxx_rrtmgp_interface.hpp"
#include "physics/rrtmgp/rrtmgp_test_utils.hpp"

#include "share/eamxx_types.hpp"
#include "share/eamxx_session.hpp"

#include "cpp/rrtmgp/mo_gas_concentrations.h"
#include "examples/all-sky/mo_garand_atmos_io.h"

#include "ekat/util/ekat_test_utils.hpp"

#include <cmath>
#include <mpi.h>

using namespace scream;

namespace {

// Names of input files we will need.
// NOTE: using old (full gpoint resolution) coefficient data for consistency with reference problem
std::string coefficients_file_sw = SCREAM_DATA_DIR "/init/rrtmgp-data-sw-g224-2018-12-04.nc";
std::string coefficients_file_lw = SCREAM_DATA_DIR "/init/rrtmgp-data-lw-g256-2018-12-04.nc";
std::string cloud_optics_file_sw = SCREAM_DATA_DIR "/init/rrtmgp-cloud-optics-coeffs-sw.nc";
std::string cloud_optics_file_lw = SCREAM_DATA_DIR "/init/rrtmgp-cloud-optics-coeffs-lw.nc";

void expect_another_arg (int i, int argc) {
  EKAT_REQUIRE_MSG(i != argc-1, "Expected another cmd-line arg.");
}

int run_kokkos(int argc, char** argv) {
  using namespace ekat::logger;
  using logger_t = Logger<LogNoFile,LogRootRank>;
  using interface_t = scream::rrtmgp::rrtmgp_interface<>;
  using utils_t = rrtmgpTest::rrtmgp_test_utils<>;
  using MDRP = utils_t::MDRP;
  using real1dk = interface_t::view_t<Real*>;
  using real2dk = interface_t::view_t<Real**>;
  using real3dk = interface_t::view_t<Real***>;

  ekat::Comm comm(MPI_COMM_WORLD);
  auto logger = std::make_shared<logger_t>("",LogLevel::info,comm);

  // Parse command line arguments
  if (argc < 3) {
    std::string msg = "Missing required inputs. Usage:\n";
    msg += argv[0];
    msg += " -i <inputfile> -b <baseline file> [options]\n";
    logger->error(msg);
    return 1;
  }
  std::string inputfile, baseline, device;

  for (int i = 1; i < argc-1; ++i) {
    if (ekat::argv_matches(argv[i], "-b", "--baseline-file")) {
      expect_another_arg(i, argc);
      ++i;
      baseline = argv[i];
    }
    if (ekat::argv_matches(argv[i], "-i", "--input-file")) {
      expect_another_arg(i, argc);
      ++i;
      inputfile = argv[i];
    }
    // RRTMGP baselines tests to not use kokoks. Swallow the arg, but ignore it
    if (std::string(argv[i])=="--kokkos-device-id=") {
      continue;
    }
  }

  // Check to see that inputfiles exist
  if (!rrtmgpTest::file_exists(inputfile.c_str())) {
    logger->error("Inputfile " + inputfile + " does not exist.\n");
    return -1;
  }
  if (!rrtmgpTest::file_exists(baseline.c_str())) {
    logger->error("Baseline " + baseline + " does not exist.\n");
    return -1;
  }

  // Initialize kokkos
  logger->info("Initialize kokkos...\n");
  scream::init_kls();

  // Get reference fluxes from input file; do this here so we can get ncol dimension
  logger->info("Read fluxes...\n");
  real2dk sw_flux_up_ref;
  real2dk sw_flux_dn_ref;
  real2dk sw_flux_dir_ref;
  real2dk lw_flux_up_ref;
  real2dk lw_flux_dn_ref;
  utils_t::read_fluxes(inputfile, sw_flux_up_ref, sw_flux_dn_ref, sw_flux_dir_ref, lw_flux_up_ref, lw_flux_dn_ref );

  // Get dimension sizes
  int ncol = sw_flux_up_ref.extent(0);
  int nlev = sw_flux_up_ref.extent(1);
  int nlay = nlev - 1;

  // Read in dummy Garand atmosphere; if this were an actual model simulation,
  // these would be passed as inputs to the driver
  // NOTE: set ncol to size of col_flx dimension in the input file. This is so
  // that we can compare to the reference data provided in that file. Note that
  // this will copy the first column of the input data (the first profile) ncol
  // times. We will then fill some fraction of these columns with clouds for
  // the test problem.
  logger->info("Read dummy atmos...\n");
  real2dk p_lay("p_lay", ncol, nlay);
  real2dk t_lay("t_lay", ncol, nlay);
  real2dk p_lev("p_lev", ncol, nlay+1);
  real2dk t_lev("t_lev", ncol, nlay+1);
  real2dk col_dry;
  GasConcsK<Real, Kokkos::LayoutRight, DefaultDevice> gas_concs;
  read_atmos(inputfile, p_lay, t_lay, p_lev, t_lev, gas_concs, col_dry, ncol);

    // Initialize absorption coefficients
  logger->info("Initialize RRTMGP...\n");
  interface_t::rrtmgp_initialize(gas_concs, coefficients_file_sw, coefficients_file_lw, cloud_optics_file_sw, cloud_optics_file_lw, logger, 2.0);

  // Setup our dummy atmosphere based on the input data we read in
  logger->info("Setup dummy atmos...\n");
  real1dk sfc_alb_dir_vis("sfc_alb_dir_vis", ncol);
  real1dk sfc_alb_dir_nir("sfc_alb_dir_nir", ncol);
  real1dk sfc_alb_dif_vis("sfc_alb_dif_vis", ncol);
  real1dk sfc_alb_dif_nir("sfc_alb_dif_nir", ncol);
  real1dk mu0("mu0", ncol);
  real2dk lwp("lwp", ncol, nlay);
  real2dk iwp("iwp", ncol, nlay);
  real2dk rel("rel", ncol, nlay);
  real2dk rei("rei", ncol, nlay);
  real2dk cld("cld", ncol, nlay);
  utils_t::dummy_atmos(
    inputfile, ncol, p_lay, t_lay,
    sfc_alb_dir_vis, sfc_alb_dir_nir,
    sfc_alb_dif_vis, sfc_alb_dif_nir,
    mu0,
    lwp, iwp, rel, rei, cld
  );

  // Setup flux outputs; In a real model run, the fluxes would be
  // input/outputs into the driver (persisting between calls), and
  // we would just have to setup the pointers to them in the
  // FluxesBroadband object
  logger->info("Setup fluxes...\n");
  const auto nswbands = interface_t::k_dist_sw_k->get_nband();
  const auto nlwbands = interface_t::k_dist_lw_k->get_nband();
  real2dk sw_flux_up ("sw_flux_up" , ncol, nlay+1);
  real2dk sw_flux_dn ("sw_flux_dn" , ncol, nlay+1);
  real2dk sw_flux_dir("sw_flux_dir", ncol, nlay+1);
  real2dk lw_flux_up ("lw_flux_up" , ncol, nlay+1);
  real2dk lw_flux_dn ("lw_flux_dn" , ncol, nlay+1);
  real2dk sw_clnclrsky_flux_up ("sw_clnclrsky_flux_up" , ncol, nlay+1);
  real2dk sw_clnclrsky_flux_dn ("sw_clnclrsky_flux_dn" , ncol, nlay+1);
  real2dk sw_clnclrsky_flux_dir("sw_clnclrsky_flux_dir", ncol, nlay+1);
  real2dk sw_clrsky_flux_up ("sw_clrsky_flux_up" , ncol, nlay+1);
  real2dk sw_clrsky_flux_dn ("sw_clrsky_flux_dn" , ncol, nlay+1);
  real2dk sw_clrsky_flux_dir("sw_clrsky_flux_dir", ncol, nlay+1);
  real2dk sw_clnsky_flux_up ("sw_clnsky_flux_up" , ncol, nlay+1);
  real2dk sw_clnsky_flux_dn ("sw_clnsky_flux_dn" , ncol, nlay+1);
  real2dk sw_clnsky_flux_dir("sw_clnsky_flux_dir", ncol, nlay+1);
  real2dk lw_clnclrsky_flux_up ("lw_clnclrsky_flux_up" , ncol, nlay+1);
  real2dk lw_clnclrsky_flux_dn ("lw_clnclrsky_flux_dn" , ncol, nlay+1);
  real2dk lw_clrsky_flux_up ("lw_clrsky_flux_up" , ncol, nlay+1);
  real2dk lw_clrsky_flux_dn ("lw_clrsky_flux_dn" , ncol, nlay+1);
  real2dk lw_clnsky_flux_up ("lw_clnsky_flux_up" , ncol, nlay+1);
  real2dk lw_clnsky_flux_dn ("lw_clnsky_flux_dn" , ncol, nlay+1);
  real3dk sw_bnd_flux_up ("sw_bnd_flux_up" , ncol, nlay+1, nswbands);
  real3dk sw_bnd_flux_dn ("sw_bnd_flux_dn" , ncol, nlay+1, nswbands);
  real3dk sw_bnd_flux_dir("sw_bnd_flux_dir", ncol, nlay+1, nswbands);
  real3dk lw_bnd_flux_up ("lw_bnd_flux_up" , ncol, nlay+1, nlwbands);
  real3dk lw_bnd_flux_dn ("lw_bnd_flux_dn" , ncol, nlay+1, nlwbands);

  // Compute band-by-band surface_albedos.
  real2dk sfc_alb_dir("sfc_alb_dir", ncol, nswbands);
  real2dk sfc_alb_dif("sfc_alb_dif", ncol, nswbands);
  interface_t::compute_band_by_band_surface_albedos(
    ncol, nswbands,
    sfc_alb_dir_vis, sfc_alb_dir_nir,
    sfc_alb_dif_vis, sfc_alb_dif_nir,
    sfc_alb_dir, sfc_alb_dif);

  // Setup some dummy aerosol optical properties
  auto aer_tau_sw = real3dk("aer_tau_sw", ncol, nlay, nswbands);
  auto aer_ssa_sw = real3dk("aer_ssa_sw", ncol, nlay, nswbands);
  auto aer_asm_sw = real3dk("aer_asm_sw", ncol, nlay, nswbands);
  auto aer_tau_lw = real3dk("aer_tau_lw", ncol, nlay, nlwbands);
  Kokkos::parallel_for(MDRP::template get<3>({ncol, nlay, nswbands}), KOKKOS_LAMBDA(int icol, int ilay, int ibnd) {
    aer_tau_sw(icol,ilay,ibnd) = 0;
    aer_ssa_sw(icol,ilay,ibnd) = 0;
    aer_asm_sw(icol,ilay,ibnd) = 0;
  });
  Kokkos::parallel_for(MDRP::template get<3>({ncol, nlay, nlwbands}), KOKKOS_LAMBDA(int icol, int ilay, int ibnd) {
    aer_tau_lw(icol,ilay,ibnd) = 0;
  });

  // These are returned as outputs now from rrtmgp_main
  // TODO: provide as inputs consistent with how aerosol is treated?
  const auto nswgpts = interface_t::k_dist_sw_k->get_ngpt();
  const auto nlwgpts = interface_t::k_dist_lw_k->get_ngpt();
  auto cld_tau_sw_bnd = real3dk("cld_tau_sw_bnd", ncol, nlay, nswbands);
  auto cld_tau_lw_bnd = real3dk("cld_tau_lw_bnd", ncol, nlay, nlwbands);
  auto cld_tau_sw = real3dk("cld_tau_sw", ncol, nlay, nswgpts);
  auto cld_tau_lw = real3dk("cld_tau_lw", ncol, nlay, nlwgpts);

  // Run RRTMGP code on dummy atmosphere
  logger->info("Run RRTMGP...\n");
  const Real tsi_scaling = 1;
  interface_t::rrtmgp_main(
    ncol, nlay,
    p_lay, t_lay, p_lev, t_lev, gas_concs,
    sfc_alb_dir, sfc_alb_dif, mu0,
    lwp, iwp, rel, rei, cld,
    aer_tau_sw, aer_ssa_sw, aer_asm_sw, aer_tau_lw,
    cld_tau_sw_bnd, cld_tau_lw_bnd,  // outputs
    cld_tau_sw, cld_tau_lw,  // outputs
    sw_flux_up, sw_flux_dn, sw_flux_dir,
    lw_flux_up, lw_flux_dn,
    sw_clnclrsky_flux_up, sw_clnclrsky_flux_dn, sw_clnclrsky_flux_dir,
    sw_clrsky_flux_up, sw_clrsky_flux_dn, sw_clrsky_flux_dir,
    sw_clnsky_flux_up, sw_clnsky_flux_dn, sw_clnsky_flux_dir,
    lw_clnclrsky_flux_up, lw_clnclrsky_flux_dn,
    lw_clrsky_flux_up, lw_clrsky_flux_dn,
    lw_clnsky_flux_up, lw_clnsky_flux_dn,
    sw_bnd_flux_up, sw_bnd_flux_dn, sw_bnd_flux_dir,
    lw_bnd_flux_up, lw_bnd_flux_dn, tsi_scaling, logger,
    true, true // extra_clnclrsky_diag, extra_clnsky_diag
    // set them both to true because we are testing them below
  );

  // Check values against baseline
  logger->info("Check values...\n");
  utils_t::read_fluxes(
    baseline,
    sw_flux_up_ref, sw_flux_dn_ref, sw_flux_dir_ref,
    lw_flux_up_ref, lw_flux_dn_ref
  );
  int nerr = 0;
  if (!utils_t::all_close(sw_flux_up_ref , sw_flux_up , 0.001)) nerr++;
  if (!utils_t::all_close(sw_flux_dn_ref , sw_flux_dn , 0.001)) nerr++;
  if (!utils_t::all_close(sw_flux_dir_ref, sw_flux_dir, 0.001)) nerr++;
  if (!utils_t::all_close(lw_flux_up_ref , lw_flux_up , 0.001)) nerr++;
  if (!utils_t::all_close(lw_flux_dn_ref , lw_flux_dn , 0.001)) nerr++;

  // Because the aerosol optical properties are all set to zero, these fluxes must be equal
  if (!utils_t::all_close(sw_flux_up , sw_clnsky_flux_up , 0.0000000001)) nerr++;
  if (!utils_t::all_close(sw_clrsky_flux_up , sw_clnclrsky_flux_up , 0.0000000001)) nerr++;
  if (!utils_t::all_close(sw_flux_dn , sw_clnsky_flux_dn , 0.0000000001)) nerr++;
  if (!utils_t::all_close(sw_clrsky_flux_dn , sw_clnclrsky_flux_dn , 0.0000000001)) nerr++;
  if (!utils_t::all_close(sw_flux_dir , sw_clnsky_flux_dir , 0.0000000001)) nerr++;
  if (!utils_t::all_close(sw_clrsky_flux_dir , sw_clnclrsky_flux_dir , 0.0000000001)) nerr++;
  if (!utils_t::all_close(lw_flux_up , lw_clnsky_flux_up , 0.0000000001)) nerr++;
  if (!utils_t::all_close(lw_clrsky_flux_up , lw_clnclrsky_flux_up , 0.0000000001)) nerr++;
  if (!utils_t::all_close(lw_flux_dn , lw_clnsky_flux_dn , 0.0000000001)) nerr++;
  if (!utils_t::all_close(lw_clrsky_flux_dn , lw_clnclrsky_flux_dn , 0.0000000001)) nerr++;

  logger->info("Cleaning up...\n");
  // Clean up or else Kokkos will throw errors
  interface_t::rrtmgp_finalize();
  scream::finalize_kls();

  return nerr != 0 ? 1 : 0;
}  // end of main driver code

}

int main(int argc, char** argv) {

    MPI_Init(&argc,&argv);
    int ret = 0;
    ret += run_kokkos(argc,argv);
    MPI_Finalize();

    return ret;
}
