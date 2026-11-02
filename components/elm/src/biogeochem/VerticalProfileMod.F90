module VerticalProfileMod
  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! Module holding routines for vertical discretization of C and N inputs into deocmposing pools
  !
  ! !USES:
  use elm_varctl, only : elm_device_ready  ! compute constructs run on the host before the device copy
  use shr_kind_mod    , only: r8 => shr_kind_r8
  use shr_log_mod     , only : errMsg => shr_log_errMsg
  use decompMod       , only : bounds_type
  use abortutils      , only : endrun
  use SoilStateType   , only : soilstate_type
  use CanopyStateType , only : canopystate_type
  use CNStateType     , only : cnstate_type
  use ColumnType      , only : col_pp
  use VegetationType       , only : veg_pp
  !
  implicit none
  save
  private
  !
  ! !PUBLIC MEMBER FUNCTIONS:
  public:: decomp_vertprofiles
  !
  logical , public :: exponential_rooting_profile = .true.
  logical , public :: pftspecific_rootingprofile = .true.
  ! how steep profile is for root C inputs (1/ e-folding depth) (1/m)
  real(r8), public :: rootprof_exp  = 3._r8
  ! how steep profile is for surface components (1/ e_folding depth) (1/m)
  real(r8), public :: surfprof_exp  = 10._r8

  ! the root-input profile of a patch (decided on the host: the two switches above have no
  ! device copy)
  integer, parameter :: rootprof_kind_clm  = 1  ! the standard ELM root fractions (soilstate rootfr)
  integer, parameter :: rootprof_kind_exp  = 2  ! exponential, one e-folding depth for all patches
  integer, parameter :: rootprof_kind_beta = 3  ! beta distribution per PFT (Jackson et al., 1996)
  !-----------------------------------------------------------------------

  ! spel acc-apply: module data read in device code (updated by the device data layer)
  !$acc declare create(rootprof_exp, surfprof_exp)
contains

  !-----------------------------------------------------------------------
  pure real(r8) function surface_shape(surface_prof, nlevbed)
    !
    ! !DESCRIPTION:
    ! The surface profile at a level, stretched to the column's bedrock when the bedrock is
    ! shallower than the decomposition layers (surface inputs then fill the layers above it).
    !
    ! !USES:
    use elm_varcon , only : zisoi
    use elm_varpar , only : nlevdecomp
    !
    ! !ARGUMENTS:
    real(r8), intent(in) :: surface_prof  ! exp(-surfprof_exp * zsoi(j)) / dzsoi_decomp(j)
    integer , intent(in) :: nlevbed       ! layers to bedrock of the column
    !$acc routine seq
    !-----------------------------------------------------------------------

    if (nlevbed < nlevdecomp) then
       surface_shape = exp(log(surface_prof) * zisoi(nlevdecomp) / zisoi(nlevbed))
    else
       surface_shape = surface_prof
    end if
  end function surface_shape

  !-----------------------------------------------------------------------
  subroutine decomp_vertprofiles(bounds, &
       num_soilc, filter_soilc, num_soilp, filter_soilp, soilc_soilp_beg, soilc_soilp_end, &
       soilstate_vars, canopystate_vars, cnstate_vars)
    !
    ! !DESCRIPTION:
    !  calculate vertical profiles for distributing soil and litter C and N
    !
    !  Note (WJS, 6-12-13): Because of this routine's placement in the driver sequence (it is
    !  called very early in each timestep, before weights are adjusted and filters are
    !  updated), it may be necessary for this routine to compute values over inactive as well
    !  as active points (since some inactive points may soon become active) - so that's what
    !  is done now. Currently, it seems to be okay to do this, because the variables computed
    !  here seem to only depend on quantities that are valid over inactive as well as active
    !  points. However, note that this routine is (mistakenly) called from two places
    !  currently - the above note applies to its call from the driver, but its call from
    !  SoilLittDecompMod uses the standard filters that just apply over active points
    !
    !  Patch quantities are computed in one kernel over the soil patch filter, column
    !  quantities in one kernel over the soil column filter. The root inputs of a column are
    !  those of its soil patches, filter_soilp(soilc_soilp_beg(fc):soilc_soilp_end(fc)), summed
    !  in patch order (as p2c: patches outside the soil filter have no root inputs).
    !
    ! !USES:
    use elm_varcon  , only : zsoi, dzsoi, zisoi, dzsoi_decomp
    use elm_varpar  , only : nlevdecomp, nlevgrnd, nlevdecomp_full
    use elm_varctl  , only : use_vertsoilc, iulog, use_dynroot
    use pftvarcon   , only : rootprof_beta, noveg
    !
    ! !ARGUMENTS:
    type(bounds_type)      , intent(in)    :: bounds
    integer                , intent(in)    :: num_soilc          ! number of soil columns in filter
    integer                , intent(in)    :: filter_soilc(:)    ! filter for soil columns
    integer                , intent(in)    :: num_soilp          ! number of soil patches in filter
    integer                , intent(in)    :: filter_soilp(:)    ! filter for soil patches
    integer                , intent(in)    :: soilc_soilp_beg(:) ! the soil patches of soil column fc:
    integer                , intent(in)    :: soilc_soilp_end(:) !   filter_soilp(soilc_soilp_beg(fc):soilc_soilp_end(fc))
    type(soilstate_type)   , intent(in)    :: soilstate_vars
    type(canopystate_type) , intent(in)    :: canopystate_vars
    type(cnstate_type)     , intent(inout) :: cnstate_vars
    !
    ! !LOCAL VARIABLES:
    real(r8) :: surface_prof(1:nlevdecomp)                       ! shallow profile of the surface inputs (1/m)
    real(r8) :: cinput_rootfr(1:num_soilp, 1:nlevdecomp)         ! root-input profile of the soil patches (filter index)
    real(r8) :: col_cinput_rootfr(1:num_soilc, 1:nlevdecomp)     ! root-input profile of the soil columns (filter index)
    real(r8) :: surface_prof_tot
    real(r8) :: rootfr_tot
    real(r8) :: col_rootfr        ! one level of col_cinput_rootfr, summed over the column's patches
    integer  :: c, j, fc, p, fp
    integer  :: alt_ind           ! last layer of the active layer (1..nlevdecomp)
    integer  :: nlevbed
    integer  :: rootprof          ! rootprof_kind_clm, _exp or _beta
    ! profile sums (checks)
    real(r8) :: froot_prof_sum
    real(r8) :: croot_prof_sum
    real(r8) :: leaf_prof_sum
    real(r8) :: stem_prof_sum
    real(r8) :: ndep_prof_sum
    real(r8) :: nfixation_prof_sum
    real(r8) :: pdep_prof_sum
    real(r8), parameter :: delta = 1.e-10_r8
    integer  :: nbad              ! columns or patches whose profiles do not integrate to 1
    real(r8), parameter :: smallparameter = tiny(1._r8)
    character(len=32) :: subname = 'decomp_vertprofiles'
    !-----------------------------------------------------------------------

    ! spel acc-locals: device storage of the local work arrays
    !$acc enter data create(surface_prof, cinput_rootfr, col_cinput_rootfr)
    associate(                                                               &
         nlev2bed             => col_pp%nlevbed                            , & ! Input: [integer (:)     ]  number of layers to bedrock
         rootfr               => soilstate_vars%rootfr_patch               , & ! Input:  [real(r8)  (:,:) ]  fraction of roots in each soil layer  (nlevgrnd)

         altmax_lastyear_indx => canopystate_vars%altmax_lastyear_indx_col , & ! Input:  [integer   (:)   ]  frost table depth (m)

         nfixation_prof       => cnstate_vars%nfixation_prof_col           , & ! Input:  [real(r8)  (:,:) ]  (1/m) profile for N fixation additions
         ndep_prof            => cnstate_vars%ndep_prof_col                , & ! Input:  [real(r8)  (:,:) ]  (1/m) profile for N fixation additions
         pdep_prof            => cnstate_vars%pdep_prof_col                , & ! Input:  [real(r8)  (:,:) ]  (1/m) profile for P depostition additions

         leaf_prof            => cnstate_vars%leaf_prof_patch              , & ! Output:  [real(r8) (:,:) ]  (1/m) profile of leaves
         froot_prof           => cnstate_vars%froot_prof_patch             , & ! Output:  [real(r8) (:,:) ]  (1/m) profile of fine roots
         croot_prof           => cnstate_vars%croot_prof_patch             , & ! Output:  [real(r8) (:,:) ]  (1/m) profile of coarse roots
         stem_prof            => cnstate_vars%stem_prof_patch              , & ! Output:  [real(r8) (:,:) ]  (1/m) profile of stems

         begp                 => bounds%begp                               , &
         endp                 => bounds%endp                               , &
         begc                 => bounds%begc                               , &
         endc                 => bounds%endc                                 &
         )

      if (use_vertsoilc) then

         ! define a single shallow surface profile for surface additions (leaves, stems, and N deposition)
         !$acc parallel loop gang vector default(present) if(elm_device_ready)
         do j = 1, nlevdecomp
            surface_prof(j) = exp(-surfprof_exp * zsoi(j)) / dzsoi_decomp(j)
         end do

         ! initialize profiles to zero (also off the filters and below the active layer)
         !$acc parallel loop gang vector collapse(2) default(present) if(elm_device_ready)
         do j = 1, nlevdecomp_full
            do p = begp, endp
               leaf_prof(p,j) = 0._r8
               froot_prof(p,j) = 0._r8
               croot_prof(p,j) = 0._r8
               stem_prof(p,j) = 0._r8
            end do
         end do
         !$acc parallel loop gang vector collapse(2) default(present) if(elm_device_ready)
         do j = 1, nlevdecomp_full
            do c = begc, endc
               nfixation_prof(c,j) = 0._r8
               ndep_prof(c,j) = 0._r8
               pdep_prof(c,j) = 0._r8
            end do
         end do

         if (.not. exponential_rooting_profile) then
            rootprof = rootprof_kind_clm
         else if (.not. pftspecific_rootingprofile) then
            rootprof = rootprof_kind_exp
         else
            rootprof = rootprof_kind_beta
         end if

         ! patches: the root-input profile (every level set), then the root and surface profiles
         ! integrated over the active layer
         !$acc parallel loop gang vector default(present) &
         !$acc&   private(p, c, nlevbed, alt_ind, rootfr_tot, surface_prof_tot, j) if(elm_device_ready)
         do fp = 1,num_soilp
            p = filter_soilp(fp)
            c = veg_pp%column(p)
            nlevbed = nlev2bed(c)

            select case (rootprof)
            case (rootprof_kind_clm)
               ! use standard ELM root fraction profiles
               !$acc loop seq
               do j = 1, nlevdecomp
                  cinput_rootfr(fp,j) = rootfr(p,j) / dzsoi_decomp(j)
               end do
            case (rootprof_kind_exp)
               ! define rooting profile from exponential parameters
               !$acc loop seq
               do j = 1, nlevdecomp
                  cinput_rootfr(fp,j) = exp(-rootprof_exp * zsoi(j)) / dzsoi_decomp(j)
               end do
            case default
               ! use beta distribution parameter from Jackson et al., 1996
               if (veg_pp%itype(p) /= noveg) then
                  rootfr_tot = 0._r8
                  !$acc loop seq
                  do j = 1, nlevdecomp
                     if (j <= nlevbed) then
                        cinput_rootfr(fp,j) = ( rootprof_beta(veg_pp%itype(p)) ** (zisoi(j-1)*100._r8) - &
                             rootprof_beta(veg_pp%itype(p)) ** (zisoi(j)*100._r8) ) &
                             / dzsoi_decomp(j)
                        rootfr_tot = rootfr_tot + cinput_rootfr(fp,j) * dzsoi_decomp(j)
                     else
                        cinput_rootfr(fp,j) = 0._r8
                     end if
                  end do
                  if (nlevbed < nlevdecomp) then
                     !$acc loop seq
                     do j = 1, nlevbed
                        cinput_rootfr(fp,j) = cinput_rootfr(fp,j) / rootfr_tot
                     end do
                  end if
               else
                  ! no vegetation: all root inputs in the top layer
                  cinput_rootfr(fp,1) = 1._r8 / dzsoi_decomp(1)
                  !$acc loop seq
                  do j = 2, nlevdecomp
                     cinput_rootfr(fp,j) = 0._r8
                  end do
               end if
            end select

            ! integrate the root and surface profiles over the active layer of the soil column
            alt_ind = min(max(altmax_lastyear_indx(c), 1), nlevdecomp)
            rootfr_tot = 0._r8
            surface_prof_tot = 0._r8
            !$acc loop seq
            do j = 1, alt_ind
               rootfr_tot = rootfr_tot + cinput_rootfr(fp,j) * dzsoi_decomp(j)
               surface_prof_tot = surface_prof_tot + surface_shape(surface_prof(j), nlevbed) * dzsoi_decomp(j)
            end do
            if ( (altmax_lastyear_indx(c) > 0) .and. (rootfr_tot > smallparameter) .and. (surface_prof_tot > smallparameter) ) then
               ! where there is not permafrost extending to the surface, integrate the profiles over the active layer
               ! this is equivalnet to integrating over all soil layers outside of permafrost regions
               !$acc loop seq
               do j = 1, alt_ind
                  froot_prof(p,j) = cinput_rootfr(fp,j) / rootfr_tot
                  croot_prof(p,j) = cinput_rootfr(fp,j) / rootfr_tot
                  ! set all surface processes to shallower profile
                  if (j <= nlevbed) then
                     leaf_prof(p,j) = surface_shape(surface_prof(j), nlevbed) / surface_prof_tot
                     stem_prof(p,j) = leaf_prof(p,j)
                  end if
               end do
            else
               ! if fully frozen, or no roots, put everything in the top layer
               froot_prof(p,1) = 1._r8/dzsoi_decomp(1)
               croot_prof(p,1) = 1._r8/dzsoi_decomp(1)
               leaf_prof(p,1) = 1._r8/dzsoi_decomp(1)
               stem_prof(p,1) = 1._r8/dzsoi_decomp(1)
            endif
         end do

         ! columns: the root inputs of the column's soil patches, then the column-native profiles
         ! (Ndep, Pdep and Nfix) integrated over the active layer
         !$acc parallel loop gang vector default(present) &
         !$acc   private(c, nlevbed, rootfr_tot, surface_prof_tot, alt_ind, j, fp, col_rootfr) if(elm_device_ready)
         do fc = 1,num_soilc
            c = filter_soilc(fc)
            nlevbed = nlev2bed(c)

            ! aggregate the patch root inputs to the column (p2c with the patches' column weights)
            !$acc loop seq
            do j = 1, nlevdecomp
               col_rootfr = 0._r8
               !$acc loop seq
               do fp = soilc_soilp_beg(fc), soilc_soilp_end(fc)
                  col_rootfr = col_rootfr + cinput_rootfr(fp,j) * veg_pp%wtcol(filter_soilp(fp))
               end do
               col_cinput_rootfr(fc,j) = col_rootfr
            end do

            ! redo column integration over active layer for column-native profiles
            alt_ind = min(max(altmax_lastyear_indx(c), 1), nlevdecomp)
            rootfr_tot = 0._r8
            surface_prof_tot = 0._r8
            !$acc loop seq
            do j = 1, min(alt_ind, nlevbed)
               rootfr_tot = rootfr_tot + col_cinput_rootfr(fc,j) * dzsoi_decomp(j)
               surface_prof_tot = surface_prof_tot + surface_prof(j) * dzsoi_decomp(j)
            end do
            if(col_pp%is_fates(c))then
               if ( (altmax_lastyear_indx(c) > 0) .and. (surface_prof_tot > smallparameter) ) then
                  !$acc loop seq
                  do j = 1,min(alt_ind, nlevbed)
                     nfixation_prof(c,j) = surface_prof(j)/ surface_prof_tot
                     ndep_prof(c,j) = surface_prof(j)/ surface_prof_tot
                     pdep_prof(c,j) = surface_prof(j)/ surface_prof_tot
                  end do
               else
                  nfixation_prof(c,1) = 1._r8/dzsoi_decomp(1)
                  ndep_prof(c,1) = 1._r8/dzsoi_decomp(1)
                  pdep_prof(c,1) = 1._r8/dzsoi_decomp(1)
               endif
            else
               if ( (altmax_lastyear_indx(c) > 0) .and. (rootfr_tot > smallparameter) .and. (surface_prof_tot > smallparameter) ) then
                  !$acc loop seq
                  do j = 1, alt_ind
                     nfixation_prof(c,j) = col_cinput_rootfr(fc,j) / rootfr_tot
                     if (j <= nlevbed) then
                        ndep_prof(c,j) = surface_prof(j)/ surface_prof_tot
                        pdep_prof(c,j) = surface_prof(j)/ surface_prof_tot
                     end if
                  end do
               else
                  nfixation_prof(c,1) = 1._r8/dzsoi_decomp(1)
                  ndep_prof(c,1) = 1._r8/dzsoi_decomp(1)
                  pdep_prof(c,1) = 1._r8/dzsoi_decomp(1)
               endif
            end if
         end do

      else

         ! for one layer decomposition model, set profiles to unity
         !$acc parallel loop gang vector collapse(2) default(present) if(elm_device_ready)
         do j = 1, nlevdecomp_full
            do p = begp, endp
               leaf_prof(p,j) = 1._r8
               froot_prof(p,j) = 1._r8
               croot_prof(p,j) = 1._r8
               stem_prof(p,j) = 1._r8
            end do
         end do
         !$acc parallel loop gang vector collapse(2) default(present) if(elm_device_ready)
         do j = 1, nlevdecomp_full
            do c = begc, endc
               nfixation_prof(c,j) = 1._r8
               ndep_prof(c,j) = 1._r8
               pdep_prof(c,j) = 1._r8
            end do
         end do

      end if

      ! check to make sure integral of all profiles = 1: count the failures on the device and
      ! report the first one on the host only when there are any
      nbad = 0
      !$acc parallel loop gang vector default(present) reduction(+:nbad) &
      !$acc&   private(c, ndep_prof_sum, nfixation_prof_sum, pdep_prof_sum, j) if(elm_device_ready)
      do fc = 1,num_soilc
         c = filter_soilc(fc)
         ndep_prof_sum = 0._r8
         nfixation_prof_sum = 0._r8
         pdep_prof_sum = 0._r8
         !$acc loop seq
         do j = 1, nlevdecomp
            ndep_prof_sum = ndep_prof_sum + ndep_prof(c,j) *  dzsoi_decomp(j)
            nfixation_prof_sum = nfixation_prof_sum + nfixation_prof(c,j) *  dzsoi_decomp(j)
            pdep_prof_sum = pdep_prof_sum + pdep_prof(c,j) *  dzsoi_decomp(j)
         end do
         if ( ( abs(ndep_prof_sum - 1._r8) > delta ) .or.  ( abs(nfixation_prof_sum - 1._r8) > delta ) .or. &
              ( abs(pdep_prof_sum - 1._r8) > delta )  ) nbad = nbad + 1
      end do
      if (nbad > 0) then  ! report on the host
         !$acc update self(canopystate_vars%altmax_lastyear_indx_col, cnstate_vars%ndep_prof_col, &
         !$acc&   cnstate_vars%nfixation_prof_col, cnstate_vars%pdep_prof_col, col_cinput_rootfr, &
         !$acc&   surface_prof) if(elm_device_ready)
         do fc = 1,num_soilc
            c = filter_soilc(fc)
            ndep_prof_sum = 0._r8
            nfixation_prof_sum = 0._r8
            pdep_prof_sum = 0._r8
            do j = 1, nlevdecomp
               ndep_prof_sum = ndep_prof_sum + ndep_prof(c,j) *  dzsoi_decomp(j)
               nfixation_prof_sum = nfixation_prof_sum + nfixation_prof(c,j) *  dzsoi_decomp(j)
               pdep_prof_sum = pdep_prof_sum + pdep_prof(c,j) *  dzsoi_decomp(j)
            end do
            if ( ( abs(ndep_prof_sum - 1._r8) > delta ) .or.  ( abs(nfixation_prof_sum - 1._r8) > delta ) .or. &
                 ( abs(pdep_prof_sum - 1._r8) > delta )  ) then
               write(iulog, *) 'profile sums: ', ndep_prof_sum, nfixation_prof_sum, pdep_prof_sum
               write(iulog, *) 'c: ', c
               write(iulog, *) 'altmax_lastyear_indx: ', altmax_lastyear_indx(c)
               write(iulog, *) 'nfixation_prof: ', nfixation_prof(c,:)
               write(iulog, *) 'ndep_prof: ', ndep_prof(c,:)
               write(iulog, *) 'pdep_prof: ', pdep_prof(c,:)
               if (use_vertsoilc) then
                  write(iulog, *) 'cinput_rootfr: ', col_cinput_rootfr(fc,:)
                  write(iulog, *) 'surface_prof: ', surface_prof(:)
               end if
               write(iulog, *) 'dzsoi_decomp: ', dzsoi_decomp(:)
               write(iulog, *) 'npfts(c): ', col_pp%npfts(c)
               call endrun(msg=" ERROR: _prof_sum-1>delta"//errMsg(__FILE__, __LINE__))
            endif
         end do
      end if

      nbad = 0
      !$acc parallel loop gang vector default(present) reduction(+:nbad) &
      !$acc&   private(p, froot_prof_sum, croot_prof_sum, leaf_prof_sum, stem_prof_sum, j) if(elm_device_ready)
      do fp = 1,num_soilp
         p = filter_soilp(fp)
         froot_prof_sum = 0._r8
         croot_prof_sum = 0._r8
         leaf_prof_sum = 0._r8
         stem_prof_sum = 0._r8
         !$acc loop seq
         do j = 1, nlevdecomp
            froot_prof_sum = froot_prof_sum + froot_prof(p,j) *  dzsoi_decomp(j)
            croot_prof_sum = croot_prof_sum + croot_prof(p,j) *  dzsoi_decomp(j)
            leaf_prof_sum = leaf_prof_sum + leaf_prof(p,j) *  dzsoi_decomp(j)
            stem_prof_sum = stem_prof_sum + stem_prof(p,j) *  dzsoi_decomp(j)
         end do
         if ( ( abs(froot_prof_sum - 1._r8) > delta ) .or.  ( abs(croot_prof_sum - 1._r8) > delta ) .or. &
              ( abs(stem_prof_sum - 1._r8) > delta ) .or.  ( abs(leaf_prof_sum - 1._r8) > delta ) ) nbad = nbad + 1
      end do
      if (nbad > 0) then  ! report on the host
         !$acc update self(canopystate_vars%altmax_lastyear_indx_col, cnstate_vars%croot_prof_patch, &
         !$acc&   cnstate_vars%froot_prof_patch, cnstate_vars%leaf_prof_patch, cnstate_vars%stem_prof_patch, &
         !$acc&   cinput_rootfr, surface_prof) if(elm_device_ready)
         do fp = 1,num_soilp
            p = filter_soilp(fp)
            froot_prof_sum = 0._r8
            croot_prof_sum = 0._r8
            leaf_prof_sum = 0._r8
            stem_prof_sum = 0._r8
            do j = 1, nlevdecomp
               froot_prof_sum = froot_prof_sum + froot_prof(p,j) *  dzsoi_decomp(j)
               croot_prof_sum = croot_prof_sum + croot_prof(p,j) *  dzsoi_decomp(j)
               leaf_prof_sum = leaf_prof_sum + leaf_prof(p,j) *  dzsoi_decomp(j)
               stem_prof_sum = stem_prof_sum + stem_prof(p,j) *  dzsoi_decomp(j)
            end do
            if ( ( abs(froot_prof_sum - 1._r8) > delta ) .or.  ( abs(croot_prof_sum - 1._r8) > delta ) .or. &
                 ( abs(stem_prof_sum - 1._r8) > delta ) .or.  ( abs(leaf_prof_sum - 1._r8) > delta ) ) then
               c = veg_pp%column(p)
               write(iulog, *) 'profile sums: ', froot_prof_sum, croot_prof_sum, leaf_prof_sum, stem_prof_sum
               write(iulog, *) 'c: ',c
               write(iulog, *) 'altmax_lastyear_indx: ', altmax_lastyear_indx(c)
               write(iulog, *) 'dzsoi_decomp: ', dzsoi_decomp(:)
               write(iulog, *) 'p, itype(p), wtcol(p): ', p, veg_pp%itype(p), veg_pp%wtcol(p)
               if (use_vertsoilc) then
                  write(iulog, *) 'surface_prof: ', surface_prof(:)
                  write(iulog, *) 'cinput_rootfr(p,:): ', cinput_rootfr(fp,:)
               end if
               write(iulog,*)  'croot_prof(p,:): ',croot_prof(p,:)
               write(iulog,*)  'froot_prof(p,:): ',froot_prof(p,:)
               write(iulog,*)  'leaf_prof(p,:): ',leaf_prof(p,:)
               write(iulog,*)  'stem_prof(p,:): ',stem_prof(p,:)
               call endrun(msg=' ERROR: sum-1 > delta'//errMsg(__FILE__, __LINE__))
            end if
         end do
      end if

    end associate

    !$acc exit data delete(surface_prof, cinput_rootfr, col_cinput_rootfr)
  end subroutine decomp_vertprofiles

end module VerticalProfileMod
