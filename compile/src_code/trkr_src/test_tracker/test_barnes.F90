!************************************************
!* This test program tests the subroutine barnes, which performs a
!* single-pass Barnes objective analysis (a distance-weighted average
!* using a Gaussian kernel) of a gridded field about a point.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_barnes

  use access_subroutines
  use trig_vals
  use trkrparms
  use verbose_output

  implicit none

  integer, parameter :: test_iimax = 3, test_jjmax = 3
  real :: test_rlon(test_iimax), test_rlat(test_jjmax)
  real :: test_fxy(test_iimax, test_jjmax)
  logical(1) :: test_defined_pt(test_iimax, test_jjmax)
  type(trackstuff) :: test_trkrinfo
  real :: test_favg, test_re, test_ri
  integer :: test_icount, test_iret
  real, parameter :: tol = 0.001

  ! trig_vals declares pi and dtr but does not initialize them (they
  ! are set at runtime in gettrk_main.f); barnes calls calcdist,
  ! which needs dtr.
  pi  = 4. * atan(1.)
  dtr = pi / 180.0
  verb = 0

  test_rlon = (/0.0, 1.0, 2.0/)
  test_rlat = (/2.0, 1.0, 0.0/)
  test_defined_pt = .true.
  test_trkrinfo%gridtype = 'regional'
  test_re = 100.0
  test_ri = 500.0

  !----------------------------------------------
  ! test 1: a spatially uniform field should produce that same value
  ! as the weighted average, regardless of the weighting kernel
  test_fxy = 50.0

  call barnes(1.0, 1.0, test_rlon, test_rlat, test_iimax, test_jjmax &
             ,1, 1, test_iimax, test_jjmax, test_fxy, test_defined_pt &
             ,1, test_re, test_ri, test_favg, test_icount, 'tracker' &
             ,test_trkrinfo, test_iret)

  if (test_iret .ne. 0 .or. abs(test_favg - 50.0) > tol) then
    write(*,*) "Error in test barnes (uniform field)"
    write(*,*) "Expected favg=50.0 but got ", test_favg, " iret=", test_iret
    error stop
  endif

  if (test_icount .ne. test_iimax*test_jjmax) then
    write(*,*) "Error in test barnes (uniform field): unexpected icount"
    write(*,*) "Expected ", test_iimax*test_jjmax, " but got ", test_icount
    error stop
  endif

  !----------------------------------------------
  ! test 2: centered exactly on a strong local peak, the weighted
  ! average should be pulled down from the peak value by its cooler
  ! surrounding neighbors, landing between the two
  test_fxy(1,1)=10.0; test_fxy(2,1)=20.0; test_fxy(3,1)=10.0
  test_fxy(1,2)=20.0; test_fxy(2,2)=100.0; test_fxy(3,2)=20.0
  test_fxy(1,3)=10.0; test_fxy(2,3)=20.0; test_fxy(3,3)=10.0

  call barnes(1.0, 1.0, test_rlon, test_rlat, test_iimax, test_jjmax &
             ,1, 1, test_iimax, test_jjmax, test_fxy, test_defined_pt &
             ,1, test_re, test_ri, test_favg, test_icount, 'tracker' &
             ,test_trkrinfo, test_iret)

  if (test_iret .ne. 0 .or. abs(test_favg - 50.6567879) > tol) then
    write(*,*) "Error in test barnes (peak surrounded by cooler pts)"
    write(*,*) "Expected favg=50.6567879 but got ", test_favg &
               ," iret=", test_iret
    error stop
  endif

end program test_subroutine_barnes
