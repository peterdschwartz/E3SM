#!/bin/bash -e

set +x 
# Handle arguments:
MODE=$1
if [ -n "$MODE" ]; then
   shift
   ARGS="$*"
fi
# template to create a case run shell script. This should only ever be called
# by case.submit when on batch. Use case.submit from the command line to run your case.

# cd to case
cd $(./xmlquery CASEROOT --value)
# Set PYTHONPATH so we can make cime calls if needed
LIBDIR=/autofs/nccs-svm1_home1/pschwar3/master-E3SM/E3SM/cime/scripts/lib
export PYTHONPATH=$LIBDIR:$PYTHONPATH

# setup environment
source .env_mach_specific.sh

# get new lid
lid=debug
export LID=$lid

# Clean/make timing dirs
RUNDIR=$(./xmlquery RUNDIR --value)
if [ -e $RUNDIR/timing ]; then
    /bin/rm -rf $RUNDIR/timing
fi
mkdir -p $RUNDIR/timing/checkpoints

# minimum namelist action
./preview_namelists --component cpl
#./preview_namelists # uncomment for full namelist generation

# uncomment for lockfile checking
# ./check_lockedfiles

# setup OMP_NUM_THREADS
export OMP_NUM_THREADS=$(./xmlquery THREAD_COUNT --value)
export OMPI_COMM_WORLD_RANK=1

# save prerun provenance?

# MPIRUN!
cd $(./xmlquery RUNDIR --value)
#jsrun -X 1 --nrs 1 --rs_per_host 1 --tasks_per_rs 1 -d plane:1 --cpu_per_rs 21 --gpu_per_rs 0 --bind packed:smt:1 -E OMP_NUM_THREADS=1 -E OMP_PROC_BIND=spread -E OMP_PLACES=threads -E OMP_STACKSIZE=256M --latency_priority cpu-cpu --stdio_mode prepended /gpfs/alpine2/cli180/proj-shared/pschwar3/e3sm_runs/uELM_MOF21points_I1850uELMCNPRDCTCBC/bld/e3sm.exe   >> e3sm.log.$LID 2>&1 
if [ -z "$MODE" ]; then
    $RUNDIR/../bld/e3sm.exe
elif [ $MODE == 'memcheck' ]; then
    compute-sanitizer --tool memcheck $ARGS $RUNDIR/../bld/e3sm.exe
elif [ $MODE == 'initcheck' ]; then
    compute-sanitizer --tool initcheck $RUNDIR/../bld/e3sm.exe
elif [ $MODE == 'gdb' ]; then
    cuda-gdb  $RUNDIR/../bld/e3sm.exe
fi

# save logs?

# save postrun provenance?

# resubmit ?
