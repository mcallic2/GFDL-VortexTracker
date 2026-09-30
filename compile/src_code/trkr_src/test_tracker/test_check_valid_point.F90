!************************************************
!* This test program tests the subroutine check_valid_point, which
!* checks whether a given lat/lon position maps to a nearby gridpoint
!* that has valid (non-bitmapped-out) data.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_check_valid_point

  use access_subroutines
  use trkrparms

  implicit none

  integer, parameter :: test_imax = 10, test_jmax = 10
  real :: test_fxy(test_imax,test_jmax), test_dx, test_dy
  logical(1) :: test_valid_pt(test_imax,test_jmax)
  type(trackstuff) :: test_trkrinfo
  integer :: test_icvpret

  test_dx = 1.0
  test_dy = 1.0
  test_fxy = 1000.0
  test_valid_pt = .true.
  test_trkrinfo%gridtype = 'regional'

  !----------------------------------------------
  ! test 1: a point in the middle of an entirely valid grid should be
  ! reported as valid
  call check_valid_point(test_imax, test_jmax, test_dx, test_dy &
                         ,test_fxy, 'min', test_valid_pt, 5.0, 5.0 &
                         ,9.0, 0.0, 9.0, 0.0, test_trkrinfo &
                         ,test_icvpret)

  if (test_icvpret .ne. 0) then
    write(*,*) "Error in test check_valid_point (all valid)"
    write(*,*) "Expected icvpret=0 but got ", test_icvpret
    error stop
  endif

  !----------------------------------------------
  ! test 2: the same point, once the gridpoints around it have been
  ! bitmapped out, should be reported as invalid
  test_valid_pt(4:8, 3:7) = .false.

  call check_valid_point(test_imax, test_jmax, test_dx, test_dy &
                         ,test_fxy, 'min', test_valid_pt, 5.0, 5.0 &
                         ,9.0, 0.0, 9.0, 0.0, test_trkrinfo &
                         ,test_icvpret)

  if (test_icvpret .ne. 99) then
    write(*,*) "Error in test check_valid_point (invalidated region)"
    write(*,*) "Expected icvpret=99 but got ", test_icvpret
    error stop
  endif

end program test_subroutine_check_valid_point
