module reweightMod

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! Top level driver for things that happen when subgrid weights are changed. This is in
  ! a separate module from subgridWeightsMod in order to keep subgridWeightsMod lower-
  ! level - and particularly to break its dependency on filterMod.
  !
  !
  ! !USES:
#include "shr_assert.h"
  use shr_log_mod    , only : errMsg => shr_log_errMsg
  use shr_kind_mod   , only : r8 => shr_kind_r8
  !
  ! PUBLIC TYPES:
  implicit none
  save

  private
  !
  ! !PUBLIC MEMBER FUNCTIONS:
  public :: reweight_wrapup               ! do modifications and error-checks after modifying subgrid weights
  
  !-----------------------------------------------------------------------

contains

  !-----------------------------------------------------------------------
  subroutine reweight_wrapup(bounds, icemask_grc)
    !
    ! !DESCRIPTION:
    ! Do additional modifications and error-checks that should be done after modifying subgrid
    ! weights
    !
    ! This should be called whenever any weights change (e.g., pft weights on the column,
    ! landunit weights on the grid cell, etc.).
    !
    ! !USES:
    use filterMod         , only : setFilters
#ifdef _OPENACC
    use openacc           , only : acc_is_present  ! spel device-data
    use filterMod         , only : filter, filter_inactive_and_active
    use DeepCopySubgridMod, only : update_clumpfilter
#endif
    use subgridWeightsMod , only : set_active, check_weights
    use decompMod         , only : bounds_type, BOUNDS_LEVEL_CLUMP
    use columntype, only : col_pp  ! spel acc-sync
    use landunittype, only : lun_pp  ! spel acc-sync
    use vegetationtype, only : veg_pp  ! spel acc-sync
    !
    ! !ARGUMENTS:
    type(bounds_type) , intent(in) :: bounds                      ! clump bounds
    real(r8)          , intent(in) :: icemask_grc( bounds%begg: ) ! ice sheet grid coverage mask [gridcell]
    !------------------------------------------------------------------------

    SHR_ASSERT(bounds%level == BOUNDS_LEVEL_CLUMP, errMsg(__FILE__, __LINE__))

    call set_active(bounds)
    call check_weights(bounds, active_only=.false.)
    call check_weights(bounds, active_only=.true.)
    !$acc update device(col_pp%active, lun_pp%active, veg_pp%active) if_present
    call setFilters(bounds, icemask_grc(bounds%begg:bounds%endg))

#ifdef _OPENACC
    ! spel device-data: setFilters rebuilt this clump's filters on the host; once the state is on the
    ! device (after elm_device_copyin) send them there. Nothing else changed here: check_weights
    ! only reads, and set_active's `active` flags are pushed above.
    if (acc_is_present(filter)) then
       call update_clumpfilter(filter(bounds%clump_index), to_device=.true.)
       call update_clumpfilter(filter_inactive_and_active(bounds%clump_index), to_device=.true.)
    end if
#endif
  end subroutine reweight_wrapup

end module reweightMod
