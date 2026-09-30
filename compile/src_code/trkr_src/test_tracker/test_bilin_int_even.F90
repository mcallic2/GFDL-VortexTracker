!************************************************
!* This test program tests the subroutine bilin_int_even, which
!* doubles the resolution of an evenly-spaced grid via bilinear
!* interpolation.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_bilin_int_even

  use access_subroutines

  implicit none

  integer, parameter :: test_imold = 3, test_jmold = 3
  real :: test_xold(test_imold,test_jmold)
  real :: test_xnew(2*test_imold-1, 2*test_jmold-1)
  integer :: i, j, test_ibiret
  real, parameter :: tol = 0.001

  ! a perfectly linear field: bilinear interpolation of a linear field
  ! is exact everywhere, which makes this easy to verify independently
  do i = 1, test_imold
    do j = 1, test_jmold
      test_xold(i,j) = real(i) + real(j)
    enddo
  enddo

  call bilin_int_even(test_imold, test_jmold, test_xold &
                      ,2*test_imold-1, 2*test_jmold-1, test_xnew &
                      ,test_ibiret)

  !----------------------------------------------
  ! test 1: original gridpoints should be preserved exactly at the
  ! odd-numbered indices of the new grid
  if (abs(test_xnew(1,1) - test_xold(1,1)) > tol .or. &
      abs(test_xnew(5,5) - test_xold(3,3)) > tol .or. &
      abs(test_xnew(3,3) - test_xold(2,2)) > tol) then
    write(*,*) "Error in test bilin_int_even: original points not preserved"
    write(*,*) "xnew(1,1)=", test_xnew(1,1), " expected ", test_xold(1,1)
    write(*,*) "xnew(5,5)=", test_xnew(5,5), " expected ", test_xold(3,3)
    write(*,*) "xnew(3,3)=", test_xnew(3,3), " expected ", test_xold(2,2)
    error stop
  endif

  !----------------------------------------------
  ! test 2: for a linear field, every interpolated point should equal
  ! what the same linear formula would give at that fractional (i,j)
  ! position -- e.g. xnew(2,2) sits at i=1.5,j=1.5 in the old grid's
  ! coordinates, so its value should be 1.5+1.5=3.0
  if (abs(test_xnew(2,2) - 3.0) > tol) then
    write(*,*) "Error in test bilin_int_even: interior point wrong"
    write(*,*) "xnew(2,2)=", test_xnew(2,2), " expected 3.0"
    error stop
  endif

  !----------------------------------------------
  ! test 3: an edge point uses a different (3-point, 1/3-weighted)
  ! formula than interior points, so it is checked separately against
  ! a hand-derived value: xnew(1,2) = (1/3)*(xnew(1,1)+xnew(1,3)+xnew(2,2))
  ! = (1/3)*(2.0 + 3.0 + 3.0) = 2.6667 (not the same as a plain linear
  ! interpolation, which is the point of testing it explicitly)
  if (abs(test_xnew(1,2) - 2.6667) > 0.001) then
    write(*,*) "Error in test bilin_int_even: edge point wrong"
    write(*,*) "xnew(1,2)=", test_xnew(1,2), " expected ~2.6667"
    error stop
  endif

end program test_subroutine_bilin_int_even
