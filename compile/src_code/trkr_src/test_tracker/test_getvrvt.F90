!************************************************
!* This test program tests the subroutine getvrvt, which decomposes
!* a u/v wind observation at a point into radial and tangential
!* components relative to a storm center.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_getvrvt

  use access_subroutines
  use trig_vals
  use verbose_output

  implicit none

  real :: test_vr, test_vt
  integer :: test_igvtret
  real, parameter :: tol = 0.01

  ! trig_vals declares pi and dtr but does not initialize them (they
  ! are set at runtime in gettrk_main.f); getvrvt calls calcdist,
  ! which needs dtr, so it must be set here first.
  pi  = 4. * atan(1.)
  dtr = pi / 180.0
  verb = 0

  ! note: igvtret is declared as an output in getvrvt's argument list
  ! but is never actually assigned inside the subroutine, so it is
  ! not checked below.

  !----------------------------------------------
  ! test 1: a point due east of the center with a purely eastward
  ! wind is moving directly away from the center -- pure radial,
  ! zero tangential
  call getvrvt(0.0, 0.0, 1.0, 0.0, 10.0, 0.0, test_vr, test_vt, 1 &
              ,test_igvtret)

  if (abs(test_vr - 10.0) > tol .or. abs(test_vt) > tol) then
    write(*,*) "Error in test getvrvt (east point, eastward wind)"
    write(*,*) "Expected vr=10.0 vt=0.0 but got ", test_vr, test_vt
    error stop
  endif

  !----------------------------------------------
  ! test 2: a point due north of the center with a purely northward
  ! wind is also moving directly away from the center -- pure radial
  call getvrvt(0.0, 0.0, 0.0, 1.0, 0.0, 10.0, test_vr, test_vt, 1 &
              ,test_igvtret)

  if (abs(test_vr - 10.0) > tol .or. abs(test_vt) > tol) then
    write(*,*) "Error in test getvrvt (north point, northward wind)"
    write(*,*) "Expected vr=10.0 vt=0.0 but got ", test_vr, test_vt
    error stop
  endif

  !----------------------------------------------
  ! test 3: a point due east of the center with a southward wind is
  ! moving purely tangentially (cyclonic sense) -- zero radial
  call getvrvt(0.0, 0.0, 1.0, 0.0, 0.0, -10.0, test_vr, test_vt, 1 &
              ,test_igvtret)

  if (abs(test_vr) > tol .or. abs(test_vt - (-10.0)) > tol) then
    write(*,*) "Error in test getvrvt (east point, southward wind)"
    write(*,*) "Expected vr=0.0 vt=-10.0 but got ", test_vr, test_vt
    error stop
  endif

end program test_subroutine_getvrvt
