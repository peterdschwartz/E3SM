# Standalone unit test of lnd2atmAvgMod (no CIME, no pFUnit); reuses hist_compute_test's
# synthetic subgrid and serial reference averages.
#
#   cmake -S . -B build [-DCMAKE_Fortran_COMPILER=nvfortran] [-DACC=MULTICORE|GPU] [-DGPU_FLAGS=cc80]
#   cmake --build build && ctest --test-dir build --output-on-failure
cmake_minimum_required(VERSION 3.16)
project(lnd2atm_avg_test Fortran)

set(ACC "OFF" CACHE STRING "OpenACC: OFF, MULTICORE or GPU (nvfortran)")
set(GPU_FLAGS "cc80" CACHE STRING "nvfortran -gpu= suboptions for ACC=GPU")

set(E3SM_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/../../../../../..)
set(ELM_MAIN ${CMAKE_CURRENT_SOURCE_DIR}/../..)
set(HIST_TEST ${CMAKE_CURRENT_SOURCE_DIR}/../hist_compute_test)

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif()
if (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -cpp -ffree-line-length-none")
  set(CMAKE_Fortran_FLAGS_DEBUG "-g -O0 -fcheck=all -fbacktrace -Wall -Wno-compare-reals -Wno-unused-dummy-argument -Wno-target-lifetime")
elseif (CMAKE_Fortran_COMPILER_ID MATCHES "^(NVHPC|PGI)$")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -Mpreprocess")
  set(CMAKE_Fortran_FLAGS_DEBUG "-g -O0")
endif()

add_executable(test_lnd2atm_avg
  ${E3SM_ROOT}/share/util/shr_kind_mod.F90
  ${HIST_TEST}/shr_sys_stub.F90
  elm_varctl_stub.F90
  ${ELM_MAIN}/CompactLayoutMod.F90
  ${ELM_MAIN}/subgridAveViewMod.F90
  ${ELM_MAIN}/histComputeMod.F90
  ${ELM_MAIN}/lnd2atmAvgMod.F90
  ${HIST_TEST}/fake_subgrid_mod.F90
  ${HIST_TEST}/hist_reference_mod.F90
  test_lnd2atm_avg.F90)
if (ACC STREQUAL "MULTICORE")
  target_compile_options(test_lnd2atm_avg PRIVATE -acc=multicore -Minfo=accel)
  target_link_options(test_lnd2atm_avg PRIVATE -acc=multicore)
elseif (ACC STREQUAL "GPU")
  # the reference runs on the host: no FMA on the device keeps the averages bit-for-bit
  target_compile_options(test_lnd2atm_avg PRIVATE -acc=gpu -gpu=${GPU_FLAGS} -Mnofma -Minfo=accel)
  target_link_options(test_lnd2atm_avg PRIVATE -acc=gpu -gpu=${GPU_FLAGS})
endif()

enable_testing()
add_test(NAME lnd2atm_avg COMMAND test_lnd2atm_avg)
