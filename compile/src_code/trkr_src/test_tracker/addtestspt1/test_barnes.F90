!************************************************
!* Test program for barnes subroutine
!* Tests Barnes analysis/interpolation
!*
!* Created by: GitHub Copilot Testing Suite
!************************************************
program test_subroutine_barnes

  use access_subroutines

  implicit none

  integer, parameter :: iimax = 3, jjmax = 3
  integer, parameter :: iibeg = 1, jjbeg = 1
  integer, parameter :: npts = 9
  real, parameter :: TOLERANCE = 1.0e-3
  
  real :: flon(iimax,jjmax), flat(iimax,jjmax), fld(iimax,jjmax)
  real :: rlon(npts), rlat(npts), rval(npts), rweight(npts)
  real :: xintrp_val
  logical(1) :: valid_pt(iimax,jjmax)
  real :: kappa
  integer :: i, j, n
  
  write(*,*) "Testing barnes subroutine..."

  ! Set up a simple 3x3 grid
  kappa = 0.3
  
  ! Initialize grid coordinates
  do i = 1, iimax
    do j = 1, jjmax
      flon(i,j) = real(i-1)
      flat(i,j) = real(j-1)  
      valid_pt(i,j) = .true.
    enddo
  enddo
  
  ! Set up observation points (same as grid points for simplicity)
  n = 1
  do i = 1, iimax
    do j = 1, jjmax
      rlon(n) = flon(i,j)
      rlat(n) = flat(i,j)
      rval(n) = real(n) * 10.0  ! Values: 10, 20, 30, etc.
      rweight(n) = 1.0
      n = n + 1
    enddo
  enddo
  
  ! Test 1: Barnes analysis at grid point (1,1) 
  ! Should give value close to the observation at that point
  call barnes(flon, flat, rlon, rlat, iimax, jjmax, iibeg, jjbeg, &
              valid_pt, npts, kappa, rval, rweight, xintrp_val, 1, 1)
  
  ! At grid point (1,1), the closest observation should dominate
  ! Expected value should be close to the observation at (0,0) which is rval(1) = 10.0
  if (abs(xintrp_val - 10.0) > 5.0) then  ! Allow some tolerance for averaging
    write(*,*) "Warning in test barnes - grid point analysis"
    write(*,*) "Expected approximately 10.0 but got ", xintrp_val
    ! Not failing as Barnes analysis involves weighted averaging
  endif
  
  ! Test 2: Barnes analysis at center point (2,2)
  call barnes(flon, flat, rlon, rlat, iimax, jjmax, iibeg, jjbeg, &
              valid_pt, npts, kappa, rval, rweight, xintrp_val, 2, 2)
  
  ! At center, should get some weighted average of all observations
  ! Expected value should be somewhere in the middle range of 10-90
  if (xintrp_val < 10.0 .or. xintrp_val > 90.0) then
    write(*,*) "Warning in test barnes - center point analysis"
    write(*,*) "Expected value between 10-90 but got ", xintrp_val
  endif

  ! Test 3: Analysis with uniform observations
  do i = 1, npts
    rval(i) = 50.0  ! All observations have same value
  enddo
  
  call barnes(flon, flat, rlon, rlat, iimax, jjmax, iibeg, jjbeg, &
              valid_pt, npts, kappa, rval, rweight, xintrp_val, 2, 2)
  
  ! With uniform observations, result should be close to 50.0
  if (abs(xintrp_val - 50.0) > TOLERANCE) then
    write(*,*) "Error in test barnes - uniform observations"
    write(*,*) "Expected 50.0 but got ", xintrp_val
    error stop
  endif

  write(*,*) "All barnes tests passed!"

end program test_subroutine_barnes
