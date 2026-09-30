!************************************************
!* This is a REGRESSION test, not a pure unit test (see the header
!* comment in test_getdata_grib.F90 for what that distinction means).
!* It runs getgridinfo_netcdf and getdata_netcdf against a real,
!* trimmed T-SHiELD regional forecast file (test_data/
!* trimmed_test_file.nc, a 264x264 crop around Hurricane Idalia from
!* the 2023-08-29 00Z C768r10n4_atl_new nest, hour 0) and checks the
!* output against values captured once, by hand, and cross-checked
!* against the matching vitals.2023082900 storm position for Idalia.
!*
!* Two things about this fixture are worth calling out explicitly,
!* since they are file-specific quirks rather than general behavior:
!*  - PRMSL in this file is in mb (not Pa, unlike GRIB2's MSLP field).
!*    getdata_netcdf does not convert units at read time, so the
!*    decoded slp array here is genuinely mb-scale (~950-1020), and
!*    the expected values below reflect that.
!*  - This file has no direct vorticity variables (rv850name/
!*    rv700name are set to 'X' below to skip them), so this test does
!*    NOT exercise a vorticity read -- see test_rvcal.F90 for that.
!*  - Local MSLP minimum vs. vitals differs by ~9-10 mb here, larger
!*    than the ~1-2 mb agreement seen in test_getdata_grib.F90. That
!*    is expected: this file is an independent, cold-started regional
!*    research forecast (T-SHiELD), not the same analysis product the
!*    vitals were derived from, so the tolerance below is looser and
!*    the position match (not the exact pressure) is the stronger
!*    signal that this is genuinely the same storm.
!*
!* Requires linking against the real NCEPLIBS stack, same as
!* test_getdata_grib.F90 (see that file's header for why).
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_getdata_netcdf

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
  use netcdf_parms
  use read_parms

  implicit none

#ifndef TEST_DATA_FILE
#define TEST_DATA_FILE "test_data/trimmed_test_file.nc"
#endif

  type(trackstuff) :: test_trkrinfo
  type(datecard)   :: test_inp
  type(netcdfstuff) :: test_netcdfinfo

  integer :: test_ncfile_id, test_imax, test_jmax, test_iggret
  integer :: test_ncfile_tmax, test_irnhret, test_ifhmax
  real :: test_dx, test_dy
  logical(1) :: test_flip_lats, test_flip_lons
  character(len=1) :: test_ncfile_has_hour0
  character(len=180) :: test_nc_filename

  logical(1), allocatable :: test_readflag(:), test_readgenflag(:)
  logical(1), allocatable :: test_valid_pt(:,:)
  integer :: test_vortex_tilt_levs(vortex_max_levs), test_num_vt_levs

  logical(1) :: expected_readflag(20)

  verb = 0

  test_trkrinfo%gridtype = 'regional'
  test_trkrinfo%type = 'tracker'
  test_trkrinfo%use_land_mask = 'n'
  test_trkrinfo%read_separate_land_mask_file = 'n'
  test_trkrinfo%enable_timing = 0

  test_inp%lt_units = 'hours'
  test_inp%modtyp = 'regional'

  test_netcdfinfo%lon_name = 'grid_xt'
  test_netcdfinfo%lat_name = 'grid_yt'
  test_netcdfinfo%time_name = 'time'
  test_netcdfinfo%time_units = 'hours'
  test_netcdfinfo%mslpname = 'PRMSL'
  test_netcdfinfo%u850name = 'u850'
  test_netcdfinfo%v850name = 'v850'
  test_netcdfinfo%u700name = 'u700'
  test_netcdfinfo%v700name = 'v700'
  test_netcdfinfo%u500name = 'u500'
  test_netcdfinfo%v500name = 'v500'
  test_netcdfinfo%u200name = 'u200'
  test_netcdfinfo%v200name = 'v200'
  test_netcdfinfo%usfcname = 'UGRD10m'
  test_netcdfinfo%vsfcname = 'VGRD10m'
  test_netcdfinfo%z850name = 'h850'
  test_netcdfinfo%z700name = 'h700'
  test_netcdfinfo%z500name = 'h500'
  test_netcdfinfo%z200name = 'h200'
  test_netcdfinfo%tmean_300_500_name = 'TMP500_300'
  test_netcdfinfo%rv850name = 'X'    ! not present in this file
  test_netcdfinfo%rv700name = 'X'    ! not present in this file
  test_netcdfinfo%lmaskname = 'X'    ! not present in this file
  test_netcdfinfo%sstname = 'X'      ! not present in this file

  ! skip every optional diagnostic block, same as test_getdata_grib.F90
  phaseflag = 'n'
  sstflag = 'n'
  genflag = 'n'
  vortex_tilt_flag = 'n'
  test_num_vt_levs = 0
  test_vortex_tilt_levs = 0

  test_nc_filename = TEST_DATA_FILE

  ! must be allocated/populated BEFORE read_netcdf_hours, which
  ! internally matches iftotalmins(1..ifhmax) against the file's own
  ! time values
  allocate(ifhours(1), iftotalmins(1), ifclockmins(1))
  ifhours(1) = 0
  iftotalmins(1) = 0
  ifclockmins(1) = 0

  call open_ncfile(test_nc_filename, test_ncfile_id)

  test_ifhmax = 1
  call read_netcdf_hours(test_nc_filename, test_ncfile_id &
                         ,test_ncfile_tmax, test_ifhmax &
                         ,test_ncfile_has_hour0, test_netcdfinfo &
                         ,test_irnhret)

  if (test_irnhret /= 0 .or. test_ncfile_tmax /= 2) then
    write(*,*) "Error in test_getdata_netcdf: read_netcdf_hours"
    write(*,*) "irnhret=", test_irnhret, " ncfile_tmax=", test_ncfile_tmax
    error stop
  endif

  !----------------------------------------------
  ! part 1: getgridinfo_netcdf should correctly identify this as a
  ! 264x264, ~0.0303-degree (~3km) regional crop
  call getgridinfo_netcdf(test_ncfile_id, test_imax, test_jmax &
                          ,test_dx, test_dy, test_trkrinfo &
                          ,test_flip_lats, test_flip_lons, test_inp &
                          ,test_netcdfinfo, test_iggret)

  if (test_iggret /= 0) then
    write(*,*) "Error in test_getdata_netcdf: getgridinfo_netcdf iggret=" &
               ,test_iggret
    error stop
  endif

  if (test_imax .ne. 264 .or. test_jmax .ne. 264) then
    write(*,*) "Error in test_getdata_netcdf: unexpected grid size"
    write(*,*) "Expected 264x264 but got ", test_imax, test_jmax
    error stop
  endif

  if (abs(test_dx - 0.0303) > 1.0e-3 .or. abs(test_dy - 0.0303) > 1.0e-3) then
    write(*,*) "Error in test_getdata_netcdf: unexpected grid spacing"
    write(*,*) "Expected dx=dy=~0.0303 but got ", test_dx, test_dy
    error stop
  endif

  !----------------------------------------------
  ! part 2: getdata_netcdf should successfully decode 16 of the 20
  ! core fields -- everything except the 2 vorticity slots (not in
  ! this file), the land mask (not in this file), and SST (skipped
  ! since sstflag='n')
  allocate(zeta(test_imax,test_jmax,nlevzeta))
  allocate(u(test_imax,test_jmax,nlevs))
  allocate(v(test_imax,test_jmax,nlevs))
  allocate(hgt(test_imax,test_jmax,nlevhgt))
  allocate(slp(test_imax,test_jmax))
  allocate(tmean(test_imax,test_jmax))
  allocate(lsmask(test_imax,test_jmax))
  allocate(test_valid_pt(test_imax,test_jmax))
  allocate(test_readflag(nreadparms), test_readgenflag(nreadgenparms))

  ! getdata_netcdf does not initialize readflag/readgenflag itself --
  ! the real "tracker" subroutine does this immediately before calling
  ! it, and skipping it here means the result depends on leftover
  ! stack/heap content rather than the subroutine's actual behavior
  test_readflag = .false.
  test_readgenflag = .false.

  call getdata_netcdf(test_ncfile_id, 0, test_readflag &
                      ,test_readgenflag, test_valid_pt, test_imax &
                      ,test_jmax, 1, test_flip_lats, test_flip_lons &
                      ,test_ncfile_tmax, test_netcdfinfo, test_trkrinfo &
                      ,test_num_vt_levs)

  expected_readflag = (/.false.,.false.,.true.,.true.,.true.,.true. &
                       ,.true.,.true.,.true.,.true.,.true.,.true. &
                       ,.true.,.true.,.true.,.true.,.false.,.true. &
                       ,.true.,.false./)

  if (any(test_readflag .neqv. expected_readflag)) then
    write(*,*) "Error in test_getdata_netcdf: readflag pattern changed"
    write(*,*) "Expected ", expected_readflag
    write(*,*) "Got      ", test_readflag
    error stop
  endif

  if (.not. all(test_valid_pt)) then
    write(*,*) "Error in test_getdata_netcdf: expected a fully valid " &
               ,"crop (no missing data within this trimmed domain)"
    error stop
  endif

  ! PRMSL in this file is mb, not Pa -- sanity-check the decoded range
  ! is mb-scale, not accidentally Pa-scale
  if (minval(slp) < 500.0 .or. maxval(slp) > 1200.0) then
    write(*,*) "Error in test_getdata_netcdf: slp out of mb-scale range"
    write(*,*) "min/max = ", minval(slp), maxval(slp)
    error stop
  endif

  !----------------------------------------------
  ! part 3: cross-check the decoded MSLP field against Hurricane
  ! Idalia's position in vitals.2023082900 for this same run. See the
  ! file header comment for why the pressure tolerance here is looser
  ! than in test_getdata_grib.F90.
  call check_local_min('10L IDALIA', 21.8, 274.9, 992.6, 21.71, 274.71)

  call baclose(test_ncfile_id, test_iggret)

contains

  subroutine check_local_min(label, slat, slon, expected_mb &
                             ,expected_lat, expected_lon)
    character(*), intent(in) :: label
    real, intent(in) :: slat, slon, expected_mb, expected_lat, expected_lon
    integer :: ii, jj, ilo, ihi, jlo, jhi, targ_i, targ_j
    real :: localmin, glat_, glon_
    real, parameter :: loc_tol = 0.3     ! degrees
    real, parameter :: mb_tol = 2.0      ! see file header: this file is
                                          ! an independent forecast, not
                                          ! the vitals' source analysis

    targ_i = nint((slon - glonmin) / test_dx)
    targ_j = nint((glatmax - slat) / test_dy)
    ilo = max(0, targ_i - 30); ihi = min(test_imax-1, targ_i + 30)
    jlo = max(0, targ_j - 30); jhi = min(test_jmax-1, targ_j + 30)

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

    if (abs(localmin - expected_mb) > mb_tol .or. &
        abs(glat_ - expected_lat) > loc_tol .or. &
        abs(glon_ - expected_lon) > loc_tol) then
      write(*,*) "Error in test_getdata_netcdf: local MSLP min near " &
                 ,label, " storm changed"
      write(*,*) "Expected ", expected_mb, " mb at (", expected_lat &
                 ,",", expected_lon, ")"
      write(*,*) "Got      ", localmin, " mb at (", glat_, ",", glon_, ")"
      error stop
    endif
  end subroutine check_local_min

end program test_getdata_netcdf
