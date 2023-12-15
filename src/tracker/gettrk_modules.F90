!*************************************************************************!
!* MODULE def_vitals:
!*
!*  Data Descriptions:
!*
!*  tcv_center      :: Hurricane Center Acronym
!*  tcv_storm_id    :: Storm Identifier (03L, etc)
!*  tcv_storm_name  :: Storm name
!*  tcv_ymd         :: Date of observation (yyyymmdd)
!*  tcv_hhmm        :: Time of observation (UTC)
!*  tcv_lat         :: Storm Lat (*10), always > 0
!*  tcv_latns       :: 'N' or 'S'
!*  tcv_lon         :: Storm Lon (*10), always > 0
!*  tcv_lonew       :: 'E' or 'W'
!*  tcv_stdir       :: Storm motion vector (in degr)
!*  tcv_stspd       :: Spd of storm movement (m/s*10)
!*  tcv_pcen        :: Min central pressure (mb)
!*  tcv_penv        :: val outrmost closed isobar(mb)
!*  tcv_penvrad     :: rad outrmost closed isobar(km)
!*  tcv_vmax        :: max sfc wind speed (m/s)
!*  tcv_vmaxrad     :: rad of max sfc wind spd (km)
!*  tcv_r15ne       :: NE rad of 15 m/s winds (km)
!*  tcv_r15se       :: SE rad of 15 m/s winds (km)
!*  tcv_r15sw       :: SW rad of 15 m/s winds (km)
!*  tcv_r15nw       :: NW rad of 15 m/s winds (km)
!*  tcv_depth       :: Storm depth (S,M,D) X = missing
!*
!*************************************************************************!
module def_vitals

  type tcvcard         ! Define a new type for a TC Vitals card
    character(len=4) :: tcv_center
    character(len=4) :: tcv_storm_id
    character(len=9) :: tcv_storm_name
    integer          :: tcv_ymd
    integer          :: tcv_hhmm
    integer          :: tcv_lat
    character(len=1) :: tcv_latns
    integer          :: tcv_lon
    character(len=1) :: tcv_lonew
    integer          :: tcv_stdir
    integer          :: tcv_stspd
    integer          :: tcv_pcen
    integer          :: tcv_penv
    integer          :: tcv_penvrad
    integer          :: tcv_vmax
    integer          :: tcv_vmaxrad
    integer          :: tcv_r15ne
    integer          :: tcv_r15se
    integer          :: tcv_r15sw
    integer          :: tcv_r15nw
    character(len=1) :: tcv_depth
  end type tcvcard

  type (tcvcard),     save, allocatable :: storm(:)
    integer,          save, allocatable :: stormswitch(:)
    real,             save, allocatable :: slonfg(:,:), slatfg(:,:)
    character(len=3), save, allocatable :: stcvtype(:) ! FOF or TCV

end module def_vitals

!*************************************************************************!
!* MODULE gen_vitals:
!*
!*  Data Descriptions:
!*
!*  gv_gen_date    :: genesis date in yyyymmddhh
!*  gv_gen_fhr     :: genesis fcst hour (usually 0)
!*  gv_gen_lat     :: genesis lat (*10), always > 0
!*  gv_gen_latns   :: 'N' or 'S'
!*  gv_gen_lon     :: genesis lon (*10), always > 0
!*  gv_gen_lonew   :: 'W' or 'E'
!*  gv_gen_type    :: 'FOF'; or TC Vitals ATCF ID
!*  gv_obs_ymd     :: Date of observation (yyyymmdd)
!*  gv_obs_hhmm    :: Time of observation (UTC)
!*  gv_obs_lat     :: Storm Lat (*10), always > 0
!*  gv_obs_latns   :: 'N' or 'S'
!*  gv_obs_lon     :: Storm Lon (*10), always > 0
!*  gv_obs_lonew   :: 'E' or 'W'
!*  gv_stdir       :: Storm motion vector (in degr)
!*  gv_stspd       :: Spd of storm movement (m/s*10)
!*  gv_pcen        :: Min central pressure (mb)
!*  gv_penv        :: val outrmost closed isobar(mb)
!*  gv_penvrad     :: rad outrmost closed isobar(km)
!*  gv_vmax        :: max sfc wind speed (m/s)
!*  gv_vmaxrad     :: rad of max sfc wind spd (km)
!*  gv_r15ne       :: NE rad of 15 m/s winds (km)
!*  gv_r15se       :: SE rad of 15 m/s winds (km)
!*  gv_r15sw       :: SW rad of 15 m/s winds (km)
!*  gv_r15nw       :: NW rad of 15 m/s winds (km)
!*  gv_depth       :: Storm depth (S,M,D) X = missing
!*
!*************************************************************************!

module gen_vitals

  type gencard     ! Define a new type for a genesis vitals card
    integer          :: gv_gen_date
    integer          :: gv_gen_fhr
    integer          :: gv_gen_lat
    character(len=1) :: gv_gen_latns
    integer          :: gv_gen_lon
    character(len=1) :: gv_gen_lonew
    character(len=3) :: gv_gen_type
    integer          :: gv_obs_ymd
    integer          :: gv_obs_hhmm
    integer          :: gv_obs_lat
    character(len=1) :: gv_obs_latns
    integer          :: gv_obs_lon
    character(len=1) :: gv_obs_lonew
    integer          :: gv_stdir
    integer          :: gv_stspd
    integer          :: gv_pcen
    integer          :: gv_penv
    integer          :: gv_penvrad
    integer          :: gv_vmax
    integer          :: gv_vmaxrad
    integer          :: gv_r15ne
    integer          :: gv_r15se
    integer          :: gv_r15sw
    integer          :: gv_r15nw
    character(len=1) :: gv_depth
    end type gencard

    type (gencard), save, allocatable :: gstorm(:)

end module gen_vitals

!*************************************************************************!
!* MODULE inparms:
!*
!*  Data Descriptions:
!*
!*  bcc      :: First 2 chars of yy of date (century)
!*  byy      :: Beginning yy of date to search for 
!*  bmm      :: Beginning mm of date to search for 
!*  bdd      :: Beginning dd of date to search for 
!*  bhh      :: Beginning hh of date to search for 
!*  model    :: integer identifier for model data used
!*  modtyp   :: 'global' or 'regional'
!*  lt_units :: 'hours' or 'minutes' to indicate the units of lead times in grib files
!*  file_seq :: 'onebig' or 'multi' tells if grib data will be input as one big file or
!*               as individual files for each tau.
!*  nesttyp  :: Either "moveable" or "fixed"
!*
!*************************************************************************!

module inparms

  type datecard  ! Define a new type for the input namelist parms
    integer          :: bc
    integer          :: by
    integer          :: bmm
    integer          :: bdd
    integer          :: bh
    integer          :: model
    character(len=8) :: modty
    character(len=7) :: lt_units
    character(len=6) :: file_seq
    character(len=8) :: nesttyp 
  end type datecard

end module inparms

!*************************************************************************!
!* MODULE trkrparms:
!*
!*  Data Descriptions:
!*
!*  westbd                       :: Western boundary of search area
!*  eastbd                       :: Eastern boundary of search area
!*  northbd                      :: Northern boundary of search area
!*  southbd                      :: Southern boundary of search area
!*  type                         :: 'tracker', 'midlat' or 'tcgen'
!*  mslpthresh                   :: min mslp gradient to be maintained
!*  use_backup_mslp_grad_check   :: If a mslp fix could not be made, do you still want
!*                                  to do an mslp gradient check, but surrounding the multi-parm fix 
!*                                  position (since we don't have an mslp fix position to search around).
!*                                  Has a value of 'y' or 'n'.
!*  max_mslp_850                 :: Max allowable distance between the tracker-found center fixes for 
!*                                  mslp and 850 zeta.
!*  v850thresh                   :: minimum azimuthally-averaged 850 Vt to be maintained
!*  v850_qwc_thresh              :: min avg 850 Vt that must be maintained in *each* quadrant for the
!*                                  quadrant wind check routine that is done for storms close to the lateral
!*                                  boundary of fixed, regional grids.
!*  use_backup_850_vt_check      :: If an 850 mb wcirc fix could not be made, do you still want
!*                                  to do an 850 mb Vt wind check, but surrounding the multi-parm fix 
!*                                  position (since we don't have an 850 wcirc fix position to search around).
!*                                  Has a value of 'y' or 'n'.
!*  gridtype                     :: 'global' or 'regional'
!*  contint                      :: MSLP contour interval to be used for "midlat" or "tcgen" cases.
!*  want_oci                     :: Flag for whether to compute & write out roci for a trkrtype=tracker run
!*  out_vit                      :: Flag for whether to write out vitals
!*  use_land_mask                :: Flag used only in tcgen tracking that tells whether or not to use a 
!*                                  land-sea mask to disregard candidate lows that are over land. It does not
!*                                  filter out storms that have already formed at a previous time and then
!*                                  move over land... it only filters out for potential new candidate lows.
!*                                  Has a value of 'y' or 'n'.
!*  read_separate_land_mask_file :: Flag that says whether or not a separate file will
!*                                  be read in that contains the land-sea mask.
!*                                  Has a value of 'y' or 'n'.
!*  inp_data_type                :: Has a value of 'grib' or 'netcdf'
!*  gribver                      :: Indicates whether input data is 
!*                                  GRIBv1 or GRIBv2 (value of '1'  or '2')
!*  g2_jpdtn                     :: Indicates GRIB2 template to use when reading 
!*                                  (0 = deterministic fcst, 1 = ens fcst)
!*  g2_mslp_parm_id              :: This is the GRIB2 ID code for MSLP. For most models, it is set to 1
!*                                  (which is simply described as "Pressure Reduced to MSL").
!*                                  However, note that for GFS and GDAS, they include an additional MSLP 
!*                                  record that uses a different SLP reduction
!*                                  method that often shows lower pressures for cyclone centers.
!*                                  1 = standard MSLP reduction, 192 = GFS / Eta model reduction
!*  g1_mslp_parm_id              :: This is the GRIB1 ID code for MSLP. For most models, it is set to
!*                                  102 (which is simply described as "Pressure Reduced to MSL"). However,
!*                                  note that for GFS and GDAS, they include an additional MSLP record
!*                                  that uses a different SLP reduction method that often shows lower 
!*                                  pressures for cyclone centers.
!*                                  102 = standard MSLP reduction, 130 = GFS / Eta model reduction
!*  g1_sfcwind_lev_typ           :: This is the GRIB1 level code for near-sfc winds. At this time (2016),
!*                                  almost all models are reporting 10m winds here, but at least for GRIB1,
!*                                  there are some differences in how various Centers code that. Most use a level type
!*                                  (PDS Octet 10) of 105 and then an  actual value of the level in PDS
!*                                  Octets 11 & 12 as 10 (for 10m). However, for some reason, ECMWF
!*                                  uses a level type of 1 (which is supposed to be for ground surface),
!*                                  and ECMWF's actual value of the level is listed as 0 (UKMET does the same thing 
!*                                  as ECMWF). Use 105 for most models. Use 1 for ECMWF, UKMET,...others?
!*  g1_sfcwind_lev_val           :: This is the GRIB1 code for the actual value of the level of the
!*                                  near-sfc winds.  As above, most Centers list it as 10, but some list it as 0.
!*                                  Use 10 for most models. Use  1 for ECMWF, UKMET,...others?
!*  enable_timing                :: 0 = disable timing
!*
!*************************************************************************!

module trkrparms

  type trackstuff  ! Define a new type for various tracker parms
    real             :: westbd
    real             :: eastbd
    real             :: northbd
    real             :: southbd
    character(len=7) :: type    !CAITLYN - highly suggest changing this name
    real             :: mslpthresh 
    character(len=1) :: use_backup_mslp_grad_check 
    real             :: max_mslp_850
    real             :: v850thresh
    real             :: v850_qwc_thresh
    character(len=1) :: use_backup_850_vt_check
    character(len=8) :: gridtype
    real             :: contint
    logical          :: want_oci
    character(len=1) :: out_vit
    character(len=1) :: use_land_mask
    character(len=1) :: read_separate_land_mask_file
    character(len=6) :: inp_data_type
    integer          :: gribver
    integer          :: g2_jpdtn
    integer          :: g2_mslp_parm_id
    integer          :: g1_mslp_parm_id
    integer          :: g1_sfcwind_lev_typ
    integer          :: g1_sfcwind_lev_val
    integer          :: enable_timing
  end type trackstuff

end module trkrparms

!*************************************************************************!
!* MODULE contours:
!*
!*  Data Descriptions:
!*
!*  maxconts = 100           :: max # of cont. intervals
!*  contint_grid_bound_check :: Contour interval to be used for MSLP for the fixed grid
!*                              boundary check that I implemented in Sep 2020.
!*
!*  xmaxcont                 :: max contour level in a field
!*  xmincont                 :: min contour level in a field
!*  contvals(maxconts)       :: contour values in the field
!*  numcont                  :: # of contour levels in a field
!*
!*************************************************************************!

module contours

  integer, parameter :: maxconts = 100
  real, save         :: contint_grid_bound_check

  type cint_stuff
    real    :: xmaxcont
    real    :: xmincont
    real    :: contvals(maxconts)
    integer :: numcont
  end type cint_stuff

end module contours

!*************************************************************************!
!* MODULE atcf:
!*
!*  Data Descriptions:
!*
!*  atcfnum  :: ATCF ID of model (63 for GFDL...)
!*  atcfname :: ATCF Name of model (GFSO for GFS...)
!*  atcfymdh :: YMDH to be used as initial date for output ATCF forecast records.  Will
!*              be equal to initial run date for all models except SREF; SREF will have a
!*              start date artificially modified to be 3 hours earlier in order to not
!*              cause the NHC interpolator to burp.
!*  atcffreq :: frequency (in centahours) of output for atcfunix and certain other
!*              files.  Default: 600 (six-hourly)
!*************************************************************************!

module atcf

  integer          :: atcfnum
  character(len=4) :: atcfname
  integer          :: atcfymdh
  integer          :: atcffreq

end module atcf

!*************************************************************************!
!* MODULE gfilename_info:
!*
!*  Data Descriptions:
!*
!*  gmodname  :: Model ID for first part of GRIB file name ("gfdl","hwrf","hrs", etc)
!*  rundescr  :: This is descriptive and up to the developer (e.g., "6thdeg", "9km_run",
!*               "1.6km_run", "15km_ens_run_member_n13", etc)
!*  atcfdescr :: This is optional. If used, it should be something that identifies
!*               the particular storm, preferablyusing the atcf ID. For example, the
!*               GFDL model standard is to use something like "ike09l", or "two02e", etc.
!*
!*************************************************************************!

module gfilename_info

  character(len=4),  save :: gmodname
  character(len=40), save :: rundescr
  character(len=40), save :: atcfdescr

end module gfilename_info

!*************************************************************************!
!* MODULE phase:
!*
!*  Data Descriptions:
!*
!*  phaseflag   :: Will phase be determined (y/n)
!*  phasescheme :: What scheme to use:
!*                 cps  = Hart's cyclone phase space
!*                 vtt  = Vitart
!*                 both = Both cps and vtt are used
!*  wcore_depth :: The contour interval (in deg K) used in determining if a closed contour 
!*                 exists in the 300-500 mb T data, for use with the vtt scheme.
!*
!*************************************************************************!

module phase

  character(len=1), save :: phaseflag
  character(len=4), save :: phasescheme
  real,             save :: wcore_depth
end module phase

!*************************************************************************!
!* MODULE structure:
!*
!*  Data Descriptions:
!*
!*  structflag             :: Will structure be analyzed (y/n)?
!*  ikeflag                :: Will IKE & SDP be computed (y/n)?
!*  radii_pctile           :: The percentile that is used in the new (2022) wind radii scheme for
!*                            determining the representative wind value within each quadrant radial band.
!*  radii_free_pass_pctile :: If the percentile value of R34 in this band is at least this
!*                            great, then bypass all further checking and consider the R34 value to be at this
!*                            radius. You should make this something substantial, i.e., not just 95.0, but 
!*                            something like 67.0, meaning at least  1/3 of points in this band must > 34 kts
!*                            in order to "get the free pass".
!*  radii_width_thresh     :: The width (in km) that is used in the new (2022) wind radii scheme
!*                            for checking how wide -- or how robust -- an R34 value is.
!*
!*************************************************************************!

module structure

  character(len=1), save :: structflag
  character(len=1), save :: ikeflag
  real,             save :: radii_pctile
  real,             save :: radii_free_pass_pctile
  real,             save :: radii_width_thresh

end module structure

!*************************************************************************!
!* MODULE shear_diags:
!*
!*  Data Descriptions:
!*
!*  shearflag :: Will vertical shear be analyzed (y/n)?
!*
!*************************************************************************!

module shear_diags

  character(len=1), save :: shearflag
end module shear_diags

!*************************************************************************!
!* MODULE sst_diags:
!*
!*  Data Descriptions:
!*
!*  sstflag :: Will SST be analyzed (y/n)?
!*
!*************************************************************************!

module sst_diags

  character(len=1), save :: sstflag

end module sst_diags

!*************************************************************************!
!* MODULE genesis_diags:
!*
!*  Data Descriptions:
!*
!*  genflag                   :: Will genesis diags be analyzed and reported (y/n)?
!*  gen_read_rh_fields        :: Will RH fields be read in directly (y/n)?
!*  need_to_compute_rh_from_q :: Will spec. humidity (q) fields be read in to compute RH
!*                               if RH is not read in? (y/n)
!*  smoothe_mslp_for_gen_scan :: Did user request to smoothe the MSLP data before
!*                               scanning for new storms in the forecast (y/n)?
!*
!*************************************************************************!

module genesis_diags

  character(len=1), save :: genflag
  character(len=1), save :: gen_read_rh_fields
  character(len=1), save :: need_to_compute_rh_from_q
  character(len=1), save :: smoothe_mslp_for_gen_scan

end module genesis_diags

!*************************************************************************!
!* MODULE tracked_parms:
!*
!*  Data Descriptions:
!*
!*
!*************************************************************************!

module tracked_parms

  real,    save, allocatable  ::  zeta(:,:,:)
  real,    save, allocatable  ::  u(:,:,:)
  real,    save, allocatable  ::  v(:,:,:)
  real,    save, allocatable  ::  hgt(:,:,:)
  real,    save, allocatable  ::  slp(:,:)
  real,    save, allocatable  ::  tmean(:,:)
  real,    save, allocatable  ::  cpshgt(:,:,:)
  real,    save, allocatable  ::  thick(:,:,:)
  real,    save, allocatable  ::  lsmask(:,:)
  real,    save, allocatable  ::  sst(:,:)
  real,    save, allocatable  ::  q850(:,:)
  real,    save, allocatable  ::  rh(:,:,:)
  real,    save, allocatable  ::  spfh(:,:,:)
  real,    save, allocatable  ::  temperature(:,:,:)
  real,    save, allocatable  ::  omega500(:,:)
  real,    save, allocatable  ::  wcirc_grid(:,:,:)
  integer, save, allocatable  :: ifhours(:)  
  integer, save, allocatable  :: iftotalmins(:)
  integer, save, allocatable  :: ifclockmins(:)
  integer, save, allocatable  :: ltix(:)
  real,    save, allocatable  :: fhreal(:)

end module tracked_parms

!*************************************************************************!
!* MODULE tracking_parm_prefs:
!*
!*  Data Descriptions:
!*
!*
!*************************************************************************!

module tracking_parm_prefs

  character(len=1), save :: user_wants_to_track_zeta850
  character(len=1), save :: user_wants_to_track_zeta700
  character(len=1), save :: user_wants_to_track_wcirc850
  character(len=1), save :: user_wants_to_track_wcirc700
  character(len=1), save :: user_wants_to_track_gph850
  character(len=1), save :: user_wants_to_track_gph700
  character(len=1), save :: user_wants_to_track_mslp
  character(len=1), save :: user_wants_to_track_wcircsfc
  character(len=1), save :: user_wants_to_track_zetasfc
  character(len=1), save :: user_wants_to_track_thick500850
  character(len=1), save :: user_wants_to_track_thick200500
  character(len=1), save :: user_wants_to_track_thick200850

end module tracking_parm_prefs

!*************************************************************************!
!* MODULE radii: For Barnes smoothing of parameters for tracking, e-folding
!*        radius = retrk (km), influence radius = ritrk (km). Max radius
!*        for searching for the max vorticity = rads (km).  There is an
!*        important distinction between rads and ritrk.  rads is used to
!*        determine the maximum distance from the guess position that
!*        we'll allow points to be in order to be considered as a
!*        candidate location for the updated fix position.  On the other
!*        hand, ritrk is used once you're doing the barnes analysis on
!*        data for that candidate location, so that if data is not within
!*        distance ritrk of the candidate location, we ignore it.  Also, 
!*        for use in find_maxmin, nhalf = the number of times to halve the
!*        spacing of the search grid.  Note that different values are used
!*        for the magnitude of the wind than for other parameters; this is
!*        so that the search area is restricted in order to avoid a 
!*        problem of the program finding one wind minimum near the center
!*        and another one out near the storm's edge.
!*
!*  Data Descriptions:
!*
!*  redlm and ridlm = the e-folding radius (km) and influence radius
!*  (km) for Barnes analysis of u,v for updating first guess lat,lon
!*  for search.  dlm = deep layer mean.
!*
!*************************************************************************!

module radii

  real, parameter :: retrk_most     = 75.0, retrk_vmag   = 60.0
  real, parameter :: ritrk_most     = 150.0, ritrk_vmag  = 120.0
  real, parameter :: rads_most      = 300.0, rads_vmag   = 120.0
  real, parameter :: retrk_coarse   = 150.0, retrk_hres  = 60.0
  real, parameter :: rads_fine      = 200.0, rads_hres   = 150.0
  real, parameter :: ritrk_coarse   = 300.0, rads_coarse = 350.0
  real, parameter :: rads_wind_circ = 250.0
  real, parameter :: ri_wind_circ   = 150.0
  real, parameter :: redlm           = 500.0, ridlm      = 1000.0
  real, parameter :: re_genscan      = 50.0
  real, parameter :: ri_genscan      = 100.0

end module radii

!*************************************************************************!
!* MODULE grid_bounds:
!*
!*  Data Descriptions:
!*
!*  glatmin, glatmax, glonmin, glonmax :: These define the boundaries of the input data grid
!*  glat(:), glon(:)                   :: Will be filled with lat/lon values for each pt on input grid
!*************************************************************************!

module grid_bounds

  real, save              ::  glatmin, glatmax, glonmin, glonmax
  real, save, allocatable ::  glat(:), glon(:)

end module grid_bounds

!*************************************************************************!
!* MODULE error_parms:
!*
!*  Data Descriptions:
!*
!*  err_gfs_init = 275.0 :: init errmax for gfs, mrf, and gdas
!*  err_reg_init = 300.0 :: init errmax for others
!*  err_ecm_max = 330.0  :: errmax for ecmwf
!*  err_reg_max = 225.0  :: errmax for others for remaining fcst times
!*  maxspeed_tc = 60     :: max speed of storm movement for tracker or tcgen cases
!*  maxspeed_ml = 80     :: max speed of storm movement for midlat cases
!*  stermn = 0.1         :: Min Std dev for trk errors
!*  uverrmax = 225.0     :: For use in get_uv_guess
!*
!*************************************************************************!

module error_parms

  real, parameter :: err_gfs_init = 275.0
  real, parameter :: err_reg_init = 300.0
  real, parameter :: err_ecm_max  = 330.0
  real, parameter :: err_reg_max  = 225.0
  real, parameter :: maxspeed_tc  = 60
  real, parameter :: maxspeed_ml  = 80
  real, parameter :: errpgro  = 1.25, errpmax = 485.0
  real, parameter :: stermn   = 0.1
  real, parameter :: uverrmax = 225.0

end module error_parms

!*************************************************************************!
!* MODULE set_max_parms:
!*
!*  Data Descriptions:
!*
!*  maxstorm_tc = 15   :: max # of storms pgm can handle, for tc tracker case
!*  maxstorm_mg = 2000 :: max # of storms pgm can handle, for midlat or tcgen case
!*  maxtime = 500      :: max # of fcst times pgm 
!*  maxtp = 14         :: max # of tracked parms 
!*  maxmodel = 20      :: max # of models currently available
!*  max_ike_cats = 6   :: max # of IKE categories
!*  interval_fhr       :: # of hrs between fcst times
!*  maxcenters = 150   :: max # of max/min centers to be tracked.
!*
!*************************************************************************!

module set_max_parms

  integer, parameter :: maxstorm_tc = 15 
  integer, parameter :: maxstorm_mg = 2000
  integer, parameter :: maxtime  = 500
  integer, parameter :: maxtp    = 14
  integer, parameter :: maxmodel = 20
  integer, parameter :: max_ike_cats = 6
  integer, save      :: interval_fhr
  integer, parameter :: maxcenters   = 150
end module set_max_parms

!*************************************************************************!
!* MODULE level_parms:
!*
!*  Data Descriptions:
!*
!*  nlevs = 5      :: max # of vert levs to be read for u & v
!*  nlevg = 3      :: # of vert levs to be used for figuring next guess position
!*  nlevhgt = 4    :: # tracked levs for hgt
!*  nlevgrzeta = 2 :: # tracked levs for gridded zeta values 
!*  nlevzeta = 3   :: # tracked levs for zeta
!*  nlevthick = 3  :: # tracked levs for thickness
!*  nlevmoist = 7  :: # tracked levs for moisture & temp for genesis applications (q,rh,temp).
!*  levsfc = 5     :: array position of sfc winds.
!*  nlev850 = 1    :: array position in u and v
!*  nlev700 = 2    :: arrays for 850, 700 & 500
!*  nlev500 = 3    :: winds, used in get_uv_center.
!* nlev200 = 4     :: 200 mb winds are in array position #4 as of 2021.
!* wgts(nlevg)     :: Wghts for use in get_next_ges
!*************************************************************************!

module level_parms

  integer, parameter :: nlevs   = 5
  integer, parameter :: nlevg   = 3
  integer, parameter :: nlevhgt = 4
  integer, parameter :: nlevgrzeta = 2
  integer, parameter :: nlevzeta   = 3
  integer, parameter :: nlevthick  = 3
  integer, parameter :: nlevmoist  = 7
  integer, parameter :: levsfc  = 5
  integer, parameter :: nlev850 = 1
  integer, parameter :: nlev700 = 2
  integer, parameter :: nlev500 = 3
  integer, parameter :: nlev200 = 4
  real, save         :: wgts(nlevg)

  data wgts /0.25, 0.50, 0.25/    ! 850, 700 & 500 mb wgts

end module level_parms

!*************************************************************************!
!* MODULE read_parms:
!*
!*  Data Descriptions:
!*
!*  nreadparms = 20 ! max # of parameters to read in for standard parms
!*  nreadcpsparms = 13 ! max # of parameters to read in for Hart's CPS
!*  nreadgenparms = 23 ! max # of parameters to read in for genesis parms
!*
!*************************************************************************!

module read_parms

  integer, parameter :: nreadparms    = 20
  integer, parameter :: nreadcpsparms = 13
  integer, parameter :: nreadgenparms = 23

end module read_parms

!*************************************************************************!
!* MODULE triag_vals:
!*
!*  Data Descriptions:
!*
!*  dtk = 111.1949    :: Dist (km) over 1 deg lat using erad = 6371.0e+3
!*  erad = 6371.0e+3  :: Earth's radius (m)
!*  ecircum = 40030.2 :: Earth's circumference (km) using erad = 6371.e3
!*
!*************************************************************************!

module trig_vals

  real, save :: pi, dtr
  real, save :: dtk     = 111.1949
  real, save :: erad    = 6371.0e+3
  real, save :: ecircum = 40030.2
  real, save :: omega   = 7.292e-5

end module trig_vals

!*************************************************************************!
!* MODULE verbose_output
!*
!*  Data Descriptions:
!*
!*  verb    :: Level of detail printed: 0 = No output, 1 = Error messages only, 2 = , 3 = All
!*  verb_g2 :: Level of detail printed, specifically for GRIB2 print  messages only.  Use if trying to 
!*             diagnose GRIB2 I/O problems: 0 = No output,  1 = Print output
!*
!*************************************************************************!

module verbose_output

  integer, save :: verb
  integer, save :: verb_g2

end module verbose_output

!*************************************************************************!
!* MODULE waitfor_parms:
!*
!*  Data Descriptions:
!*
!*  use_waitfor          :: y or n, for waiting for input files
!*  wait_min_age         :: min age (in seconds), time since last file modification
!*  wait_min_size        :: minimum file size in bytes
!*  wait_max_wait        :: max total wait time in seconds 
!*  wait_sleeptime       :: number of seconds to wait between checks
!*  use_per_fcst_command :: enable per_fcst_command
!*  per_fcst_command     :: command to run every forecast time
!*
!*************************************************************************!

module waitfor_parms

  character(len=1)           :: use_waitfor
  integer(kind=8)            :: wait_min_age
  integer(kind=8)            :: wait_min_size
  integer(kind=8)            :: wait_max_wait
  integer(kind=8)            :: wait_sleeptime
  integer, parameter         :: pfc_cmd_len = 800
  character(len=1)           :: use_per_fcst_command
  character(len=pfc_cmd_len) :: per_fcst_command

end module waitfor_parms

!*************************************************************************!
!* MODULE netcdf_parms:
!*
!*  Data Descriptions:
!*
!*  num_netcdf_vars        :: Total *possible* number of input NetCDF variables, including those
!*                         :: that are included in the input file and those that are not.
!*  netcdf_filename        :: character file name for the NetCDF file.
!*  netcdf_lsmask_filename :: character file name for the optional, separate 
!*                            NetCDF file if the user has indicated this with the
!*                            read_separate_land_mask_file flag. 
!*  rv850name              :: 850 mb rel vort
!*  v700name               :: 700 mb rel vort
!*  u850name               :: 850 mb u-comp
!*  v850name               :: 850 mb v-comp
!*  u700name               :: 700 mb u-comp
!*  v700name               :: 700 mb v-comp
!*  z850name               :: 850 mb gp height
!*  z700name               :: 700 mb gp height
!*  mslpname               :: mslp
!*  usfcname               :: near-sfc u-comp
!*  vsfcname               :: near-sfc v-comp
!*  u500name               :: 500 mb u-comp
!*  v500name               :: 500 mb v-comp
!*  tmean_300_500_name     :: Mean Temp in 300-500 mb layer
!*  z500name               :: 500 mb gp height
!*  z200name               :: 200 mb gp height
!*  lmaskname              :: Land mask
!*  z900name               :: 900 mb gp height
!*  z800name               :: 800 mb gp height
!*  z750name               :: 750 mb gp height
!*  z650name               :: 650 mb gp height
!*  z600name               :: 600 mb gp height
!*  z550name               :: 550 mb gp height
!*  z450name               :: 450 mb gp height
!*  z400name               :: 400 mb gp height
!*  z350name               :: 350 mb gp height
!*  z300name               :: 300 mb gp height
!*  time_name              :: Name of time variable, usually "time"
!*  lon_name               :: longitudes
!*  lat_name               :: latitudes
!*  time_units             :: "days" or "hours"
!*  u200name               :: 200 mb u-comp
!*  v200name               :: 200 mb v-comp
!*  sstname                :: SST
!*  q850name               :: 850 mb specific humidity
!*  rh1000name             :: 1000 mb RH
!*  rh925name              :: 925 mb RH
!*  rh800name              :: 800 mb RH
!*  rh750name              :: 750 mb RH
!*  rh700name              :: 700 mb RH
!*  rh650name              :: 650 mb RH
!*  rh600name              :: 600 mb RH
!*  spfh1000name           :: 1000 mb specific humidity
!*  spfh925name            :: 925 mb specific humidity
!*  spfh800name            :: 800 mb specific humidity
!*  spfh750name            :: 750 mb specific humidity
!*  spfh700name            :: 700 mb specific humidity
!*  spfh650name            :: 650 mb specific humidity
!*  spfh600name            :: 600 mb specific humidity
!*  temp1000name           :: 1000 mb temperature
!*  temp925name            :: 925 mb temperature
!*  temp800name            :: 800 mb temperature
!*  temp750name            :: 750 mb temperature
!*  temp700name            :: 700 mb temperature
!*  temp650name            :: 650 mb temperature
!*  temp600name            :: 600 mb temperature
!*  omega500name           :: 500 mb omega
!*
!*************************************************************************!

module netcdf_parms

  type netcdfstuff  ! Define a new type for NetCDF information
                    ! All of these "name" variables are the names for the 
                    ! different variables in the NetCDF file.
    integer            :: num_netcdf_vars
    character(len=180) :: netcdf_filename
    character(len=180) :: netcdf_lsmask_filename
    character(len=30)  :: rv850name
    character(len=30)  :: rv700name
    character(len=30)  :: u850name
    character(len=30)  :: v850name
    character(len=30)  :: u700name
    character(len=30)  :: v700name
    character(len=30)  :: z850name
    character(len=30)  :: z700name
    character(len=30)  :: mslpname
    character(len=30)  :: usfcname
    character(len=30)  :: vsfcname
    character(len=30)  :: u500name
    character(len=30)  :: v500name
    character(len=30)  :: tmean_300_500_name
    character(len=30)  :: z500name
    character(len=30)  :: z200name
    character(len=30)  :: lmaskname
    character(len=30)  :: z900name
    character(len=30)  :: z800name
    character(len=30)  :: z750name
    character(len=30)  :: z650name
    character(len=30)  :: z600name
    character(len=30)  :: z550name
    character(len=30)  :: z450name
    character(len=30)  :: z400name
    character(len=30)  :: z350name
    character(len=30)  :: z300name
    character(len=30)  :: time_name
    character(len=30)  :: lon_name
    character(len=30)  :: lat_name
    character(len=30)  :: time_units
    character(len=30)  :: u200name
    character(len=30)  :: v200name
    character(len=30)  :: sstname
    character(len=30)  :: q850name
    character(len=30)  :: rh1000name
    character(len=30)  :: rh925name
    character(len=30)  :: rh800name
    character(len=30)  :: rh750name
    character(len=30)  :: rh700name
    character(len=30)  :: rh650name
    character(len=30)  :: rh600name
    character(len=30)  :: spfh1000name
    character(len=30)  :: spfh925name
    character(len=30)  :: spfh800name
    character(len=30)  :: spfh750name
    character(len=30)  :: spfh700name
    character(len=30)  :: spfh650name
    character(len=30)  :: spfh600name
    character(len=30)  :: temp1000name
    character(len=30)  :: temp925name
    character(len=30)  :: temp800name
    character(len=30)  :: temp750name
    character(len=30)  :: temp700name
    character(len=30)  :: temp650name
    character(len=30)  :: temp600name
    character(len=30)  :: omega500name
  end type netcdfstuff

  real,    save, allocatable :: netcdf_file_time_values(:)
  integer, save, allocatable :: nctotalmins(:)

end module netcdf_parms