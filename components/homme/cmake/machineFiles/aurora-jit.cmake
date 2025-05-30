#module restore
#module load spack-pe-base cmake
#module list


SET (AURORA_MACHINE TRUE CACHE BOOL "")

SET(BUILD_HOMME_WITHOUT_PIOLIBRARY TRUE CACHE BOOL "")
SET(HOMMEXX_MPI_ON_DEVICE FALSE CACHE BOOL "")

SET(HOMME_FIND_BLASLAPACK TRUE CACHE BOOL "")

SET(WITH_PNETCDF FALSE CACHE FILEPATH "")

SET(USE_QUEUING FALSE CACHE BOOL "")

#temp hack
SET(HOMME_USE_KOKKOS TRUE CACHE BOOL "")
SET(HOMME_USE_MKL TRUE CACHE BOOL "")

SET(BUILD_HOMME_PREQX_KOKKOS TRUE CACHE BOOL "")
SET(BUILD_HOMME_THETA_KOKKOS TRUE CACHE BOOL "")

set(Kokkos_ROOT $ENV{KOKKOS_HOME} CACHE STRING "")

SET(USE_TRILINOS OFF CACHE BOOL "")

SET(HOMME_ENABLE_COMPOSE FALSE CACHE BOOL "")

SET(CMAKE_CXX_STANDARD 17)

SET(CMAKE_C_COMPILER "mpicc" CACHE STRING "")
SET(CMAKE_Fortran_COMPILER "mpifort" CACHE STRING "")
SET(CMAKE_CXX_COMPILER "mpicxx" CACHE STRING "")

#AOT flags
SET(SYCL_COMPILE_FLAGS "-std=c++17 -fsycl -fsycl-device-code-split=per_kernel -fno-sycl-id-queries-fit-in-int -fsycl-unnamed-lambda")
SET(SYCL_LINK_FLAGS "-fsycl-max-parallel-link-jobs=32 -fsycl")

SET(ADD_Fortran_FLAGS "-fc=ifx -fpscomp logicals -O3 -DNDEBUG -DCPRINTEL -g" CACHE STRING "")
SET(ADD_C_FLAGS "-O3 -DNDEBUG " CACHE STRING "")

SET(ADD_CXX_FLAGS "-std=c++17 -fp-model=precise -O3 -DNDEBUG ${SYCL_COMPILE_FLAGS}" CACHE STRING "")
SET(ADD_LINKER_FLAGS "-O3 -DNDEBUG ${SYCL_LINK_FLAGS} -fortlib" CACHE STRING "")

set (ENABLE_OPENMP OFF CACHE BOOL "")
set (ENABLE_COLUMN_OPENMP OFF CACHE BOOL "")
set (ENABLE_HORIZ_OPENMP OFF CACHE BOOL "")

set (HOMME_TESTING_PROFILE "dev" CACHE STRING "")

set (USE_NUM_PROCS 12 CACHE STRING "")

SET (USE_MPI_OPTIONS "--pmi=pmix --cpu-bind list:0-7,104-111:8-15,112-119:16-23,120-127:24-31,128-135:32-39,136-143:40-47,144-151:52-59,156-163:60-67,164-171:68-75,172-179:76-83,180-187:84-91,188-195:92-99,196-203 gpu_tile_compact.sh" CACHE FILEPATH "")
