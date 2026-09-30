!************************************************
!* This test program tests the subroutine sort_storms_by_pressure,
!* which returns the permutation of storm indices from lowest to
!* highest MSLP.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_sort_storms_by_pressure

  use access_subroutines
  use set_max_parms

  implicit none

  integer, parameter :: test_maxstorm = 4
  real    :: test_gridprs(test_maxstorm, maxtime)
  integer :: test_sortindex(test_maxstorm), test_issret
  integer :: expected_sortindex(test_maxstorm)

  test_gridprs = 0.0

  !----------------------------------------------
  ! test 1: at a forecast hour beyond the first (ifh > 1), the storms
  ! are sorted by the pressure they had at the *previous* hour
  ! (index ifh-1), lowest pressure (strongest storm) first
  test_gridprs(1,1) = 980.0
  test_gridprs(2,1) = 920.0
  test_gridprs(3,1) = 950.0
  test_gridprs(4,1) = 1000.0
  expected_sortindex = (/2, 3, 1, 4/)

  call sort_storms_by_pressure(test_gridprs, 2, test_maxstorm &
                               ,test_sortindex, test_issret)

  if (any(test_sortindex .ne. expected_sortindex)) then
    write(*,*) "Error in test sort_storms_by_pressure (ifh > 1)"
    write(*,*) "Expected ", expected_sortindex, " but got ", test_sortindex
    error stop
  endif

  !----------------------------------------------
  ! test 2: at the first forecast hour (ifh <= 1) there is no previous
  ! hour to sort by, so the routine just returns the storms in their
  ! original (already-strongest-first) order, regardless of gridprs
  expected_sortindex = (/1, 2, 3, 4/)

  call sort_storms_by_pressure(test_gridprs, 1, test_maxstorm &
                               ,test_sortindex, test_issret)

  if (any(test_sortindex .ne. expected_sortindex)) then
    write(*,*) "Error in test sort_storms_by_pressure (ifh = 1)"
    write(*,*) "Expected ", expected_sortindex, " but got ", test_sortindex
    error stop
  endif

end program test_subroutine_sort_storms_by_pressure
