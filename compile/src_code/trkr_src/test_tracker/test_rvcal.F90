!************************************************
!* This test program tests the subroutine rvcal, which computes
!* relative vorticity (zeta) from the module-level u/v wind arrays
!* on a lat/lon grid and writes the result into the module-level
!* zeta array (it does not return the field through an argument).
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_rvcal

  use access_subroutines
  use trig_vals
  use grid_bounds
  use tracked_parms
  use level_parms
  use verbose_output

  implicit none

  integer, parameter :: test_imax = 5, test_jmax = 5
  real :: test_dlon, test_dlat
  logical(1) :: test_vp(test_imax, test_jmax)
  character*7 :: test_rvctype
  integer :: i
  real, parameter :: tol = 1.0e-9
  real :: expected_zeta_j2

  ! trig_vals declares pi and dtr but does not initialize them (they
  ! are set at runtime in gettrk_main.f); rvcal needs dtr.
  pi  = 4. * atan(1.)
  dtr = pi / 180.0
  verb = 0

  test_dlon = 1.0
  test_dlat = 1.0
  glatmax = 2.0   ! grid rows sit at 2N, 1N, 0 (equator), 1S, 2S

  allocate(u(test_imax, test_jmax, 5), v(test_imax, test_jmax, 5))
  allocate(zeta(test_imax, test_jmax, 3))
  u = 10.0   ! uniform 850 mb u-wind, no shear anywhere
  v = 0.0    ! uniform v-wind
  test_vp = .true.
  test_rvctype = 'tracker'

  call rvcal(test_imax, test_jmax, test_dlon, test_dlat, 1, test_rvctype &
            ,test_vp)

  !----------------------------------------------
  ! test 1: with a spatially uniform wind field there is no shear, so
  ! the only surviving term is the spherical-geometry curvature term,
  ! tanfac(j)*u -- which is exactly zero at the equator (row 3 of this
  ! 5-row grid, since glatmax=2 and dlat=1)
  do i = 2, test_imax - 1
    if (abs(zeta(i,3,1)) > tol) then
      write(*,*) "Error in test rvcal (uniform wind at equator)"
      write(*,*) "Expected zeta=0 at i=", i, " but got ", zeta(i,3,1)
      error stop
    endif
  enddo

  !----------------------------------------------
  ! test 2: away from the equator (row 2, at 1N) the curvature term is
  ! non-zero and equal to tan(dtr*lat)/erad * u
  expected_zeta_j2 = (tan(dtr*1.0)/erad) * 10.0

  do i = 2, test_imax - 1
    if (abs(zeta(i,2,1) - expected_zeta_j2) > tol) then
      write(*,*) "Error in test rvcal (uniform wind off equator)"
      write(*,*) "Expected zeta=", expected_zeta_j2, " but got " &
                 ,zeta(i,2,1), " at i=", i
      error stop
    endif
  enddo

end program test_subroutine_rvcal
