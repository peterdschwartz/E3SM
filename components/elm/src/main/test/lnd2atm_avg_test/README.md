# lnd2atmAvgMod unit test

Checks the table of gridcell averages that `lnd2atmMod` uses for the land -> atmosphere export
state (`lnd2atmAvgMod`) against the serial averages to gridcells of the history test
(`../hist_compute_test/hist_reference_mod.F90`: `ref_p2g`, `ref_c2g`), on that test's synthetic
subgrid (`fake_subgrid_mod`: landunits ordered by type across gridcells, bounds not starting at
1, zero weights, inactive points).

54 entries cover patch and column sources, every c2l/l2g scale-type pair (the unity pair goes
through the `*_range_unity` averages, as in `subgridAveMod`), single fields and levels of 2d
fields added as `lnd2atmMod` adds them (ELM's pointer components), and both groups (the
minimal export state and the rest of `lnd2atm`), averaged separately. Every step has new values
(10% spval), and the subgrid changes every 3 steps. The gridcell values must equal the
reference bit for bit.

```bash
cmake -S . -B build -DCMAKE_Fortran_COMPILER=gfortran && cmake --build build && ctest --test-dir build --output-on-failure
cmake -S . -B build-mc -DCMAKE_Fortran_COMPILER=nvfortran -DACC=MULTICORE && cmake --build build-mc && build-mc/test_lnd2atm_avg
cmake -S . -B build-gpu -DCMAKE_Fortran_COMPILER=nvfortran -DACC=GPU && cmake --build build-gpu && build-gpu/test_lnd2atm_avg
```

`elm_varctl_stub.F90` stands in for ELM's `elm_varctl` (`subgridAveViewMod` uses
`elm_device_ready`). The GPU build uses `-Mnofma`, as the history test does.
