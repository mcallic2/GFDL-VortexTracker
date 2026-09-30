!************************************************
!* This test program tests the subroutine check_land_mask, which
!* samples the land-sea mask around a point (at the point itself plus
!* 8 points 75 km out) to decide whether that point is predominantly
!* over water (less than 50% land).
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_check_land_mask

  use access_subroutines
  use grid_bounds
  use tracked_parms
  use trkrparms
  use trig_vals
  use verbose_output

  implicit none

  integer, parameter :: test_imax = 20, test_jmax = 20
  logical(1) :: test_valid_pt(test_imax,test_jmax)
  character(len=1) :: test_water
  character(len=20) :: test_gm_wrap_flag
  real :: test_fract_land, test_dx, test_dy
  integer :: test_iclmret, i, j

  pi  = 4. * atan(1.)
  dtr = pi / 180.0
  verb = 0

  allocate(glon(test_imax), glat(test_jmax))
  allocate(lsmask(test_imax,test_jmax))
  glon = (/(real(i-1)*0.25, i=1,test_imax)/)
  glat = (/(20.0 - real(j-1)*0.25, j=1,test_jmax)/)
  glonmin = glon(1); glonmax = glon(test_imax)
  glatmax = glat(1); glatmin = glat(test_jmax)
  test_dx = 0.25; test_dy = 0.25
  test_valid_pt = .true.
  test_gm_wrap_flag = 'none'

  !----------------------------------------------
  ! test 1: an entirely-ocean mask should be reported as over water,
  ! with a land fraction of 0
  lsmask = 0.0

  call check_land_mask(test_imax, test_jmax, 10, 10, test_fract_land &
                       ,test_valid_pt, test_dx, test_dy, test_water, 1 &
                       ,test_gm_wrap_flag, test_iclmret)

  if (test_water .ne. 'y' .or. abs(test_fract_land) > 0.001) then
    write(*,*) "Error in test check_land_mask (all ocean)"
    write(*,*) "Expected water=y fract_land=0.0 but got ", test_water &
               ,test_fract_land
    error stop
  endif

  !----------------------------------------------
  ! test 2: an entirely-land mask should be reported as over land,
  ! with a land fraction of 1
  lsmask = 1.0

  call check_land_mask(test_imax, test_jmax, 10, 10, test_fract_land &
                       ,test_valid_pt, test_dx, test_dy, test_water, 1 &
                       ,test_gm_wrap_flag, test_iclmret)

  if (test_water .ne. 'n' .or. abs(test_fract_land - 1.0) > 0.001) then
    write(*,*) "Error in test check_land_mask (all land)"
    write(*,*) "Expected water=n fract_land=1.0 but got ", test_water &
               ,test_fract_land
    error stop
  endif

  !----------------------------------------------
  ! test 3: if the center point itself has no valid data, the routine
  ! bails out immediately and reports "not water" with a sentinel
  ! fract_land of 99.0, regardless of the surrounding mask
  lsmask = 0.0
  test_valid_pt(10,10) = .false.

  call check_land_mask(test_imax, test_jmax, 10, 10, test_fract_land &
                       ,test_valid_pt, test_dx, test_dy, test_water, 1 &
                       ,test_gm_wrap_flag, test_iclmret)

  if (test_water .ne. 'n' .or. abs(test_fract_land - 99.0) > 0.001) then
    write(*,*) "Error in test check_land_mask (invalid center point)"
    write(*,*) "Expected water=n fract_land=99.0 but got ", test_water &
               ,test_fract_land
    error stop
  endif

end program test_subroutine_check_land_mask
