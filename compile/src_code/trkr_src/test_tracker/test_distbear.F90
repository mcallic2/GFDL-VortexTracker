!************************************************
!* This test program tests the subroutine distbear, which computes
!* a target lat/lon given an origin, a distance, and a bearing.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_distbear

  use access_subroutines
  use trig_vals

  implicit none

  real :: test_xlatt, test_xlont
  real, parameter :: tol = 0.1

  ! trig_vals declares pi and dtr but does not initialize them (they
  ! are set at runtime in gettrk_main.f); any test that exercises a
  ! subroutine using dtr/pi must set them here first.
  pi  = 4. * atan(1.)
  dtr = pi / 180.0

  !----------------------------------------------
  ! test 1: a distance of zero should return the same point
  call distbear(10.0, 20.0, 0.0, 45.0, test_xlatt, test_xlont, 'none')

  if (abs(test_xlatt - 10.0) > tol .or. abs(test_xlont - 20.0) > tol) then
    write(*,*) "Error in test distbear (dist=0)"
    write(*,*) "Expected xlatt=10.0 xlont=20.0 but got ", test_xlatt, test_xlont
    error stop
  endif

  !----------------------------------------------
  ! test 2: starting on the equator, heading due east (bearing=90) for
  ! a quarter of the earth's circumference should land at 90E, lat=0
  call distbear(0.0, 0.0, 10007.54, 90.0, test_xlatt, test_xlont, 'none')

  if (abs(test_xlatt - 0.0) > tol .or. abs(test_xlont - 90.0) > tol) then
    write(*,*) "Error in test distbear (east quarter-circumference)"
    write(*,*) "Expected xlatt=0.0 xlont=90.0 but got ", test_xlatt, test_xlont
    error stop
  endif

  !----------------------------------------------
  ! test 3: starting on the equator, heading due north (bearing=0) for
  ! a quarter of the earth's circumference should land at the north pole
  call distbear(0.0, 0.0, 10007.54, 0.0, test_xlatt, test_xlont, 'none')

  if (abs(test_xlatt - 90.0) > tol) then
    write(*,*) "Error in test distbear (north quarter-circumference)"
    write(*,*) "Expected xlatt=90.0 but got ", test_xlatt
    error stop
  endif

end program test_subroutine_distbear
