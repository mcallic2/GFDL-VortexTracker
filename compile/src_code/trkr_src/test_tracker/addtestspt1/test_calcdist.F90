!************************************************
!* Test program for calcdist subroutine
!* Tests distance calculation between geographic points
!*
!* Created by: GitHub Copilot Testing Suite
!************************************************
program test_subroutine_calcdist

  use access_subroutines

  implicit none

  real, parameter :: TOLERANCE = 1.0e-5
  real :: rlonb, rlatb, rlonc, rlatc, xdist
  integer :: degrees
  
  write(*,*) "Testing calcdist subroutine..."

  ! Test 1: Distance between same point (should be 0)
  rlonb = 45.0
  rlatb = 45.0
  rlonc = 45.0
  rlatc = 45.0
  degrees = 1
  
  call calcdist(rlonb, rlatb, rlonc, rlatc, xdist, degrees)
  
  if (abs(xdist) > TOLERANCE) then
    write(*,*) "Error in test calcdist - zero distance"
    write(*,*) "Expected 0 but got ", xdist
    error stop
  endif

  ! Test 2: Distance along equator (1 degree longitude)
  rlonb = 0.0
  rlatb = 0.0
  rlonc = 1.0
  rlatc = 0.0
  
  call calcdist(rlonb, rlatb, rlonc, rlatc, xdist, degrees)
  
  ! At equator, 1 degree longitude ≈ 111.32 km ≈ 60.1 nm
  if (abs(xdist - 60.1) > 5.0) then  ! Allow 5 nm tolerance
    write(*,*) "Error in test calcdist - equator distance"
    write(*,*) "Expected approximately 60.1 nm but got ", xdist
    error stop
  endif

  ! Test 3: Distance along meridian (1 degree latitude)
  rlonb = 0.0
  rlatb = 0.0
  rlonc = 0.0
  rlatc = 1.0
  
  call calcdist(rlonb, rlatb, rlonc, rlatc, xdist, degrees)
  
  ! 1 degree latitude ≈ 60 nm
  if (abs(xdist - 60.0) > 5.0) then  ! Allow 5 nm tolerance
    write(*,*) "Error in test calcdist - meridian distance"
    write(*,*) "Expected approximately 60 nm but got ", xdist
    error stop
  endif

  ! Test 4: Known distance (New York to Los Angeles approximately)
  ! NYC: (40.7128, -74.0060), LA: (34.0522, -118.2437)
  rlonb = -74.0060
  rlatb = 40.7128
  rlonc = -118.2437
  rlatc = 34.0522
  
  call calcdist(rlonb, rlatb, rlonc, rlatc, xdist, degrees)
  
  ! Expected distance approximately 2124 nm
  if (abs(xdist - 2124.0) > 100.0) then  ! Allow 100 nm tolerance
    write(*,*) "Error in test calcdist - NYC to LA distance"
    write(*,*) "Expected approximately 2124 nm but got ", xdist
    error stop
  endif

  write(*,*) "All calcdist tests passed!"

end program test_subroutine_calcdist
