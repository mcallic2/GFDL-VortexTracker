#!/bin/bash --login
#PJM -L node=1:noncont
#PJM -L elapse=1:00:00
#PJM -L rscgrp=small
#PJM --mpi "proc=1"
#PJM -j
#PJM -S
#PJM -o log.run_tracker

# USER - all sbatch commands above have to be editted according to
# which rdhpc system is being used

#--------------------------------------------------------------
# Script written by Tim Marchok --> timothy.marchok@noaa.gov
# Edited by Caitlyn McAllister  --> caitlyn.mcallister@noaa.gov
#--------------------------------------------------------------

export PS4=' + TRAKCER SET UP line $LINENO: '

ulimit -c unlimited

export LD_LIBRARY_PATH=/package/fx1000/operlib/lib/:/opt/FJSVxtclanga/tcsds-1.2.33/lib64:$LD_LIBRARY_PATH

#-----------------------------------------------------------
# Set critical initial variables and directories
#-----------------------------------------------------------

export cmodel=gfs
export vit_hr_incr=6
atcfname="gfs" # caitlyn, ting has these set line 149
atcfout="gfs"  # set on line 150

export fcstlen=126
export fcsthrs=' 000 006 012 018 024 030 036 042 048 054 060 066 072 078
                 084 090 096 102 108 114 120 126  99  99   99
                  99  99  99  99  99  99  99  99  99  99   99
                  99  99  99  99  99  99  99  99  99  99
                  99  99  99  99  99  99  99  99  99  99
                  99  99  99  99  99  99  99  99  99'

export curymdh=2023092912 # this doesn't match the date of his filename

#
export scc=` echo $curymdh | cut -c1-2`
export syy=` echo $curymdh | cut -c3-4`
export smm=` echo $curymdh | cut -c5-6`
export sdd=` echo $curymdh | cut -c7-8`
export shh=` echo $curymdh | cut -c9-10`

# USER - add paths to location of repository (i.e. home=) and location of workroot
# no other paths should need to be changed
# do not add spaces next to = (ex. home=/home/...)
export home=/nwpr/fdda/p143/TOOLS/GFDL-VortexTracker_CWAHPC
export workroot=/nwpr/fdda/p143/TOOLS/WRF_VTracker
export rundir=${home}/run
export srcroot=${home}/code/src
export modulesetup=${home}/code/modulefile-setup
export execdir=${home}/code/exec
export tcvit_date=${home}/files/bin/tcvit_date
export NDATE=${home}/files/bin/ndate.x


# this next variable specifies the name of a seperate land-sea mask file
# that can be used in case the main input netcdf file does not contain its own
# land-sea mask record
export ncdf_ls_mask_filename=

export gix=grbindex
export gribver=2 # 1 = grib1/ecmwf, 2 = grib2/gfs
export basin=al  # is this the correct basin?
# USER - please choose "tracker" or "tcgen"
export trkrtype=tracker


wdir=${workroot}/${curymdh}
if [ ! -d ${wdir} ]; then mkdir -p ${wdir}; fi

set +x
echo " "
echo "+++ Top of run_tshd_ez.sh, time= `date`"
echo "    curymdh=    $curymdh"
echo "    trkrtype=   $trkrtype"
echo "    gribver=    ${gribver}"
echo "    wdir=       ${wdir}"
echo " "
set -x

set -x

export PDY=`     echo $curymdh | cut -c1-8`
export yyyy=`    echo $curymdh | cut -c1-4`
export cyc=`     echo $curymdh | cut -c9-10`
export ymdh=${PDY}${cyc}

export wdir=${workroot}/${PDY}${cyc}
export DATA=${workroot}/${PDY}${cyc}

# figure out if the wdir/DATA path might break, if so use these
export wdir=${workroot}/${PDY}${cyc}/${cmodel}
export DATA=${workroot}/${PDY}${cyc}/${cmodel}

if [ ! -d ${workroot} ]; then mkdir -p ${workroot}; fi
if [ ! -d ${wdir} ];     then mkdir -p ${pdir}; fi

cd $wdir

#--------------------------------------------------------------------------------
# Check the TC Vitals to see if there are any observed storms for the input ymdh.
#--------------------------------------------------------------------------------

tcvit_logfile=${rundir}/tcvit_logfile.${yyyy}.txt

# caitlyn, do i add the if statement?

${tcvit_date} ${curymdh} | egrep "JTWC|NHC"           | \
grep -v TEST | awk 'substr($0,6,1) !~ /8/ {print $0}'   \
>${wdir}/vitals.${curymdh}

num_storms=` cat ${wdir}/vitals.${curymdh} | wc -l`

# A quirk of the I/O for the tracker program is that the
# vitals file must exist, even if it's empty (i.e., there
# are no storms).  So this next IF statement checks to see if there
# are any storms for the current YMDH.  If there are, then we simply
# continue after catting the vitals file out for display in the
# output file.  If storms do not exist, then do a touch to just
# create an empty file.

if [ ${num_storms} -gt 0 ]; then
  set +x
  echo " "
  echo "+++ ${num_storms} Observed storms exist for ${curymdh}: " | tee -a  ${tcvit_logfile}
  cat ${wdir}/vitals.${curymdh}
  cat ${wdir}/vitals.${curymdh} >> ${tcvit_logfile}
  echo " "
  set -x
else
  touch ${wdir}/vitals.${curymdh}
fi

#------------------------------------------------------------------------
# Set variables & parameters for the input namelist for T-SHiELD...
#------------------------------------------------------------------------

#export trkrebd=339.0   # boundary only used by tracker if trkrtype = tcgen or midlat
#export trkrwbd=260.0   # boundary only used by tracker if trkrtype = tcgen or midlat
#export trkrnbd=40.0    # boundary only used by tracker if trkrtype = tcgen or midlat
#export trkrsbd=7.0     # boundary only used by tracker if trkrtype = tcgen or midlat
#export regtype=altg    # This variable is only needed if trkrtype = tcgen or midlat
# caitlyn, since regtype is commented out it could be messing up the outout atcf files

COM=${DATA}
atcfnum=10    # different
atcfname="TWRF"
atcfout="HAIKUI"
atcfymdh=${PDY}${cyc}
max_mslp_850=400.0
mslpthresh=0.0015
v850thresh=1.5000
v850_qwc_thresh=1.0000
cint_grid_bound_check=0.50
modtyp='regional'             # should this be regional?
nest_type='fixed'
export WCORE_DEPTH=1.0
export PHASEFLAG=y
export PHASE_SCHEME=both
#export PHASE_SCHEME=vtt
#export PHASE_SCHEME=cps
export STRUCTFLAG=y
export IKEFLAG=y
export genflag=y
export sstflag=y
export shear_calc_flag=y

export gen_read_rh_fields=n
# export use_land_mask=y
# export read_separate_land_mask_file=y
export use_land_mask=n
export read_separate_land_mask_file=n
export need_to_compute_rh_from_q=y
export smoothe_mslp_for_gen_scan=y
atcfnum=10      # repeated
atcffreq=600
rundescr="3KM"          # different
atcfdescr="HAIKUI"      # different
file_sequence="multi"   # different
#file_sequence="onebig"   # figure this out
lead_time_units='minutes' #dont think this should be minutes

# g2_jpdtn sets the variable that will be used as "JPDTN" for
# the call to getgb2, if gribver=2.  jpdtn=1 for ens data,
# jpdtn=0 for deterministic data.
g2_jpdtn=0
inp_data_type=grib
model=41    # different

# have no idea what these actually are or need to set to
g2_mlsp_parm_id=192
g1_mslp_parm_id=130
g1_sfcwind_lev_typ=105
g1_sfcwind_lev_val=10

ATCFNAME=` echo "${atcfname}" | tr '[a-z]' '[A-Z]'`

export atcfymdh=${PDY}${cyc}

export use_land_mask=${use_land_mask:-no}
# contour_interval=100.0
contour_interval=1.0
radii_pctile=95.0
radii_free_pass_pctile=67.0
radii_width_thresh=15.0
# radii_width_thresh=30.0
write_vit=n
want_oci=.TRUE.
use_backup_mslp_grad_check=${use_backup_mslp_grad_check:-y}
use_backup_850_vt_check=${use_backup_850_vt_check:-y}

#------------------------------------------------------------------------------
# USER - These next definitions declare the names of the variables inside
# the input data files. This allows the tracker to know the exact name of the
# record to look for. Please match these to the variables within the netcdf
# data files.
# By default they are all set to "X", user will need to change these variables
# according to what atmospheric data is in netcdf file.
# Example: geopotential height @ 500m will need to be changed from
# ncdf_z500name="X" --> ncdf_z500name=h500
#------------------------------------------------------------------------------
ncdf_num_netcdf_vars=999
ncdf_rv850name="X"
ncdf_rv700name="X"
ncdf_u850name="X"
ncdf_v850name="X"
ncdf_u700name="X"
ncdf_v700name="X"
ncdf_z850name="X"
ncdf_z700name="X"
ncdf_mslpname="X"
ncdf_usfcname="X"
ncdf_vsfcname="X"
ncdf_u500name="X"
ncdf_v500name="X"
ncdf_u200name="X"
ncdf_v200name="X"
ncdf_tmean_300_500_name="X"
ncdf_z200name="X"
ncdf_lmaskname="X"
ncdf_z900name="X"
ncdf_z800name="X"
ncdf_z750name="X"
ncdf_z650name="X"
ncdf_z600name="X"
ncdf_z550name="X"
ncdf_z500name="X"
ncdf_z450name="X"
ncdf_z400name="X"
ncdf_z350name="X"
ncdf_z300name="X"
ncdf_time_name="X"
ncdf_lon_name="X"
ncdf_lat_name="X"
ncdf_sstname="X"
ncdf_q850name="X"
ncdf_rh1000name="X"
ncdf_rh925name="X"
ncdf_rh800name="X"
ncdf_rh750name="X"
ncdf_rh700name="X"
ncdf_rh650name="X"
ncdf_rh600name="X"
ncdf_spfh1000name="X"
ncdf_spfh925name="X"
ncdf_spfh800name="X"
ncdf_spfh750name="X"
ncdf_spfh700name="X"
ncdf_spfh650name="X"
ncdf_spfh600name="X"
ncdf_temp1000name="X"
ncdf_temp925name="X"
ncdf_temp800name="X"
ncdf_temp750name="X"
ncdf_temp700name="X"
ncdf_temp650name="X"
ncdf_temp600name="X"
ncdf_omega500name="X"

# ting chi had this before is started editing
gribfile=${data_dir}/${atcfname}.${rundescr}.${atcfdescr}.${curymdh}.f00000
ixfile=${data_dir}/${atcfname}.${rundescr}.${atcfdescr}.${curymdh}.f00000.ix

#-----------------------------------------------------------------------
# Now process the ECMWF file in order to interpolate the GP height data
# to get it from 300 to 900 mb, every 50 mb.  With some models, this is
# not necessary because that vertical resolution of data already exists
# in the data.  But with ECMWF, that's not the case; we only have their
# GP height data at a limited subset of vertical levels, and those
# levels are specified in the text file, ecmwf_hgt_levs.txt.  The
# vint.x program reads in that list of vertical levels and interpolates
# to levels in between them in order to have that 50-mb vertical
# resolution starting at 900 mb and going up to and including 300 mb.
#--------------------------------------------------------------------------

# add grib file
$gix ${DATA}/gfsgribfile.${PDY}${CYL} ${DATA}/ecixfile.${PDY}${CYL}
gribfile=${DATA}/gfsgribfile.${PDY}${CYL}
ixfile=${DATA}/ecixfile.${PDY}${CYL}

# Define the name of a file that we will cat extra GRIB records into

catfile=${DATA}/${cmodel}.${PDY}${CYL}.catfile
>${catfile}


# Cycle through all the forecast hours and process the data to
# vertically interpolate and average the data....

for fhour in ${fcsthrs}
do

  if [ ${fhour} -eq 99 ]
  then
    continue
  fi

  set +x
  echo " "
  echo "Date in interpolation for fhour= $fhour before = `date`"
  echo " "
  set -x

  gfile=${DATA}/gfsgribfile.${PDY}${CYL}
  ifile=${DATA}/ecixfile.${PDY}${CYL}
  $gix $gfile $ifile

# ----------------------------------------------------
# First, interpolate height data to get data from
# 300 to 900 mb, every 50 mb....

  gparm=156
  namelist=${DATA}/vint_input.${PDY}${CYL}.z
  echo "&timein ifcsthour=${fhour},"       >${namelist}
  echo "        iparm=${gparm},"          >>${namelist}
  echo "        gribver=${gribver},"      >>${namelist}
  echo "        g2_jpdtn=${g2_jpdtn}/"    >>${namelist}

  ln -s -f ${gfile}                                   fort.11
  ln -s -f ${rundir}/tracker_hgt_levs                 fort.16
  ln -s -f ${ifile}                                   fort.31
  ln -s -f ${DATA}/${cmodel}.${PDY}${CYL}.z.f${fhour} fort.51

  ${execdir}/vint.x <${namelist}
  rcc=$?

  if [ $rcc -ne 0 ]; then
    set +x
    echo " "
    echo "ERROR in call to vint for GPH at fhour= $fhour"
    echo "rcc= $rcc      EXITING.... "
    echo " "
    set -x
    exit 91
  fi

# ----------------------------------------------------
# Now interpolate temperature data to get data from
# 300 to 500 mb, every 50 mb.  As with the GP height
# data just above, we are only doing this because we
# get the ECMWF temperature data at reduced vertical
# resolution.  That resolution is defined in the
# ecmwf_tmp_levs.txt file, which vint.x reads in to
# interpolate between these levels.

  gparm=130
  namelist=${DATA}/vint_input.${PDY}${CYL}
  echo "&timein ifcsthour=${fhour},"       >${namelist}
  echo "        iparm=${gparm},"          >>${namelist}
  echo "        gribver=${gribver},"      >>${namelist}
  echo "        g2_jpdtn=${g2_jpdtn}/"    >>${namelist}

  ln -s -f ${gfile}                                   fort.11
  ln -s -f ${rundir}/tracker_tmp_levs                 fort.16
  ln -s -f ${ifile}                                   fort.31
  ln -s -f ${DATA}/${cmodel}.${PDY}${CYL}.t.f${fhour} fort.51

  ${execdir}/vint.x <${namelist}
  rcc=$?

  if [ $rcc -ne 0 ]; then
    set +x
    echo " "
    echo "ERROR in call to vint for T at fhour= $fhour"
    echo "rcc= $rcc      EXITING.... "
    echo " "
    set -x
    exit 91
  fi

# ----------------------------------------------------
# Now average the temperature data that we just
# interpolated to get the mean 300-500 mb temperature...

  ffile=${DATA}/${cmodel}.${PDY}${CYL}.t.f${fhour}
  ifile=${DATA}/${cmodel}.${PDY}${CYL}.t.f${fhour}.i
  $gix ${ffile} ${ifile}

  namelist=${DATA}/tave_input.${PDY}${CYL}
  echo "&timein ifcsthour=${fhour},"       >${namelist}
  echo "        iparm=${gparm},"          >>${namelist}
  echo "        gribver=${gribver},"      >>${namelist}
  echo "        g2_jpdtn=${g2_jpdtn}/"    >>${namelist}

  ln -s -f ${ffile}                                      fort.11
  ln -s -f ${ifile}                                      fort.31
  ln -s -f ${DATA}/${cmodel}_tave.${PDY}${CYL}.f${fhour} fort.51

  ${execdir}/tave.x <${namelist}
  rcc=$?

  if [ $rcc -ne 0 ]; then
    set +x
    echo " "
    echo "ERROR in call to tave at fhour= $fhour"
    echo "rcc= $rcc      EXITING.... "
    echo " "
    set -x
    exit 91
  fi

  tavefile=${DATA}/${cmodel}_tave.${PDY}${CYL}.f${fhour}
  zfile=${DATA}/${cmodel}.${PDY}${CYL}.z.f${fhour}
  cat ${zfile} ${tavefile} >>${catfile}

  set +x
  echo " "
  echo "Date in interpolation for fhour= $fhour after = `date`"
  echo " "
  set -x

done

# Now cat the interpolate height data and the averaged
# temperature data onto the end of the original ECMWF file.

cat ${catfile} >>${gfile}

#####################################################
# Populate the namelist, using the variables that
# were declared above.
#####################################################

namelist=${DATA}/input.${atcfout}.${PDY}${cyc}

echo "&datein inp%bcc=${scc},inp%byy=${syy},inp%bmm=${smm},"      >${namelist}
echo "        inp%bdd=${sdd},inp%bhh=${shh},inp%model=${model}," >>${namelist}
echo "        inp%modtyp='${modtyp}',"                           >>${namelist}
echo "        inp%lt_units='${lead_time_units}',"                >>${namelist}
echo "        inp%file_seq='${file_sequence}',"                  >>${namelist}
echo "        inp%nesttyp='${nest_type}'/"                       >>${namelist}
echo "&atcfinfo atcfnum=${atcfnum},atcfname='${ATCFNAME}',"      >>${namelist}
echo "          atcfymdh=${atcfymdh},atcffreq=${atcffreq}/"      >>${namelist}
echo "&trackerinfo trkrinfo%westbd=${trkrwbd},"                  >>${namelist}
echo "      trkrinfo%eastbd=${trkrebd},"                         >>${namelist}
echo "      trkrinfo%northbd=${trkrnbd},"                        >>${namelist}
echo "      trkrinfo%southbd=${trkrsbd},"                        >>${namelist}
echo "      trkrinfo%type='${trkrtype}',"                        >>${namelist}
echo "      trkrinfo%mslpthresh=${mslpthresh},"                  >>${namelist}
echo "      trkrinfo%use_backup_mslp_grad_check='${use_backup_mslp_grad_check}',"  >>${namelist}
echo "      trkrinfo%max_mslp_850=${max_mslp_850},"              >>${namelist}
echo "      trkrinfo%v850thresh=${v850thresh},"                  >>${namelist}
echo "      trkrinfo%v850_qwc_thresh=${v850_qwc_thresh},"        >>${namelist}
echo "      trkrinfo%use_backup_850_vt_check='${use_backup_850_vt_check}',"  >>${namelist}
echo "      trkrinfo%gridtype='${modtyp}',"                      >>${namelist}
echo "      trkrinfo%enable_timing=1,"                           >>${namelist}
echo "      trkrinfo%contint=${contour_interval},"               >>${namelist}
echo "      trkrinfo%want_oci=${want_oci},"                      >>${namelist}
echo "      trkrinfo%out_vit='${write_vit}',"                    >>${namelist}
echo "      trkrinfo%use_land_mask='${use_land_mask}',"          >>${namelist}
echo "      trkrinfo%read_separate_land_mask_file='${read_separate_land_mask_file}',"   >>${namelist}
echo "      trkrinfo%inp_data_type='${inp_data_type}',"          >>${namelist}
echo "      trkrinfo%gribver=${gribver},"                        >>${namelist}
echo "      trkrinfo%g2_jpdtn=${g2_jpdtn},"                      >>${namelist}
echo "      trkrinfo%g2_mslp_parm_id=${g2_mslp_parm_id},"        >>${namelist}
echo "      trkrinfo%g1_mslp_parm_id=${g1_mslp_parm_id},"        >>${namelist}
echo "      trkrinfo%g1_sfcwind_lev_typ=${g1_sfcwind_lev_typ},"  >>${namelist}
echo "      trkrinfo%g1_sfcwind_lev_val=${g1_sfcwind_lev_val}/"  >>${namelist}
echo "&phaseinfo phaseflag='${PHASEFLAG}',"                      >>${namelist}
echo "           phasescheme='${PHASE_SCHEME}',"                 >>${namelist}
echo "           wcore_depth=${WCORE_DEPTH}/"                    >>${namelist}
echo "&structinfo structflag='${STRUCTFLAG}',"                   >>${namelist}
echo "            ikeflag='${IKEFLAG}',"                         >>${namelist}
echo "            radii_pctile=${radii_pctile},"                 >>${namelist}
echo "            radii_free_pass_pctile=${radii_free_pass_pctile},"  >>${namelist}
echo "            radii_width_thresh=${radii_width_thresh}/"     >>${namelist}
echo "&fnameinfo  gmodname='${atcfname}',"                       >>${namelist}
echo "            rundescr='${rundescr}',"                       >>${namelist}
echo "            atcfdescr='${atcfdescr}'/"                     >>${namelist}
echo "&cintinfo contint_grid_bound_check=${cint_grid_bound_check}/" >>${namelist}
echo "&waitinfo use_waitfor='n',"                                >>${namelist}
echo "          wait_min_age=10,"                                >>${namelist}
echo "          wait_min_size=100,"                              >>${namelist}
echo "          wait_max_wait=1800,"                             >>${namelist}
echo "          wait_sleeptime=5,"                               >>${namelist}
echo "          per_fcst_command=''/"                            >>${namelist}
echo "&netcdflist netcdfinfo%num_netcdf_vars=${ncdf_num_netcdf_vars}," >>${namelist}
echo "      netcdfinfo%netcdf_filename='${netcdffile}',"                   >>${namelist}
echo "      netcdfinfo%netcdf_lsmask_filename='${ncdf_ls_mask_filename}'," >>${namelist}
echo "      netcdfinfo%rv850name='${ncdf_rv850name}',"             >>${namelist}
echo "      netcdfinfo%rv700name='${ncdf_rv700name}',"             >>${namelist}
echo "      netcdfinfo%u850name='${ncdf_u850name}',"               >>${namelist}
echo "      netcdfinfo%v850name='${ncdf_v850name}',"               >>${namelist}
echo "      netcdfinfo%u700name='${ncdf_u700name}',"               >>${namelist}
echo "      netcdfinfo%v700name='${ncdf_v700name}',"               >>${namelist}
echo "      netcdfinfo%z850name='${ncdf_z850name}',"               >>${namelist}
echo "      netcdfinfo%z700name='${ncdf_z700name}',"               >>${namelist}
echo "      netcdfinfo%mslpname='${ncdf_mslpname}',"               >>${namelist}
echo "      netcdfinfo%usfcname='${ncdf_usfcname}',"               >>${namelist}
echo "      netcdfinfo%vsfcname='${ncdf_vsfcname}',"               >>${namelist}
echo "      netcdfinfo%u500name='${ncdf_u500name}',"               >>${namelist}
echo "      netcdfinfo%v500name='${ncdf_v500name}',"               >>${namelist}
echo "      netcdfinfo%u200name='${ncdf_u200name}',"               >>${namelist}
echo "      netcdfinfo%v200name='${ncdf_v200name}',"               >>${namelist}
echo "      netcdfinfo%tmean_300_500_name='${ncdf_tmean_300_500_name}',"  >>${namelist}
echo "      netcdfinfo%z500name='${ncdf_z500name}',"               >>${namelist}
echo "      netcdfinfo%z200name='${ncdf_z200name}',"               >>${namelist}
echo "      netcdfinfo%lmaskname='${ncdf_lmaskname}',"             >>${namelist}
echo "      netcdfinfo%z900name='${ncdf_z900name}',"               >>${namelist}
echo "      netcdfinfo%z850name='${ncdf_z850name}',"               >>${namelist}
echo "      netcdfinfo%z800name='${ncdf_z800name}',"               >>${namelist}
echo "      netcdfinfo%z750name='${ncdf_z750name}',"               >>${namelist}
echo "      netcdfinfo%z700name='${ncdf_z700name}',"               >>${namelist}
echo "      netcdfinfo%z650name='${ncdf_z650name}',"               >>${namelist}
echo "      netcdfinfo%z600name='${ncdf_z600name}',"               >>${namelist}
echo "      netcdfinfo%z550name='${ncdf_z550name}',"               >>${namelist}
echo "      netcdfinfo%z500name='${ncdf_z500name}',"               >>${namelist}
echo "      netcdfinfo%z450name='${ncdf_z450name}',"               >>${namelist}
echo "      netcdfinfo%z400name='${ncdf_z400name}',"               >>${namelist}
echo "      netcdfinfo%z350name='${ncdf_z350name}',"               >>${namelist}
echo "      netcdfinfo%z300name='${ncdf_z300name}',"               >>${namelist}
echo "      netcdfinfo%time_name='${ncdf_time_name}',"             >>${namelist}
echo "      netcdfinfo%lon_name='${ncdf_lon_name}',"               >>${namelist}
echo "      netcdfinfo%lat_name='${ncdf_lat_name}',"               >>${namelist}
echo "      netcdfinfo%time_units='${ncdf_time_units}',"           >>${namelist}
echo "      netcdfinfo%sstname='${ncdf_sstname}',"                 >>${namelist}
echo "      netcdfinfo%q850name='${ncdf_q850name}',"               >>${namelist}
echo "      netcdfinfo%rh1000name='${ncdf_rh1000name}',"           >>${namelist}
echo "      netcdfinfo%rh925name='${ncdf_rh925name}',"             >>${namelist}
echo "      netcdfinfo%rh800name='${ncdf_rh800name}',"             >>${namelist}
echo "      netcdfinfo%rh750name='${ncdf_rh750name}',"             >>${namelist}
echo "      netcdfinfo%rh700name='${ncdf_rh700name}',"             >>${namelist}
echo "      netcdfinfo%rh650name='${ncdf_rh650name}',"             >>${namelist}
echo "      netcdfinfo%rh600name='${ncdf_rh600name}',"             >>${namelist}
echo "      netcdfinfo%spfh1000name='${ncdf_spfh1000name}',"       >>${namelist}
echo "      netcdfinfo%spfh925name='${ncdf_spfh925name}',"         >>${namelist}
echo "      netcdfinfo%spfh800name='${ncdf_spfh800name}',"         >>${namelist}
echo "      netcdfinfo%spfh750name='${ncdf_spfh750name}',"         >>${namelist}
echo "      netcdfinfo%spfh700name='${ncdf_spfh700name}',"         >>${namelist}
echo "      netcdfinfo%spfh650name='${ncdf_spfh650name}',"         >>${namelist}
echo "      netcdfinfo%spfh600name='${ncdf_spfh600name}',"         >>${namelist}
echo "      netcdfinfo%temp1000name='${ncdf_temp1000name}',"       >>${namelist}
echo "      netcdfinfo%temp925name='${ncdf_temp925name}',"         >>${namelist}
echo "      netcdfinfo%temp800name='${ncdf_temp800name}',"         >>${namelist}
echo "      netcdfinfo%temp750name='${ncdf_temp750name}',"         >>${namelist}
echo "      netcdfinfo%temp700name='${ncdf_temp700name}',"         >>${namelist}
echo "      netcdfinfo%temp650name='${ncdf_temp650name}',"         >>${namelist}
echo "      netcdfinfo%temp600name='${ncdf_temp600name}',"         >>${namelist}
echo "      netcdfinfo%omega500name='${ncdf_omega500name}'/"       >>${namelist}
echo "&parmpreflist user_wants_to_track_zeta850='${user_wants_to_track_zeta850}'," >>${namelist}
echo "      user_wants_to_track_zeta700='${user_wants_to_track_zeta700}',"         >>${namelist}
echo "      user_wants_to_track_wcirc850='${user_wants_to_track_wcirc850}',"       >>${namelist}
echo "      user_wants_to_track_wcirc700='${user_wants_to_track_wcirc700}',"       >>${namelist}
echo "      user_wants_to_track_gph850='${user_wants_to_track_gph850}',"           >>${namelist}
echo "      user_wants_to_track_gph700='${user_wants_to_track_gph700}',"           >>${namelist}
echo "      user_wants_to_track_mslp='${user_wants_to_track_mslp}',"               >>${namelist}
echo "      user_wants_to_track_wcircsfc='${user_wants_to_track_wcircsfc}',"       >>${namelist}
echo "      user_wants_to_track_zetasfc='${user_wants_to_track_zetasfc}',"         >>${namelist}
echo "      user_wants_to_track_thick500850='${user_wants_to_track_thick500850}'," >>${namelist}
echo "      user_wants_to_track_thick200500='${user_wants_to_track_thick200500}'," >>${namelist}
echo "      user_wants_to_track_thick200850='${user_wants_to_track_thick200850}'/" >>${namelist}
echo "&verbose verb=3,verb_g2=0/"                                      >>${namelist}
echo "&sheardiaginfo shearflag='${shear_calc_flag}'/"                  >>${namelist}
echo "&sstdiaginfo sstflag='${sstflag}'/"                              >>${namelist}
echo "&gendiaginfo genflag='${genflag}',"                              >>${namelist}
echo "             gen_read_rh_fields='${gen_read_rh_fields}',"        >>${namelist}
echo "             need_to_compute_rh_from_q='${need_to_compute_rh_from_q}',"  >>${namelist}
echo "             smoothe_mslp_for_gen_scan='${smoothe_mslp_for_gen_scan}'/"  >>${namelist}

##########################################################################
# Now link various files that are either needed as input to the tracker,
# or are output from the tracker.  Note that the namelist file is linked
# to a fortran unit, instead of using the standard way of redirect on the
# the command line (e.g., gettrk.exe < namelist_file).  The reason for
# this is that someone from NCEP told me that they encountered an issue
# on one of the platforms running the tracker where the operating system
# balked at the use of the redirect.  So, to make things easy, the
# namelist is just fortran-unit-linked to unit 555 now.
#
# With the exception of unit 555 for the namelist, all unit numbers < 50
# are for input, and all unit numbers > 50 are for output.
##########################################################################

cp ${namelist} namelist.gettrk
ln -s -f namelist.gettrk                                             fort.555

if [ ${inp_data_type} = 'grib' ]; then
  ln -s -f ${gribfile}                                               fort.11
else
  ln -s -f ${netcdffile}                                             fort.11
  if [ ${read_separate_land_mask_file} = 'y' ]; then
    ln -s -f ${ncdf_ls_mask_filename}                                fort.17
  fi
fi



if [ -s ${DATA}/vitals.upd.${atcfout}.${PDY}${shh} ]; then
  cp ${DATA}/vitals.upd.${atcfout}.${PDY}${shh} \
     ${DATA}/tcvit_rsmc_storms.txt
fi

if [ -s ${DATA}/genvitals.upd.${atcfout}.${PDY}${shh} ]; then
  cp ${DATA}/genvitals.upd.${atcfout}.${PDY}${shh} \
     ${DATA}/tcvit_genesis_storms.txt
fi

ln -s -f ${rundir}/tracker_leadtimes                         fort.15

if [ ${inp_data_type} = 'grib' ]; then
  ln -s -f ${ixfile}                                                 fort.31
fi

if [ ${trkrtype} = 'tracker' ]; then
  ln -s -f ${DATA}/trak.${atcfout}.all.${PDY}${CYL}          fort.61
  ln -s -f ${DATA}/trak.${atcfout}.atcf.${PDY}${CYL}         fort.62
  ln -s -f ${DATA}/trak.${atcfout}.radii.${PDY}${CYL}        fort.63
  ln -s -f ${DATA}/trak.${atcfout}.atcfunix.${PDY}${CYL}     fort.64
  ln -s -f ${DATA}/trak.${atcfout}.atcf_gen.${PDY}${CYL}     fort.66
  ln -s -f ${DATA}/trak.${atcfout}.atcfunix_ext.${PDY}${CYL} fort.68
  ln -s -f ${DATA}/trak.${atcfout}.atcf_hfip.${PDY}${CYL}    fort.69
  ln -s -f ${DATA}/trak.${atcfout}.parmfix.${PDY}${CYL}      fort.81
else
  ln -s -f ${DATA}/trak.${atcfout}.all.${regtype}.${PDY}${CYL}          fort.61
  ln -s -f ${DATA}/trak.${atcfout}.atcf.${regtype}.${PDY}${CYL}         fort.62
  ln -s -f ${DATA}/trak.${atcfout}.radii.${regtype}.${PDY}${CYL}        fort.63
  ln -s -f ${DATA}/trak.${atcfout}.atcfunix.${regtype}.${PDY}${CYL}     fort.64
  ln -s -f ${DATA}/trak.${atcfout}.atcf_gen.${regtype}.${PDY}${CYL}     fort.66
  ln -s -f ${DATA}/trak.${atcfout}.atcfunix_ext.${regtype}.${PDY}${CYL} fort.68
  ln -s -f ${DATA}/trak.${atcfout}.atcf_hfip.${regtype}.${PDY}${CYL}    fort.69
  ln -s -f ${DATA}/trak.${atcfout}.parmfix.${regtype}.${PDY}${CYL}      fort.81
fi

if [ ${atcfname} = 'aear' ]
then
  ln -s -f ${DATA}/trak.${atcfout}.initvitl.${PDY}${CYL}           fort.65
fi

if [ ${write_vit} = 'y' ]
then
  ln -s -f ${DATA}/output_genvitals.${atcfout}.${PDY}${shh}        fort.67
fi

if [ ${PHASEFLAG} = 'y' ]; then
  ln -s -f ${DATA}/trak.${atcfout}.cps_parms.${PDY}${CYL}          fort.71
fi

if [ ${STRUCTFLAG} = 'y' ]; then
  ln -s -f ${DATA}/trak.${atcfout}.structure.${regtype}.${PDY}${CYL}          fort.72
  ln -s -f ${DATA}/trak.${atcfout}.fractwind.${regtype}.${PDY}${CYL}          fort.73
  ln -s -f ${DATA}/trak.${atcfout}.pdfwind.${regtype}.${PDY}${CYL}            fort.76
fi

if [ ${IKEFLAG} = 'y' ]; then
  ln -s -f ${DATA}/trak.${atcfout}.ike.${regtype}.${PDY}${CYL}                fort.74
fi

if [ ${trkrtype} = 'midlat' -o ${trkrtype} = 'tcgen' -o ${trkrtype} = 'tracker' ]; then
  ln -s -f ${DATA}/trkrmask.${atcfout}.${regtype}.${PDY}${CYL}     fort.77
fi

########################################################################
# Now run the tracker....
########################################################################

set +x
echo " "
echo " -----------------------------------------------"
echo "           NOW EXECUTING TRACKER......"
echo " -----------------------------------------------"
echo " "
set -x

echo "gettrk start for $atcfout at ${CYL}z at `date`"

set +x
echo "+++ TIMING: BEFORE gettrk  ---> `date`"
set -x

export FOR_DUMP_CORE_FILE=TRUE
ulimit -s unlimited

echo " "
echo "before gettrk, Output of ulimit command follows...."
ulimit -a
echo "before gettrk, Done: Output of ulimit command."

${execdir}/gettrk.x
gettrk_rcc=$?

set +x
echo "+++ TIMING: AFTER  gettrk  ---> `date`"
echo "   "
echo "   Return code from tracker= gettrk_rcc= ${gettrk_rcc}"
echo "   "
set -x
