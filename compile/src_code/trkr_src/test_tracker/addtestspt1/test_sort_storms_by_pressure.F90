!************************************************
!* Test program for sort_storms_by_pressure subroutine
!* Tests sorting of storms by minimum pressure
!*
!* Created by: GitHub Copilot Testing Suite
!************************************************
program test_subroutine_sort_storms_by_pressure

  use access_subroutines

  implicit none

  integer, parameter :: maxstorm = 4
  real :: gridprs(maxstorm)
  integer :: ifh, sortindex(maxstorm)
  integer :: i
  real :: expected_order(maxstorm)
  integer :: expected_indices(maxstorm)
  
  write(*,*) "Testing sort_storms_by_pressure subroutine..."

  ! Test 1: Sort pressures from lowest to highest
  ifh = 0
  gridprs(1) = 980.0  ! Higher pressure (weaker storm)
  gridprs(2) = 920.0  ! Lowest pressure (strongest storm)  
  gridprs(3) = 950.0  ! Medium pressure
  gridprs(4) = 1000.0 ! Highest pressure (weakest storm)
  
  ! Expected sorted order: indices 2,3,1,4 (pressures: 920,950,980,1000)
  expected_indices(1) = 2  ! storm with 920 mb
  expected_indices(2) = 3  ! storm with 950 mb  
  expected_indices(3) = 1  ! storm with 980 mb
  expected_indices(4) = 4  ! storm with 1000 mb
  
  call sort_storms_by_pressure(gridprs, ifh, maxstorm, sortindex)
  
  ! Check if sorting is correct
  do i = 1, maxstorm
    if (sortindex(i) /= expected_indices(i)) then
      write(*,*) "Error in test sort_storms_by_pressure"
      write(*,*) "Position ", i, ": expected index ", expected_indices(i), &
                 " but got ", sortindex(i)
      error stop
    endif
  enddo

  ! Test 2: Already sorted case
  gridprs(1) = 900.0  ! Lowest  
  gridprs(2) = 950.0  
  gridprs(3) = 980.0
  gridprs(4) = 1000.0 ! Highest
  
  expected_indices(1) = 1
  expected_indices(2) = 2  
  expected_indices(3) = 3
  expected_indices(4) = 4
  
  call sort_storms_by_pressure(gridprs, ifh, maxstorm, sortindex)
  
  do i = 1, maxstorm
    if (sortindex(i) /= expected_indices(i)) then
      write(*,*) "Error in test sort_storms_by_pressure - already sorted"
      write(*,*) "Position ", i, ": expected index ", expected_indices(i), &
                 " but got ", sortindex(i)
      error stop
    endif
  enddo

  ! Test 3: Reverse sorted case
  gridprs(1) = 1000.0 ! Highest
  gridprs(2) = 980.0  
  gridprs(3) = 950.0
  gridprs(4) = 900.0  ! Lowest
  
  expected_indices(1) = 4  ! storm with 900 mb
  expected_indices(2) = 3  ! storm with 950 mb
  expected_indices(3) = 2  ! storm with 980 mb  
  expected_indices(4) = 1  ! storm with 1000 mb
  
  call sort_storms_by_pressure(gridprs, ifh, maxstorm, sortindex)
  
  do i = 1, maxstorm
    if (sortindex(i) /= expected_indices(i)) then
      write(*,*) "Error in test sort_storms_by_pressure - reverse sorted"
      write(*,*) "Position ", i, ": expected index ", expected_indices(i), &
                 " but got ", sortindex(i)
      error stop
    endif
  enddo

  write(*,*) "All sort_storms_by_pressure tests passed!"

end program test_subroutine_sort_storms_by_pressure
