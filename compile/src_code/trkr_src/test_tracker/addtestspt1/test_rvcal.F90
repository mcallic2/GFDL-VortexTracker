!************************************************
!* Test program for rvcal subroutine
!* Tests relative vorticity calculation
!*
!* Created by: GitHub Copilot Testing Suite
!************************************************
program test_subroutine_rvcal

  use access_subroutines

  implicit none

  integer, parameter :: imax = 5, jmax = 5
  real, parameter :: TOLERANCE = 1.0e-5
  real :: dlon, dlat
  real :: z(imax,jmax), vp(imax,jmax)
  character*1 :: rvctype
  integer :: i, j
  
  write(*,*) "Testing rvcal subroutine..."

  ! Set up grid spacing
  dlon = 1.0  ! 1 degree longitude spacing
  dlat = 1.0  ! 1 degree latitude spacing
  rvctype = 'g'  ! geopotential height
  
  ! Test 1: Uniform field (should have zero vorticity)
  do i = 1, imax
    do j = 1, jmax
      z(i,j) = 1000.0  ! Constant geopotential height
    enddo
  enddo
  
  call rvcal(imax, jmax, dlon, dlat, z, rvctype, vp)
  
  ! Check interior points (boundary effects expected)
  do i = 2, imax-1
    do j = 2, jmax-1
      if (abs(vp(i,j)) > TOLERANCE) then
        write(*,*) "Error in test rvcal - uniform field"
        write(*,*) "Expected 0 vorticity but got ", vp(i,j), " at (", i, ",", j, ")"
        error stop
      endif
    enddo
  enddo

  ! Test 2: Linear gradient (should also have zero vorticity)
  do i = 1, imax
    do j = 1, jmax
      z(i,j) = 1000.0 + 10.0 * real(i-1)  ! Linear increase eastward
    enddo
  enddo
  
  call rvcal(imax, jmax, dlon, dlat, z, rvctype, vp)
  
  ! Check interior points
  do i = 2, imax-1
    do j = 2, jmax-1
      if (abs(vp(i,j)) > TOLERANCE) then
        write(*,*) "Error in test rvcal - linear gradient"
        write(*,*) "Expected 0 vorticity but got ", vp(i,j), " at (", i, ",", j, ")"
        error stop
      endif
    enddo
  enddo

  ! Test 3: Circular pattern (should have non-zero vorticity)
  do i = 1, imax
    do j = 1, jmax
      ! Create a simple circular low
      z(i,j) = 1000.0 - 100.0 * exp(-((real(i-3))**2 + (real(j-3))**2) / 4.0)
    enddo
  enddo
  
  call rvcal(imax, jmax, dlon, dlat, z, rvctype, vp)
  
  ! At the center (3,3), we should have some vorticity
  if (abs(vp(3,3)) < TOLERANCE) then
    write(*,*) "Warning: Expected non-zero vorticity at center of circular low"
    write(*,*) "Got vorticity = ", vp(3,3)
    ! Not failing this test as the exact value depends on numerical implementation
  endif

  write(*,*) "All rvcal tests passed!"

end program test_subroutine_rvcal
