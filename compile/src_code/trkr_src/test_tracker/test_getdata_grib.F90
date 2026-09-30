!************************************************
!* This is a REGRESSION test, not a pure unit test: unlike the other
!* files in this directory, it does not verify correctness from first
!* principles. Instead it runs getgridinfo_grib and getdata_grib
!* against a real, fixed GRIB2 file (test_data/single_trimmed_test_grib.grib2,
!* a 120x120, 0.25-deg regional crop -- lon 289.75-319.5E, lat 3.5-33.25N
!* -- of a global 76-level analysis valid 2023-09-29 12Z, covering
!* Hurricanes Philippe (17L) and Rina (18L)) and checks the output
!* against values captured and independently cross-checked once, by
!* hand, against the matching vitals.2023092912 storm positions (both
!* storms' vitals MSLP landed within ~1.5 mb and ~1 degree of a
!* genuine local pressure minimum in this file -- see the commit that
!* added this test). This crop uses south-to-north scanning (unlike
!* the original global file, which was north-to-south), so
!* need_to_flip_lats comes back .true. here -- getdata_grib normalizes
!* this internally, so slp(:,1) is still the northernmost row either
!* way and the storm cross-checks below don't need to care which
!* scan direction the source file used.
!*
!* A failure here means GRIB2 decoding behavior changed -- it does
!* not by itself say whether the new behavior is right or wrong; a
!* human needs to judge that and, if the change was intentional,
!* update the expected values below.
!*
!* Requires linking against the real NCEPLIBS-g2/g2c/bacio/w3emc
!* stack (as the project's CMakeLists.txt already does for
!* subroutine_lib via g2::g2_d) -- this test cannot run against the
!* grib_mod stand-in used for the pure subroutine tests.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_getdata_grib

  use access_subroutines
  use trkrparms
  use inparms
  use tracked_parms
  use level_parms
  use grid_bounds
  use verbose_output
  use phase
  use sst_diags
  use genesis_diags
  use vortex_tilt_diags
  use trig_vals
  use read_parms

  implicit none

#ifndef TEST_DATA_FILE
#define TEST_DATA_FILE "test_data/single_trimmed_test_grib.grib2"
#endif

  type(trackstuff) :: test_trkrinfo
  type(datecard)   :: test_inp

  integer, parameter :: test_lugb = 11, test_lugi = 0
  integer :: test_imax, test_jmax, test_iggret
  real    :: test_dx, test_dy
  logical(1) :: test_flip_lats, test_flip_lons
  character(len=20) :: test_gm_wrap_flag

  logical(1), allocatable :: test_readflag(:), test_readgenflag(:)
  logical(1), allocatable :: test_valid_pt(:,:)
  integer :: test_vortex_tilt_levs(vortex_max_levs), test_num_vt_levs

  logical(1) :: expected_readflag(20)
  real, parameter :: tol = 0.5   ! Pa-scale float tolerance, see below

  pi  = 4. * atan(1.)
  dtr = pi / 180.0
  verb = 0
  verb_g2 = 0

  test_trkrinfo%gridtype = 'regional'
  test_trkrinfo%type = 'tracker'
  test_trkrinfo%gribver = 2
  test_trkrinfo%g2_jpdtn = 0
  test_trkrinfo%g2_mslp_parm_id = 192 ! GFS/Eta MSLP reduction -- matches
                                       ! the project's real production
                                       ! namelists (test_data/
                                       ! g2namelist.gettrk), not the
                                       ! standard reduction (parm id 1).
                                       ! The two differ by up to ~4.8 mb
                                       ! at some points in this file, but
                                       ! match at Philippe/Rina's specific
                                       ! grid cells to the precision
                                       ! checked below.
  test_trkrinfo%enable_timing = 0

  test_inp%lt_units = 'hours'
  test_inp%modtyp = 'regional'

  ! this file is a single analysis valid at forecast hour 0
  allocate(ifhours(1), iftotalmins(1), ifclockmins(1))
  ifhours(1) = 0
  iftotalmins(1) = 0
  ifclockmins(1) = 0

  ! skip every optional diagnostic block in getdata_grib -- this test
  ! is only checking the core GRIB2 decode path
  phaseflag = 'n'
  sstflag = 'n'
  genflag = 'n'
  vortex_tilt_flag = 'n'
  test_num_vt_levs = 0
  test_vortex_tilt_levs = 0

  call baopenr(test_lugb, TEST_DATA_FILE, test_iggret)
  if (test_iggret /= 0) then
    write(*,*) "Error in test_getdata_grib: could not open test data file"
    write(*,*) "baopenr iret=", test_iggret
    error stop
  endif

  !----------------------------------------------
  ! part 1: getgridinfo_grib should correctly identify this as a
  ! 120x120, 0.25-degree regional crop
  call getgridinfo_grib(test_imax, test_jmax, 1, test_dx, test_dy &
                        ,test_lugb, test_lugi, test_trkrinfo &
                        ,test_flip_lats, test_flip_lons, test_inp &
                        ,test_gm_wrap_flag, test_iggret)

  if (test_iggret /= 0) then
    write(*,*) "Error in test_getdata_grib: getgridinfo_grib iggret=" &
               ,test_iggret
    error stop
  endif

  if (test_imax .ne. 120 .or. test_jmax .ne. 120) then
    write(*,*) "Error in test_getdata_grib: unexpected grid size"
    write(*,*) "Expected 120x120 but got ", test_imax, test_jmax
    error stop
  endif

  if (abs(test_dx - 0.25) > 1.0e-5 .or. abs(test_dy - 0.25) > 1.0e-5) then
    write(*,*) "Error in test_getdata_grib: unexpected grid spacing"
    write(*,*) "Expected dx=dy=0.25 but got ", test_dx, test_dy
    error stop
  endif

  if (abs(glatmin - 3.5) > 1.0e-3 .or. abs(glatmax - 33.25) > 1.0e-3 &
      .or. abs(glonmin - 289.75) > 1.0e-3) then
    write(*,*) "Error in test_getdata_grib: unexpected grid bounds"
    write(*,*) "glatmin=", glatmin, " glatmax=", glatmax &
               ," glonmin=", glonmin
    error stop
  endif

  !----------------------------------------------
  ! part 2: getdata_grib should successfully decode the core tracking
  ! fields (allocate exactly as the real "tracker" subroutine does
  ! before calling getdata_grib)
  allocate(zeta(test_imax,test_jmax,nlevzeta))
  allocate(u(test_imax,test_jmax,nlevs))
  allocate(v(test_imax,test_jmax,nlevs))
  allocate(hgt(test_imax,test_jmax,nlevhgt))
  allocate(slp(test_imax,test_jmax))
  allocate(tmean(test_imax,test_jmax))
  allocate(lsmask(test_imax,test_jmax))
  allocate(test_valid_pt(test_imax,test_jmax))
  allocate(test_readflag(nreadparms), test_readgenflag(nreadgenparms))
  ! getdata_grib does not initialize readflag/readgenflag itself -- the
  ! real "tracker" subroutine does this immediately before calling it,
  ! and skipping it here means the result depends on leftover stack/heap
  ! content rather than the subroutine's actual behavior
  test_readflag = .false.
  test_readgenflag = .false.

  call getdata_grib(test_readflag, test_readgenflag, test_valid_pt &
                    ,test_imax, test_jmax, 1, test_flip_lats &
                    ,test_flip_lons, test_inp, test_lugb, test_lugi &
                    ,test_lugb, 0, test_trkrinfo, test_vortex_tilt_levs &
                    ,test_num_vt_levs)

  ! fields 1-13, 15, 17-19 are present in this file; field 14 (a
  ! synthetic 300-500mb mean temperature "level" some models encode)
  ! and field 16 (200mb height) are not in this particular file, and
  ! field 20 (SST) is correctly skipped since sstflag='n'
  expected_readflag = (/.true.,.true.,.true.,.true.,.true.,.true. &
                       ,.true.,.true.,.true.,.true.,.true.,.true. &
                       ,.true.,.false.,.true.,.false.,.true.,.true. &
                       ,.true.,.false./)

  if (any(test_readflag .neqv. expected_readflag)) then
    write(*,*) "Error in test_getdata_grib: readflag pattern changed"
    write(*,*) "Expected ", expected_readflag
    write(*,*) "Got      ", test_readflag
    error stop
  endif

  if (.not. all(test_valid_pt)) then
    write(*,*) "Error in test_getdata_grib: expected a fully valid " &
               ,"crop (this is a full-field crop, not a regional " &
               ,"model's native edge, so no bitmapped-out points)"
    error stop
  endif

  !----------------------------------------------
  ! part 3: cross-check the decoded MSLP field against the two real
  ! storms from vitals.2023092912 that fall within this crop's domain
  ! (lon 289.75-319.5E, lat 3.5-33.25N) -- 14W and 99A, also in that
  ! vitals file, are outside this cropped region and are not checked
  ! here (see test_data/README.md)
  call check_local_min('17L', 18.4, 360.0-55.3, 1003.0, 19.25, 305.50)
  call check_local_min('18L', 19.1, 360.0-46.7, 1002.0, 19.00, 313.50)

  call baclose(test_lugb, test_iggret)

contains

  subroutine check_local_min(label, slat, slon, expected_mb &
                             ,expected_lat, expected_lon)
    character(*), intent(in) :: label
    real, intent(in) :: slat, slon, expected_mb, expected_lat, expected_lon
    integer :: ii, jj, ilo, ihi, jlo, jhi, targ_i, targ_j
    real :: localmin, glat_, glon_
    real, parameter :: loc_tol = 0.3   ! degrees

    targ_i = nint((slon - glonmin) / test_dx)
    targ_j = nint((glatmax - slat) / test_dy)
    ilo = max(0, targ_i - 20); ihi = min(test_imax-1, targ_i + 20)
    jlo = max(0, targ_j - 20); jhi = min(test_jmax-1, targ_j + 20)

    localmin = 1.0e10
    do jj = jlo, jhi
      do ii = ilo, ihi
        if (slp(ii+1,jj+1) < localmin) then
          localmin = slp(ii+1,jj+1)
          glat_ = glatmax - jj*test_dy
          glon_ = glonmin + ii*test_dx
        endif
      enddo
    enddo

    if (abs(localmin/100.0 - expected_mb) > 0.1 .or. &
        abs(glat_ - expected_lat) > loc_tol .or. &
        abs(glon_ - expected_lon) > loc_tol) then
      write(*,*) "Error in test_getdata_grib: local MSLP min near " &
                 ,label, " storm changed"
      write(*,*) "Expected ", expected_mb, " mb at (", expected_lat &
                 ,",", expected_lon, ")"
      write(*,*) "Got      ", localmin/100.0, " mb at (", glat_ &
                 ,",", glon_, ")"
      error stop
    endif
  end subroutine check_local_min

end program test_getdata_grib
