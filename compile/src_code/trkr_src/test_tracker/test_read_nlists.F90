!************************************************
!* This is a REGRESSION test, not a pure unit test (see the header
!* comment in test_getdata_grib.F90 for what that distinction means).
!* It runs read_nlists against the project's two real production
!* namelist files (test_data/g2namelist.gettrk and test_data/
!* ncdfnamelist.gettrk, for the same Philippe/Rina GRIB2 run and the
!* Idalia NetCDF run used by the other regression tests) and checks
!* that every namelist group parses into the expected values.
!*
!* IMPORTANT: read_nlists does not take a filename argument -- it
!* hardcodes "namelist.gettrk" in the current working directory. This
!* test works around that by copying the real fixture there at
!* runtime (via execute_command_line) before calling it, which is
!* also why this test can't be run from just anywhere: it writes (and
!* leaves) a file named namelist.gettrk in whatever directory it's
!* run from.
!*
!* The GRIB2 namelist has vortex_tilt_flag='y', which makes
!* read_nlists also read a separate list of vertical levels from
!* whatever file is already open on unit 18 -- there's no real such
!* file checked in for this project yet, so this test opens a small
!* synthetic one (test_data/vtilt_levels.txt, 3 levels) just to
!* exercise that code path; the levels in it are not meaningful
!* production values.
!*
!* A failure here means namelist-parsing behavior changed -- it does
!* not by itself say whether the new behavior is right or wrong; a
!* human needs to judge that and, if the change was intentional,
!* update the expected values below.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_read_nlists

  use access_subroutines
  use inparms
  use trkrparms
  use atcf
  use phase
  use structure
  use gfilename_info
  use contours
  use verbose_output
  use waitfor_parms
  use netcdf_parms
  use tracking_parm_prefs
  use shear_diags
  use genesis_diags
  use sst_diags
  use vortex_tilt_diags

  implicit none

#ifndef G2_NAMELIST_FILE
#define G2_NAMELIST_FILE "test_data/g2namelist.gettrk"
#endif
#ifndef NCDF_NAMELIST_FILE
#define NCDF_NAMELIST_FILE "test_data/ncdfnamelist.gettrk"
#endif
#ifndef VTILT_LEVELS_FILE
#define VTILT_LEVELS_FILE "test_data/vtilt_levels.txt"
#endif

  type(datecard) :: test_inp
  type(trackstuff) :: test_trkrinfo
  type(netcdfstuff) :: test_netcdfinfo
  integer :: test_num_vt_levs
  integer :: test_vortex_tilt_levs(vortex_max_levs)
  integer :: test_lunml

  !----------------------------------------------
  ! part 1: the NetCDF (Idalia) production namelist -- vortex_tilt_flag
  ! is 'n' here, so this exercises the simpler of the two paths
  call execute_command_line('cp ' // NCDF_NAMELIST_FILE // &
                             ' ./namelist.gettrk')

  test_lunml = 21
  call read_nlists(test_inp, test_trkrinfo, test_netcdfinfo &
                   ,test_num_vt_levs, test_vortex_tilt_levs, test_lunml)

  if (test_inp%bcc .ne. 20 .or. test_inp%byy .ne. 23 .or. &
      test_inp%bmm .ne. 8 .or. test_inp%bdd .ne. 29 .or. &
      test_inp%bhh .ne. 0 .or. test_inp%model .ne. 41 .or. &
      trim(test_inp%modtyp) .ne. 'regional') then
    write(*,*) "Error in test read_nlists (NetCDF): &datein group"
    error stop
  endif

  if (atcfnum .ne. 15 .or. trim(atcfname) .ne. 'TSHD' .or. &
      atcfymdh .ne. 2023082900 .or. atcffreq .ne. 600) then
    write(*,*) "Error in test read_nlists (NetCDF): &atcfinfo group"
    error stop
  endif

  if (abs(test_trkrinfo%westbd - 260.0) > 1.0e-4 .or. &
      abs(test_trkrinfo%mslpthresh - 0.0015) > 1.0e-6 .or. &
      trim(test_trkrinfo%gridtype) .ne. 'regional' .or. &
      test_trkrinfo%gribver .ne. 1 .or. &
      test_trkrinfo%g2_mslp_parm_id .ne. 192 .or. &
      .not. test_trkrinfo%want_oci) then
    write(*,*) "Error in test read_nlists (NetCDF): &trackerinfo group"
    error stop
  endif

  if (trim(test_netcdfinfo%mslpname) .ne. 'PRMSL' .or. &
      trim(test_netcdfinfo%lon_name) .ne. 'grid_xt' .or. &
      trim(test_netcdfinfo%lat_name) .ne. 'grid_yt' .or. &
      trim(test_netcdfinfo%u850name) .ne. 'u850') then
    write(*,*) "Error in test read_nlists (NetCDF): &netcdflist group"
    error stop
  endif

  if (phaseflag .ne. 'y' .or. trim(phasescheme) .ne. 'both' .or. &
      structflag .ne. 'y' .or. ikeflag .ne. 'y' .or. &
      trim(gmodname) .ne. 'tshd' .or. verb .ne. 3 .or. &
      shearflag .ne. 'y' .or. sstflag .ne. 'y' .or. genflag .ne. 'y' &
      .or. vortex_tilt_flag .ne. 'n') then
    write(*,*) "Error in test read_nlists (NetCDF): remaining groups"
    write(*,*) "phaseflag=", phaseflag, " structflag=", structflag &
               ," gmodname=", gmodname, " verb=", verb &
               ," shearflag=", shearflag, " sstflag=", sstflag &
               ," genflag=", genflag, " vortex_tilt_flag=" &
               ,vortex_tilt_flag
    error stop
  endif

  !----------------------------------------------
  ! part 2: the GRIB2 (Philippe/Rina) production namelist --
  ! vortex_tilt_flag is 'y' here, exercising the separate
  ! vortex-tilt-levels file read on unit 18
  call execute_command_line('cp ' // G2_NAMELIST_FILE // &
                             ' ./namelist.gettrk')
  open(unit=18, file=VTILT_LEVELS_FILE, status='old')

  call read_nlists(test_inp, test_trkrinfo, test_netcdfinfo &
                   ,test_num_vt_levs, test_vortex_tilt_levs, test_lunml)

  if (test_inp%model .ne. 1 .or. trim(test_inp%modtyp) .ne. 'global') &
  then
    write(*,*) "Error in test read_nlists (GRIB2): &datein group"
    error stop
  endif

  if (trim(atcfname) .ne. 'G2GF') then
    write(*,*) "Error in test read_nlists (GRIB2): &atcfinfo group"
    error stop
  endif

  if (trim(test_trkrinfo%gridtype) .ne. 'global' .or. &
      test_trkrinfo%gribver .ne. 2 .or. &
      test_trkrinfo%g2_mslp_parm_id .ne. 192 .or. &
      trim(test_trkrinfo%inp_data_type) .ne. 'grib') then
    write(*,*) "Error in test read_nlists (GRIB2): &trackerinfo group"
    error stop
  endif

  if (vortex_tilt_flag .ne. 'y' .or. trim(vortex_tilt_parm) .ne. 'zeta') &
  then
    write(*,*) "Error in test read_nlists (GRIB2): &vortextiltinfo group"
    error stop
  endif

  if (test_num_vt_levs .ne. 3 .or. &
      any(test_vortex_tilt_levs(1:3) .ne. (/850,700,500/))) then
    write(*,*) "Error in test read_nlists (GRIB2): vortex tilt levels"
    write(*,*) "Expected 3 levels (850,700,500) but got " &
               ,test_num_vt_levs, test_vortex_tilt_levs(1:3)
    error stop
  endif

  close(18)

end program test_read_nlists
