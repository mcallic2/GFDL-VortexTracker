!************************************************
!* This test program tests the subroutines conv1d2d_logic and
!* conv1d2d_real, which reshape a 1-d row-major array into a 2-d
!* (imax,jmax) array, optionally flipping it north-south for grids
!* whose data runs south-to-north.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_conv1d2d

  use access_subroutines

  implicit none

  integer, parameter :: test_imax = 3, test_jmax = 2
  logical(1) :: test_lb1d(test_imax*test_jmax)
  logical(1) :: test_lb2d(test_imax, test_jmax)
  logical(1) :: expected_lb2d(test_imax, test_jmax)
  real       :: test_r1d(test_imax*test_jmax)
  real       :: test_r2d(test_imax, test_jmax)
  real       :: expected_r2d(test_imax, test_jmax)
  logical(1) :: flipflag

  !----------------------------------------------
  ! conv1d2d_logic, no flip: row 1 of input becomes column 1 of output
  test_lb1d = (/.true., .false., .true., .false., .true., .true./)
  expected_lb2d(:,1) = (/.true., .false., .true./)
  expected_lb2d(:,2) = (/.false., .true., .true./)
  flipflag = .false.

  call conv1d2d_logic(test_imax, test_jmax, test_lb1d, test_lb2d, flipflag)

  if (any(test_lb2d .neqv. expected_lb2d)) then
    write(*,*) "Error in test conv1d2d_logic (no flip)"
    error stop
  endif

  !----------------------------------------------
  ! conv1d2d_logic, with flip: rows come out in reverse (south-to-north
  ! input becomes north-to-south output)
  expected_lb2d(:,1) = (/.false., .true., .true./)
  expected_lb2d(:,2) = (/.true., .false., .true./)
  flipflag = .true.

  call conv1d2d_logic(test_imax, test_jmax, test_lb1d, test_lb2d, flipflag)

  if (any(test_lb2d .neqv. expected_lb2d)) then
    write(*,*) "Error in test conv1d2d_logic (flip)"
    error stop
  endif

  !----------------------------------------------
  ! conv1d2d_real, no flip
  test_r1d = (/1.0, 2.0, 3.0, 4.0, 5.0, 6.0/)
  expected_r2d(:,1) = (/1.0, 2.0, 3.0/)
  expected_r2d(:,2) = (/4.0, 5.0, 6.0/)
  flipflag = .false.

  call conv1d2d_real(test_imax, test_jmax, test_r1d, test_r2d, flipflag)

  if (any(test_r2d .ne. expected_r2d)) then
    write(*,*) "Error in test conv1d2d_real (no flip)"
    write(*,*) "Expected ", expected_r2d, " but got ", test_r2d
    error stop
  endif

  !----------------------------------------------
  ! conv1d2d_real, with flip
  expected_r2d(:,1) = (/4.0, 5.0, 6.0/)
  expected_r2d(:,2) = (/1.0, 2.0, 3.0/)
  flipflag = .true.

  call conv1d2d_real(test_imax, test_jmax, test_r1d, test_r2d, flipflag)

  if (any(test_r2d .ne. expected_r2d)) then
    write(*,*) "Error in test conv1d2d_real (flip)"
    write(*,*) "Expected ", expected_r2d, " but got ", test_r2d
    error stop
  endif

end program test_subroutine_conv1d2d
