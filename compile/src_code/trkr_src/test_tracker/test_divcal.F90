!************************************************
!* This test program tests the subroutine divcal, which computes
!* horizontal divergence from the module-level u/v wind arrays on a
!* lat/lon grid, in the same style as rvcal computes relative
!* vorticity (see test_rvcal.F90) -- output is scaled by 1e4.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_divcal

  use access_subroutines
  use trig_vals
  use grid_bounds
  use tracked_parms
  use level_parms
  use verbose_output

  implicit none

  integer, parameter :: test_imax = 5, test_jmax = 5
  real :: test_dlon, test_dlat, test_divx4(test_imax,test_jmax)
  logical(1) :: test_vp(test_imax,test_jmax)
  integer :: test_idvcret, i
  real, parameter :: tol = 1.0e-9
  real :: expected_divx4_j2

  ! trig_vals declares pi and dtr but does not initialize them (they
  ! are set at runtime in gettrk_main.f); divcal needs dtr.
  pi  = 4. * atan(1.)
  dtr = pi / 180.0
  verb = 0

  test_dlon = 1.0
  test_dlat = 1.0
  glatmax = 2.0   ! grid rows sit at 2N, 1N, 0 (equator), 1S, 2S

  allocate(u(test_imax, test_jmax, 5), v(test_imax, test_jmax, 5))
  u = 0.0     ! uniform v-only wind, no shear anywhere
  v = 10.0
  test_vp = .true.

  call divcal(test_imax, test_jmax, test_dlon, test_dlat, test_divx4 &
             ,test_vp, 1, test_idvcret)

  !----------------------------------------------
  ! test 1: with a spatially uniform wind field there is no shear, so
  ! the only surviving term is the spherical-geometry curvature term,
  ! -tanfac(j)*v -- which is exactly zero at the equator (row 3 of
  ! this 5-row grid, since glatmax=2 and dlat=1)
  do i = 2, test_imax - 1
    if (abs(test_divx4(i,3)) > tol) then
      write(*,*) "Error in test divcal (uniform wind at equator)"
      write(*,*) "Expected divx4=0 at i=", i, " but got ", test_divx4(i,3)
      error stop
    endif
  enddo

  !----------------------------------------------
  ! test 2: away from the equator (row 2, at 1N) the curvature term is
  ! non-zero and equal to -tan(dtr*lat)/erad * v * 1e4
  expected_divx4_j2 = -(tan(dtr*1.0)/erad) * 10.0 * 1.0e4

  do i = 2, test_imax - 1
    if (abs(test_divx4(i,2) - expected_divx4_j2) > tol) then
      write(*,*) "Error in test divcal (uniform wind off equator)"
      write(*,*) "Expected divx4=", expected_divx4_j2, " but got " &
                 ,test_divx4(i,2), " at i=", i
      error stop
    endif
  enddo

end program test_subroutine_divcal
