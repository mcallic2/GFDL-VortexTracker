!************************************************
!* This test program tests the subroutine qsort, which returns the
!* permutation of indices that would sort a double-precision array
!* into increasing order (it does not reorder the array itself).
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_qsort

  use access_subroutines

  implicit none

  integer, parameter :: dp = selected_real_kind(12, 60)
  integer, parameter :: test_n = 5
  real (dp)          :: test_x(test_n)
  integer             :: test_ind(test_n), expected_ind(test_n)
  integer             :: i

  !----------------------------------------------
  ! test 1: a simple unsorted array
  test_x       = (/5.0d0, 1.0d0, 4.0d0, 2.0d0, 3.0d0/)
  expected_ind = (/2, 4, 5, 3, 1/)

  call qsort(test_x, test_ind, test_n)

  if (any(test_ind .ne. expected_ind)) then
    write(*,*) "Error in test qsort"
    write(*,*) "Expected ", expected_ind, " but got ", test_ind
    error stop
  endif

  ! the indices should give x in increasing order when applied
  do i = 1, test_n - 1
    if (test_x(test_ind(i)) > test_x(test_ind(i+1))) then
      write(*,*) "Error in test qsort: result is not sorted"
      error stop
    endif
  enddo

  !----------------------------------------------
  ! test 2: an already-sorted array should come back unchanged
  test_x       = (/1.0d0, 2.0d0, 3.0d0, 4.0d0, 5.0d0/)
  expected_ind = (/1, 2, 3, 4, 5/)

  call qsort(test_x, test_ind, test_n)

  if (any(test_ind .ne. expected_ind)) then
    write(*,*) "Error in test qsort (already sorted)"
    write(*,*) "Expected ", expected_ind, " but got ", test_ind
    error stop
  endif

end program test_subroutine_qsort
