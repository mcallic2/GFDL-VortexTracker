!************************************************
!* Test program for distbear subroutine
!* Tests distance and bearing calculations between geographic points
!*
!* Created by: GitHub Copilot Testing Suite
!************************************************
program test_subroutine_distbear

  use access_subroutines

  implicit none

  ! Test parameters
  real, parameter :: TOLERANCE = 1.0e-5
  real :: rlatin, rlonin, dist, bear, xlatt, xlont
  real :: expected_dist, expected_bear
  real :: test_degrees
  integer :: degrees

  write(*,*) "Testing distbear subroutine..."

  ! Test 1: Distance between New York and Los Angeles (known values)
  ! NYC: (40.7128, -74.0060), LA: (34.0522, -118.2437)
  rlatin = 40.7128
  rlonin = -74.0060
  xlatt = 34.0522
  xlont = -118.2437
  
  ! Expected distance in nautical miles (approximately 2124 nm)
  expected_dist = 2124.0
  
  call distbear(rlatin, rlonin, dist, bear, xlatt, xlont, degrees)
  
  ! Check if calculated distance is within reasonable tolerance
  if (abs(dist - expected_dist) > 100.0) then  ! Allow 100 nm tolerance
    write(*,*) "Error in test distbear - distance calculation"
    write(*,*) "Expected approximately ", expected_dist, " but got ", dist
    error stop
  endif

  ! Test 2: Zero distance (same point)
  rlatin = 45.0
  rlonin = -90.0
  xlatt = 45.0
  xlont = -90.0
  
  call distbear(rlatin, rlonin, dist, bear, xlatt, xlont, degrees)
  
  if (abs(dist) > TOLERANCE) then
    write(*,*) "Error in test distbear - zero distance"
    write(*,*) "Expected 0 but got ", dist
    error stop
  endif

  ! Test 3: Due north bearing (0 degrees)
  rlatin = 30.0
  rlonin = 0.0
  xlatt = 40.0
  xlont = 0.0
  
  call distbear(rlatin, rlonin, dist, bear, xlatt, xlont, degrees)
  
  ! Bearing should be close to 0 (due north)
  if (abs(bear) > 5.0) then  ! Allow 5 degree tolerance
    write(*,*) "Error in test distbear - bearing calculation"
    write(*,*) "Expected approximately 0 degrees but got ", bear
    error stop
  endif

  write(*,*) "All distbear tests passed!"

end program test_subroutine_distbear
