!************************************************
!* This test program tests the subroutine stdevcalc, which calculates
!* the standard deviation of the values in an array around a given
!* mean, skipping any elements flagged as not valid. As a special
!* case, if the standard deviation comes out to exactly 0 (which can
!* happen with just 2 points, since their mean sits exactly between
!* them), it is forced to 1.0 instead -- the calling routine would
!* otherwise treat a standard deviation of 0 as a fatal error.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_stdevcalc

  use access_subroutines

  implicit none

  integer                  :: test_kmax
  real, dimension(4)       :: test_xdat
  real, dimension(2)       :: test_xdat0
  logical(1), dimension(4) :: test_valid
  real                     :: test_xavg
  real                     :: test_stdx, expected_stdx
  integer                  :: isret

  ! test stdx > 0.0
  test_kmax     = 4
  test_xdat     = (/2.0, 4.0, 6.0, 8.0/)
  test_valid    = .true.
  test_xavg     = 5.0  ! avg of test_xdat
  expected_stdx = 2.23606797749979

  call stdevcalc(test_xdat, test_kmax, test_valid, test_xavg, test_stdx, isret)

  if (test_stdx .ne. expected_stdx) then
    write(*,*) "Error in test stdevcalc (stdx > 0)"
    write(*,*) "Expected ", expected_stdx, " but got ", test_stdx
    error stop
  endif

  ! test stdx = 0.0
  test_kmax     = 2
  test_xdat0    = (/2.0, 2.0/)
  test_valid    = .true.
  test_xavg     = 2.0  ! avg of test_xdat
  expected_stdx = 1.0

  call stdevcalc(test_xdat0, test_kmax, test_valid, test_xavg, test_stdx, isret)

  if (test_stdx .ne. expected_stdx) then
    write(*,*) "Error in test stdevcalc (stdx = 0)"
    write(*,*) "Expected ", expected_stdx, " but got ", test_stdx
    error stop
  endif

end program test_subroutine_stdevcalc