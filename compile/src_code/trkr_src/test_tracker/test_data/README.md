# Test data fixtures

## GRIB2 (test_getdata_grib.F90)
- `single_trimmed_test_grib.grib2` — a 120x120, 0.25-degree regional
  crop (lon 289.75-319.5E, lat 3.5-33.25N) of a global 76-level GRIB2
  analysis valid 2023-09-29 12Z, covering Hurricanes Philippe (17L)
  and Rina (18L). Extracted with:
  `wgrib2 g2gf.0p25deg.test76l.2023092912.f00000 -small_grib 289.7:319.7 3.4:33.4 single_trimmed_test_grib.grib2`
  Uses south-to-north scanning (unlike the original global file),
  which getdata_grib normalizes internally via need_to_flip_lats.
- `vitals.2023092912` — the matching tcvitals record for the full
  original file (4 storms; only 17L and 18L fall inside this crop's
  domain, and are the ones this test checks). Both storms' decoded
  local MSLP minima landed within ~1.5 mb and ~1 degree of the vitals
  position, matching the values independently confirmed against the
  original uncropped global file.

## NetCDF (test_getdata_netcdf.F90)
- `trimmed_test_file.nc` — a 264x264 crop (grid_xt 270.9-278.9,
  grid_yt 17.8-25.8, 2 time steps) of a real T-SHiELD C768r10n4_atl_new
  regional nest forecast, valid 2023-08-29 00Z, cropped around
  Hurricane Idalia. Extracted with:
  `ncks -d grid_xt,270.9,278.9 -d grid_yt,17.8,25.8 -d time,0,1
  -v grid_xt,grid_yt,time,PRMSL,u850,v850,u700,v700,u500,v500,u200,v200,UGRD10m,VGRD10m,h850,h700,h500,h200,TMP500_300
  tshldcombined.nc trimmed_test_file.nc`
- `vitals.2023082900` — the matching tcvitals record. Idalia's decoded
  local MSLP minimum landed within ~0.2 degrees of the vitals position
  (~992.6 mb vs. the vitals' 983 mb -- the ~9-10 mb gap is expected: this
  file is an independent, cold-started regional research forecast, not
  the same analysis product the vitals were derived from). See the file
  header comment in test_getdata_netcdf.F90 for more on this and on the
  file's other quirks (PRMSL is in mb, not Pa; no direct vorticity
  variables).

Note: the GRIB2 file is ~970 KB and the NetCDF file is ~9 MB.

## Namelists (test_read_nlists.F90)
- `g2namelist.gettrk` — the real production namelist for the
  Philippe/Rina GRIB2 run (matches `single_trimmed_test_grib.grib2`).
  Notably uses `g2_mslp_parm_id=192` (GFS/Eta reduction), which is why
  `test_getdata_grib.F90` uses that value rather than the standard
  reduction (`1`).
- `ncdfnamelist.gettrk` — the real production namelist for the Idalia
  NetCDF run (matches `trimmed_test_file.nc`). Confirms the variable
  name mapping used in `test_getdata_netcdf.F90` (`PRMSL`, `grid_xt`,
  `grid_yt`, `u850`, etc.) is exactly what production uses.
- `vtilt_levels.txt` — a small, synthetic (not real production) list
  of vertical levels, used only to exercise the vortex-tilt-levels
  file read that `read_nlists` triggers when `vortex_tilt_flag='y'`
  (as it is in `g2namelist.gettrk`). No real file of this kind is
  checked in yet.

Note: `read_nlists` hardcodes the filename `namelist.gettrk` in the
current working directory rather than taking one as an argument, so
`test_read_nlists.F90` copies each fixture there at runtime before
calling it.

## Lead times (test_read_fhours.F90)
- `leadtimes.txt` — a real production lead-times file (22 entries,
  6-hourly, 0h through 126h). Conventionally lives at
  `run/init_data/leadtimes.txt` and is placed at `fort.15` by the run
  script before `gettrk.x` runs, since `read_fhours` reads from that
  hardcoded unit with no OPEN statement of its own. Same workaround
  as `namelist.gettrk`: this test copies the fixture to a literal
  `fort.15` in the working directory at runtime.
