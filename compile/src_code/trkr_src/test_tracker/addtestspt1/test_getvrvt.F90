!************************************************
!* Test program for getvrvt subroutine
!* Tests calculation of radial and tangential wind components
!*
!* Created by: GitHub Copilot Testing Suite
!************************************************
program test_subroutine_getvrvt

  use access_subroutines

  implicit none

  real, parameter :: TOLERANCE = 1.0e-4
  real :: centlon, centlat, xlon, xlat
  real :: u, v, vr, vt, xrad
  real :: expected_vr, expected_vt
  
  write(*,*) "Testing getvrvt subroutine..."

  ! Test 1: Pure eastward wind (u=10, v=0) at point east of center
  centlon = 0.0
  centlat = 0.0
  xlon = 1.0  ! 1 degree east of center
  xlat = 0.0  ! same latitude
  u = 10.0
  v = 0.0
  
  call getvrvt(centlon, centlat, xlon, xlat, u, v, vr, vt, xrad)
  
  ! For eastward wind at point east of center:
  ! - radial component should be positive (away from center)
  ! - tangential component should be zero
  expected_vr = 10.0
  expected_vt = 0.0
  
  if (abs(vr - expected_vr) > TOLERANCE) then
    write(*,*) "Error in test getvrvt - radial component"
    write(*,*) "Expected ", expected_vr, " but got ", vr
    error stop
  endif
  
  if (abs(vt - expected_vt) > TOLERANCE) then
    write(*,*) "Error in test getvrvt - tangential component"
    write(*,*) "Expected ", expected_vt, " but got ", vt
    error stop
  endif

  ! Test 2: Pure northward wind (u=0, v=10) at point north of center
  centlon = 0.0
  centlat = 0.0
  xlon = 0.0  ! same longitude
  xlat = 1.0  ! 1 degree north of center
  u = 0.0
  v = 10.0
  
  call getvrvt(centlon, centlat, xlon, xlat, u, v, vr, vt, xrad)
  
  ! For northward wind at point north of center:
  ! - radial component should be positive (away from center)
  ! - tangential component should be zero
  expected_vr = 10.0
  expected_vt = 0.0
  
  if (abs(vr - expected_vr) > TOLERANCE) then
    write(*,*) "Error in test getvrvt - northward radial component"
    write(*,*) "Expected ", expected_vr, " but got ", vr
    error stop
  endif
  
  if (abs(vt - expected_vt) > TOLERANCE) then
    write(*,*) "Error in test getvrvt - northward tangential component"
    write(*,*) "Expected ", expected_vt, " but got ", vt
    error stop
  endif

  ! Test 3: Pure tangential wind (cyclonic circulation)
  centlon = 0.0
  centlat = 0.0
  xlon = 1.0  ! 1 degree east of center
  xlat = 0.0  ! same latitude
  u = 0.0     ! no eastward component
  v = -10.0   ! southward wind creates cyclonic circulation
  
  call getvrvt(centlon, centlat, xlon, xlat, u, v, vr, vt, xrad)
  
  ! For southward wind at point east of center:
  ! - radial component should be zero
  ! - tangential component should be negative (cyclonic)
  expected_vr = 0.0
  expected_vt = -10.0
  
  if (abs(vr - expected_vr) > TOLERANCE) then
    write(*,*) "Error in test getvrvt - tangential radial component"
    write(*,*) "Expected ", expected_vr, " but got ", vr
    error stop
  endif
  
  if (abs(vt - expected_vt) > TOLERANCE) then
    write(*,*) "Error in test getvrvt - tangential component value"
    write(*,*) "Expected ", expected_vt, " but got ", vt
    error stop
  endif

  write(*,*) "All getvrvt tests passed!"

end program test_subroutine_getvrvt
