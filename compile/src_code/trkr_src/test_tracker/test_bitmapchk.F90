!************************************************
!* This test program tests the subroutine bitmapchk, which flags
!* bitmapped-out (missing) grid values as -999.0 and returns the
!* min/max over the remaining valid values.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_bitmapchk

  use access_subroutines

  implicit none

  integer, parameter :: test_n = 4
  logical(1)          :: test_ld(test_n)
  real                :: test_d(test_n), expected_d(test_n)
  real                :: test_dmin, test_dmax

  !----------------------------------------------
  ! one bitmapped-out point (index 2); it should be set to -999.0 and
  ! excluded from the min/max
  test_ld    = (/.true., .false., .true., .true./)
  test_d     = (/1.0, 999.0, 3.0, -2.0/)
  expected_d = (/1.0, -999.0, 3.0, -2.0/)

  call bitmapchk(test_n, test_ld, test_d, test_dmin, test_dmax)

  if (any(test_d .ne. expected_d)) then
    write(*,*) "Error in test bitmapchk: values"
    write(*,*) "Expected ", expected_d, " but got ", test_d
    error stop
  endif

  if (test_dmin .ne. -2.0 .or. test_dmax .ne. 3.0) then
    write(*,*) "Error in test bitmapchk: min/max"
    write(*,*) "Expected dmin=-2.0 dmax=3.0 but got ", test_dmin, test_dmax
    error stop
  endif

end program test_subroutine_bitmapchk
