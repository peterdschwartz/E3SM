module dynPriorWeightsMod

#include "shr_assert.h"

  !---------------------------------------------------------------------------
  ! !DESCRIPTION:
  ! Defines a derived type and associated methods for working with prior subgrid weights
  ! (i.e., before the weight updates of this time step)
  !
  ! !USES:
  use shr_kind_mod   , only : r8 => shr_kind_r8
  use shr_log_mod    , only : errMsg => shr_log_errMsg
  use decompMod      , only : bounds_type, BOUNDS_LEVEL_PROC
  use ColumnType     , only : col_pp
  use VegetationType , only : veg_pp
  !
  implicit none
  save
  private
  !

  ! !PUBLIC TYPES:
  public :: prior_weights_type
  public :: set_prior_weights

  type prior_weights_type
     ! Components are public for ease-of-use and efficiency. However, these components
     ! should be treated as read-only!
     real(r8), pointer, public :: pwtcol(:)  => null()   ! prior pft weight on the column
     logical , pointer, public :: cactive(:) => null()   ! prior col_pp%active flags
  end type prior_weights_type

  interface prior_weights_type
     module procedure constructor   ! initialize a prior_weights_type object
  end interface prior_weights_type

contains

  ! ======================================================================
  ! Constructors
  ! ======================================================================

  ! ----------------------------------------------------------------------
  type(prior_weights_type) function constructor(bounds)
    !
    ! !DESCRIPTION:
    ! Initialize a prior_weights_type object
    !
    ! !ARGUMENTS:
    type(bounds_type), intent(in) :: bounds   ! processor bounds
    !
    ! !LOCAL VARIABLES:

    character(len=*), parameter :: subname = 'prior_weights_type constructor'
    ! ----------------------------------------------------------------------

    SHR_ASSERT(bounds%level == BOUNDS_LEVEL_PROC, subname // ': argument must be PROC-level bounds')

    allocate(constructor%pwtcol(bounds%begp:bounds%endp))
    allocate(constructor%cactive(bounds%begc:bounds%endc))
  end function constructor


  ! ======================================================================
  ! Public methods
  ! ======================================================================

  ! ----------------------------------------------------------------------
  subroutine set_prior_weights(this, bounds)
    !
    ! !DESCRIPTION:
    ! Set prior weights to current weights
    ! !ARGUMENTS:
    type(prior_weights_type) , intent(inout) :: this   ! this object
    type(bounds_type)         , intent(in)    :: bounds
    !
    ! !LOCAL VARIABLES:
    integer :: p, c,begp,endp,begc,endc   ! patch & col indices
    ! ----------------------------------------------------------------------
    begp = bounds%begp; endp = bounds%endp
    begc = bounds%begc; endc = bounds%endc

    !$acc parallel loop independent gang vector default(present) async(1)
    do p = begp, endp
       this%pwtcol(p) = veg_pp%wtcol(p)
    end do

    !$acc parallel loop independent gang vector default(present) async(2)
    do c = begc, endc
       this%cactive(c) = col_pp%active(c)
    end do
  end subroutine set_prior_weights


end module dynPriorWeightsMod
