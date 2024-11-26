program test_subroutine_calcdist

  use access_subroutines

  implicit none

  real(kind=8) :: rlonb, rlatb, rlonc, rlatc
  real :: xdist, degrees

  rlonb = 290.302790053734 ; rlatb = 32.6722090494220
  rlonc = 291.636122115501 ; rlatc = 34.0055411111895
  !xdist = 1.73736245681984
 

  call calcdist(rlonb, rlatb, rlonc, rlatc, xdist, degrees)

  print *, xdist, degrees

end program test_subroutine_calcdist