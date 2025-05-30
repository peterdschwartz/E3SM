#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

module thread_mod

#ifdef _OPENMP
  use omp_lib, only: omp_get_thread_num, &
       omp_in_parallel, &
       omp_set_num_threads, &
       omp_get_max_threads, &
       omp_get_num_threads, &
       omp_get_nested
#endif

  implicit none
  private

#ifdef MODEL_CESM
  integer, public, pointer :: NThreads   ! total number of threads
                                         ! standalone HOMME: from namelist
                                         ! in CAM: set by driver
  integer, public, pointer :: hthreads   ! computed based on nthreads, vthreads,nelemd
  integer, public, pointer :: vthreads   ! not used unless set in namelist
#else
 integer, public :: NThreads   ! total number of threads
                                ! standalone HOMME: from namelist
                                ! in CAM: set by driver
  integer, public :: hthreads   ! computed based on nthreads, vthreads,nelemd
  integer, public :: vthreads = 1   ! not used unless set in namelist
#endif
  public :: omp_get_thread_num
  public :: omp_in_parallel
  public :: omp_set_num_threads
  public :: omp_get_max_threads
  public :: omp_get_num_threads
  public :: omp_get_nested

#ifndef _OPENMP
contains

  function omp_get_thread_num() result(ithr)
    integer ithr
    ithr=0
  end function omp_get_thread_num

  function omp_get_num_threads() result(ithr)
    integer ithr
    ithr=1
  end function omp_get_num_threads

  function omp_in_parallel() result(ans)
    logical ans
    ans=.FALSE.
  end function omp_in_parallel

  subroutine omp_set_num_threads(NThreads)
    integer Nthreads
    NThreads=1
  end subroutine omp_set_num_threads

  integer function omp_get_max_threads()
    omp_get_max_threads=1
  end function omp_get_max_threads

  integer function omp_get_nested()
    omp_get_nested=0
  end function omp_get_nested

#endif

end module thread_mod
