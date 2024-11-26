program test_subroutine_compute_rh_from_q

  use access_subroutines; use trkrparms; use tracked_parms

  implicit none

  integer    :: ist, ifh, ip, maxstorm, ichrret
  integer, parameter :: imax=2, jmax=2
  real       :: dx, dy
  logical(1) :: valid_pt(imax,jmax), readgenflag(23)

  allocate (temperature(1,1,1))
  allocate (rh(1,1,1))
  allocate(spfh(1,1,1))

  ist = 1 ; ifh = 1 ; ip = 3 ; maxstorm = 2000 ; ichrret = 1
  dx = 0.00303 ; dy = 0.00303
  valid_pt = .true. ; readgenflag = .true.

  temperature = 32.0
  rh = 89.0
  spfh = 89.0
  ! subroutine compute_rh_from_q (ist,ifh,imax,jmax,dx,dy,ip
  ! valid_pt,maxstorm,trkrinfo,readgenflag,ichrret)

  ! case 2: z=1, qix=9, tix=16, penv=100.0
  call compute_rh_from_q(ist, ifh, imax, jmax, dx, dy, &
       ip, valid_pt, maxstorm, readgenflag, ichrret)

end program