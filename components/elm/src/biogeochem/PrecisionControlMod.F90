module PrecisionControlMod

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! controls on very low values in critical state variables
  !
  ! !USES:
  use elm_varctl, only : elm_device_ready  ! compute constructs run on the host before the device copy
  use shr_kind_mod        , only : r8 => shr_kind_r8
  use shr_log_mod         , only : errMsg => shr_log_errMsg
  use abortutils          , only : endrun
  use elm_varctl          , only : nu_com
  use elm_varpar          , only : ndecomp_pools
  use ColumnType          , only : col_pp
  use ColumnDataType      , only : col_cs, c13_col_cs, c14_col_cs
  use ColumnDataType      , only : col_ns, col_ps
  use VegetationType      , only : veg_pp
  use VegetationDataType  , only : veg_cs, c13_veg_cs, c14_veg_cs
  use VegetationDataType  , only : veg_ns, veg_ps

  !
  implicit none
  save
  private
  !
  ! !PUBLIC MEMBER FUNCTIONS:
  public:: PrecisionControl
  !-----------------------------------------------------------------------

contains

  !-----------------------------------------------------------------------
  subroutine PrecisionControl(num_soilc, filter_soilc, num_soilp, filter_soilp)
    !
    ! !DESCRIPTION:
    ! On the radiation time step, force leaf and deadstem c and n to 0 if
    ! they get too small.
    !
    ! !USES:
    use elm_varctl , only : iulog, use_c13, use_c14, use_fates
    use elm_varpar , only : nlevdecomp_full, crop_prog
    use pftvarcon  , only : iscft
    use CNDecompCascadeConType , only : decomp_cascade_con
    use NutrientStateType, only : nlinked_pools, igrain_pools, &
         vegetation_nutrient_state_small_pools, vegetation_nutrient_state_truncate
    !
    ! !ARGUMENTS:
    integer                  , intent(in)    :: num_soilc       ! number of soil columns in filter
    integer                  , intent(in)    :: filter_soilc(:) ! filter for soil columns
    integer                  , intent(in)    :: num_soilp       ! number of soil patchs in filter
    integer                  , intent(in)    :: filter_soilp(:) ! filter for soil patches
    !
    ! !LOCAL VARIABLES:
    integer :: c,p,j,k,l  ! indices
    integer :: fp,fc    ! lake filter indices
    real(r8):: pc,pn,pp    ! truncation terms for patch-level corrections
    real(r8):: cc,cn,cp    ! truncation terms for column-level corrections
    real(r8):: pc13     ! truncation terms for patch-level corrections
    real(r8):: cc13     ! truncation terms for column-level corrections
    real(r8):: pc14     ! truncation terms for patch-level corrections
    real(r8):: cc14     ! truncation terms for column-level corrections
    real(r8):: ccrit    ! critical carbon state value for truncation
    real(r8):: ncrit    ! critical nitrogen state value for truncation
    real(r8):: pcrit    ! critical phosphorus state value for truncation
    real(r8):: cc_eca
    real(r8):: cn_eca
    real(r8):: cp_eca
    logical :: small(nlinked_pools), small_iso(nlinked_pools) ! linked pools to truncate (C, N, P; isotopes)
    integer :: nreset         ! small negative soil mineral N values reset to zero
    !-----------------------------------------------------------------------

    integer :: spel_dc_1, spel_dc_2, spel_dc_3, spel_dc_4  ! spel defer-checks: elements recorded by deferred checks
    associate(&
         floating_cn_ratio_decomp_pools   =>    decomp_cascade_con%floating_cn_ratio_decomp_pools , &
         floating_cp_ratio_decomp_pools   =>    decomp_cascade_con%floating_cp_ratio_decomp_pools , &
         initial_cn_ratio                 =>    decomp_cascade_con%initial_cn_ratio                 &
         )

      ! set the critical carbon state value for truncation (gC/m2)
      ccrit = 1.e-8_r8

      ! set the critical nitrogen state value for truncation (gN/m2)
      ncrit = 1.e-8_r8

      ! set the critical phosphorus state value for truncation (gN/m2)
      pcrit = 1.e-8_r8

      ! patch loop
      if (.not.use_fates) then
         !$acc parallel loop gang vector default(present) private(p, k, pc, pn, pp, pc13, pc14, small, small_iso) if(elm_device_ready)
         do fp = 1,num_soilp
            p = filter_soilp(fp)

            ! initialize the patch-level C and N truncation terms
            pc = 0._r8
            pn = 0._r8
            pp = 0._r8
            if ( use_c13 ) pc13 = 0._r8
            if ( use_c14 ) pc14 = 0._r8

            ! do tests on state variables for precision control
            ! for linked C-N state variables, perform precision test on
            ! the C component, but truncate C, C13, and N components

            ! pools linked across C, N and P: test the carbon pool, truncate C, N, P (and C13, C14;
            ! grain only on crops, and not for the isotopes)
            call vegetation_nutrient_state_small_pools(veg_cs%core, p, ccrit, small)
            ! element by element: array assignments in kernels are miscompiled
            !$acc loop seq
            do k = 1, nlinked_pools
               small_iso(k) = small(k)
            end do
            !$acc loop seq
            do k = 1, size(igrain_pools)
               if (.not. (crop_prog .and. iscft(veg_pp%itype(p)))) small(igrain_pools(k)) = .false.
               small_iso(igrain_pools(k)) = .false.
            end do
            call vegetation_nutrient_state_truncate(veg_cs%core, p, small, pc)
            call vegetation_nutrient_state_truncate(veg_ns%core, p, small, pn)
            if ( use_c13 ) call vegetation_nutrient_state_truncate(c13_veg_cs%core, p, small_iso, pc13)
            if ( use_c14 ) call vegetation_nutrient_state_truncate(c14_veg_cs%core, p, small_iso, pc14)
            call vegetation_nutrient_state_truncate(veg_ps%core, p, small, pp)

            ! gresp_storage (C only)
            if (abs(veg_cs%gresp_storage(p)) < ccrit) then
               pc = pc + veg_cs%gresp_storage(p)
               veg_cs%gresp_storage(p) = 0._r8
               if ( use_c13 ) then
                  pc13 = pc13 + c13_veg_cs%gresp_storage(p)
                  c13_veg_cs%gresp_storage(p) = 0._r8
               endif
               if ( use_c14 ) then
                  pc14 = pc14 + c14_veg_cs%gresp_storage(p)
                  c14_veg_cs%gresp_storage(p) = 0._r8
               endif
            end if

            ! gresp_xfer(c only)
            if (abs(veg_cs%gresp_xfer(p)) < ccrit) then
               pc = pc + veg_cs%gresp_xfer(p)
               veg_cs%gresp_xfer(p) = 0._r8
               if ( use_c13 ) then
                  pc13 = pc13 + c13_veg_cs%gresp_xfer(p)
                  c13_veg_cs%gresp_xfer(p) = 0._r8
               endif
               if ( use_c14 ) then
                  pc14 = pc14 + c14_veg_cs%gresp_xfer(p)
                  c14_veg_cs%gresp_xfer(p) = 0._r8
               endif
            end if

            ! cpool (C only)
            if (abs(veg_cs%core%pool(p)) < ccrit) then
               pc = pc + veg_cs%core%pool(p)
               veg_cs%core%pool(p) = 0._r8
               if ( use_c13 ) then
                  pc13 = pc13 + c13_veg_cs%core%pool(p)
                  c13_veg_cs%core%pool(p) = 0._r8
               endif
               if ( use_c14 ) then
                  pc14 = pc14 + c14_veg_cs%core%pool(p)
                  c14_veg_cs%core%pool(p) = 0._r8
               endif
            end if

            if ( crop_prog .and. iscft(veg_pp%itype(p)))then
               ! xsmrpool (C only)
               if (abs(veg_cs%xsmrpool(p)) < ccrit) then
                  pc = pc + veg_cs%xsmrpool(p)
                  veg_cs%xsmrpool(p) = 0._r8
               end if
            end if

            ! retransn (N only)
            if (abs(veg_ns%retrans%pool(p)) < ncrit) then
               pn = pn + veg_ns%retrans%pool(p)
               veg_ns%retrans%pool(p) = 0._r8
            end if

            ! retransp (P only)
            if (abs(veg_ps%retrans%pool(p)) < pcrit) then
               pp = pp + veg_ps%retrans%pool(p)
               veg_ps%retrans%pool(p) = 0._r8
            end if

            ! npool (N only)
            if (abs(veg_ns%core%pool(p)) < ncrit) then
               pn = pn + veg_ns%core%pool(p)
               veg_ns%core%pool(p) = 0._r8
            end if

            ! ppool (P only)
            if (abs(veg_ps%core%pool(p)) < pcrit) then
               pp = pp + veg_ps%core%pool(p)
               veg_ps%core%pool(p) = 0._r8
            end if

            veg_cs%core%trunc_sink(p) = veg_cs%core%trunc_sink(p) + pc
            veg_ns%core%trunc_sink(p) = veg_ns%core%trunc_sink(p) + pn
            veg_ps%core%trunc_sink(p) = veg_ps%core%trunc_sink(p) + pp

            if ( use_c13 ) then
               c13_veg_cs%core%trunc_sink(p) = c13_veg_cs%core%trunc_sink(p) + pc13
            endif
            if ( use_c14 ) then
               c14_veg_cs%core%trunc_sink(p) = c14_veg_cs%core%trunc_sink(p) + pc14
            endif

         end do ! end of pft loop
      end if ! end of if(.not.use_fates)


         ! column loop
         !$acc parallel loop gang vector default(present) private(c, j, cc, cc13, cc14, cn, k) if(elm_device_ready)
         do fc = 1,num_soilc
            c = filter_soilc(fc)

            !$acc loop seq
            do j = 1,nlevdecomp_full
               ! initialize the column-level C and N truncation terms
               cc = 0._r8
               if ( use_c13 ) cc13 = 0._r8
               if ( use_c14 ) cc14 = 0._r8
               cn = 0._r8

               ! do tests on state variables for precision control
               ! for linked C-N state variables, perform precision test on
               ! the C component, but truncate both C and N components


               ! all decomposing pools C and N
               !$acc loop seq
               do k = 1, ndecomp_pools

                  if (abs(col_cs%core%decomp_pools_vr(c,j,k)) < ccrit) then
                     cc = cc + col_cs%core%decomp_pools_vr(c,j,k)
                     col_cs%core%decomp_pools_vr(c,j,k) = 0._r8
                     cn = cn + col_ns%core%decomp_pools_vr(c,j,k)
                     col_ns%core%decomp_pools_vr(c,j,k) = 0._r8
                     if ( use_c13 ) then
                        cc13 = cc13 + c13_col_cs%core%decomp_pools_vr(c,j,k)
                        c13_col_cs%core%decomp_pools_vr(c,j,k) = 0._r8
                     endif
                     if ( use_c14 ) then
                        cc14 = cc14 + c14_col_cs%core%decomp_pools_vr(c,j,k)
                        c14_col_cs%core%decomp_pools_vr(c,j,k) = 0._r8
                     endif
                  end if

               end do

               ! not doing precision control on soil mineral N, since it will
               ! be getting the N truncation flux anyway.

               col_cs%core%trunc_sink_vr(c,j) = col_cs%core%trunc_sink_vr(c,j) + cc
               col_ns%core%trunc_sink_vr(c,j) = col_ns%core%trunc_sink_vr(c,j) + cn
               if ( use_c13 ) then
                  c13_col_cs%core%trunc_sink_vr(c,j) = c13_col_cs%core%trunc_sink_vr(c,j) + cc13
               endif
               if ( use_c14 ) then
                  c14_col_cs%core%trunc_sink_vr(c,j) = c14_col_cs%core%trunc_sink_vr(c,j) + cc14
               endif
            end do

         end do   ! end of column loop

         ! remove small negative perturbations for stability purposes, if any should arise.
         ! (one thread per column and level; the number of resets is reported after the kernel)
         nreset = 0
         !$acc parallel loop gang vector collapse(2) default(present) private(c) reduction(+:nreset) if(elm_device_ready)
         do fc = 1,num_soilc
            do j = 1,nlevdecomp_full
               c = filter_soilc(fc)
               if (abs(col_ns%smin_no3_vr(c,j)) < ncrit/1e4_r8) then
                  if ( col_ns%smin_no3_vr(c,j)  < 0._r8 ) then
                     col_ns%smin_no3_vr(c,j) = 0._r8
                     nreset = nreset + 1
                  endif
               end if
               if (abs(col_ns%smin_nh4_vr(c,j)) < ncrit/1e4_r8) then
                  if ( col_ns%smin_nh4_vr(c,j)  < 0._r8 ) then
                     col_ns%smin_nh4_vr(c,j) = 0._r8
                     nreset = nreset + 1
                  endif
               end if
            end do
         end do
         if (nreset > 0) write(iulog, *) nreset, ' values of smin_no3_vr/smin_nh4_vr in (-10^-12, 0) reset to zero'


        if (nu_com .eq. 'ECA') then
            ! decompose P pool adjust according to C pool
            !do fc = 1,num_soilc
            !   c = filter_soilc(fc)
            !   do j = 1,nlevdecomp_full
            !      cp_eca = 0.0_r8
            !      do l = 1,ndecomp_pools
            !         if (abs(col_cs%decomp_cpools_vr(c,j,k)) < ccrit) then
            !            if (.not.use_fates) then
            !               cp_eca = cp_eca + col_ps%decomp_ppools_vr(c,j,k)
            !               col_ps%decomp_ppools_vr(c,j,k) = 0._r8
            !            endif
            !         endif
            !      end do
            !      col_ps%ptrunc_vr(c,j) = col_ps%ptrunc_vr(c,j) + cp_eca
            !   end do
            !end do

            ! fix soil CN ratio drift (normally < 0.01% drift)
            !$acc parallel loop gang vector default(present) private(c, j, cn_eca, l) if(elm_device_ready)
            do fc = 1,num_soilc
               c = filter_soilc(fc)
               !$acc loop seq
               do j = 1,nlevdecomp_full
                  cn_eca = 0.0_r8
                  !$acc loop seq
                  do l = 1,ndecomp_pools
                     if ( col_cs%core%decomp_pools_vr(c,j,l) > 0.0_r8 ) then
                          if(abs(col_cs%core%decomp_pools_vr(c,j,l) / col_ns%core%decomp_pools_vr(c,j,l) - initial_cn_ratio(l) ) > 1.0e-3_r8 &
                          .and. (.not. floating_cn_ratio_decomp_pools(l)) ) then
                        cn_eca = cn_eca - ( col_cs%core%decomp_pools_vr(c,j,l) / initial_cn_ratio(l) - col_ns%core%decomp_pools_vr(c,j,l) )

                          col_ns%core%decomp_pools_vr(c,j,l) = col_cs%core%decomp_pools_vr(c,j,l) / initial_cn_ratio(l)
                     end if
                   end if
                  end do
                  col_ns%core%trunc_sink_vr(c,j) = col_ns%core%trunc_sink_vr(c,j) + cn_eca
               end do
             end do

            ! remove small negative perturbations for stability purposes, if any should arise in N,P pools
            ! for floating CN, CP ratio pools
            ! spel acc-sync: device data this host code uses
            !$acc update self(col_ns%core%decomp_pools_vr, col_ns%core%trunc_sink_vr, &
            !$acc&   col_ps%core%decomp_pools_vr, col_ps%core%trunc_sink_vr) if_present if(elm_device_ready)
            do fc = 1,num_soilc
               c = filter_soilc(fc)
               do j = 1,nlevdecomp_full

                  cn_eca = 0.0_r8
                  cp_eca = 0.0_r8
                  do l = 1,ndecomp_pools
                     if ( col_ns%core%decomp_pools_vr(c,j,l) < 0.0_r8 .and. floating_cn_ratio_decomp_pools(l) ) then
                        if ( abs(col_ns%core%decomp_pools_vr(c,j,l))  < ncrit ) then
                           cn_eca = cn_eca - ncrit + col_ns%core%decomp_pools_vr(c,j,l)
                           col_ns%core%decomp_pools_vr(c,j,l) = ncrit
                        else
#ifndef _OPENACC                                
                           write(iulog, "(A,2I8,E8.1)") 'error decomp_npools is negative: ',j,l,col_ns%core%decomp_pools_vr(c,j,l)
                           call endrun(msg=errMsg(__FILE__, __LINE__))
#endif
                        end if
                     end if
                     if ( col_ps%core%decomp_pools_vr(c,j,l)  < 0.0_r8 .and. floating_cp_ratio_decomp_pools(l) ) then
                        if ( abs(col_ps%core%decomp_pools_vr(c,j,l))  < ncrit/1e4_r8 ) then
                           cp_eca = cp_eca - ncrit/1e4_r8 + col_ps%core%decomp_pools_vr(c,j,l)
                           col_ps%core%decomp_pools_vr(c,j,l) = ncrit/1e4_r8
                         else
#ifndef _OPENACC
                           write(iulog, "(A,2I8,E8.1)") 'error decomp_ppools is negative: ',j,l,col_ps%core%decomp_pools_vr(c,j,l)
                           call endrun(msg=errMsg(__FILE__, __LINE__))
#endif
                         end if
                     end if

                  end do

                  col_ns%core%trunc_sink_vr(c,j) = col_ns%core%trunc_sink_vr(c,j) + cn_eca
                  col_ps%core%trunc_sink_vr(c,j) = col_ps%core%trunc_sink_vr(c,j) + cp_eca

               end do
            end do
            !$acc update device(col_ns%core%decomp_pools_vr, col_ns%core%trunc_sink_vr, &
            !$acc&   col_ps%core%decomp_pools_vr, col_ps%core%trunc_sink_vr) if_present

          if(.not.use_fates) then
            spel_dc_1 = 0  ! spel defer-checks
            spel_dc_2 = 0  ! spel defer-checks
            spel_dc_3 = 0  ! spel defer-checks
            spel_dc_4 = 0  ! spel defer-checks
            !$acc parallel loop gang vector default(present) private(p) reduction(max:spel_dc_1) &
            !$acc   reduction(max:spel_dc_2) reduction(max:spel_dc_3) reduction(max:spel_dc_4) if(elm_device_ready)
            do fp = 1,num_soilp
               p = filter_soilp(fp)
#ifndef _OPENACC
               if (veg_ns%retrans%pool(p) < 0._r8) spel_dc_1 = max(spel_dc_1, fp - (1) + 1)  ! spel defer-checks
               if (veg_ns%core%pool(p) < 0._r8) spel_dc_2 = max(spel_dc_2, fp - (1) + 1)  ! spel defer-checks
               if (veg_ps%retrans%pool(p) < 0._r8) spel_dc_3 = max(spel_dc_3, fp - (1) + 1)  ! spel defer-checks
               if (veg_ps%core%pool(p) < 0._r8) spel_dc_4 = max(spel_dc_4, fp - (1) + 1)  ! spel defer-checks
#endif
            end do
            if (spel_dc_1 > 0) then  ! spel defer-checks: the last element where the check held
               ! spel acc-sync: device data this host code uses
               !$acc update self(veg_ns%retrans%pool) if_present if(elm_device_ready)
               fp = 1 + spel_dc_1 - 1
               p = filter_soilp(fp)

                  write(iulog, *) 'error retransn_patch is negative: ',p
                  write(iulog, *) 'retransn_patch: ', veg_ns%retrans%pool(p)
                  call endrun(msg=errMsg(__FILE__, __LINE__))
            end if
            if (spel_dc_2 > 0) then  ! spel defer-checks: the last element where the check held
               ! spel acc-sync: device data this host code uses
               !$acc update self(veg_ns%core%pool) if_present if(elm_device_ready)
               fp = 1 + spel_dc_2 - 1
               p = filter_soilp(fp)
                  write(iulog, *) 'error npool_patch is negative: ',p
                  write(iulog, *) 'npool_patch: ', veg_ns%core%pool(p)
                  call endrun(msg=errMsg(__FILE__, __LINE__))
            end if
            if (spel_dc_3 > 0) then  ! spel defer-checks: the last element where the check held
               ! spel acc-sync: device data this host code uses
               !$acc update self(veg_ps%retrans%pool) if_present if(elm_device_ready)
               fp = 1 + spel_dc_3 - 1
               p = filter_soilp(fp)
                  write(iulog, *) 'error retransp_patch is negative: ',p
                  write(iulog, *) 'retransp_patch: ', veg_ps%retrans%pool(p)
                  call endrun(msg=errMsg(__FILE__, __LINE__))
            end if
            if (spel_dc_4 > 0) then  ! spel defer-checks: the last element where the check held
               ! spel acc-sync: device data this host code uses
               !$acc update self(veg_ps%core%pool) if_present if(elm_device_ready)
               fp = 1 + spel_dc_4 - 1
               p = filter_soilp(fp)
                  write(iulog, *) 'error ppool_patch is negative: ',p
                  write(iulog, *) 'ppool_patch: ', veg_ps%core%pool(p)
                  call endrun(msg=errMsg(__FILE__, __LINE__))
            end if
         endif

       endif  !if ECA



    end associate

 end subroutine PrecisionControl

end module PrecisionControlMod
