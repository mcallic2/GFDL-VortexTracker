program test_subroutine_distbear

  use access_subroutines

  implicit none

  real :: lat, lon, dist(19), bear
  real :: output_lon, output_lat
  real :: test_lon, test_lat
  real, parameter :: rad_earth_km = 6372.797  ! radius of earth
  real, parameter :: pi = 4.0 * atan(1.0)   ! Both pi and dtr were declared in module 
  real, parameter :: dtr = pi / 180.0
  integer, parameter :: numdist = 19, numazim = 24
  integer :: idist, icount

  dist =(/50.0,  75.0,  100.0, 125.0, 150.0, 175.0, 200.0, 225.0, 250.0, 275.0, &
          300.0, 325.0, 350.0, 375.0, 400.0, 425.0, 450.0, 475.0, 500.0/)

  lat = 28.95
  lon = 288.80

  do idist = 1, numdist
    do icount = 1, 19

    bear = ((real(icount)-1.0) * 15.0) + 7.5
    call distbear (lat, lon, dist(idist), bear, output_lat, output_lon, "none")

    enddo
  enddo

  !print *, lat, lon
  !print *, dist
  !print *, bear
  print *, output_lat
  print *, output_lon
end program test_subroutine_distbear