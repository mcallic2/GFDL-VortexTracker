!************************************************
!* This test program tests the subroutine bilin_int_uneven, which
!* bilinearly interpolates a gridded field (here, sea-level pressure,
!* cparm='p') to an arbitrary lat/lon location.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_bilin_int_uneven

  use access_subroutines
  use grid_bounds
  use tracked_parms
  use trkrparms
  use verbose_output

  implicit none

  integer, parameter :: test_imax = 4, test_jmax = 3
  logical(1) :: test_valid_pt(test_imax, test_jmax)
  type(trackstuff) :: test_trkrinfo
  real :: test_xintrp_val, test_dx, test_dy
  integer :: test_bimct, test_ibiret, i, j
  real, parameter :: tol = 0.001

  verb = 0

  ! set up a small, evenly-spaced grid: lon 0..3E, lat 2N..0 (grids in
  ! this codebase run north to south, i.e. glat(1) is the northmost row)
  allocate(glon(test_imax), glat(test_jmax))
  allocate(slp(test_imax, test_jmax))
  glon = (/0.0, 1.0, 2.0, 3.0/)
  glat = (/2.0, 1.0, 0.0/)
  glatmax = 2.0
  glatmin = 0.0
  glonmin = 0.0
  glonmax = 3.0
  test_dx = 1.0
  test_dy = 1.0

  do i = 1, test_imax
    do j = 1, test_jmax
      slp(i,j) = 100.0*i + 10.0*j
    enddo
  enddo

  test_valid_pt = .true.
  test_trkrinfo%gridtype = 'regional'
  test_bimct = 0

  !----------------------------------------------
  ! test 1: interpolating exactly at a grid point should return that
  ! grid point's value
  call bilin_int_uneven(1.0, 1.0, test_dx, test_dy, test_imax, test_jmax &
                        ,test_trkrinfo, 1020, 'p', test_xintrp_val &
                        ,test_valid_pt, test_bimct, 1, 1, 'tracker' &
                        ,test_ibiret)

  if (test_ibiret .ne. 0 .or. abs(test_xintrp_val - slp(2,2)) > tol) then
    write(*,*) "Error in test bilin_int_uneven (at grid point)"
    write(*,*) "Expected ", slp(2,2), " but got ", test_xintrp_val &
               ," ibiret=", test_ibiret
    error stop
  endif

  !----------------------------------------------
  ! test 2: interpolating at the exact center of a grid cell should
  ! return the average of the four surrounding corners
  call bilin_int_uneven(1.5, 1.5, test_dx, test_dy, test_imax, test_jmax &
                        ,test_trkrinfo, 1020, 'p', test_xintrp_val &
                        ,test_valid_pt, test_bimct, 1, 1, 'tracker' &
                        ,test_ibiret)

  if (test_ibiret .ne. 0 .or. &
      abs(test_xintrp_val - (slp(2,1)+slp(3,1)+slp(3,2)+slp(2,2))/4.0) &
      > tol) then
    write(*,*) "Error in test bilin_int_uneven (cell center)"
    write(*,*) "Expected ", (slp(2,1)+slp(3,1)+slp(3,2)+slp(2,2))/4.0 &
               ," but got ", test_xintrp_val, " ibiret=", test_ibiret
    error stop
  endif

end program test_subroutine_bilin_int_uneven
