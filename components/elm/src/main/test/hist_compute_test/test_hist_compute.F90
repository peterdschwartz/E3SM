program test_hist_compute

  !-----------------------------------------------------------------------
  ! Unit test of histComputeMod and subgridAveViewMod against
  ! hist_reference_mod (the original serial ELM algorithm) on a synthetic
  ! subgrid.
  !
  ! - Averages to gridcells: p2g_range, c2g_range, l2g_range and t2g_range for every
  !   gridcell and scale type must equal the serial scatter loops.
  ! - History: model arrays at every subgrid level, 1d and 2d, some with their
  !   lower bound reset to 1 and some multi-layer snow fields, are registered
  !   on three tapes (two averaged to gridcells, one on the native subgrid)
  !   with random time operations (I, A, X, M, U, L) and scale types; one
  !   model array may appear on several tapes. Each step gets new values (10%
  !   missing), and every few steps new weights, active flags and snow layers.
  !   After every update, and every normalize at the end of a tape's
  !   interval, all buffers and counters must equal the reference bit for bit.
  !
  ! With OpenACC the model arrays and the subgrid live on the device, as in
  ! ELM: the test copies new values there and the buffers back.
  !
  !   test_hist_compute          run the test (exit status 1 on a mismatch)
  !   test_hist_compute bench    time the reference and histComputeMod on a
  !                              larger subgrid
  !-----------------------------------------------------------------------

  use shr_kind_mod      , only : r8 => shr_kind_r8
  use elm_varctl_stub        , only : elm_device_ready
  use subgridAveViewMod , only : subgrid_ave_view, p2g_range, c2g_range, l2g_range, t2g_range
  use subgridAveViewMod , only : p2g_range_unity, c2g_range_unity, scale_unity
  use CompactLayoutMod  , only : compact_groups, compact_ngroups, compact_group_new, compact_group_fill, &
       compact_lev_patch, compact_lev_col, compact_cidx_p, compact_cidx_c, compact_report
  use histComputeMod
  use fake_subgrid_mod
  use hist_reference_mod

  implicit none

  integer, parameter :: ntapes = 3

  type model_array
     real(r8), allocatable :: a1(:), a2(:,:)
     integer :: level, rank, num2d, no_snow
     integer :: cgroup = 0, cslot = 0   ! compact layout: group buffer column holding this array
  end type model_array

  type ref_buffer
     real(r8), allocatable :: hbuf(:,:)
     integer , allocatable :: nacs(:,:)
  end type ref_buffer

  type(model_array), allocatable, target :: arrays(:)
  type(hist_src1d) , allocatable :: src1(:)
  type(hist_src2d) , allocatable :: src2(:)
  type(hist_active_field), allocatable :: fields(:)
  type(ref_buffer) , allocatable :: ref(:)
  type(subgrid_ave_view) :: view
  integer :: tape_first(ntapes+1)
  integer :: seed_size, nfail, ncase, nreported = 0
  logical, allocatable :: reported(:)
  integer, allocatable :: seed(:)
  character(len=16) :: arg
  real(r8) :: t_ref, t_new
  logical  :: bench = .false.   ! timing run: fixed missing values, fixed subgrid
  logical  :: arrays_on_device = .false.   ! the model arrays were copied to the device (OpenACC)
  logical  :: use_compact = .true.   ! 'nocompact': no model array in the compact layout

  call random_seed(size=seed_size)
  allocate(seed(seed_size))
  seed(:) = 20261017
  call random_seed(put=seed)

  arg = ' '
  if (command_argument_count() > 0) call get_command_argument(1, arg)

  if (trim(arg) == 'nocompact') use_compact = .false.
  if (trim(arg) == 'bench') then
     bench = .true.
     call build_subgrid(ng=4000, offset=1000)
     call subgrid_view(view)
     call setup_fields(nsrc=300, nfld=600)
     call run(nsteps=24, extrasnow=.false., check=.false.)
     write(*,'(a,i0,a,i0,a,i0,a)') 'bench: ', endg-begg+1, ' gridcells, ', endp-begp+1, &
          ' patches, ', size(fields), ' fields, 24 steps'
     write(*,'(a,f9.3,a)') '  reference (old code):           ', t_ref, ' s'
     write(*,'(a,f9.3,a)') '  histComputeMod (device path):   ', t_new, ' s'
     write(*,'(a,f9.1)')   '  speedup:                        ', t_ref / t_new
#ifndef _OPENACC
     elm_device_ready = .false.
     call run(nsteps=24, extrasnow=.false., check=.false.)
     write(*,'(a,f9.3,a)') '  histComputeMod (host path):     ', t_new, ' s'
     write(*,'(a,f9.1)')   '  speedup:                        ', t_ref / t_new
#endif
     stop
  end if

  call build_subgrid(ng=37, offset=10)
  call subgrid_view(view)
  call setup_fields(nsrc=90, nfld=180)
  write(*,'(a,i0,a,i0,a,i0,a,i0,a,i0,a)') 'subgrid: ', endg-begg+1, ' gridcells, ', &
       endt-begt+1, ' topounits, ', endl-begl+1, ' landunits, ', endc-begc+1, ' columns, ', &
       endp-begp+1, ' patches'
  write(*,'(a,i0,a,i0,a)') 'fields:  ', size(fields), ' on 3 tapes, from ', size(arrays), ' model arrays'
  write(*,'(a,i0,a,i0,a,i0,a)') 'compact: ', count(arrays(:)%cgroup > 0), ' arrays in compact groups; ', &
       n_compact_p, ' member patches, ', n_compact_c, ' member columns'
  call compact_report(6)

  nfail = 0
  ncase = 0
  allocate(reported(size(fields)))
  reported(:) = .false.
  ! histComputeMod's device path (the kernel; serial here without OpenACC): elm_device_ready is the
  ! stub's .true. As in ELM, the model arrays reach the device after the first hist_compute_build
  ! and are attached then (hist_compute_attach); on a GPU the host copies are made wrong while the
  ! kernel runs (decoy), so a kernel reading host memory through an unattached pointer fails.
  call run(nsteps=60, extrasnow=.false., check=.true.)
  call run(nsteps=60, extrasnow=.true.,  check=.true.)
#ifndef _OPENACC
  ! the host path (without OpenACC the model arrays are on the host either way)
  elm_device_ready = .false.
  write(*,'(a)') 'host path:'
  call run(nsteps=60, extrasnow=.false., check=.true.)
  call run(nsteps=60, extrasnow=.true.,  check=.true.)
  elm_device_ready = .true.
#endif
  if (nfail > 0) then
     write(*,'(a,i0,a)') 'FAIL: ', nfail, ' mismatches'
     error stop 1
  end if
  write(*,'(a,i0,a)') 'PASS: ', ncase, ' comparisons bit-for-bit with the reference'

contains

  !-----------------------------------------------------------------------
  subroutine setup_fields(nsrc, nfld)
    ! Random model arrays (copied to the device by the first run, after the
    ! history setup, as in ELM), and fields on three tapes that use them.
    integer, intent(in) :: nsrc, nfld
    integer :: i, f, t, beg, end, n, lb

    allocate(arrays(nsrc), src1(nsrc), src2(nsrc))
    do i = 1, nsrc
       associate(m => arrays(i))
       m%level   = rand_int(lev_grid, lev_patch)
       m%rank    = rand_int(1, 2)
       m%num2d   = 1
       m%no_snow = no_snow_unset
       if (m%rank == 2) m%num2d = rand_int(1, 7)
       if (m%rank == 2 .and. m%level >= lev_col .and. urand() < 0.4_r8) then
          m%num2d   = nlevsno
          m%no_snow = rand_int(no_snow_normal, no_snow_zero)
       end if
       beg = level_beg(m%level); end = level_end(m%level); n = end - beg + 1
       lb = beg
       if (urand() < 0.25_r8) lb = 1      ! pointer to an array section
       if (m%rank == 1) then
          allocate(m%a1(lb:lb+n-1))
          m%a1(:) = 0._r8
          src1(i)%ptr => m%a1
       else
          if (m%no_snow /= no_snow_unset) then
             allocate(m%a2(lb:lb+n-1, -nlevsno+1:0))   ! as ELM's snow arrays
          else
             allocate(m%a2(lb:lb+n-1, m%num2d))
          end if
          m%a2(:,:) = 0._r8
          src2(i)%ptr => m%a2
       end if
       end associate
    end do

    ! compact layout: a third of the rank-1 patch and column arrays live in a
    ! group buffer (one group per level; fill 0 for patches, spval for columns,
    ! as the init-time zeroing leaves them); their full copy m%a1 only feeds the reference
    if (use_compact) then
       call compact_arrays(lev_patch, compact_lev_patch, 1, 0._r8, 'patch group')
       call compact_arrays(lev_col, compact_lev_col, 1, spval, 'column group')
       call compact_arrays(lev_col, compact_lev_col, 2, 0._r8, 'column rank-2 group')
       call compact_arrays(lev_patch, compact_lev_patch, 2, spval, 'patch rank-2 group')
    end if

    ! tapes 1 and 2 average to gridcells (hist_dov2xy), tape 3 doesn't
    allocate(fields(nfld), ref(nfld))
    f = 0
    do t = 1, ntapes
       tape_first(t) = f + 1
       do i = 1, nfld / ntapes
          f = f + 1
          fields(f)%source_index = rand_int(1, nsrc)
          associate(m => arrays(fields(f)%source_index), fld => fields(f))
          fld%source_level     = m%level
          fld%source_rank      = m%rank
          fld%num_levels       = m%num2d
          fld%no_snow_behavior = m%no_snow
          fld%compact_group    = m%cgroup
          fld%compact_slot     = m%cslot
          fld%time_op          = rand_int(time_inst, time_min_valid)
          fld%average_to_gridcell = t < 3 .and. m%level /= lev_grid
          fld%c2l_scale = 1          ! mostly 'unity', as in ELM's field list
          fld%l2g_scale = 1
          if (urand() < 0.4_r8) fld%c2l_scale = rand_int(2, n_c2l)
          if (urand() < 0.4_r8) fld%l2g_scale = rand_int(2, n_l2g)
          if (fld%average_to_gridcell) then
             beg = begg; end = endg
          else
             beg = level_beg(fld%source_level); end = level_end(fld%source_level)
          end if
          allocate(ref(f)%hbuf(end-beg+1, fld%num_levels), ref(f)%nacs(end-beg+1, fld%num_levels))
          end associate
       end do
    end do
    tape_first(ntapes+1) = f + 1
  end subroutine setup_fields

  !-----------------------------------------------------------------------
  subroutine compact_arrays(level, clevel, rank, fill, name)
    ! Every third rank-`rank` model array of `level` lives in one compact group
    ! (its column of the group buffer); m%a1 / m%a2 stay as the reference's
    ! copies. A rank-2 group takes the arrays of the first eligible array's
    ! num2d (one level count per group); snow arrays never.
    integer , intent(in) :: level, clevel, rank
    real(r8), intent(in) :: fill
    character(len=*), intent(in) :: name
    integer :: i, g, slot, nfld, nlev
    logical :: eligible(size(arrays))
    do i = 1, size(arrays)
       eligible(i) = arrays(i)%level == level .and. arrays(i)%rank == rank .and. mod(i, 3) == 0 &
            .and. arrays(i)%no_snow == no_snow_unset .and. arrays(i)%cgroup == 0
    end do
    nlev = 0
    nfld = 0
    do i = 1, size(arrays)
       if (.not. eligible(i)) cycle
       if (rank == 2 .and. nlev == 0) nlev = arrays(i)%num2d
       if (rank == 2 .and. arrays(i)%num2d /= nlev) cycle
       nfld = nfld + 1
    end do
    if (nfld == 0) return
    if (rank == 2) then
       g = compact_group_new(name, clevel, nfld, nlev)
    else
       g = compact_group_new(name, clevel, nfld)
    end if
    call compact_group_fill(g, fill)
    slot = 0
    do i = 1, size(arrays)
       if (.not. eligible(i)) cycle
       if (rank == 2 .and. arrays(i)%num2d /= nlev) cycle
       slot = slot + 1
       arrays(i)%cgroup = g
       arrays(i)%cslot  = slot
    end do
  end subroutine compact_arrays

  !-----------------------------------------------------------------------
  subroutine run(nsteps, extrasnow, check)
    integer, intent(in) :: nsteps
    logical, intent(in) :: extrasnow, check
    integer :: step, f, t, ierr
    character(len=128) :: msg
    integer(8) :: c0, c1, rate

    extrasnowlayers = extrasnow
    call hist_compute_build(view, fields, tape_first, src1, src2, extrasnow, ierr, msg)
    if (ierr /= 0) then
       write(*,*) 'build failed for field ', ierr, ': ', trim(msg)
       error stop 1
    end if
    ! ELM's order: the model state reaches the device after the history setup; attach then
    if (.not. arrays_on_device) then
       call arrays_to_device()
       arrays_on_device = .true.
    end if
    call hist_compute_attach(src1, src2)
    do f = 1, size(fields)
       ref(f)%hbuf(:,:) = 0._r8
       ref(f)%nacs(:,:) = 0
    end do

    t_ref = 0._r8; t_new = 0._r8
    do step = 1, nsteps
       call new_values()
       if (mod(step, 7) == 0 .and. .not. bench) call perturb_subgrid(0.2_r8)
       if (check) call check_averages(step)

       call system_clock(c0, rate)
       do f = 1, size(fields)
          call ref_update_field(fields(f), src1, src2, ref(f)%hbuf, ref(f)%nacs)
       end do
       call system_clock(c1)
       t_ref = t_ref + real(c1 - c0, r8) / rate

       call decoy_host(.true.)
       call system_clock(c0)
       call hist_compute_update(view, src1, src2)
       call system_clock(c1)
       call decoy_host(.false.)
       t_new = t_new + real(c1 - c0, r8) / rate
       if (check) call compare('update', step)

       ! end of each tape's interval: normalize, compare, zero
       do t = 1, ntapes
          if (mod(step, 4 + 3*t) /= 0) cycle
          call hist_compute_normalize(t)
          do f = tape_first(t), tape_first(t+1) - 1
             call ref_normalize(fields(f), ref(f)%hbuf, ref(f)%nacs)
          end do
          if (check) call compare('normalize', step)
          call hist_compute_zero(t)
          do f = tape_first(t), tape_first(t+1) - 1
             ref(f)%hbuf(:,:) = 0._r8
             ref(f)%nacs(:,:) = 0
          end do
       end do
    end do
  end subroutine run

  !-----------------------------------------------------------------------
  subroutine arrays_to_device()
    ! Copy the model arrays to the device (OpenACC).
    integer :: i
    do i = 1, size(arrays)
       if (arrays(i)%rank == 1) then
          !$acc enter data copyin(arrays(i)%a1)
       else
          !$acc enter data copyin(arrays(i)%a2)
       end if
    end do
  end subroutine arrays_to_device

  !-----------------------------------------------------------------------
  subroutine decoy_host(on)
    ! On a device with its own memory: make the host copies of everything the
    ! kernel reads wrong (negated; off restores them exactly), so a kernel that
    ! reads host memory through an unattached pointer fails the comparison.
#ifdef _OPENACC
    use openacc, only : acc_get_device_type, acc_device_nvidia
#endif
    logical, intent(in) :: on
#ifdef _OPENACC
    integer :: i, g
    if (acc_get_device_type() /= acc_device_nvidia) return
    do i = 1, size(arrays)
       if (arrays(i)%rank == 1) then
          arrays(i)%a1(:) = -arrays(i)%a1(:)
       else
          arrays(i)%a2(:,:) = -arrays(i)%a2(:,:)
       end if
    end do
    do g = 1, compact_ngroups
       if (associated(compact_groups(g)%data))  compact_groups(g)%data(:,:)    = -compact_groups(g)%data(:,:)
       if (associated(compact_groups(g)%data3)) compact_groups(g)%data3(:,:,:) = -compact_groups(g)%data3(:,:,:)
    end do
    call decoy_subgrid()
#endif
  end subroutine decoy_host

  !-----------------------------------------------------------------------
  subroutine new_values()
    ! New values of all model arrays, 10% missing.
    integer :: i, k, j

    do i = 1, size(arrays)
       associate(m => arrays(i))
       if (m%rank == 1) then
          do k = lbound(m%a1, 1), ubound(m%a1, 1)
             m%a1(k) = value(i + k)
          end do
          if (m%cgroup > 0) call compact_values(m)
          !$acc update device(m%a1)
       else
          do j = lbound(m%a2, 2), ubound(m%a2, 2)
             do k = lbound(m%a2, 1), ubound(m%a2, 1)
                m%a2(k, j) = value(i + k + j)
             end do
          end do
          if (m%cgroup > 0) call compact_values(m)
          !$acc update device(m%a2)
       end if
       end associate
    end do
  end subroutine new_values

  subroutine compact_values(m)
    ! The compact copy of a compact model array: members take the full copy's
    ! value; the full copy itself gets the layout's values on non-members (the
    ! group's fill on special points, spval elsewhere), as the full layout would
    ! hold, so the reference (reading m%a1) and histComputeMod (reading the
    ! buffer through the map) must agree bit for bit.
    type(model_array), intent(inout) :: m
    integer :: beg, end, k, p, lb
    beg = level_beg(m%level); end = level_end(m%level)
    if (m%rank == 1) then
       lb = lbound(m%a1, 1)
    else
       lb = lbound(m%a2, 1)
    end if
    do p = beg, end
       if (m%level == lev_patch) then
          k = compact_cidx_p(p)
       else
          k = compact_cidx_c(p)
       end if
       if (m%rank == 1) then
          if (k > 0) then
             compact_groups(m%cgroup)%data(k, m%cslot) = m%a1(p - beg + lb)
          else if (k < 0) then
             m%a1(p - beg + lb) = compact_groups(m%cgroup)%fill
          else
             m%a1(p - beg + lb) = spval
          end if
       else
          if (k > 0) then
             compact_groups(m%cgroup)%data3(k, 1:m%num2d, m%cslot) = m%a2(p - beg + lb, 1:m%num2d)
          else if (k < 0) then
             m%a2(p - beg + lb, :) = compact_groups(m%cgroup)%fill
          else
             m%a2(p - beg + lb, :) = spval
          end if
       end if
    end do
    if (m%rank == 1) then
       !$acc update device(compact_groups(m%cgroup)%data)
    else
       !$acc update device(compact_groups(m%cgroup)%data3)
    end if
  end subroutine compact_values

  real(r8) function value(key)
    ! 10% missing: random each step (test), or at fixed points (bench, as in
    ! a model, where missing values mark points without the quantity)
    integer, intent(in) :: key
    logical :: missing
    if (bench) then
       missing = mod(key * 7919, 10) == 0
    else
       missing = urand() < 0.1_r8
    end if
    if (missing) then
       value = spval
    else
       value = 600._r8 * (urand() - 0.3_r8)
    end if
  end function value

  !-----------------------------------------------------------------------
  subroutine check_averages(step)
    ! The averages to gridcells against the serial scatter loops, for every
    ! scale type, on random values of each level (10% missing): over all
    ! gridcells on the host, and in chunks of gridcells in a kernel (on the
    ! device with OpenACC), as subgridAveMod calls them.
    integer, intent(in) :: step
    integer, parameter :: chunk_len = 16
    real(r8) :: pv(begp:endp), cv(begc:endc), lv(begl:endl), tv(begt:endt)
    real(r8) :: ref_avg(begg:endg), avg(begg:endg)
    integer  :: i, ic2l, il2g, nbad, chunk, nchunk, g0, g1

    do i = begp, endp ; pv(i) = value(i) ; end do
    do i = begc, endc ; cv(i) = value(i) ; end do
    do i = begl, endl ; lv(i) = value(i) ; end do
    do i = begt, endt ; tv(i) = value(i) ; end do

    nbad = 0
    do ic2l = 1, n_c2l
       do il2g = 1, n_l2g
          call ref_p2g(pv, ref_avg, ic2l, il2g)
          call p2g_range(view, begg, endg, pv, begp, ic2l, il2g, avg)
          nbad = nbad + count(avg /= ref_avg)
          call ref_c2g(cv, ref_avg, ic2l, il2g)
          call c2g_range(view, begg, endg, cv, begc, ic2l, il2g, avg)
          nbad = nbad + count(avg /= ref_avg)
       end do
    end do
    ! the unity kernels: bit for bit the general ones with the unity ids
    call ref_p2g(pv, ref_avg, scale_unity, scale_unity)
    call p2g_range_unity(view, begg, endg, pv, begp, avg)
    nbad = nbad + count(avg /= ref_avg)
    call ref_c2g(cv, ref_avg, scale_unity, scale_unity)
    call c2g_range_unity(view, begg, endg, cv, begc, avg)
    nbad = nbad + count(avg /= ref_avg)
    do il2g = 1, n_l2g
       call ref_l2g(lv, ref_avg, il2g)
       call l2g_range(view, begg, endg, lv, begl, il2g, avg)
       nbad = nbad + count(avg /= ref_avg)
    end do
    call ref_t2g(tv, ref_avg)
    call t2g_range(view, begg, endg, tv, begt, avg)
    nbad = nbad + count(avg /= ref_avg)

    ! the same averages in chunks of gridcells, one gang each
    nchunk = (endg - begg) / chunk_len + 1
    call ref_p2g(pv, ref_avg, n_c2l, n_l2g)
    !$acc parallel loop gang default(present) copyin(pv) copyout(avg) private(g0, g1)
    do chunk = 1, nchunk
       g0 = begg + (chunk-1) * chunk_len ; g1 = min(g0 + chunk_len - 1, endg)
       call p2g_range(view, g0, g1, pv, begp, n_c2l, n_l2g, avg(g0:g1))
    end do
    nbad = nbad + count(avg /= ref_avg)
    call ref_c2g(cv, ref_avg, n_c2l, n_l2g)
    !$acc parallel loop gang default(present) copyin(cv) copyout(avg) private(g0, g1)
    do chunk = 1, nchunk
       g0 = begg + (chunk-1) * chunk_len ; g1 = min(g0 + chunk_len - 1, endg)
       call c2g_range(view, g0, g1, cv, begc, n_c2l, n_l2g, avg(g0:g1))
    end do
    nbad = nbad + count(avg /= ref_avg)
    call ref_p2g(pv, ref_avg, scale_unity, scale_unity)
    !$acc parallel loop gang default(present) copyin(pv) copyout(avg) private(g0, g1)
    do chunk = 1, nchunk
       g0 = begg + (chunk-1) * chunk_len ; g1 = min(g0 + chunk_len - 1, endg)
       call p2g_range_unity(view, g0, g1, pv, begp, avg(g0:g1))
    end do
    nbad = nbad + count(avg /= ref_avg)
    call ref_c2g(cv, ref_avg, scale_unity, scale_unity)
    !$acc parallel loop gang default(present) copyin(cv) copyout(avg) private(g0, g1)
    do chunk = 1, nchunk
       g0 = begg + (chunk-1) * chunk_len ; g1 = min(g0 + chunk_len - 1, endg)
       call c2g_range_unity(view, g0, g1, cv, begc, avg(g0:g1))
    end do
    nbad = nbad + count(avg /= ref_avg)
    call ref_l2g(lv, ref_avg, n_l2g)
    !$acc parallel loop gang default(present) copyin(lv) copyout(avg) private(g0, g1)
    do chunk = 1, nchunk
       g0 = begg + (chunk-1) * chunk_len ; g1 = min(g0 + chunk_len - 1, endg)
       call l2g_range(view, g0, g1, lv, begl, n_l2g, avg(g0:g1))
    end do
    nbad = nbad + count(avg /= ref_avg)
    call ref_t2g(tv, ref_avg)
    !$acc parallel loop gang default(present) copyin(tv) copyout(avg) private(g0, g1)
    do chunk = 1, nchunk
       g0 = begg + (chunk-1) * chunk_len ; g1 = min(g0 + chunk_len - 1, endg)
       call t2g_range(view, g0, g1, tv, begt, avg(g0:g1))
    end do
    nbad = nbad + count(avg /= ref_avg)

    ncase = ncase + 1
    if (nbad > 0) then
       nfail = nfail + 1
       write(*,'(a,i0,a,i0,a)') 'averages differ from the serial loops at step ', step, ': ', &
            nbad, ' gridcell values'
    end if
  end subroutine check_averages

  !-----------------------------------------------------------------------
  subroutine compare(what, step)
    character(len=*), intent(in) :: what
    integer         , intent(in) :: step
    real(r8), pointer :: hbuf(:,:)
    integer , pointer :: nacs(:,:)
    integer :: f, t, lev, i, nshown

    do t = 1, ntapes
       call hist_compute_update_host(t)
    end do
    do f = 1, size(fields)
       call hist_compute_views(f, hbuf, nacs)
       ncase = ncase + 1
       if (any(shape(hbuf) /= shape(ref(f)%hbuf))) then
          write(*,*) 'shape mismatch: field ', f
          nfail = nfail + 1
       else if (any(hbuf /= ref(f)%hbuf) .or. any(nacs /= ref(f)%nacs)) then
          nfail = nfail + 1
          if (.not. reported(f)) then   ! each field once, at its first mismatch
             reported(f) = .true.
             nreported = nreported + 1
             write(*,'(a,a,a,i0,a,i0,a,5i3,l2,a,i0,a,i0,a,es9.2)') 'mismatch after ', what, ' step ', step, &
                  ' field ', f, ' (level rank levels time_op snow gcell):', fields(f)%source_level, &
                  fields(f)%source_rank, fields(f)%num_levels, fields(f)%time_op, &
                  fields(f)%no_snow_behavior, fields(f)%average_to_gridcell, ' values differing: ', &
                  count(hbuf /= ref(f)%hbuf), ', counters: ', count(nacs /= ref(f)%nacs), &
                  ', max relative difference: ', &
                  maxval(abs(hbuf - ref(f)%hbuf) / max(abs(ref(f)%hbuf), tiny(1._r8)))
             if (nreported <= 12) then   ! the first differing elements of the first fields
                nshown = 0
                do lev = 1, size(hbuf, 2)
                   do i = lbound(hbuf, 1), ubound(hbuf, 1)
                      if (hbuf(i,lev) /= ref(f)%hbuf(i-lbound(hbuf,1)+1,lev) .or. &
                           nacs(i,lev) /= ref(f)%nacs(i-lbound(hbuf,1)+1,lev)) then
                         nshown = nshown + 1
                         if (nshown > 4) exit
                         write(*,'(a,i0,a,i0,a,es14.6,a,es14.6,a,i0,a,i0)') '    point ', i, ' level ', lev, &
                              ': got ', hbuf(i,lev), ' ref ', ref(f)%hbuf(i-lbound(hbuf,1)+1,lev), &
                              '  nacs got ', nacs(i,lev), ' ref ', ref(f)%nacs(i-lbound(hbuf,1)+1,lev)
                      end if
                   end do
                   if (nshown > 4) exit
                end do
             end if
          end if
       end if
    end do
  end subroutine compare

end program test_hist_compute
