!************************************************
!* This test program tests the subroutine compute_q_from_rh, which
!* derives 850 mb specific humidity from temperature and relative
!* humidity using Teten's formula for saturation vapor pressure, for
!* models that provide RH but not q directly.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_compute_q_from_rh

  use access_subroutines
  use tracked_parms
  use read_parms
  use trkrparms

  implicit none

  integer, parameter :: test_imax = 3, test_jmax = 3
  logical(1) :: test_valid_pt(test_imax,test_jmax)
  logical(1) :: test_readgenflag(nreadgenparms)
  type(trackstuff) :: test_trkrinfo
  integer :: test_ichrret
  real, parameter :: expected_q850 = 0.0066694524
  real, parameter :: tol = 1.0e-6

  allocate(t850(test_imax,test_jmax), rh850(test_imax,test_jmax) &
          ,q850(test_imax,test_jmax))
  test_valid_pt = .true.
  test_readgenflag = .false.
  test_readgenflag(2) = .true.
  test_readgenflag(3) = .true.

  !----------------------------------------------
  ! test 1: RH given as a whole-number percent (e.g. 75, not 0.75)
  t850 = 283.0    ! 9.85 C
  rh850 = 75.0

  call compute_q_from_rh(1, 1, test_imax, test_jmax, 1.0, 1.0 &
                         ,test_valid_pt, 15, test_trkrinfo &
                         ,test_readgenflag, test_ichrret)

  if (abs(q850(2,2) - expected_q850) > tol) then
    write(*,*) "Error in test compute_q_from_rh (RH as percent)"
    write(*,*) "Expected q850=", expected_q850, " but got ", q850(2,2)
    error stop
  endif

  !----------------------------------------------
  ! test 2: the same physical RH given as a 0-1 fraction (0.75, not
  ! 75) should produce the identical q850 -- the subroutine detects
  ! which scale it was given and adjusts, so the physical answer must
  ! not depend on which convention the input used
  rh850 = 0.75

  call compute_q_from_rh(1, 1, test_imax, test_jmax, 1.0, 1.0 &
                         ,test_valid_pt, 15, test_trkrinfo &
                         ,test_readgenflag, test_ichrret)

  if (abs(q850(2,2) - expected_q850) > tol) then
    write(*,*) "Error in test compute_q_from_rh (RH as fraction)"
    write(*,*) "Expected q850=", expected_q850, " but got ", q850(2,2)
    error stop
  endif

end program test_subroutine_compute_q_from_rh
