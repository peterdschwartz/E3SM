#include "catch2/catch.hpp"

#include "share/eamxx_types.hpp"
#include "ekat/ekat_pack.hpp"
#include "ekat/kokkos/ekat_kokkos_utils.hpp"
#include "shoc_functions.hpp"
#include "shoc_test_data.hpp"
#include "share/util/eamxx_setup_random_test.hpp"

#include "shoc_unit_tests_common.hpp"

namespace scream {
namespace shoc {
namespace unit_test {

template <typename D>
struct UnitWrap::UnitTest<D>::TestDiagSecondMoments : public UnitWrap::UnitTest<D>::Base {

  void run_property()
  {
    static constexpr Int shcol    = 2;
    static constexpr Int nlev     = 5;
    static constexpr auto nlevi   = nlev + 1;

    // Property test for the mid level function:
    //  diag_second_moments

    // TEST
    //  Feed routine profiles with well mixed, unstable, and stable layers
    //  Verify output is as physically expected and that output falls within
    //  a reasonable range.

    // Define the liquid water potential temperature [K]
    static constexpr Real thetal[nlev] = {310, 307, 302, 302, 303};
    // Define the total water mixing ratio [kg/kg]
    static constexpr Real qw[nlev] = {1e-2, 1.2e-2, 1.5e-2, 1.5e-2, 1.4e-2};
    // Define the zonal wind [m/s]
    static constexpr Real u_wind[nlev] = {4, 4, 2, 0, -1};
    // define the meridional wind [m/s]
    static constexpr Real v_wind[nlev] = {-2, -2, 1, 3, 0};
    // Define the TKE [m2/s2]
    static constexpr Real tke[nlev] = {0.2, 0.3, 0.5, 0.4, 0.1};
    // Define the heights on the zi grid [m]
    static constexpr Real zi_grid[nlevi] = {900, 500, 150, 90, 50, 0};
    // Define the return to isotropy timescale [s]
    static constexpr Real isotropy[nlev] = {1000, 2000, 4000, 1000, 500};
    // Define the eddy vicosity for heat and momentum [m2/s]
    static constexpr Real tkh[nlev] = {3, 10, 50, 30, 20};
    // Define the mixing length [m]
    static constexpr Real shoc_mix[nlev] = {300, 500, 2000, 1500, 300};

    // set a large value to test that boundaries have not been modifed
    static constexpr Real largeval = 1000;

    // establish reasonable bounds for checking result
    static constexpr Real thl_sec_ubound = 1000; // [K^s]
    static constexpr Real qwthl_sec_bound = 1e-1; // [K kg/kg]
    static constexpr Real wthl_sec_bound = 10; // [K m/s]
    static constexpr Real wqw_sec_bound = 1e-3; // [kg/kg m/s]
    static constexpr Real uw_sec_bound = 10; // [m2/s2]
    static constexpr Real vw_sec_bound = 10; // [m2/s2]
    static constexpr Real wtke_sec_bound = 1; // [m3/s3]

    // Compute height information based on zi_grid
    Real zt_grid[nlev];
    Real dz_zi[nlevi];
    // Compute heights on midpoint grid
    for(Int n = 0; n < nlev; ++n) {
      zt_grid[n] = 0.5*(zi_grid[n]+zi_grid[n+1]);
      if (n == 0){
        dz_zi[n] = 0;
      }
      else{
        dz_zi[n] = zt_grid[n-1] - zt_grid[n];
      }
    }
    // set upper condition for dz_zi
    dz_zi[nlevi-1] = zt_grid[nlev-1];

    // Default SHOC formulation, not 1.5 TKE closure assumptions
    const bool shoc_1p5tke = false;

    // Initialize data structure for bridging to F90
    DiagSecondMomentsData SDS(shcol, nlev, nlevi, shoc_1p5tke);

    // Test that the inputs are reasonable.
    REQUIRE( (SDS.shcol == shcol && SDS.nlev == nlev && SDS.nlevi == nlevi) );
    REQUIRE(SDS.nlevi == SDS.nlev+1);

    // Load up the new data
    for(Int s = 0; s < shcol; ++s) {
      // Fill in test data on zt_grid.
      for(Int n = 0; n < nlev; ++n) {
        const auto offset = n + s * nlev;

        SDS.zt_grid[offset] = zt_grid[n];
        SDS.tke[offset] = tke[n];
        SDS.thetal[offset] = thetal[n];
        SDS.qw[offset] = qw[n];
        SDS.u_wind[offset] = u_wind[n];
        SDS.v_wind[offset] = v_wind[n];
        SDS.isotropy[offset] = isotropy[n];
        SDS.shoc_mix[offset] = shoc_mix[n];
        // Intentionally feed tk and tkh the same value
        SDS.tk[offset] = tkh[n];
        SDS.tkh[offset] = tkh[n];
      }

      // Fill in test data on zi_grid.
      for(Int n = 0; n < nlevi; ++n) {
        const auto offset = n + s * nlevi;

        SDS.dz_zi[offset] = dz_zi[n];
        SDS.zi_grid[offset] = zi_grid[n];

        // Initialize the boundaries for the second moments
        //  THESE SHOULD NOT BE MODIFIED BY THIS ROUTINE
        if ( (n == 0 || n == nlevi-1) ){
          SDS.thl_sec[offset]=largeval;
          SDS.qw_sec[offset]=largeval;
          SDS.qwthl_sec[offset]=largeval;
          SDS.wthl_sec[offset]=largeval;
          SDS.wqw_sec[offset]=largeval;
          SDS.uw_sec[offset]=largeval;
          SDS.vw_sec[offset]=largeval;
          SDS.wtke_sec[offset]=largeval;
        }
      }

    }

    // Check that the inputs make sense

    for(Int s = 0; s < shcol; ++s) {
      // nlevi loop
      for (Int n = 0; n < nlevi; ++n){
        const auto offset = n + s * nlevi;
        // Make sure top level dz_zi value is zero
        if (n == 0){
          REQUIRE(SDS.dz_zi[offset] == 0);
        }
        // Otherwise, should be greater than zero
        else{
          REQUIRE(SDS.dz_zi[offset] > 0);
        }
        // Check that zi increases updward
        if (n < nlevi-1){
          REQUIRE(SDS.zi_grid[offset + 1] - SDS.zi_grid[offset] < 0);
        }
      }
      // nlev loop
      for (Int n = 0; n < nlev; ++n){
        const auto offset = n + s * nlev;
        // Check that zt increases upward
        if (n < nlev-1){
          REQUIRE(SDS.zt_grid[offset + 1] - SDS.zt_grid[offset] < 0);
        }
        REQUIRE(SDS.shoc_mix[offset] > 0);
        REQUIRE(SDS.tke[offset] > 0);
        REQUIRE(SDS.tkh[offset] > 0);
        REQUIRE(SDS.tk[offset] > 0);
        REQUIRE(SDS.qw[offset] > 0);
        REQUIRE(SDS.thetal[offset] > 0);
        REQUIRE(SDS.isotropy[offset] > 0);
      }
    }

    // Call the C++ implementation
    diag_second_moments(SDS);

    // Verify output makes sense
    for(Int s = 0; s < shcol; ++s) {
      for (Int n = 0; n < nlev; ++n){
        const auto offset = n + s * nlev;
        // Verify TKE is in reasonable range
        REQUIRE(SDS.w_sec[offset] > 0);
        REQUIRE(SDS.w_sec[offset] < SDS.tke[offset]);
      }
      for (Int n = 0; n < nlevi; ++n){
        const auto offset = n + s * nlevi;

        // validate that the boundary points
        //  have NOT been modified for second moments
        if (n == 0 || n == nlevi-1){
          SDS.thl_sec[offset]=largeval;
          SDS.qw_sec[offset]=largeval;
          SDS.qwthl_sec[offset]=largeval;
          SDS.wthl_sec[offset]=largeval;
          SDS.wqw_sec[offset]=largeval;
          SDS.uw_sec[offset]=largeval;
          SDS.vw_sec[offset]=largeval;
          SDS.wtke_sec[offset]=largeval;
        }
        else{
          // Validate Downgradient assumption for
          //   various possible layers.  Note that these physics
          //   have been tested in lower level functions, but
          //   as a double check, will do here for ONE variable.
          // conditionally stable layer
          if ((thetal[n-1] - thetal[n]) > 0){
            REQUIRE(SDS.wthl_sec[offset] < 0);
          }
          // well mixed layer
          if ((thetal[n-1] - thetal[n]) == 0){
            REQUIRE(SDS.wthl_sec[offset] == 0);
          }
          // unstable layer
          if ((thetal[n-1] - thetal[n]) < 0){
            REQUIRE(SDS.wthl_sec[offset] > 0);
          }

          // Validate the covariance formulation.
          // well mixed layer test
          if ((thetal[n-1] - thetal[n]) == 0 ||
              (qw[n-1] - qw[n]) == 0){
            REQUIRE(SDS.qwthl_sec[offset] == 0);
          }

          // validate values are NEGATIVE if potential
          //  temperature INCREASES with height and total water
          //  DECREASES with height
          if ((thetal[n-1] - thetal[n]) > 0 &&
              (qw[n-1] - qw[n]) < 0){
            REQUIRE(SDS.qwthl_sec[offset] < 0);
          }

          // validate values are POSITIVE if both
          //   potential temperature and total water
          //   DECREASE with height
          if ((thetal[n-1] - thetal[n]) < 0 &&
              (qw[n-1] - qw[n]) < 0){
            REQUIRE(SDS.qwthl_sec[offset] > 0);
          }

          // Now check that all output falls in reasonable bounds
          REQUIRE(SDS.thl_sec[offset] >= 0);
          REQUIRE(SDS.thl_sec[offset] < thl_sec_ubound);

          REQUIRE(SDS.qw_sec[offset] >= 0);
          REQUIRE(SDS.qw_sec[offset] < thl_sec_ubound);

          REQUIRE(std::abs(SDS.qwthl_sec[offset]) < qwthl_sec_bound);
          REQUIRE(std::abs(SDS.wthl_sec[offset]) < wthl_sec_bound);
          REQUIRE(std::abs(SDS.qwthl_sec[offset]) < qwthl_sec_bound);
          REQUIRE(std::abs(SDS.wqw_sec[offset]) < wqw_sec_bound);
          REQUIRE(std::abs(SDS.uw_sec[offset]) < uw_sec_bound);
          REQUIRE(std::abs(SDS.vw_sec[offset]) < vw_sec_bound);
          REQUIRE(std::abs(SDS.wtke_sec[offset]) < wtke_sec_bound);
        }
      }
    }

    // SECOND TEST
    // If SHOC is reverted to a 1.5 TKE closure then test to make sure that
    //  all values of the scalar variances are zero everywhere.
    //  Will use the same input data as the previous test.

    // Activate 1.5 TKE closure assumptions
    SDS.shoc_1p5tke = true;

    // Call the C++ implementation
    diag_second_moments(SDS);

    // Require that all values of w2 are ZERO
    for (Int s = 0; s < shcol; ++s){
      // nlev checks
      for (Int n = 0; n < nlev; ++n){
        const auto offset = n + s * nlev;
        REQUIRE(SDS.w_sec[offset] == 0);
      }
      // nlevi checks
      for (Int n = 0; n < nlevi; ++n){
        const auto offset = n + s * nlevi;
        REQUIRE(SDS.thl_sec[offset] == 0);
        REQUIRE(SDS.qw_sec[offset] == 0);
        REQUIRE(SDS.qwthl_sec[offset] == 0);
      }
    }

  } // run_property

  void run_bfb()
  {
    auto engine = Base::get_engine();

    DiagSecondMomentsData baseline_data[] = {
      DiagSecondMomentsData(36,  72, 73, false),
      DiagSecondMomentsData(72,  72, 73, false),
      DiagSecondMomentsData(128, 72, 73, false),
      DiagSecondMomentsData(256, 72, 73, false),
    };

    // Generate random input data
    for (auto& d : baseline_data) {
      d.randomize(engine);
    }

    // Create copies of data for use by cxx. Needs to happen before reads so that
    // inout data is in original state
    DiagSecondMomentsData cxx_data[] = {
      DiagSecondMomentsData(baseline_data[0]),
      DiagSecondMomentsData(baseline_data[1]),
      DiagSecondMomentsData(baseline_data[2]),
      DiagSecondMomentsData(baseline_data[3]),
    };

    // Assume all data is in C layout

    // Read baseline data
    if (this->m_baseline_action == COMPARE) {
      for (auto& d : baseline_data) {
        d.read(Base::m_ifile);
      }
    }

    // Get data from cxx
    for (auto& d : cxx_data) {
      diag_second_moments(d);
    }

    // Verify BFB results, all data should be in C layout
    if (SCREAM_BFB_TESTING && this->m_baseline_action == COMPARE) {
      static constexpr Int num_runs = sizeof(baseline_data) / sizeof(DiagSecondMomentsData);
      for (Int i = 0; i < num_runs; ++i) {
        DiagSecondMomentsData& d_baseline = baseline_data[i];
        DiagSecondMomentsData& d_cxx = cxx_data[i];
        for (Int k = 0; k < d_baseline.total(d_baseline.w_sec); ++k) {
          REQUIRE(d_baseline.w_sec[k] == d_cxx.w_sec[k]);
        }
        for (Int k = 0; k < d_baseline.total(d_baseline.thl_sec); ++k) {
          REQUIRE(d_baseline.thl_sec[k] == d_cxx.thl_sec[k]);
          REQUIRE(d_baseline.qw_sec[k] == d_cxx.qw_sec[k]);
          REQUIRE(d_baseline.wthl_sec[k] == d_cxx.wthl_sec[k]);
          REQUIRE(d_baseline.wqw_sec[k] == d_cxx.wqw_sec[k]);
          REQUIRE(d_baseline.qwthl_sec[k] == d_cxx.qwthl_sec[k]);
          REQUIRE(d_baseline.uw_sec[k] == d_cxx.uw_sec[k]);
          REQUIRE(d_baseline.vw_sec[k] == d_cxx.vw_sec[k]);
          REQUIRE(d_baseline.wtke_sec[k] == d_cxx.wtke_sec[k]);
        }
      }
    } // SCREAM_BFB_TESTING
    else if (this->m_baseline_action == GENERATE) {
      for (auto& d : cxx_data) {
        d.write(Base::m_ofile);
      }
    }
  } // run_bfb

};

} // namespace unit_test
} // namespace shoc
} // namespace scream

namespace {

TEST_CASE("diag_second_moments_property", "shoc")
{
  using TestStruct = scream::shoc::unit_test::UnitWrap::UnitTest<scream::DefaultDevice>::TestDiagSecondMoments;

  TestStruct().run_property();
}

TEST_CASE("diag_second_moments_bfb", "shoc")
{
  using TestStruct = scream::shoc::unit_test::UnitWrap::UnitTest<scream::DefaultDevice>::TestDiagSecondMoments;

  TestStruct().run_bfb();
}

} // empty namespace
