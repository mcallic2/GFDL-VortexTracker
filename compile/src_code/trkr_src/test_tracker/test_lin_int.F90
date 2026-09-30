!************************************************
!* This test program tests the subroutines lin_int and lin_int_lon,
!* which linearly interpolate evenly-spaced data onto a twice-as-
!* dense grid. lin_int_lon is the longitude-aware version that
!* handles interpolating across the Greenwich meridian.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_lin_int

  use access_subroutines

  implicit none

  integer, parameter :: test_n = 3
  real               :: test_xold(test_n), test_xnew(2*test_n-1)
  real               :: expected_xnew(2*test_n-1)
  real               :: test_lold(test_n), test_lnew(2*test_n-1)
  real               :: expected_lnew(2*test_n-1)

  !----------------------------------------------
  ! test subroutine lin_int: evenly-spaced values interpolate to the
  ! midpoints between them
  test_xold     = (/2.0, 4.0, 6.0/)
  expected_xnew = (/2.0, 3.0, 4.0, 5.0, 6.0/)

  call lin_int(test_n, 2*test_n-1, test_xold, test_xnew, 0)

  if (any(test_xnew .ne. expected_xnew)) then
    write(*,*) "Error in test lin_int"
    write(*,*) "Expected ", expected_xnew, " but got ", test_xnew
    error stop
  endif

  !----------------------------------------------
  ! test subroutine lin_int_lon: interpolating between 355 and 5
  ! degrees should cross the Greenwich meridian at 360 (i.e. 0), not
  ! average down to 180 the way a plain linear interpolation would
  test_lold     = (/350.0, 355.0, 5.0/)
  expected_lnew = (/350.0, 352.5, 355.0, 360.0, 5.0/)

  call lin_int_lon(test_n, 2*test_n-1, test_lold, test_lnew, 0)

  if (any(test_lnew .ne. expected_lnew)) then
    write(*,*) "Error in test lin_int_lon"
    write(*,*) "Expected ", expected_lnew, " but got ", test_lnew
    error stop
  endif

end program test_subroutine_lin_int
