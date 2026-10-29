module accumulMod

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! This module contains generic subroutines that can be used to
  ! define, accumulate and extract  user-specified fields over
  ! user-defined intervals. Each interval  and accumulation type is
  ! unique to each field processed.
  ! Subroutine [init_accumulator] defines the values of the accumulated
  ! field data structure. Subroutine [update_accum_field] does
  ! the actual accumulation for a given field.
  ! Four types of accumulations are possible:
  ! - Average over time interval. Time average fields are only
  !   valid at the end of the averaging interval.
  ! - Running mean over time interval. Running means are valid once the
  !   length of the simulation exceeds the
  ! - Running accumulation over time interval. Accumulated fields are
  !   continuously accumulated. The trigger value "-99999." resets
  !   the accumulation to zero.
  !
  ! Inactive / zero-weight subgrid elements are skipped during update,
  ! following the CLM (ctsm5.4.042) active-element accumulator fix.
  !
  ! The fields and their per-step update/extraction are in accumComputeMod (device
  ! kernels when the state is on the device: elm_device_ready); this module keeps the field
  ! list, the lookup by name, the initialization and the restart.
  !
  ! !USES:
  use elm_varctl, only : elm_device_ready  ! compute constructs run on the host before the device copy
  use shr_kind_mod, only: r8 => shr_kind_r8
  use shr_sys_mod , only: shr_sys_abort
  use elm_varctl  , only: iulog, elm_device_ready
  use accumComputeMod, only : accum_field, accumResetVal, accum_type_code, accum_update, accum_extract, &
       accum_host_values, accum_device_values
  use TopounitType   , only : top_pp
  use LandunitType   , only : lun_pp
  use ColumnType     , only : col_pp
  use VegetationType , only : veg_pp
  !
  ! !PUBLIC TYPES:
  implicit none
  save
  !
  ! !PUBLIC MEMBER FUNCTIONS:
  public :: accumulRest          ! Write/read restart of accumulation fields
  public :: init_accum_field     ! Initialize an accumulator field
  public :: print_accum_fields   ! Print info about accumulator fields
  public :: extract_accum_field  ! Extracts the current value of an accumulator field
  public :: update_accum_field   ! Update the current value of an accumulator field
  public :: accumResetVal        ! (accumComputeMod) the runaccum reset trigger

  interface extract_accum_field
     module procedure extract_accum_field_sl ! Extract current val of single-level accumulator field
     module procedure extract_accum_field_ml ! Extract current val of multi-level accumulator field
  end interface
  interface update_accum_field               ! Updates the current value of an accumulator field
     module procedure update_accum_field_sl  ! Update single-level accumulator field
     module procedure update_accum_field_ml  ! Update multi-level accumulator field
  end interface
  private
  !

  integer, parameter :: max_accum = 100    !maximum number of accumulated fields
  type (accum_field) :: accum(max_accum)   !array accumulated fields
  integer :: naccflds = 0                  !accumulator field counter

  !------------------------------------------------------------------------

contains

  !------------------------------------------------------------------------
  subroutine init_accum_field (name, units, desc, &
       accum_type, accum_period, numlev, subgrid_type, init_value, type2d)
    !
    ! !DESCRIPTION:
    ! Initialize accumulation fields. This subroutine sets:
    ! o name  of accumulated field
    ! o units of accumulated field
    ! o accumulation type of accumulated field
    ! o description of accumulated fields: accdes
    ! o accumulation period for accumulated field (in iterations)
    ! o initial value of accumulated field
    !
    ! !USES:
    use shr_const_mod, only: SHR_CONST_CDAY
    use elm_time_manager, only : get_step_size
    use decompMod, only : get_proc_bounds, get_proc_global
    !
    ! !ARGUMENTS:
    implicit none
    character(len=*), intent(in)           :: name         !field name
    character(len=*), intent(in)           :: units        !field units
    character(len=*), intent(in)           :: desc         !field description
    character(len=*), intent(in)           :: accum_type   !field type: tavg, runm, runa, ins
    integer , intent(in)                   :: accum_period !field accumulation period
    character(len=*), intent(in)           :: subgrid_type !["gridcell","topounit","landunit","column" or "pft"]
    integer , intent(in)                   :: numlev       !number of vertical levels
    real(r8), intent(in)                   :: init_value   !field initial or reset value
    character(len=*), intent(in), optional :: type2d       !level type (optional) - needed if numlev > 1
    !
    ! !LOCAL VARIABLES:
    integer :: nf           ! field index
    integer :: beg1d,end1d  ! beggining and end subgrid indices
    integer :: num1d        ! total number subgrid indices
    integer :: begp, endp   ! per-proc beginning and ending pft indices
    integer :: begc, endc   ! per-proc beginning and ending column indices
    integer :: begl, endl   ! per-proc beginning and ending landunit indices
    integer :: begt, endt   ! per-proc beginning and ending topographic unit indices
    integer :: begg, endg   ! per-proc gridcell ending gridcell indices
    integer :: begCohort, endCohort   ! per-proc beg end cohort indices
    integer :: numg         ! total number of gridcells across all processors
    integer :: numt         ! total number of topographic units all processors
    integer :: numl         ! total number of landunits across all processors
    integer :: numc         ! total number of columns across all processors
    integer :: nump         ! total number of pfts across all processors
    integer :: numCohort    ! total number of cohorts across all processors
    !------------------------------------------------------------------------

    ! Determine necessary indices

    call get_proc_bounds(begg, endg, begt, endt, begl, endl, begc, endc, begp, endp, &
         begCohort, endCohort )
    call get_proc_global(numg, numt, numl, numc, nump, numCohort)

    ! update field index
    ! Consistency check that number of accumulated does not exceed maximum.

    naccflds = naccflds + 1
    if (naccflds > max_accum) then
       write(iulog,*) 'ACCUMULINIT error: user-defined accumulation fields ', &
            'equal to ',naccflds,' exceeds max_accum'
       call shr_sys_abort()
    end if
    nf = naccflds

    ! Note accumulation period must be converted from days
    ! to number of iterations

    accum(nf)%name    = trim(name)
    accum(nf)%units   = trim(units)
    accum(nf)%desc    = trim(desc)
    accum(nf)%acctype = trim(accum_type)
    accum(nf)%acctype_code = accum_type_code(accum_type)
    if (accum(nf)%acctype_code == 0) then
       write(iulog,*) 'ACCUMULINIT error: incorrect accumulation type ', trim(accum_type), ' for field ', &
            trim(name), '; only [timeavg, runmean, runaccum] are currently acceptable'
       call shr_sys_abort()
    end if
    accum(nf)%initval = init_value
    accum(nf)%period  = accum_period
    if (accum(nf)%period < 0) then
       accum(nf)%period = -accum(nf)%period * nint(SHR_CONST_CDAY) / get_step_size()
    end if

    select case (trim(subgrid_type))
    case ('gridcell')
       beg1d = begg
       end1d = endg
       num1d = numg
       ! Gridcells have no type-level active flag; treat all as active.
       allocate(accum(nf)%active_storage(beg1d:end1d))
       accum(nf)%active_storage(:) = .true.
       accum(nf)%active => accum(nf)%active_storage
    case ('topounit')
       beg1d = begt
       end1d = endt
       num1d = numt
       accum(nf)%active => top_pp%active
    case ('landunit')
       beg1d = begl
       end1d = endl
       num1d = numl
       accum(nf)%active => lun_pp%active
    case ('column')
       beg1d = begc
       end1d = endc
       num1d = numc
       accum(nf)%active => col_pp%active
    case ('pft')
       beg1d = begp
       end1d = endp
       num1d = nump
       accum(nf)%active => veg_pp%active
    case default
       write(iulog,*)'ACCUMULINIT: unknown subgrid type ',subgrid_type
       call shr_sys_abort ()
    end select

    accum(nf)%type1d = trim(subgrid_type)
    accum(nf)%beg1d = beg1d
    accum(nf)%end1d = end1d
    accum(nf)%num1d = num1d
    accum(nf)%numlev = numlev

    if (present(type2d)) then
       accum(nf)%type2d = type2d
    else
       accum(nf)%type2d = ' '
    end if
    
    ! Allocate and initialize accumulation field

    allocate(accum(nf)%val(beg1d:end1d,numlev))
    accum(nf)%val(beg1d:end1d,1:numlev) = init_value

    allocate(accum(nf)%nsteps(beg1d:end1d,numlev))
    accum(nf)%nsteps(beg1d:end1d,1:numlev) = 0

  end subroutine init_accum_field

  !------------------------------------------------------------------------
  subroutine print_accum_fields()
    !
    ! !DESCRIPTION:
    ! Diagnostic printout of accumulated fields
    !
    ! !USES:
    use spmdMod, only : masterproc
    !
    ! !ARGUMENTS:
    implicit none
    !
    integer :: i,nf   !indices
    !------------------------------------------------------------------------

    if (masterproc) then
       write(iulog,*)
       write(iulog,*) 'Initializing variables for time accumulation .....'
       write(iulog,'(72a1)') ("-",i=1,60)
       write(iulog,*) 'Accumulated fields'
       write(iulog,1002)
       write(iulog,'(72a1)') ("_",i=1,71)
       do nf = 1, naccflds
          if (accum(nf)%period /= huge(1)) then
             write(iulog,1003) nf,accum(nf)%name,accum(nf)%units,&
                  accum(nf)%acctype, accum(nf)%period, accum(nf)%initval, &
                  accum(nf)%desc
          else
             write(iulog,1004) nf,accum(nf)%name,accum(nf)%units,&
                  accum(nf)%acctype, accum(nf)%initval, accum(nf)%desc
          endif
       end do
       write(iulog,'(72a1)') ("_",i=1,71)
       write(iulog,*)
       write(iulog,'(72a1)') ("-",i=1,60)
       write(iulog,*) 'Successfully initialized variables for accumulation'
       write(iulog,*)
    endif

1002 format(' No',' Name    ',' Units   ',' Type          ','Period',' Inival',' Description')
1003 format((1x,i2),(1x,a8),(1x,a8),(1x,a8), (1x,i7),(1x,f4.0),(1x,a40))
1004 format((1x,i2),(1x,a8),(1x,a8),(1x,a8),'  N.A.',(1x,f4.0),(1x,a40))

  end subroutine print_accum_fields

  !------------------------------------------------------------------------
  subroutine extract_accum_field_sl (name, field, nstep)
    !
    ! !DESCRIPTION:
    ! Extract single-level accumulated field.
    ! This routine extracts the field values from the multi-level
    ! accumulation field. It extracts the current value except if
    ! the field type is a time average. In this case, an absurd value
    ! is assigned to  indicate the time average is not yet valid.
    !
    ! !USES:
    use elm_varcon, only : spval, ispval
    !
    ! !ARGUMENTS:
    implicit none
    character(len=*), intent(in) :: name     !field name
    real(r8), pointer, dimension(:) :: field !field values for current time step
    integer , intent(in) :: nstep            !timestep index
    !
    ! !LOCAL VARIABLES:
    integer :: i,nf          !indices
    integer :: beg,end         !subgrid beginning,ending indices
    !------------------------------------------------------------------------

    ! find field index. return if "name" is not on list

    nf = 0
    do i = 1, naccflds
       if (name == accum(i)%name) nf = i
    end do
    if (nf == 0) then
       write(iulog,*) 'EXTRACT_ACCUM_FIELD_SL error: field name ',name,' not found'
       call shr_sys_abort
    endif

    ! error check

    beg = accum(nf)%beg1d
    end = accum(nf)%end1d
    if (size(field,dim=1) < end-beg+1) then
       write(iulog,*)'ERROR in extract_accum_field for field ',accum(nf)%name
       write(iulog,*)'size of first dimension of field is ',&
            size(field,dim=1),' and should be ',end-beg+1
       call shr_sys_abort
    endif

    ! extract field (spval when a time average is not ready)

    call accum_extract(accum(nf), field(beg:end), nstep, spval, elm_device_ready)

  end subroutine extract_accum_field_sl

  !------------------------------------------------------------------------
  subroutine extract_accum_field_ml (name, field, nstep)
    !
    ! !DESCRIPTION:
    ! Extract mutli-level accumulated field.
    ! This routine extracts the field values from the multi-level
    ! accumulation field. It extracts the current value except if
    ! the field type is a time average. In this case, an absurd value
    ! is assigned to  indicate the time average is not yet valid.
    !
    ! !USES:
    use elm_varcon, only : spval
    !
    ! !ARGUMENTS:
    implicit none
    character(len=*), intent(in) :: name       !field name
    real(r8), pointer, dimension(:,:) :: field !field values for current time step
    integer, intent(in) :: nstep               !timestep index
    !
    ! !LOCAL VARIABLES:
    integer :: i,nf            !indices
    integer :: beg,end         !subgrid beginning,ending indices
    integer :: numlev          !number of vertical levels
    !------------------------------------------------------------------------

    ! find field index. return if "name" is not on list

    nf = 0
    do i = 1, naccflds
       if (name == accum(i)%name) nf = i
    end do
    if (nf == 0) then
       write(iulog,*) 'EXTRACT_ACCUM_FIELD_ML error: field name ',name,' not found'
       call shr_sys_abort
    endif

    ! error check

    numlev = accum(nf)%numlev
    beg = accum(nf)%beg1d
    end = accum(nf)%end1d
    if (size(field,dim=1) < end-beg+1) then
       write(iulog,*)'ERROR in extract_accum_field for field ',accum(nf)%name
       write(iulog,*)'size of first dimension of field is ',&
            size(field,dim=1),' and should be ',end-beg+1
       call shr_sys_abort
    else if (size(field,dim=2) /= numlev) then
       write(iulog,*)'ERROR in extract_accum_field for field ',accum(nf)%name
       write(iulog,*)'size of second dimension of field iis ',&
            size(field,dim=2),' and should be ',numlev
       call shr_sys_abort
    endif

    !extract field (spval when a time average is not ready)

    call accum_extract(accum(nf), field(beg:end, 1:numlev), nstep, spval, elm_device_ready)

  end subroutine extract_accum_field_ml

  !------------------------------------------------------------------------
  subroutine update_accum_field_sl (name, field, nstep)
    !
    ! !DESCRIPTION:
    ! Accumulate single level field over specified time interval.
    ! The appropriate field is accumulated in the array [accval].
    ! Values of 'field' are ignored at inactive points.
    !
    ! !ARGUMENTS:
    implicit none
    character(len=*), intent(in) :: name     !field name
    real(r8), pointer, dimension(:) :: field !field values for current time step
    integer , intent(in) :: nstep            !time step index
    !
    ! !LOCAL VARIABLES:
    integer :: i,nf                !indices
    integer :: beg,end             !subgrid beginning,ending indices
    !------------------------------------------------------------------------

    ! find field index. return if "name" is not on list

    nf = 0
    do i = 1, naccflds
       if (name == accum(i)%name) nf = i
    end do
    if (nf == 0) then
       write(iulog,*) 'UPDATE_ACCUM_FIELD_SL error: field name ',name,' not found'
       call shr_sys_abort
    endif

    ! error check

    beg = accum(nf)%beg1d
    end = accum(nf)%end1d
    if (size(field,dim=1) < end-beg+1) then
       write(iulog,*)'ERROR in UPDATE_ACCUM_FIELD_SL for field ',accum(nf)%name
       write(iulog,*)'size of first dimension of field is ',size(field,dim=1),&
            ' and should be ',end-beg+1
       call shr_sys_abort
    endif

    ! accumulate field (the accumulation type was checked by init_accum_field)

    if (accum_check_on()) then
       call accum_check_1d(accum(nf), field(beg:end), nstep)
    else
       call accum_update(accum(nf), field(beg:end), nstep, elm_device_ready)
    end if

  end subroutine update_accum_field_sl

  !------------------------------------------------------------------------
  subroutine update_accum_field_ml (name, field, nstep)
    !
    ! !DESCRIPTION:
    ! Accumulate multi level field over specified time interval.
    ! Values of 'field' are ignored at inactive points.
    !
    ! !ARGUMENTS:
    implicit none
    character(len=*), intent(in) :: name       !field name
    real(r8), pointer, dimension(:,:) :: field !field values for current time step
    integer , intent(in) :: nstep              !time step index
    !
    ! !LOCAL VARIABLES:
    integer :: i,nf                !indices
    integer :: beg,end             !subgrid beginning,ending indices
    integer :: numlev              !number of vertical levels
    !------------------------------------------------------------------------

    ! find field index. return if "name" is not on list

    nf = 0
    do i = 1, naccflds
       if (name == accum(i)%name) nf = i
    end do
    if (nf == 0) then
       write(iulog,*) 'UPDATE_ACCUM_FIELD_ML error: field name ',name,' not found'
       call shr_sys_abort
    endif

    ! error check

    numlev = accum(nf)%numlev
    beg = accum(nf)%beg1d
    end = accum(nf)%end1d
    if (size(field,dim=1) < end-beg+1) then
       write(iulog,*)'ERROR in UPDATE_ACCUM_FIELD_ML for field ',accum(nf)%name
       write(iulog,*)'size of first dimension of field is ',size(field,dim=1),&
            ' and should be ',end-beg+1
       call shr_sys_abort
    else if (size(field,dim=2) /= numlev) then
       write(iulog,*)'ERROR in UPDATE_ACCUM_FIELD_ML for field ',accum(nf)%name
       write(iulog,*)'size of second dimension of field is ',size(field,dim=2),&
            ' and should be ',numlev
       call shr_sys_abort
    endif

    ! accumulate field (the accumulation type was checked by init_accum_field)

    call accum_update(accum(nf), field(beg:end, 1:numlev), nstep, elm_device_ready)

  end subroutine update_accum_field_ml

  !------------------------------------------------------------------------
  logical function accum_check_on()
    ! DEBUG (SPEL_ACCUM_CHECK=1): check every device update of a single-level field
    logical, save :: first = .true., on = .false.
    character(len=8) :: s
    integer :: ios
    if (first) then
       s = ' '
#ifdef _OPENACC
       call get_environment_variable('SPEL_ACCUM_CHECK', s, status=ios)
#endif
       on = trim(s) == '1'
       first = .false.
    end if
    accum_check_on = on .and. elm_device_ready
  end function accum_check_on

  subroutine accum_check_1d(f, field, nstep)
    ! DEBUG: the input's device copy against its host copy, and the device update against the
    ! same update on the host from the device's state and inputs; mismatches go to iulog
#ifdef _OPENACC
    use openacc, only : acc_is_present
#endif
    type(accum_field), intent(inout) :: f
    real(r8), intent(in) :: field(f%beg1d:)
    integer , intent(in) :: nstep
    type(accum_field) :: r
    real(r8), allocatable :: dev(:)
    integer :: k, nin, nval, nn
#ifdef _OPENACC
    allocate(dev(f%beg1d:f%end1d))
    dev = field(f%beg1d:f%end1d)
    nin = 0
    if (acc_is_present(field)) then
       !$acc parallel loop present(field) copyout(dev) if(elm_device_ready)
       do k = f%beg1d, f%end1d
          dev(k) = field(k)
       end do
       nin = count(dev /= field(f%beg1d:f%end1d))
    end if
    if (f%resident) call accum_host_values(f)
    r = f
    r%resident = .false.
    allocate(r%val(f%beg1d:f%end1d, f%numlev), r%nsteps(f%beg1d:f%end1d, f%numlev))
    r%val = f%val
    r%nsteps = f%nsteps
    call accum_update(r, dev, nstep, .false.)
    call accum_update(f, field, nstep, .true.)
    call accum_host_values(f)
    nval = count(f%val /= r%val)
    nn = count(f%nsteps /= r%nsteps)
    if (nin + nval + nn > 0) write(iulog,'(a,a8,a,i6,a,l2,a,i8,a,i8,a,i8)') ' ACCUM_CHECK ', f%name, ' nstep', nstep, &
         ' input present', acc_is_present(field), ' input dev/=host', nin, ' val differ', nval, ' nsteps differ', nn
    deallocate(r%val, r%nsteps, dev)
#endif
  end subroutine accum_check_1d

  !------------------------------------------------------------------------
  subroutine accumulRest( ncid, flag )
    !
    ! !DESCRIPTION:
    ! Read/write accumulation restart data
    !
    ! !USES:
    use elm_varcon      , only : ispval
    use restUtilMod     , only : restartvar
    use ncdio_pio       , only : file_desc_t, ncd_double, ncd_int
    !
    ! !ARGUMENTS:
    implicit none
    type(file_desc_t), intent(inout) :: ncid   !netcdf unit
    character(len=*) , intent(in) :: flag   !'define','read', or 'write'
    !
    ! !LOCAL VARIABLES:
    integer :: nf                             ! indices
    logical :: readvar                        ! determine if variable is on initial file
    character(len=128) :: varname             ! temporary
    character(len= 32) :: subname='AccumRest' ! subroutine name
    !------------------------------------------------------------------------

    do nf = 1,naccflds

       ! fields that live on the device: their current values for the restart file
       if (flag == 'write') call accum_host_values(accum(nf))

       ! Note = below need to allocate rbuf for single level variables, since
       ! accum(nf)%val is always 2d

       varname = trim(accum(nf)%name) // '_VALUE'
       if (accum(nf)%numlev == 1) then
          call restartvar(ncid=ncid, flag=flag, varname=varname, xtype=ncd_double, &
               dim1name=accum(nf)%type1d, &
               long_name=accum(nf)%desc, units=accum(nf)%units, &
               interpinic_flag='interp', &
               data=accum(nf)%val, readvar=readvar)
       else
          call restartvar(ncid=ncid, flag=flag, varname=varname, xtype=ncd_double, &
               dim1name=accum(nf)%type1d, dim2name=accum(nf)%type2d, &
               long_name=accum(nf)%desc, units=accum(nf)%units, &
               interpinic_flag='interp', &
               data=accum(nf)%val, readvar=readvar)
       end if

       varname = trim(accum(nf)%name) // '_NSTEPS'
       if (accum(nf)%numlev == 1) then
          call restartvar(ncid=ncid, flag=flag, varname=varname, xtype=ncd_int, &
               dim1name=accum(nf)%type1d, &
               long_name='number of accumulated steps for '//trim(accum(nf)%name), &
               units='-', &
               interpinic_flag='interp', &
               data=accum(nf)%nsteps, readvar=readvar)
       else
          call restartvar(ncid=ncid, flag=flag, varname=varname, xtype=ncd_int, &
               dim1name=accum(nf)%type1d, dim2name=accum(nf)%type2d, &
               long_name='number of accumulated steps for '//trim(accum(nf)%name), &
               units='-', &
               interpinic_flag='interp', &
               data=accum(nf)%nsteps, readvar=readvar)
       end if
       if (flag == 'read' .and. .not. readvar) then
          accum(nf)%nsteps(accum(nf)%beg1d:accum(nf)%end1d,1:accum(nf)%numlev) = 0
       end if

       varname = trim(accum(nf)%name) // '_PERIOD'
       call restartvar(ncid=ncid, flag=flag, varname=varname, xtype=ncd_int, &
            long_name=trim(accum(nf)%desc), units='time steps', &
            imissing_value=ispval, ifill_value=huge(1), &
            interpinic_flag='copy', &
            data=accum(nf)%period, readvar=readvar)

       ! a restart read after the fields moved to the device (none in a normal run)
       if (flag == 'read') call accum_device_values(accum(nf))

    end do

  end subroutine accumulRest

end module accumulMod
