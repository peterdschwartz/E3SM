if (NOT DEBUG)
  string(APPEND CFLAGS " -O2 -Mvect=nosimd")
endif()
if (COMP_NAME STREQUAL gptl)
  string(APPEND CPPDEFS " -DHAVE_SLASHPROC")
endif()
if (NOT DEBUG)
  string(APPEND FFLAGS " -O2 -Mvect=nosimd -DSUMMITDEV_PGI")
endif()
string(APPEND LDFLAGS " -gpu=cc70,cc60,deepcopy -Minfo=accel")
string(APPEND SLIBS " -L$ENV{HDF5_PATH}/lib -lhdf5_hl -lhdf5 -L$ENV{NETCDF_C_PATH}/lib -lnetcdf -L$ENV{NETCDF_FORTRAN_PATH}/lib -lnetcdff -L$ENV{BLASLAPACK_DIR} -lblas -llapack")
set(CXX_LINKER "FORTRAN")
string(APPEND CXX_LIBS " -lstdc++")
set(MPICXX "mpicxx")
set(PIO_FILESYSTEM_HINTS "gpfs")
set(SFC "nvfortran")
set(NETCDF_C_PATH "$ENV{NETCDF_C_PATH}")
set(NETCDF_FORTRAN_PATH "$ENV{NETCDF_FORTRAN_PATH}")
set(PNETCDF_PATH "")
set(SUPPORTS_CXX "TRUE")