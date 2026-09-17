!************************************************
!* Test program for bilin_int_uneven subroutine
!* Tests bilinear interpolation on uneven grids
!*
!* Created by: GitHub Copilot Testing Suite
!************************************************
program test_subroutine_bilin_int_uneven

  use access_subroutines

  implicit none

  integer, parameter :: imax = 3, jmax = 3
  real, parameter :: TOLERANCE = 1.0e-5
  
  real :: targlat, targlon, dx, dy
  real :: xlon(imax,jmax), xlat(imax,jmax), field(imax,jmax)
  real :: interp_val, expected_val
  integer :: i, j
  integer :: ibiret

  write(*,*) "Testing bilin_int_uneven subroutine..."

  ! Set up a simple 3x3 grid
  dx = 1.0
  dy = 1.0
  
  ! Initialize longitude and latitude arrays
  do i = 1, imax
    do j = 1, jmax
      xlon(i,j) = real(i-1) * dx
      xlat(i,j) = real(j-1) * dy
      field(i,j) = real(i + j - 2)  ! Simple field values: 0,1,2,1,2,3,2,3,4
    enddo
  enddo

  ! Test 1: Interpolation at grid point (should return exact value)
  targlat = 1.0
  targlon = 1.0
  expected_val = 2.0  ! field(2,2) = 1+1 = 2
  
  call bilin_int_uneven(targlat, targlon, dx, dy, xlon, xlat, &
                        field, imax, jmax, interp_val, ibiret)
  
  if (ibiret /= 0) then
    write(*,*) "Error: bilin_int_uneven returned error code ", ibiret
    error stop
  endif
  
  if (abs(interp_val - expected_val) > TOLERANCE) then
    write(*,*) "Error in test bilin_int_uneven - grid point interpolation"
    write(*,*) "Expected ", expected_val, " but got ", interp_val
    error stop
  endif

  ! Test 2: Interpolation at center of grid cell
  targlat = 0.5
  targlon = 0.5
  expected_val = 1.0  ! Should be average of corners: (0+1+1+2)/4 = 1
  
  call bilin_int_uneven(targlat, targlon, dx, dy, xlon, xlat, &
                        field, imax, jmax, interp_val, ibiret)
  
  if (ibiret /= 0) then
    write(*,*) "Error: bilin_int_uneven returned error code ", ibiret
    error stop
  endif
  
  if (abs(interp_val - expected_val) > TOLERANCE) then
    write(*,*) "Error in test bilin_int_uneven - center interpolation"
    write(*,*) "Expected ", expected_val, " but got ", interp_val
    error stop
  endif

  write(*,*) "All bilin_int_uneven tests passed!"

end program test_subroutine_bilin_int_uneven
