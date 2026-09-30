!************************************************
!* This test program tests the subroutine calcdist, which computes
!* the great-circle distance and angular separation (in degrees)
!* between two lat/lon points.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_calcdist

  use access_subroutines
  use trig_vals

  implicit none

  real :: test_xdist, test_degrees
  real, parameter :: tol = 0.05

  ! trig_vals declares pi and dtr but does not initialize them (they
  ! are set at runtime in gettrk_main.f); any test that exercises a
  ! subroutine using dtr must set it here first. ecircum, used inside
  ! calcdist, does have a default value in the module and needs no
  ! extra setup.
  pi  = 4. * atan(1.)
  dtr = pi / 180.0

  !----------------------------------------------
  ! test 1: distance between a point and itself should be zero
  call calcdist(10.0, 20.0, 10.0, 20.0, test_xdist, test_degrees)

  if (abs(test_xdist) > tol .or. abs(test_degrees) > tol) then
    write(*,*) "Error in test calcdist (same point)"
    write(*,*) "Expected xdist=0.0 degrees=0.0 but got ", test_xdist, test_degrees
    error stop
  endif

  !----------------------------------------------
  ! test 2: two points on the equator 90 degrees of longitude apart
  ! are 90 degrees / a quarter of the earth's circumference apart
  call calcdist(0.0, 0.0, 90.0, 0.0, test_xdist, test_degrees)

  if (abs(test_degrees - 90.0) > tol .or. abs(test_xdist - 10007.55) > 1.0) then
    write(*,*) "Error in test calcdist (equator quarter-circumference)"
    write(*,*) "Expected degrees=90.0 xdist=~10007.5 but got "
     write(*,*) test_xdist, test_degrees
    error stop
  endif

  !----------------------------------------------
  ! test 3: a point on the equator to the north pole is also 90
  ! degrees / a quarter of the earth's circumference apart
  call calcdist(0.0, 0.0, 0.0, 90.0, test_xdist, test_degrees)

  if (abs(test_degrees - 90.0) > tol .or. abs(test_xdist - 10007.55) > 1.0) then
    write(*,*) "Error in test calcdist (equator to pole)"
    write(*,*) "Expected degrees=90.0 xdist=~10007.5 but got "
    write(*,*) test_xdist, test_degrees
    error stop
  endif

end program test_subroutine_calcdist
