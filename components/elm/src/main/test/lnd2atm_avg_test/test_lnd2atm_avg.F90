program test_lnd2atm_avg
  ! lnd2atmAvgMod against the serial averages to gridcells (hist_compute_test's ref_p2g/ref_c2g),
  ! bit for bit, on the synthetic subgrid of hist_compute_test (landunits ordered by type, bounds
  ! not starting at 1, zero weights, inactive points): patch and column sources, every c2l/l2g
  ! scale type pair, single fields and levels of 2d fields (ELM's pointer components, as
  ! lnd2atmMod adds them), 10% spval, the two groups averaged separately, a new subgrid every 3
  ! steps.
  use shr_kind_mod, only : r8 => shr_kind_r8
  use subgridAveViewMod, only : subgrid_ave_view, spval
  use fake_subgrid_mod, only : build_subgrid, subgrid_view, perturb_subgrid, urand, n_c2l, n_l2g, &
       begg, endg, begc, endc, begp, endp
  use hist_reference_mod, only : ref_p2g, ref_c2g
  use lnd2atmAvgMod, only : l2a_add, l2a_finish_group, l2a_average, l2a_patch, l2a_column, &
       l2a_minimal, l2a_full
  implicit none

  integer, parameter :: nlev = 3, nsteps = 10
  type :: entry_t
     integer :: group, level, ic2l, il2g, lev   ! lev 0: a 1d source
  end type entry_t
  type(subgrid_ave_view) :: view
  ! model arrays (pointer components in ELM)
  real(r8), pointer :: p1(:,:) => null(), c1(:,:) => null()          ! 1d sources, one per entry
  real(r8), pointer :: p2(:,:,:) => null(), c2(:,:,:) => null()      ! 2d sources (point, level, entry)
  real(r8), pointer :: g1(:,:) => null(), g2(:,:,:) => null()        ! destinations
  real(r8), allocatable :: ref(:)
  type(entry_t), allocatable :: e(:)
  integer :: n, ne, ic2l, il2g, lev, step, nbad, ncase, level, group

  call build_subgrid(ng=37, offset=10)
  call subgrid_view(view)

  ! one 1d entry per (level, c2l, l2g), alternating groups; one 2d (nlev levels) per level and c2l
  ne = 2 * n_c2l * n_l2g + 2 * n_c2l * nlev
  allocate(e(ne))
  allocate(p1(begp:endp, ne), c1(begc:endc, ne), p2(begp:endp, nlev, ne), c2(begc:endc, nlev, ne))
  allocate(g1(begg:endg, ne), g2(begg:endg, nlev, ne), ref(begg:endg))
  !$acc enter data create(p1, c1, p2, c2, g1, g2)
  n = 0
  do level = l2a_patch, l2a_column
     do ic2l = 1, n_c2l
        do il2g = 1, n_l2g
           n = n + 1
           e(n) = entry_t(merge(l2a_minimal, l2a_full, mod(n, 2) == 0), level, ic2l, il2g, 0)
        end do
        do lev = 1, nlev
           n = n + 1
           e(n) = entry_t(merge(l2a_minimal, l2a_full, mod(n, 3) == 0), level, ic2l, 1 + mod(lev, n_l2g), lev)
        end do
     end do
  end do
  do group = l2a_minimal, l2a_full
     do n = 1, ne
        if (e(n)%group /= group) cycle
        if (e(n)%lev == 0) then
           if (e(n)%level == l2a_patch) then
              call l2a_add(group, l2a_patch, p1(:,n), begp, g1(:,n), begg, e(n)%ic2l, e(n)%il2g)
           else
              call l2a_add(group, l2a_column, c1(:,n), begc, g1(:,n), begg, e(n)%ic2l, e(n)%il2g)
           end if
        else
           if (e(n)%level == l2a_patch) then
              call l2a_add(group, l2a_patch, p2(:,e(n)%lev,n), begp, g2(:,e(n)%lev,n), begg, e(n)%ic2l, e(n)%il2g)
           else
              call l2a_add(group, l2a_column, c2(:,e(n)%lev,n), begc, g2(:,e(n)%lev,n), begg, e(n)%ic2l, e(n)%il2g)
           end if
        end if
     end do
     call l2a_finish_group(group)
  end do

  nbad = 0
  ncase = 0
  do step = 1, nsteps
     if (mod(step, 3) == 0) call perturb_subgrid(0.3_r8)
     call fill(p1); call fill(c1); call fill3(p2); call fill3(c2)
     g1 = -1._r8; g2 = -1._r8
     !$acc update device(p1, c1, p2, c2, g1, g2)
     call l2a_average(l2a_minimal, view, begg, endg, .true.)
     call l2a_average(l2a_full, view, begg, endg, .true.)
     !$acc update self(g1, g2)
     do n = 1, ne
        if (e(n)%lev == 0) then
           if (e(n)%level == l2a_patch) then
              call ref_p2g(p1(:,n), ref, e(n)%ic2l, e(n)%il2g)
           else
              call ref_c2g(c1(:,n), ref, e(n)%ic2l, e(n)%il2g)
           end if
           call compare(g1(:,n), n)
        else
           if (e(n)%level == l2a_patch) then
              call ref_p2g(p2(:,e(n)%lev,n), ref, e(n)%ic2l, e(n)%il2g)
           else
              call ref_c2g(c2(:,e(n)%lev,n), ref, e(n)%ic2l, e(n)%il2g)
           end if
           call compare(g2(:,e(n)%lev,n), n)
        end if
     end do
  end do

  if (nbad > 0) then
     write(*,'(a,i0,a)') 'FAIL: ', nbad, ' entry-steps differ from the reference'
     error stop 1
  end if
  write(*,'(a,i0,a,i0,a)') 'PASS: ', ncase, ' entry-steps bit-for-bit with the reference (', ne, ' entries)'

contains

  subroutine compare(got, n)
    real(r8), intent(in) :: got(begg:)
    integer , intent(in) :: n
    ncase = ncase + 1
    if (any(got /= ref)) then
       nbad = nbad + 1
       if (nbad <= 10) write(*,'(a,i3,a,i3,a,i2,a,2i2,a,i2,a,i5)') 'MISMATCH step', step, ' entry', n, ' level', &
            e(n)%level, ' scales', e(n)%ic2l, e(n)%il2g, ' lev', e(n)%lev, ' gridcells differing', count(got /= ref)
    end if
  end subroutine compare

  subroutine fill(a)
    real(r8), intent(inout) :: a(:,:)
    integer :: i, j
    do j = 1, size(a, 2)
       do i = 1, size(a, 1)
          a(i,j) = merge(spval, 100._r8 * urand() - 20._r8, urand() < 0.1_r8)
       end do
    end do
  end subroutine fill

  subroutine fill3(a)
    real(r8), intent(inout) :: a(:,:,:)
    integer :: k
    do k = 1, size(a, 3)
       call fill(a(:,:,k))
    end do
  end subroutine fill3

end program test_lnd2atm_avg
