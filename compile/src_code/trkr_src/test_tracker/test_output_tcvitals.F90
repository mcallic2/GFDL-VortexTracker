!************************************************
!* This test program tests the subroutine output_tcvitals, which
!* writes a tcvitals-format record for a storm's found position,
!* converting from signed lat/lon (north/east positive) into the
!* tcvitals encoding (magnitude*10 plus a N/S or E/W hemisphere flag).
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_output_tcvitals

  use access_subroutines
  use def_vitals
  use inparms
  use set_max_parms
  use verbose_output

  implicit none

  type(datecard) :: test_inp
  real :: test_xlon, test_xlat
  integer :: test_iovret

  character(len=4)  :: r_center
  character(len=3)  :: r_id
  character(len=9)  :: r_name
  integer :: r_ymd, r_hhmm, r_lat, r_lon, r_stdir, r_stspd, r_pcen &
            ,r_penv, r_penvrad, r_vmax, r_vmaxrad, r_r1, r_r2, r_r3, r_r4
  character(len=1) :: r_latns, r_lonew, r_depth

  verb = 0

  allocate(storm(1))
  storm(1)%tcv_storm_id = '17L '
  storm(1)%tcv_storm_name = 'PHILIPPE'
  storm(1)%tcv_ymd = 20230929
  storm(1)%tcv_hhmm = 1200
  storm(1)%tcv_stdir = 280
  storm(1)%tcv_stspd = 21
  storm(1)%tcv_pcen = 1003
  storm(1)%tcv_penv = 1008
  storm(1)%tcv_penvrad = 300
  storm(1)%tcv_vmax = 15
  storm(1)%tcv_vmaxrad = 40
  storm(1)%tcv_r15ne = -999
  storm(1)%tcv_r15se = -999
  storm(1)%tcv_r15sw = -999
  storm(1)%tcv_r15nw = -999
  storm(1)%tcv_depth = 'D'

  open(unit=65, file='test_output_tcvitals_tmp.txt', status='replace')

  !----------------------------------------------
  ! test 1: northern hemisphere, western hemisphere position
  test_xlon = 304.7   ! 55.3W
  test_xlat = 18.4    ! 18.4N
  call output_tcvitals(test_xlon, test_xlat, test_inp, 1, test_iovret)

  if (test_iovret .ne. 0) then
    write(*,*) "Error in test output_tcvitals: iovret=", test_iovret
    error stop
  endif

  rewind(65)
  read(65,21) r_center,r_id,r_name,r_ymd,r_hhmm,r_lat,r_latns,r_lon &
             ,r_lonew,r_stdir,r_stspd,r_pcen,r_penv,r_penvrad,r_vmax &
             ,r_vmaxrad,r_r1,r_r2,r_r3,r_r4,r_depth
   21 format (a4,1x,a3,1x,a9,1x,i8.8,1x,i4.4,1x,i3,a1,1x,i4,a1,1x &
            ,i3,1x,i3,3(1x,i4),1x,i2,1x,i3,1x,4(i4,1x),a1)

  ! 18.4*10+0.5 = 184.5 -> truncates to 184; N since xlat>=0
  ! 304.7 >= 180, so lon = 3600 - (304.7*10+0.5 truncated to 3047) = 553, W
  if (r_lat .ne. 184 .or. r_latns .ne. 'N' .or. &
      r_lon .ne. 553 .or. r_lonew .ne. 'W') then
    write(*,*) "Error in test output_tcvitals (NW position)"
    write(*,*) "Expected lat=184N lon=553W but got ", r_lat, r_latns &
               ,r_lon, r_lonew
    error stop
  endif

  !----------------------------------------------
  ! test 2: southern hemisphere, eastern hemisphere position
  rewind(65)
  test_xlon = 72.5    ! 72.5E
  test_xlat = -10.5   ! 10.5S
  call output_tcvitals(test_xlon, test_xlat, test_inp, 1, test_iovret)

  rewind(65)
  read(65,21) r_center,r_id,r_name,r_ymd,r_hhmm,r_lat,r_latns,r_lon &
             ,r_lonew,r_stdir,r_stspd,r_pcen,r_penv,r_penvrad,r_vmax &
             ,r_vmaxrad,r_r1,r_r2,r_r3,r_r4,r_depth

  ! 10.5*10+0.5 = 105.5 -> truncates to 105; S since xlat<0
  ! 72.5 < 180, so lon = 72.5*10+0.5 truncated to 725, E
  if (r_lat .ne. 105 .or. r_latns .ne. 'S' .or. &
      r_lon .ne. 725 .or. r_lonew .ne. 'E') then
    write(*,*) "Error in test output_tcvitals (SE position)"
    write(*,*) "Expected lat=105S lon=725E but got ", r_lat, r_latns &
               ,r_lon, r_lonew
    error stop
  endif

  close(65, status='delete')

end program test_subroutine_output_tcvitals
