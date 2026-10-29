# accumComputeMod unit test

Checks the per-step update and extraction of ELM's accumulator fields (`accumComputeMod`,
used by `accumulMod`) against `accum_reference_mod`: the original serial algorithm of
`update_accum_field_sl/ml` and `extract_accum_field_sl/ml`, applied to plain arrays.

18 fields cover every accumulation type (`timeavg`, `runmean`, `runaccum`), periods of 1, 6
and 24 steps, single- and multi-level fields, and bounds that don't start at 1. About 15% of
the points are inactive, and the active flags change every 7 steps. The `runaccum` fields get
reset triggers (`-99999`) and values that reach both clamps (0 and 99999). Every step from
nstep 0 to 100, the values, the step counts and the extracted values must equal the
reference bit for bit.

With OpenACC the fields move to the device at their first update, as in ELM. Half the
fields pass model arrays that are already on the device (like ELM's type components), the
others local buffers that are not (copied by the data clauses). Every 10th step runs on the
host (`on_device` false, a host segment of the driver), which pulls the field first and
pushes it after. MULTICORE shares host memory and cannot catch a missing transfer; the GPU
build does (dropping the push after a host update fails 734 field-steps).

The single-level fields go through pointer dummies, as `accumulMod`'s
`update/extract_accum_field_sl` pass them (sections of pointers). With `contiguous` dummies
in `accumComputeMod` the compiler passed a temporary copy there, so an extraction updated the
temporary instead of the device copy of the model array (819 field-steps on the GPU; gfortran
warns "An array temporary was created").

```bash
cmake -S . -B build -DCMAKE_Fortran_COMPILER=gfortran && cmake --build build && ctest --test-dir build --output-on-failure
# nvfortran, OpenACC on host threads
cmake -S . -B build-mc -DCMAKE_Fortran_COMPILER=nvfortran -DACC=MULTICORE && cmake --build build-mc && build-mc/test_accum_compute
# nvfortran, OpenACC on a GPU
cmake -S . -B build-gpu -DCMAKE_Fortran_COMPILER=nvfortran -DACC=GPU && cmake --build build-gpu && build-gpu/test_accum_compute
```

The GPU build uses `-Mnofma`, as the history test does: the reference runs on the host, and
fused multiply-adds on the device change the running means in the last bits.
