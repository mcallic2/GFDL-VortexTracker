!************************************************
!* This test program tests the subroutine check_bounds, which checks
!* whether a storm's guessed position is within the tracker's data
!* grid: strictly for regional grids, and separately, whether a storm
!* is too close to the pole for global midlat/tcgen tracking.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_check_bounds

  use access_subroutines
  use trkrparms
  use grid_bounds
  use verbose_output

  implicit none

  type(trackstuff) :: test_trkrinfo
  integer :: test_icbret

  verb = 0

  !----------------------------------------------
  ! test 1: regional grid, guess position inside the grid bounds
  test_trkrinfo%gridtype = 'regional'
  glonmin = 280.0; glonmax = 320.0; glatmin = 0.0; glatmax = 40.0

  call check_bounds(300.0, 20.0, 1, 1, test_trkrinfo, test_icbret)

  if (test_icbret .ne. 0) then
    write(*,*) "Error in test check_bounds (regional, inside)"
    write(*,*) "Expected icbret=0 but got ", test_icbret
    error stop
  endif

  !----------------------------------------------
  ! test 2: regional grid, guess position outside the grid bounds
  call check_bounds(340.0, 20.0, 1, 1, test_trkrinfo, test_icbret)

  if (test_icbret .ne. 95) then
    write(*,*) "Error in test check_bounds (regional, outside)"
    write(*,*) "Expected icbret=95 but got ", test_icbret
    error stop
  endif

  !----------------------------------------------
  ! test 3: global grid, midlat run, storm too close to the pole
  test_trkrinfo%gridtype = 'global'
  test_trkrinfo%type = 'midlat'

  call check_bounds(300.0, 87.0, 1, 1, test_trkrinfo, test_icbret)

  if (test_icbret .ne. 95) then
    write(*,*) "Error in test check_bounds (global midlat, near pole)"
    write(*,*) "Expected icbret=95 but got ", test_icbret
    error stop
  endif

  !----------------------------------------------
  ! test 4: global grid, midlat run, storm well away from the pole
  call check_bounds(300.0, 45.0, 1, 1, test_trkrinfo, test_icbret)

  if (test_icbret .ne. 0) then
    write(*,*) "Error in test check_bounds (global midlat, mid-latitude)"
    write(*,*) "Expected icbret=0 but got ", test_icbret
    error stop
  endif

end program test_subroutine_check_bounds
