!************************************************
!* This test program tests the subroutine get_ijplus1_check_wrap,
!* which returns the four (i,j) neighbors of a grid point, wrapping
!* around the Greenwich meridian for global grids and returning an
!* error code for regional grids where the neighbor would fall off
!* the edge of the grid.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_get_ijplus1_check_wrap

  use access_subroutines
  use trkrparms
  use verbose_output

  implicit none

  type(trackstuff) :: test_trkrinfo
  integer :: test_iplus1, test_jplus1, test_iminus1, test_jminus1
  integer :: test_igicwret

  ! suppress the routine's diagnostic prints; does not affect the
  ! values being tested
  verb = 0

  !----------------------------------------------
  ! global grid, at the eastern edge: i+1 should wrap around to 1
  test_trkrinfo%gridtype = 'global'

  call get_ijplus1_check_wrap(360, 181, 360, 90, test_iplus1, test_jplus1 &
                              ,test_iminus1, test_jminus1, test_trkrinfo &
                              ,test_igicwret)

  if (test_igicwret .ne. 0 .or. test_iplus1 .ne. 1) then
    write(*,*) "Error in test get_ijplus1_check_wrap (global east wrap)"
    write(*,*) "Expected igicwret=0 iplus1=1 but got ", test_igicwret, test_iplus1
    error stop
  endif

  !----------------------------------------------
  ! global grid, at the western edge: i-1 should wrap around to imax
  call get_ijplus1_check_wrap(360, 181, 1, 90, test_iplus1, test_jplus1 &
                              ,test_iminus1, test_jminus1, test_trkrinfo &
                              ,test_igicwret)

  if (test_igicwret .ne. 0 .or. test_iminus1 .ne. 360) then
    write(*,*) "Error in test get_ijplus1_check_wrap (global west wrap)"
    write(*,*) "Expected igicwret=0 iminus1=360 but got ", test_igicwret, test_iminus1
    error stop
  endif

  !----------------------------------------------
  ! regional grid, at the eastern edge: should return error code 98
  ! rather than wrapping, since a regional grid has no wraparound
  test_trkrinfo%gridtype = 'regional'

  call get_ijplus1_check_wrap(100, 100, 100, 50, test_iplus1, test_jplus1 &
                              ,test_iminus1, test_jminus1, test_trkrinfo &
                              ,test_igicwret)

  if (test_igicwret .ne. 98) then
    write(*,*) "Error in test get_ijplus1_check_wrap (regional east edge)"
    write(*,*) "Expected igicwret=98 but got ", test_igicwret
    error stop
  endif

  !----------------------------------------------
  ! any grid, too close to the north/south edge: should return error
  ! code 91
  call get_ijplus1_check_wrap(100, 100, 50, 1, test_iplus1, test_jplus1 &
                              ,test_iminus1, test_jminus1, test_trkrinfo &
                              ,test_igicwret)

  if (test_igicwret .ne. 91) then
    write(*,*) "Error in test get_ijplus1_check_wrap (north/south edge)"
    write(*,*) "Expected igicwret=91 but got ", test_igicwret
    error stop
  endif

end program test_subroutine_get_ijplus1_check_wrap
