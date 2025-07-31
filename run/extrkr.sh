#!/usr/bin/bash

export PS4=' + extrkr.sh line $LINENO: '

cd $PBS_O_WORKDIR

source /usr/share/lmod/lmod/init/bash

echo " "
echo " module list BEFORE wcoss2-setup.sh"
module list
echo " "

# export JASPER_PATH=/usrx/local/prod/packages/gnu/4.8.5/jasper/1.900.29/lib
# export HDF5_PATH=/usrx/local/prod/packages/ips/18.0.1/hdf5/1.10.1/lib
# export LD_LIBRARY_PATH=${JASPER_PATH}:${HDF5_PATH}:${LD_LIBRARY_PATH}

# export JPEG_PATH=/apps/spack/libjpeg/9c/intel/19.1.3.304/jkr3isi257ktoouprwaxcn4twtye747z/lib
# export JASPER_PATH=/apps/spack/jasper/2.0.25/intel/19.1.3.304/sjib74krrorkyczqpqah4tvewmlnqdx4/lib64
# export NETCDF_PATH=/apps/prod/hpc-stack/intel-19.1.3.304/netcdf/4.7.4/lib
# export HDF5_PATH=/apps/prod/hpc-stack/intel-19.1.3.304/hdf5/1.10.6/lib
# export LD_LIBRARY_PATH=${JASPER_PATH}:${JPEG_PATH}:${NETCDF_PATH}:${HDF5_PATH}:${LD_LIBRARY_PATH}

export MODPATH=/lfs/h2/emc/hur/save/timothy.marchok/trak/para/sorc/gettrk.fd/20250423/code/modulefile-setup
cd $MODPATH

echo " "

source wcoss2-setup.sh

echo " module list AFTER wcoss2-setup.sh"
module list 
echo " "

loopnum=$1
cmodel=$2
ymdh=$3
pert=$4
init_flag=$5

# USE_OPER_VITALS=NO
# USE_OPER_VITALS=INIT_ONLY
USE_OPER_VITALS=YES

set +x
##############################################################################
echo " "
echo "------------------------------------------------"
echo "xxxx - Track vortices in model GRIB output"
echo "------------------------------------------------"
echo "History: Mar 1998 - Marchok - First implementation of this new script."
echo "         Apr 1999 - Marchok - Modified to allow radii output file and"
echo "                              to allow reading of 4-digit years from"
echo "                              TC vitals file."
echo "         Oct 2000 - Marchok - Fixed bugs: (1) copygb target grid scanning mode"
echo "                              flag had an incorrect value of 64 (this prevented"
echo "                              NAM, NGM and ECMWF from being processed correctly);" 
echo "                              Set it to 0.  (2) ECMWF option was using the "
echo "                              incorrect input date (today's date instead of "
echo "                              yesterday's)."
echo "         Jan 2001 - Marchok - Hours now listed in script for each model and "
echo "                              passed into program.  Script included to process"
echo "                              GFDL & Ensemble data.  Call to DBN included to "
echo "                              pass data to OSO and the Navy.  Forecast length"
echo "                              extended to 5 days for GFS & MRF."
echo " "
echo "                    In the event of a crash, you can contact Tim "
echo "                    Marchok at GFDL at (609) 452-6534 or tpm@gfdl.gov"
echo " "
echo "Current time is: `date`"
echo " "
##############################################################################
set -x

##############################################################################
#
#    FLOW OF CONTROL
#
# 1. Define data directories and file names for the input model 
# 2. Process input starting date/cycle information
# 3. Update TC Vitals file and select storms to be processed
# 4. Cut apart input GRIB files to select only the needed parms and hours
# 5. Execute the tracker
# 6. Copy the output track files to various locations
#
##############################################################################

########################################
msg="has begun for ${cmodel} at ${CYL}z"
postmsg "$jlogfile" "$msg"
########################################

# This script runs the hurricane tracker using operational GRIB model output.  
# This script makes sure that the data files exist, it then pulls all of the 
# needed data records out of the various GRIB forecast files and puts them 
# into one, consolidated GRIB file, and then runs a program that reads the TC 
# Vitals records for the input day and updates the TC Vitals (if necessary).
# It then runs gettrk, which actually does the tracking.
# 
# Environmental variable inputs needed for this scripts:
#  PDY   -- The date for data being processed, in YYYYMMDD format
#  CYL   -- The numbers for the cycle for data being processed (00, 06, 12, 18)
#  cmodel -- Model being processed (gfs, mrf, ukmet, ecmwf, nam, ngm, ngps,
#                                   fv3, gdas, gfdl, ens (ncep ensemble))
#  envir -- 'prod' or 'test'
#  SENDCOM -- 'YES' or 'NO'
#  stormenv -- This is only needed by the tracker run for the GFDL model.
#              'stormenv' contains the name/id that is used in the input
#              grib file names.
#  pert  -- This is only needed by the tracker run for the NCEP ensemble.
#           'pert' contains the ensemble member id (e.g., n2, p4, etc.)
#           which is used as part of the grib file names.
#
# For testing script interactively in non-production set following vars:
#     gfsvitdir  - Directory for GFS Error Checked Vitals
#     namvitdir  - Directory for NAM Error Checked Vitals (Defunct... 8/2018)
#     gltrkdir   - Directory for output tracks
#     homesyndir - Directory with syndir scripts/exec/fix 
#     archsyndir - Directory with syndir scripts/exec/fix 
#

#----------------------------------------------#
#   Get input date information                 #
#----------------------------------------------#

export PDY=` echo $ymdh | cut -c1-8`
export CYL=` echo $ymdh | cut -c9-10`

export PDY=${PDY:-$1}
export CYL=${cyc:-$2}
export CYCLE=t${CYL}z
export cmodel=${cmodel:-$3}
export jobid=${jobid:-testjob}
export envir=${envir:-prod}
export SENDCOM=${SENDCOM:-NO}
export PARAFLAG=${PARAFLAG:-NO}
export PHASEFLAG=y
export WCORE_DEPTH=1.0
#export PHASE_SCHEME=vtt
#export PHASE_SCHEME=cps
export PHASE_SCHEME=both
export STRUCTFLAG=n
export IKEFLAG=n

if [ ${PARAFLAG} = 'YES' ]
then
  echo 
else
# For NAVGEM, this job runs in a job that has CYL as '09' 
# or '21', we need CYL to be 00 or 12, respectively.
  if [ ${cmodel} = 'ngps' ]
  then
    if [ ${CYL} = '09' ]
    then
      CYL='00'
      CYCLE=t00z
    else
      CYL='12'
      CYCLE=t12z
    fi
  fi
fi

if [ ${cmodel} = 'ens'  -o ${cmodel} = 'eens' -o ${cmodel} = 'sref' -o\
     ${cmodel} = 'cens' -o ${cmodel} = 'fens' ]; then
  export TRKDATA=/lfs/h2/emc/ptmp/timothy.marchok/mgout3/${PDY}${cyc}/${cmodel}/${pert}
else
  export TRKDATA=${TRKDATA:-/lfs/h2/emc/ptmp/timothy.marchok/genout/${PDY}${cyc}/${cmodel}}
##  export TRKDATA=/ptmpp1/Timothy.Marchok/trakouth/${PDY}${cyc}/${cmodel}
fi

export DATA=${TRKDATA:-/lfs/h2/emc/ptmp/timothy.marchok/genout/${PDY}${cyc}/${cmodel}}
if [ ! -d $DATA ]
then
   mkdir -p $DATA
   cd $DATA
#   /nwprod/util/ush/setup.sh
fi
cd $DATA

#if [ ${PARAFLAG} = 'YES' ]
#then 
#  /nwprod/util/ush/setup.sh
#fi

if [ ${#PDY} -eq 0 -o ${#CYL} -eq 0 -o ${#cmodel} -eq 0 ]
then
  set +x
  echo
  echo "Something wrong with input data.  One or more input variables has length 0"
  echo "PDY= ${PDY}, CYL= ${CYL}, cmodel= ${cmodel}"
  echo "EXITING...."
  set -x
  err_exit " FAILED ${jobid} -- BAD INPUTS AT LINE $LINENO IN TRACKER SCRIPT - ABNORMAL EX
IT"
else
  set +x
  echo " "
  echo " #-----------------------------------------------------------------#"
  echo " At beginning of tracker script, the following imported variables "
  echo " are defined: "
  echo "   PDY ................................... $PDY"
  echo "   CYL ................................... $CYL"
  echo "   CYCLE ................................. $CYCLE"
  echo "   cmodel ................................ $cmodel"
  echo "   jobid ................................. $jobid"
  echo "   envir ................................. $envir"
  echo "   SENDCOM ............................... $SENDCOM"
  echo " "
  set -x
fi

scc=`echo ${PDY} | cut -c1-2`
syy=`echo ${PDY} | cut -c3-4`
smm=`echo ${PDY} | cut -c5-6`
sdd=`echo ${PDY} | cut -c7-8`
shh=${CYL}
symd=`echo ${PDY} | cut -c3-8`
syyyy=`echo ${PDY} | cut -c1-4`
symdh=${PDY}${CYL}

export gfsvitdir=${gfsvitdir:-/lfs/h1/ops/prod/com/gfs/v16.3/gfs.${PDY}/${CYL}/atmos}
export gltrkdir=${gltrkdir:-/com/hur/${envir}/global}
export TPCATdir=/tpcprd/atcf

export gettrk_exec_dir=/lfs/h2/emc/hur/save/timothy.marchok/trak/para/exec/2024a
export homesyndir=${homesyndir:-/nwprod/util}
export exectrkdir=${exectrkdir:-${homesyndir}/exec}
export ushtrkdir=${ushtrkdir:-${homesyndir}/ush}

# export archsyndir=${archsyndir:-/gpfs/${mchar}p1/nco/ops/com/arch/prod/syndat}
# export archsyndir=${archsyndir:-/gpfs/dell1/nco/ops/com/gfs/prod/syndat}

if [ ${syyyy} -eq 2022 ]; then

  set +x
  echo "+++ NOTE: For 2022, the NCEP vitals were split between 2 different archives."
  echo "+++ I combined them into one file in my $rundir"
  echo " "
  set -x

  export archsyndir=${rundir}

  set +x
  echo "+++ Therefore, archsyndir= $archsyndir"
  set -x

else
  export archsyndir=${archsyndir:-/lfs/h1/ops/prod/com/gfs/v16.3/syndat}
fi

cp /lfs/h1/ops/prod/com/date/t${CYL}z ncepdate
export CENT=` cut -c7-8 ncepdate `

export wgrib=$WGRIB
export wgrib2=$WGRIB2
export cnvgrib=$CNVGRIB

echo " "
echo "WGRIB= ${WGRIB}"
echo " "

if [ -s $WGRIB ]
then
  wgrib=$WGRIB
else
  set +x
  echo " "
  echo "!!! ERROR: wgrib is not available, script will crash.  Exiting...."
  echo " "
  set -x
  err_exit " FAILED ${jobid} -- line= $LINENO IN TRACKER SCRIPT - ABNORMAL EXIT"
fi

export maxtime=65    # Max number of forecast time levels

#----------------------------------------------------------------#
#
#    --- Define data directories and data file names ---
#               
# Convert the input model to lowercase letters and check to see 
# if it's a valid model, and assign a model ID number to it.  
# This model ID number is passed into the Fortran program to 
# let the program know what set of forecast hours to use in the 
# ifhours array.  Also, set the directories for the operational 
# input GRIB data files and create templates for the file names.
# While only 1 of these sets of directories and file name 
# templates is used during a particular run of this script, 
# "gfsvitdir" is used every time, because that is the directory 
# that contains the error-checked TC vitals file that Steve Lord 
# produces, and so it is included after the case statement.
#
# NOTE: The varible PDY is now defined within the J-Jobs that
# call this script.  Therefore there is no reason to do this
# here.
#
# NOTE: The script that processes the ECMWF data defines PDY as
# the current day, and in this script we need PDY to be 
# yesterday's date (for the ecmwf ONLY).  So instead, the ecmwf
# script will pass the variable PDYm1 to this script, and in the
# case statement below we change that to PDY.
#
# NOTE: Do NOT try to standardize this script by changing all of 
# these various data directories' variable names to be all the 
# same, such as "datadir".  As you'll see in the data cutting 
# part of this script below, different methods are used to cut 
# apart different models, thus it is important to know the 
# difference between them....
#----------------------------------------------------------------#

cmodel=`echo ${cmodel} | tr "[A-Z]" "[a-z]"`

# "gribver" is an environmental variable that should be defined
# and exported in the parent script that calls this script.
export gribver=${gribver:-1}
export vit_hr_incr=6

case ${cmodel} in 

  gfs) set +x                                       ;
       echo " "; echo " ++ operational GFS chosen"  ;
       echo " "                                     ;
       set -x                                       ;
       gfsdir=${DATA}                                ;
       gfsgfile=gfs.t${CYL}z.pgrb2.0p25.f            ;
       gfsifile=gfs.t${CYL}z.pgrb2.0p25.if           ;
       COM=/lfs/h1/ops/prod/com/gfs/v16.3/gfs.${PDY}     ;
       fcstlen=126                                      ;
       fcsthrs=' 000 006 012 018 024 030 036 042 048 054 060 066 072 078
                 084 090 096 102 108 114 120 126  99  99  99
                  99  99  99  99  99  99  99  99  99  99  99
                  99  99  99  99  99  99  99  99  99  99  99
                  99  99  99  99  99  99  99  99
                 99  99  99  99  99  99  99  99  99  99' ;
       vit_hr_incr=6                                ;
       atcfnum=15                                   ;
       if [ ${loopnum} -eq 8 ]; then
         atcfname="gfsr"                              
         atcfout="gfsr"                               
       else
         atcfname="avnt"                              
         atcfout="avnt"                               
       fi                                           ;
       export trkrebd=350.0                         ;
       export trkrwbd=260.0                         ;
       export trkrnbd=40.0                          ;
       export trkrsbd=1.0                           ;
       regtype=altg                                 ;
       atcffreq=600                                 ;
       rundescr="xxxx"                              ;
       atcfdescr="xxxx"                             ;
       file_sequence="onebig"                       ;
       mslpthresh=0.0015                            ;
       v850thresh=1.5000                            ;
       v850_qwc_thresh=1.0000                       ;
       cint_grid_bound_check=0.50                   ;
       modtyp='global'                              ;
       nest_type='fixed'                            ;
       lead_time_units='hours'                      ;
       gribver=2                                    ;
       export PHASEFLAG=y                           ;
       export PHASE_SCHEME=both                     ;
       export STRUCTFLAG=n                          ;
       export IKEFLAG=n                             ;
       export sstflag=y                             ;
       export shear_calc_flag=y                     ;
       export genflag=n                             ;
       export gen_read_rh_fields=n                  ;
#       export use_land_mask=y                       ;
       export use_land_mask=n                       ;
#       export read_separate_land_mask_file=y        ;
       export read_separate_land_mask_file=n        ;
       export need_to_compute_rh_from_q=n           ;
       export smoothe_mslp_for_gen_scan=n           ;
       export depth_of_mslp_for_gen_scan=0.50       ;
       export vortex_tilt_flag=y                    ;
       export vortex_tilt_parm=zeta                 ;
#       export vortex_tilt_parm=wcirc                ;
#       export vortex_tilt_parm=temp                 ;
#       export vortex_tilt_parm=hgt                  ;
       export vortex_tilt_allow_thresh=1.0          ;
       # g2_jpdtn sets the variable that will be used as "JPDTN" for
       # the call to getgb2, if gribver=2.  jpdtn=1 for ens data,
       # jpdtn=0 for deterministic data.
       g2_jpdtn=0                                   ;
       inp_data_type=grib                           ;
#       g2_mslp_parm_id=1                            ;
       g2_mslp_parm_id=192                          ;
#       g1_mslp_parm_id=102                          ;
       g1_mslp_parm_id=130                          ;
       g1_sfcwind_lev_typ=105                       ;
       g1_sfcwind_lev_val=10                        ;
       model=1                                     ;;

  ecmwf) set +x                                         ;
       echo " "; echo " ++ operational ECMWF chosen"    ;
       echo " "                                         ;
       set -x                                           ;
       ecmwfdir=/lfs/h1/ops/prod/dcom/${PDY}/wgrbbul/ecmwf ;
       ecmwfgfile=                                      ;
       ecmwfifile=                                      ;
       COM=/lfs/h1/ops/prod/com/ecmwf/v2.1/ecmwf.${PDY}    ;
       fcstlen=240                                      ;
       fcsthrs=' 00 06 12 18 24 30 36 42 48 54 60 66 72 78
                 84 90 96 102 108 114 120 126 132 138 144
                 150 156 162 168 174 180  186  192  198  204  210
                  216  222  228  234  240  99  99  99  99  99
                  99  99  99 99  99  99  99  99  99  99
                 99  99  99  99  99  99  99  99  99' ;
       atcfnum=19                                       ;
       atcfname="emx "                                  ;
       atcfout="emx"                                    ;
       atcffreq=600                                 ;
       rundescr="xxxx"                                  ;
       atcfdescr="xxxx"                                 ;
       file_sequence="onebig"                           ;
       mslpthresh=0.0015                                ;
       v850thresh=1.5000                                ;
       modtyp='global'                                  ;
       lead_time_units='hours'                          ;
       gribver=1                                        ;
       # g2_jpdtn sets the variable that will be used as "JPDTN" for
       # the call to getgb2, if gribver=2.  jpdtn=1 for ens data,
       # jpdtn=0 for deterministic data.
       g2_jpdtn=0                                   ;
       inp_data_type=grib                           ;
#       g2_mslp_parm_id=1                            ;
       g2_mslp_parm_id=192                          ;
#       g1_mslp_parm_id=102                          ;
#       g1_mslp_parm_id=130                          ;
       g1_mslp_parm_id=151                          ;
       g1_sfcwind_lev_typ=1                         ;
       g1_sfcwind_lev_val=0                         ;
       model=4                                         ;;

  *) set +x; echo " "; echo " !!! Model selected is not recognized."             ;
     echo " Model= ---> ${cmodel} <--- ..... Please submit the script again...."  ;
     echo " ";  set -x;
     err_exit " FAILED ${jobid} -- UNKNOWN cmodel IN TRACKER SCRIPT - ABNORMAL EXIT";;

esac

if [ ${PHASEFLAG} = 'y' ]; then

  if [ ${vortex_tilt_flag} = 'y' ]; then

    if [ ${vortex_tilt_parm} = 'zeta' -o ${vortex_tilt_parm} = 'wcirc' ]; then

      wgrib_parmlist=" HGT:850 HGT:700 UGRD:850 UGRD:800 UGRD:750 UGRD:700 UGRD:650 UGRD:600 UGRD:550 UGRD:500 UGRD:450 UGRD:400 UGRD:350 UGRD:300 UGRD:250 UGRD:200 VGRD:850 VGRD:800 VGRD:750 VGRD:700 VGRD:650 VGRD:600 VGRD:550 VGRD:500 VGRD:450 VGRD:400 VGRD:350 VGRD:300 VGRD:250 VGRD:200 SurfaceU SurfaceV ABSV:850 ABSV:700 PRMSL MSLET HGT:925 HGT:900 HGT:800 HGT:750 HGT:650 HGT:600 HGT:550 HGT:500 HGT:450 HGT:400 HGT:350 HGT:300 HGT:250 TMP:500 TMP:450 TMP:400 TMP:350 TMP:300 TMP:250 RH:1000 RH:925 RH:800 RH:750 RH:700 RH:650 RH:600 VVEL:500 LAND:surface :TMP:surface"

    elif [ ${vortex_tilt_parm} = 'hgt' ]; then

      wgrib_parmlist=" HGT:850 HGT:700 UGRD:850 UGRD:700 UGRD:500 UGRD:200 VGRD:850 VGRD:700 VGRD:500 VGRD:200 SurfaceU SurfaceV ABSV:850 ABSV:700 PRMSL MSLET HGT:925 HGT:900 HGT:800 HGT:750 HGT:650 HGT:600 HGT:550 HGT:500 HGT:450 HGT:400 HGT:350 HGT:300 HGT:250 HGT:200 TMP:500 TMP:450 TMP:400 TMP:350 TMP:300 TMP:250 RH:1000 RH:925 RH:800 RH:750 RH:700 RH:650 RH:600 VVEL:500 LAND:surface :TMP:surface"

    elif [ ${vortex_tilt_parm} = 'temp' ]; then

      wgrib_parmlist=" HGT:850 HGT:700 UGRD:850 UGRD:700 UGRD:500 UGRD:200 VGRD:850 VGRD:700 VGRD:500 VGRD:200 SurfaceU SurfaceV ABSV:850 ABSV:700 PRMSL MSLET HGT:925 HGT:900 HGT:800 HGT:750 HGT:650 HGT:600 HGT:550 HGT:500 HGT:450 HGT:400 HGT:350 HGT:300 HGT:250 TMP:850 TMP:800 TMP:750 TMP:700 TMP:650 TMP:600 TMP:550 TMP:500 TMP:450 TMP:400 TMP:350 TMP:300 TMP:250 TMP:200 RH:1000 RH:925 RH:800 RH:750 RH:700 RH:650 RH:600 VVEL:500 LAND:surface :TMP:surface"

    fi

  else

    wgrib_parmlist=" HGT:850 HGT:700 UGRD:850 UGRD:700 UGRD:500 UGRD:200 VGRD:850 VGRD:700 VGRD:500 VGRD:200 SurfaceU SurfaceV ABSV:850 ABSV:700 PRMSL MSLET HGT:925 HGT:900 HGT:800 HGT:750 HGT:650 HGT:600 HGT:550 HGT:500 HGT:450 HGT:400 HGT:350 HGT:300 HGT:250 TMP:500 TMP:450 TMP:400 TMP:350 TMP:300 TMP:250 RH:1000 RH:925 RH:800 RH:750 RH:700 RH:650 RH:600 VVEL:500 LAND:surface :TMP:surface"

    wgrib_ec_hires_parmlist=" GH:850 GH:700 U:850 U:700 U:500 V:850 V:700 V:500 10U:sfc 10V:sfc MSL:sfc GH:300 GH:400 GH:500 GH:925 T:300 T:400 T:500"

  fi

else

  if [ ${vortex_tilt_flag} = 'y' ]; then

    if [ ${vortex_tilt_parm} = 'zeta' -o ${vortex_tilt_parm} = 'wcirc' ]; then

      wgrib_parmlist=" HGT:850 HGT:700 UGRD:850 UGRD:800 UGRD:750 UGRD:700 UGRD:650 UGRD:600 UGRD:550 UGRD:500 UGRD:450 UGRD:400 UGRD:350 UGRD:300 UGRD:250 UGRD:200 VGRD:850 VGRD:800 VGRD:750 VGRD:700 VGRD:650 VGRD:600 VGRD:550 VGRD:500 VGRD:450 VGRD:400 VGRD:350 VGRD:300 VGRD:250 VGRD:200 SurfaceU SurfaceV ABSV:850 ABSV:700 PRMSL MSLET LAND:surface :TMP:surface"

    elif [ ${vortex_tilt_parm} = 'hgt' ]; then

      wgrib_parmlist=" HGT:850 HGT:800 HGT:750 HGT:700 HGT:650 HGT:600 HGT:550 HGT:500 HGT:450 HGT:400 HGT:350 HGT:300 HGT:250 HGT:200 UGRD:850 UGRD:700 UGRD:500 UGRD:200 VGRD:850 VGRD:700 VGRD:500 VGRD:200 SurfaceU SurfaceV ABSV:850 ABSV:700 PRMSL MSLET LAND:surface :TMP:surface"

    elif [ ${vortex_tilt_parm} = 'temp' ]; then

      wgrib_parmlist=" TMP:850 TMP:800 TMP:750 TMP:700 TMP:650 TMP:600 TMP:550 TMP:500 TMP:450 TMP:400 TMP:350 TMP:300 TMP:250 TMP:200 HGT:850 HGT:700 UGRD:850 UGRD:700 UGRD:500 UGRD:200 VGRD:850 VGRD:700 VGRD:500 VGRD:200 SurfaceU SurfaceV ABSV:850 ABSV:700 PRMSL MSLET LAND:surface :TMP:surface"

    fi

  else

    wgrib_parmlist=" HGT:850 HGT:700 UGRD:850 UGRD:700 UGRD:500 UGRD:200 VGRD:850 VGRD:700 VGRD:500 VGRD:200 SurfaceU SurfaceV ABSV:850 ABSV:700 PRMSL MSLET LAND:surface :TMP:surface"

    wgrib_ec_hires_parmlist=" GH:850 GH:700 U:850 U:700 U:500 V:850 V:700 V:500 10U:sfc 10V:sfc MSL:sfc"

  fi

fi


#---------------------------------------------------------------#
#
#      --------  TC Vitals processing   --------
#
# Check Steve Lord's operational tcvitals file to see if any 
# vitals records were processed for this time by his system.  
# If there were, then you'll find a file in /com/gfs/prod/gfs.yymmdd 
# with the vitals in it.  Also check the raw TC Vitals file in
# /gpfs/dell1/nco/ops/com/gfs/prod/syndat , since this may contain storms that Steve's 
# system ignored (Steve's system will ignore all storms that are 
# either over land or very close to land);  We still want to track 
# these inland storms, AS LONG AS THEY ARE NHC STORMS (don't 
# bother trying to track inland storms that are outside of NHC's 
# domain of responsibility -- we don't need that info).
# UPDATE 5/12/98 MARCHOK: The script is updated so that for the
#   global models, the gfs directory is checked for the error-
#   checked vitals file, while for the regional models, the 
#   nam directory is checked for that file.
# UPDATE 3/27/09 MARCHOK: The SREF is run at off-synoptic times
#   (03,09,15,21Z).  There are no tcvitals issued at these offtimes,
#   so the updating of the "old" tcvitals is critical for running
#   the tracker on SREF.  For updating the old tcvitals for SREF,
#   we need to look 3h back, not 6h as for the other models that
#   run at synoptic times.  Therefore, we've introduced a
#   variable called "vit_incr" here.
#--------------------------------------------------------------#

set +x
echo " "
echo "              -----------------------------"
echo " "
echo " Now sorting and updating the TC Vitals file.  Please wait...."
echo " "
set -x

if [ ${cmodel} = 'sref' ]; then
  vit_incr=3
else
  vit_incr=6
fi

# Get the vitals for the current time, the time 6h ahead, and the time
# 6h ago.  The supvit executable will sort them out and keep only the
# current vitals, if they exist. 

old_ymdh=` $NDATE -${vit_incr} ${PDY}${CYL}`
old_4ymd=` echo ${old_ymdh} | cut -c1-8`
old_ymd=` echo ${old_ymdh} | cut -c3-8`
old_hh=`  echo ${old_ymdh} | cut -c9-10`
old_str="${old_ymd} ${old_hh}00"

future_ymdh=` $NDATE ${vit_incr} ${PDY}${CYL}`
future_4ymd=` echo ${future_ymdh} | cut -c1-8`
future_ymd=` echo ${future_ymdh} | cut -c3-8`
future_hh=`  echo ${future_ymdh} | cut -c9-10`
future_str="${future_ymd} ${future_hh}00"

synvitdir=/lfs/h1/ops/prod/com/gfs/v16.3/gfs.${PDY}/${CYL}/atmos
synvitfile=gfs.t${CYL}z.syndata.tcvitals.tm00
synvitold_dir=/lfs/h1/ops/prod/com/gfs/v16.3/gfs.${old_4ymd}/${old_hh}/atmos
synvitold_file=gfs.t${old_hh}z.syndata.tcvitals.tm00
synvitfuture_dir=/lfs/h1/ops/prod/com/gfs/v16.3/gfs.${future_4ymd}/${future_hh}/atmos
synvitfuture_file=gfs.t${future_hh}z.syndata.tcvitals.tm00

current_str="${symd} ${CYL}00"

if [ -s ${synvitdir}/${synvitfile} -o\
     -s ${synvitold_dir}/${synvitold_file} -o\
     -s ${synvitfuture_dir}/${synvitfuture_file} ]
then
  grep "${old_str}" ${synvitold_dir}/${synvitold_file}        \
                  >${DATA}/tmpsynvit.${atcfout}.${PDY}${CYL}
  grep "${current_str}"  ${synvitdir}/${synvitfile}                  \
                 >>${DATA}/tmpsynvit.${atcfout}.${PDY}${CYL}
  grep "${future_str}" ${synvitfuture_dir}/${synvitfuture_file}  \
                 >>${DATA}/tmpsynvit.${atcfout}.${PDY}${CYL}
else
  set +x
  echo " "
  echo " There is no (synthetic) TC vitals file for ${CYL}z in ${synvitdir},"
  echo " nor is there a TC vitals file for ${old_hh}z in ${synvitold_dir}."
  echo " nor is there a TC vitals file for ${future_hh}z in ${synvitfuture_dir},"
  echo " Checking the raw TC Vitals file ....."
  echo " "
  set -x
fi

# Take the vitals from Steve Lord's /com/gfs/prod tcvitals file,
# and cat them with the NHC-only vitals from the raw, original
# /com/arch/prod/synda_tcvitals file.  Do this because the nwprod
# tcvitals file is the original tcvitals file, and Steve runs a
# program that ignores the vitals for a storm that's over land or
# even just too close to land, and for tracking purposes for the
# US regional models, we need these locations.  Only include these
# "inland" storm vitals for NHC (we're not going to track inland 
# storms that are outside of NHC's domain of responsibility -- we 
# don't need that info).  
# UPDATE 5/12/98 MARCHOK: awk logic is added to screen NHC 
#   vitals such as "91L NAMELESS" or "89E NAMELESS", since TPC 
#   does not want tracks for such storms.

grep "${old_str}" ${archsyndir}/syndat_tcvitals.${CENT}${syy}   | \
      grep -v TEST | awk 'substr($0,6,1) !~ /8/ {print $0}' \
      >${DATA}/tmprawvit.${atcfout}.${PDY}${CYL}
grep "${current_str}"  ${archsyndir}/syndat_tcvitals.${CENT}${syy}   | \
      grep -v TEST | awk 'substr($0,6,1) !~ /8/ {print $0}' \
      >>${DATA}/tmprawvit.${atcfout}.${PDY}${CYL}
grep "${future_str}" ${archsyndir}/syndat_tcvitals.${CENT}${syy} | \
      grep -v TEST | awk 'substr($0,6,1) !~ /8/ {print $0}' \
      >>${DATA}/tmprawvit.${atcfout}.${PDY}${CYL}


# IMPORTANT:  When "cat-ing" these files, make sure that the vitals
# files from the "raw" TC vitals files are first in order and Steve's
# TC vitals files second.  This is because Steve's vitals file has
# been error-checked, so if we have a duplicate tc vitals record in
# these 2 files (very likely), program supvit.x below will
# only take the last vitals record listed for a particular storm in
# the vitals file (all previous duplicates are ignored, and Steve's
# error-checked vitals records are kept).

cat ${DATA}/tmprawvit.${atcfout}.${PDY}${CYL} ${DATA}/tmpsynvit.${atcfout}.${PDY}${CYL} \
        >${DATA}/vitals.${atcfout}.${PDY}${CYL}


#--------------------------------------------------------------#
# Now run a fortran program that will read all the TC vitals
# records for the current dtg and the dtg from 6h ago, and
# sort out any duplicates.  If the program finds a storm that
# was included in the vitals file 6h ago but not for the current
# dtg, this program updates the 6h-old first guess position
# and puts these updated records as well as the records from
# the current dtg into a temporary vitals file.  It is this
# temporary vitals file that is then used as the input for the
# tracking program.
#--------------------------------------------------------------#

oldymdh=` $NDATE -${vit_incr} ${PDY}${CYL}`
oldyy=`echo ${oldymdh} | cut -c3-4`
oldmm=`echo ${oldymdh} | cut -c5-6`
olddd=`echo ${oldymdh} | cut -c7-8`
oldhh=`echo ${oldymdh} | cut -c9-10`
oldymd=${oldyy}${oldmm}${olddd}

futureymdh=` $NDATE 6 ${PDY}${CYL}`
futureyy=`echo ${futureymdh} | cut -c3-4`
futuremm=`echo ${futureymdh} | cut -c5-6`
futuredd=`echo ${futureymdh} | cut -c7-8`
futurehh=`echo ${futureymdh} | cut -c9-10`
futureymd=${futureyy}${futuremm}${futuredd}

echo "&datenowin   dnow%yy=${syy}, dnow%mm=${smm},"       >${DATA}/suv_input.${atcfout}.${PDY}${CYL}
echo "             dnow%dd=${sdd}, dnow%hh=${CYL}/"      >>${DATA}/suv_input.${atcfout}.${PDY}${CYL}
echo "&dateoldin   dold%yy=${oldyy}, dold%mm=${oldmm},"    >>${DATA}/suv_input.${atcfout}.${PDY}${CYL}
echo "             dold%dd=${olddd}, dold%hh=${oldhh}/"    >>${DATA}/suv_input.${atcfout}.${PDY}${CYL}
echo "&datefuturein  dfuture%yy=${futureyy}, dfuture%mm=${futuremm},"  >>${DATA}/suv_input.${atcfout}.${PDY}${CYL}
echo "               dfuture%dd=${futuredd}, dfuture%hh=${futurehh}/"  >>${DATA}/suv_input.${atcfout}.${PDY}${CYL}
echo "&hourinfo  vit_hr_incr=${vit_hr_incr}/"  >>${DATA}/suv_input.${atcfout}.${PDY}${CYL}

numvitrecs=`cat ${DATA}/vitals.${atcfout}.${PDY}${CYL} | wc -l`
if [ ${numvitrecs} -eq 0 ]
then

  if [ ${trkrtype} = 'tracker' ]
  then
    set +x
    echo " "
    echo "!!! NOTE -- There are no vitals records for this time period."
    echo "!!! File ${DATA}/vitals.${atcfout}.${PDY}${CYL} is empty."
    echo "!!! It could just be that there are no storms for the current"
    echo "!!! time.  Please check the dates and submit this job again...."
    echo " "
    set -x
    exit 1
  fi

fi

# For tcgen cases, filter to use only vitals from the ocean 
# basin of interest....

if [ ${trkrtype} = 'tcgen' ]
  then

  if [ ${numvitrecs} -gt 0 ]
  then
    
    fullvitfile=${DATA}/vitals.${atcfout}.${PDY}${CYL}
    cp $fullvitfile ${DATA}/vitals.all_basins.${atcfout}.${PDY}${CYL}
    basin=` echo $regtype | cut -c1-2`

    if [ ${basin} = 'al' ]; then
      cat $fullvitfile | awk '{if (substr($0,8,1) == "L") print $0}' \
               >${DATA}/vitals.tcgen_al_only.${atcfout}.${PDY}${CYL}
      cp ${DATA}/vitals.tcgen_al_only.${atcfout}.${PDY}${CYL} \
         ${DATA}/vitals.${atcfout}.${PDY}${CYL}
    fi
    if [ ${basin} = 'ep' ]; then
      cat $fullvitfile | awk '{if (substr($0,8,1) == "E") print $0}' \
               >${DATA}/vitals.tcgen_ep_only.${atcfout}.${PDY}${CYL}
      cp ${DATA}/vitals.tcgen_ep_only.${atcfout}.${PDY}${CYL} \
         ${DATA}/vitals.${atcfout}.${PDY}${CYL}
    fi
    if [ ${basin} = 'wp' ]; then
      cat $fullvitfile | awk '{if (substr($0,8,1) == "W") print $0}' \
               >${DATA}/vitals.tcgen_wp_only.${atcfout}.${PDY}${CYL}
      cp ${DATA}/vitals.tcgen_wp_only.${atcfout}.${PDY}${CYL} \
         ${DATA}/vitals.${atcfout}.${PDY}${CYL}
    fi

    cat ${DATA}/vitals.${atcfout}.${PDY}${CYL}

  fi
    
fi

# - - - - - - - - - - - - -
# Before running the program to read, sort and update the vitals,
# first run the vitals through some awk logic, the purpose of 
# which is to convert all the 2-digit years into 4-digit years.
# Beginning 4/21/99, NHC and JTWC will begin sending the vitals
# with 4-digit years, however it is unknown when other global
# forecasting centers will begin using 4-digit years, thus we
# need the following logic to ensure that all the vitals going
# into supvit.f have uniform, 4-digit years in their records.
#
# 1/8/2000: sed code added by Tim Marchok due to the fact that 
#       some of the vitals were getting past the syndata/qctropcy
#       error-checking with a colon in them; the colon appeared
#       in the character immediately to the left of the date, which
#       was messing up the "(length($4) == 8)" statement logic.
# - - - - - - - - - - - - -

sed -e "s/\:/ /g"  ${DATA}/vitals.${atcfout}.${PDY}${CYL} > ${DATA}/tempvit
mv ${DATA}/tempvit ${DATA}/vitals.${atcfout}.${PDY}${CYL}

awk '
{
  yycheck = substr($0,20,2)
  if ((yycheck == 20 || yycheck == 19) && (length($4) == 8)) {
    printf ("%s\n",$0)
  }
  else {
    if (yycheck >= 0 && yycheck <= 50) {
      printf ("%s20%s\n",substr($0,1,19),substr($0,20))
    }
    else {
      printf ("%s19%s\n",substr($0,1,19),substr($0,20))
    }
  }
} ' ${DATA}/vitals.${atcfout}.${PDY}${CYL} >${DATA}/vitals.${atcfout}.${PDY}${CYL}.y4

mv ${DATA}/vitals.${atcfout}.${PDY}${CYL}.y4 ${DATA}/vitals.${atcfout}.${PDY}${CYL}

if [ ${numvitrecs} -gt 0 ]
then

  export pgm=supvit
  . prep_step

  ln -s -f ${DATA}/vitals.${atcfout}.${PDY}${CYL}         fort.31
  ln -s -f ${DATA}/vitals.upd.${atcfout}.${PDY}${CYL}     fort.51

  msg="$pgm start for $atcfout at ${CYL}z"
  postmsg "$jlogfile" "$msg"

  ${exectrkdir}/supvit.x <${DATA}/suv_input.${atcfout}.${PDY}${CYL}
  suvrcc=$?

  if [ ${suvrcc} -eq 0 ]
  then
    msg="$pgm end for $atcfout at ${CYL}z completed normally"
    postmsg "$jlogfile" "$msg"
  else
    set +x
    echo " "
    echo "!!! ERROR -- An error occurred while running supvit.x, "
    echo "!!! which is the program that updates the TC Vitals file."
    echo "!!! Return code from supvit.x = ${suvrcc}"
    echo "!!! model= ${atcfout}, forecast initial time = ${PDY}${CYL}"
    echo "!!! Exiting...."
    echo " "
    set -x
    err_exit " FAILED ${jobid} - ERROR RUNNING SUPVIT IN TRACKER SCRIPT- ABNORMAL EXIT"
  fi

else

  touch ${DATA}/vitals.upd.${atcfout}.${PDY}${CYL}

fi

#-----------------------------------------------------------------
# In this section, check to see if the user requested the use of 
# operational TC vitals records for the initial time only.  This 
# option might be used for a retrospective medium range forecast
# in which the user wants to initialize with the storms that are
# currently there, but then let the model do its own thing for 
# the next 10 or 14 days....


if [ ${USE_OPER_VITALS} = 'INIT_ONLY' ]; then

  if [ ${init_flag} = 'yes' ]; then
    set +x
    echo " "
    echo "NOTE: User has requested that operational historical TC vitals be used,"
    echo "      but only for the initial time, which we are currently at."
    echo " "
    set -x
  else
    set +x
    echo " "
    echo "NOTE: User has requested that operational historical TC vitals be used,"
    echo "      but only for the initial time, which we are now *PAST*."
    echo " "
    set -x
    >${DATA}/vitals.upd.${atcfout}.${PDY}${CYL}
  fi
    
elif [ ${USE_OPER_VITALS} = 'NO' ]; then
    
  set +x
  echo " "
  echo "NOTE: User has requested that historical vitals not be used...."
  echo " "
  set -x
  >${DATA}/vitals.upd.${atcfout}.${PDY}${CYL}
    
fi

#------------------------------------------------------------------#
# Now select all storms to be processed, that is, process every
# storm that's listed in the updated vitals file for the current
# forecast hour.  If there are no storms for the current time,
# then exit.
#------------------------------------------------------------------#

numvitrecs=`cat ${DATA}/vitals.upd.${atcfout}.${PDY}${CYL} | wc -l`
if [ ${numvitrecs} -eq 0 ]
then
  if [ ${trkrtype} = 'tracker' ]
  then
    set +x
    echo " "
    echo "!!! NOTE -- There are no vitals records for this time period "
    echo "!!! in the UPDATED vitals file."
    echo "!!! It could just be that there are no storms for the current"
    echo "!!! time.  Please check the dates and submit this job again...."
    echo " "
    set -x
    exit 1
  fi
fi

set +x
echo " "
echo " *--------------------------------*"
echo " |        STORM SELECTION         |"
echo " *--------------------------------*"
echo " "
set -x

ict=1
while [ $ict -le 15 ]
do
  stormflag[${ict}]=3
  (( ict++ ))
done

dtg_current="${symd} ${CYL}00"
stormmax=` grep "${dtg_current}" ${DATA}/vitals.upd.${atcfout}.${PDY}${CYL} | wc -l`

if [ ${stormmax} -gt 15 ]
then
  stormmax=15
fi

sct=1
while [ ${sct} -le ${stormmax} ]
do
  stormflag[${sct}]=1
  (( sct++ ))
done


#---------------------------------------------------------------#
#
#    --------  "Genesis" Vitals processing   --------
#
# May 2006:  This entire genesis tracking system is being
# upgraded to more comprehensively track and categorize storms.
# One thing that has been missing from the tracking system is
# the ability to keep track of storms from one analysis cycle
# to the next.  That is, the current system has been very
# effective at tracking systems within a forecast, but we have
# no methods in place for keeping track of storms across
# difference initial times.  For example, if we are running
# the tracker on today's 00z GFS analysis, we will get a
# position for various storms at the analysis time.  But then
# if we go ahead and run again at 06z, we have no way of
# telling the tracker that we know about the 00z position of
# this storm.  We now address that problem by creating
# "genesis" vitals, that is, when a storm is found at an
# analysis time, we not only produce "atcfunix" output to
# detail the track & intensity of a found storm, but we also
# produce a vitals record that will be used for the next
# run of the tracker script.  These "genesis vitals" records
# will be of the format:
#
#  YYYYMMDDHH_AAAH_LLLLX_TYP
#
#    Where:
#
#      YYYYMMDDHH = Date the storm was FIRST identified
#                   by the tracker.
#             AAA = Abs(Latitude) * 10; integer value
#               H = 'N' for norther hem, 'S' for southern hem
#            LLLL = Abs(Longitude) * 10; integer value
#               X = 'E' for eastern hem, 'W' for western hem
#             TYP = Tropical cyclone storm id if this is a
#                   tropical cyclone (e.g., "12L", or "09W", etc).
#                   If this is one that the tracker instead "Found
#                   On the Fly (FOF)", we simply put those three
#                   "FOF" characters in there.

genvitdir=/lfs/h2/emc/hur/save/timothy.marchok/trak/para/scripts/gfs_trak_2024
genvitfile=${genvitdir}/genesis.vitals.${cmodel}.${atcfout}.${CENT}${syy}

d6ago_ymdh=` $NDATE -6 ${PDY}${CYL}`
d6ago_4ymd=` echo ${d6ago_ymdh} | cut -c1-8`
d6ago_ymd=` echo ${d6ago_ymdh} | cut -c3-8`
d6ago_hh=`  echo ${d6ago_ymdh} | cut -c9-10`
d6ago_str="${d6ago_ymd} ${d6ago_hh}00"

d6ahead_ymdh=` $NDATE 6 ${PDY}${CYL}`
d6ahead_4ymd=` echo ${d6ahead_ymdh} | cut -c1-8`
d6ahead_ymd=` echo ${d6ahead_ymdh} | cut -c3-8`
d6ahead_hh=`  echo ${d6ahead_ymdh} | cut -c9-10`
d6ahead_str="${d6ahead_ymd} ${d6ahead_hh}00"

syyyym6=` echo ${d6ago_ymdh} | cut -c1-4`
smmm6=`   echo ${d6ago_ymdh} | cut -c5-6`
sddm6=`   echo ${d6ago_ymdh} | cut -c7-8`
shhm6=`   echo ${d6ago_ymdh} | cut -c9-10`

syyyyp6=` echo ${d6ahead_ymdh} | cut -c1-4`
smmp6=`   echo ${d6ahead_ymdh} | cut -c5-6`
sddp6=`   echo ${d6ahead_ymdh} | cut -c7-8`
shhp6=`   echo ${d6ahead_ymdh} | cut -c9-10`

set +x
echo " "
echo " d6ago_str=    --->${d6ago_str}<---"
echo " current_str=  --->${current_str}<---"
echo " d6ahead_str=  --->${d6ahead_str}<---"
echo " "
echo " Listing and contents of ${genvitdir}/genesis.vitals.${atcfout}.${CENT}${syy} follow "
echo " for the times 6h ago, current and 6h ahead:"
echo " "
set -x

ls -la ${genvitdir}/genesis.vitals.${atcfout}.${CENT}${syy}
cat ${genvitdir}/genesis.vitals.${atcfout}.${CENT}${syy}

set +x
echo " "
echo " "
set -x

grep "${d6ago_str}" ${genvitfile}                           \
       >${DATA}/genvitals.${cmodel}.${atcfout}.${PDY}${CYL}
grep "${current_str}"  ${genvitfile}                           \
      >>${DATA}/genvitals.${cmodel}.${atcfout}.${PDY}${CYL}
grep "${d6ahead_str}" ${genvitfile}                         \
      >>${DATA}/genvitals.${cmodel}.${atcfout}.${PDY}${CYL}

grep "${d6ago_str}"     ${genvitfile}
grep "${current_str}"   ${genvitfile}
grep "${d6ahead_str}"   ${genvitfile}


echo "&datenowin   dnow%yy=${syyyy}, dnow%mm=${smm},"          >${DATA}/sgv_input.${atcfout}.${PDY}${CYL}
echo "             dnow%dd=${sdd}, dnow%hh=${CYL}/"           >>${DATA}/sgv_input.${atcfout}.${PDY}${CYL}
echo "&date6agoin  d6ago%yy=${syyyym6}, d6ago%mm=${smmm6},"   >>${DATA}/sgv_input.${atcfout}.${PDY}${CYL}
echo "             d6ago%dd=${sddm6}, d6ago%hh=${shhm6}/"     >>${DATA}/sgv_input.${atcfout}.${PDY}${CYL}
echo "&date6aheadin  d6ahead%yy=${syyyyp6}, d6ahead%mm=${smmp6}," >>${DATA}/sgv_input.${atcfout}.${PDY}${CYL}
echo "               d6ahead%dd=${sddp6}, d6ahead%hh=${shhp6}/"   >>${DATA}/sgv_input.${atcfout}.${PDY}${CYL}

num_gen_vits=`cat ${DATA}/genvitals.${cmodel}.${atcfout}.${PDY}${CYL} | wc -l`

if [ ${num_gen_vits} -gt 0 ]
then

  export pgm=supvit_gen
  . prep_step

  ln -s -f ${DATA}/genvitals.${cmodel}.${atcfout}.${PDY}${CYL}      fort.31
  ln -s -f ${DATA}/genvitals.upd.${cmodel}.${atcfout}.${PDY}${CYL}  fort.51

  msg="$pgm start for $atcfout at ${CYL}z"
  postmsg "$jlogfile" "$msg"

  ${exectrkdir}/supvit_gen <${DATA}/sgv_input.${atcfout}.${PDY}${CYL}
  sgvrcc=$?

  if [ ${sgvrcc} -eq 0 ]
  then
    msg="$pgm end for $atcfout at ${CYL}z completed normally"
    postmsg "$jlogfile" "$msg"
  else
    set +x
    echo " "
    echo "!!! ERROR -- An error occurred while running supvit_gen, "
    echo "!!! which is the program that updates the genesis vitals file."
    echo "!!! Return code from supvit_gen = ${sgvrcc}"
    echo "!!! model= ${atcfout}, forecast initial time = ${PDY}${CYL}"
    echo "!!! Exiting...."
    echo " "
    set -x
    err_exit " FAILED ${jobid} - ERROR RUNNING SUPVIT_GEN IN TRACKER SCRIPT- ABNORMAL EXIT"
    exit 8
  fi
    
else
   
  touch ${DATA}/genvitals.upd.${cmodel}.${atcfout}.${PDY}${CYL}
    
fi


#-----------------------------------------------------------------#
#
#         ------  CUT APART INPUT GRIB FILES  -------
#
# For the selected model, cut apart the GRIB input files in order
# to pull out only the variables that we need for the tracker.  
# Put these selected variables from all forecast hours into 1 big 
# GRIB file that we'll use as input for the tracker.
# 
# The wgrib utility (/nwprod/util/exec/wgrib) is used to cut out 
# the needed parms for the GFS, MRF, GDAS, UKMET and NAVGEM files.
# The utility /nwprod/util/exec/copygb is used to interpolate the 
# NGM (polar stereographic) and NAM (Lambert Conformal) data from 
# their grids onto lat/lon grids.  Note that while the lat/lon 
# grid that I specify overlaps into areas that don't have any data 
# on the original grid, Mark Iredell wrote the copygb software so 
# that it will mask such "no-data" points with a bitmap (just be 
# sure to check the lbms in your fortran program after getgb).
#-----------------------------------------------------------------#

set +x
echo " "
echo " -----------------------------------------"
echo "   NOW CUTTING APART INPUT GRIB FILES TO "
echo "   CREATE 1 BIG GRIB INPUT FILE "
echo " -----------------------------------------"
echo " "
set -x

cgb=$COPYGB
cgb2=$COPYGB2

gix=$GRBINDEX
g2ix=$GRB2INDEX

regflag=`grep NHC ${DATA}/vitals.upd.${atcfout}.${PDY}${CYL} | wc -l`


# ------------------------------
#   Process ECMWF, if selected
# ------------------------------

# As of Summer, 2005, ECMWF is now sending us high res (1-degree) data on
# a global grid with 12-hourly resolution out to 240h.  Previously, we
# only got their data on a low res (2.5-degree) grid, from 35N-35S, with
# 24-hourly resolution out to only 168h.
  
if [ ${model} -eq 4 ]
then

  if [ $loopnum -eq 1 ] 
  then

    if [ -s ${DATA}/ecgribfile.${PDY}${CYL} ]
    then
      rm ${DATA}/ecgribfile.${PDY}${CYL}
    fi

    immddhh=`echo ${PDY}${CYL}| cut -c5-`
    ict=0

    for fhour in ${fcsthrs}
    do
    
      if [ ${fhour} -eq 99 ]
      then
        continue
      fi
      
      fhr=${fhour}
      echo "fhr= $fhr"
      fmmddhh=` $NDATE ${fhr} ${PDY}${CYL} | cut -c5- `
#      ec_hires_orig=DCD${immddhh}00${fmmddhh}001
      if [ ${fhr} -eq 0 ]; then
        ec_hires_orig=U1D${immddhh}00${fmmddhh}011
      else
        ec_hires_orig=U1D${immddhh}00${fmmddhh}001
      fi

      if [ ! -s ${ecmwfdir}/${ec_hires_orig} ]
      then
        set +x
        echo " "
        echo " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo " !!! ECMWF File missing: ${ecmwfdir}/${ec_hires_orig}"
        echo " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo " "
        set -x
        continue
      fi
      
      ecfile=${ecmwfdir}/${ec_hires_orig}
      $wgrib -s $ecfile >ec.ix
  
      for parm in ${wgrib_ec_hires_parmlist}
      do
        grep "${parm}" ec.ix | $wgrib -s $ecfile -i -grib -append \
                              -o ${DATA}/ecgribfile.${PDY}${CYL}
      done
        
      (( ict++ ))

    done

  fi

  if [ $loopnum -eq 1 ]; then

    $gix ${DATA}/ecgribfile.${PDY}${CYL} ${DATA}/ecixfile.${PDY}${CYL}


    catfile=${DATA}/${cmodel}.${PDY}${CYL}.catfile
    >${catfile}

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

      gfile=${DATA}/ecgribfile.${PDY}${CYL}
      ifile=${DATA}/ecixfile.${PDY}${CYL}
      $gix $gfile $ifile

#     ----------------------------------------------------
#     First, interpolate height data to get data from 
#     300 to 900 mb, every 50 mb....

      gparm=156
      namelist=${DATA}/vint_input.${PDY}${CYL}.z
      echo "&timein ifcsthour=${fhour},"       >${namelist}
      echo "        iparm=${gparm},"          >>${namelist}
      echo "        gribver=${gribver},"      >>${namelist}
      echo "        g2_jpdtn=${g2_jpdtn}/"    >>${namelist}

      ln -s -f ${gfile}                                   fort.11
      ln -s -f ${rundir}/ecmwf_hgt_levs.txt               fort.16
      ln -s -f ${ifile}                                   fort.31
      ln -s -f ${DATA}/${cmodel}.${PDY}${CYL}.z.f${fhour} fort.51

      ${exectrkdir}/vint.x <${namelist}
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

#     ----------------------------------------------------
#     Now interpolate temperature data to get data from
#     300 to 500 mb, every 50 mb....

      gparm=130
      namelist=${DATA}/vint_input.${PDY}${CYL}
      echo "&timein ifcsthour=${fhour},"       >${namelist}
      echo "        iparm=${gparm},"          >>${namelist}
      echo "        gribver=${gribver},"      >>${namelist}
      echo "        g2_jpdtn=${g2_jpdtn}/"    >>${namelist}

      ln -s -f ${gfile}                                   fort.11
      ln -s -f ${rundir}/ecmwf_tmp_levs.txt               fort.16
      ln -s -f ${ifile}                                   fort.31
      ln -s -f ${DATA}/${cmodel}.${PDY}${CYL}.t.f${fhour} fort.51

      ${exectrkdir}/vint.x <${namelist}
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

#     ----------------------------------------------------
#     Now average the temperature data that we just 
#     interpolated to get the mean 300-500 mb temperature...

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

      ${exectrkdir}/tave.x <${namelist}
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

    cat ${catfile} >>${gfile}

  fi 

  $gix ${DATA}/ecgribfile.${PDY}${CYL} ${DATA}/ecixfile.${PDY}${CYL}
  gribfile=${DATA}/ecgribfile.${PDY}${CYL}
  ixfile=${DATA}/ecixfile.${PDY}${CYL}

fi


# ------------------------------
#   Process GFS, if selected
# ------------------------------
  
if [ ${model} -eq 1 ]
then

  if [ $loopnum -eq 1 ]
  then

    if [ -s ${DATA}/gfsgribfile.${PDY}${CYL} ]
    then 
      rm ${DATA}/gfsgribfile.${PDY}${CYL}
    fi

    rm ${DATA}/master.gfsgribfile.${PDY}${CYL}.f*
    rm ${DATA}/gfsgribfile.${PDY}${CYL}.f*
    >${DATA}/gfsgribfile.${PDY}${CYL}

    set +x 
    echo " "
    echo "Time before gfs wgrib loop is `date`"
    echo " "
    set -x
  
    for fhour in ${fcsthrs}
    do
  
      if [ ${fhour} -eq 99 ]
      then
        continue
      fi
  
      if [ ! -s ${gfsdir}/${gfsgfile}${fhour} ]
      then
        set +x
        echo " "
        echo " "
        echo " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo " !!! GFS file is missing                              !!!!!!!!!!!!!!"
        echo " !!! Check for the existence of this file:            !!!!!!!!!!!!!!"
        echo " !!!    GFS File: ${gfsdir}/${gfsgfile}${fhour}"
        echo " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo " "
        set -x
        continue
      fi

      if [ ${gribver} -eq 1 ]; then

        gfile=${gfsdir}/${gfsgfile}${fhour}
        $wgrib -s $gfile >gfs.ix

        for parm in ${wgrib_parmlist}
        do
          case ${parm} in
            "SurfaceU")
              grep "UGRD:10 m " gfs.ix | $wgrib -s $gfile -i -grib -append \
                          -o ${DATA}/master.gfsgribfile.${PDY}${CYL}.f${fhour} ;;
            "SurfaceV")
              grep "VGRD:10 m " gfs.ix | $wgrib -s $gfile -i -grib -append \
                          -o ${DATA}/master.gfsgribfile.${PDY}${CYL}.f${fhour} ;;
                     *)
              grep "${parm}" gfs.ix | $wgrib -s $gfile -i -grib -append \
                          -o ${DATA}/master.gfsgribfile.${PDY}${CYL}.f${fhour} ;;
          esac
        done

        gfs_master_file=${DATA}/master.gfsgribfile.${PDY}${CYL}.f${fhour}
        gfs_converted_file=${DATA}/gfsgribfile.${PDY}${CYL}.f${fhour}
        gfs_cat_file=${DATA}/gfsgribfile.${PDY}${CYL}
        $cgb -g4 -i2 -x ${gfs_master_file} ${gfs_converted_file}
        cat ${gfs_converted_file} >>${gfs_cat_file}

      else

        gfile=${gfsdir}/${gfsgfile}${fhour}
        $wgrib2 -s $gfile >gfs.ix

        for parm in ${wgrib_parmlist}
        do
          case ${parm} in
            "SurfaceU")
              grep "UGRD:10 m " gfs.ix | $wgrib2 -i $gfile -append -grib \
                              ${DATA}/master.gfsgribfile.${PDY}${CYL}.f${fhour} ;;
            "SurfaceV")
              grep "VGRD:10 m " gfs.ix | $wgrib2 -i $gfile -append -grib \
                              ${DATA}/master.gfsgribfile.${PDY}${CYL}.f${fhour} ;;
                     *)
              grep "${parm}" gfs.ix | $wgrib2 -i $gfile -append -grib \
                              ${DATA}/master.gfsgribfile.${PDY}${CYL}.f${fhour} ;;
          esac
        done

#        gfs_master_file=${DATA}/master.gfsgribfile.${PDY}${CYL}.f${fhour}
#        gfs_converted_file=${DATA}/gfsgribfile.${PDY}${CYL}.f${fhour}


        gfs_cat_file=${DATA}/gfsgribfile.${PDY}${CYL}
        cat ${DATA}/master.gfsgribfile.${PDY}${CYL}.f${fhour} >>${gfs_cat_file}


#       Option 1
#       Uncomment and use this next block to convert from 0.25 to 0.50 deg
#
#        $g2ix ${gfs_master_file} ${gfs_master_file}.ix
#
#        g1=${gfs_master_file}
#        x1=${gfs_master_file}.ix
#
#        grid4="0 6 0 0 0 0 0 0 720 361 0 0 90000000 0 48 -90000000 359500000 500000 500000 0"
#
#        time $cgb2 -g "${grid4}" ${g1} ${x1} ${gfs_converted_file}
#
#        cat ${gfs_converted_file} >>${gfs_cat_file}
#
#       Option 2
#       Uncomment and use these next lines if using the full 0.25-deg resolution.
#
#        $g2ix ${gfs_master_file} ${gfs_master_file}.ix
#
#        g1=${gfs_master_file}
#        x1=${gfs_master_file}.ix
#
#        *** DEC 2022: No need to do this copygb interpolation since the pgrb2 
#            files are at the resolution that we need.
#
#        grid4="0 6 0 0 0 0 0 0 1440 721 0 0 90000000 0 48 -90000000 359750000 250000 250000 0"
#
#        time $cgb2 -g "${grid4}" ${g1} ${x1} ${gfs_converted_file}
#
#        cat ${gfs_converted_file} >>${gfs_cat_file}

      fi

    done

    if [ ${gribver} -eq 1 ]; then
      $gix ${DATA}/gfsgribfile.${PDY}${CYL} ${DATA}/gfsixfile.${PDY}${CYL}
    else

#     Option A
#     Uncomment and use this block to convert from GRIB2 to GRIB1
#
#      time $cnvgrib -g21 ${DATA}/gfsgribfile.${PDY}${CYL} ${DATA}/gfsgribfile.${PDY}${CYL}.grib1
#      mv ${DATA}/gfsgribfile.${PDY}${CYL} ${DATA}/gfsgribfile.${PDY}${CYL}.grib2
#      mv ${DATA}/gfsgribfile.${PDY}${CYL}.grib1 ${DATA}/gfsgribfile.${PDY}${CYL}
#      $gix ${DATA}/gfsgribfile.${PDY}${CYL} ${DATA}/gfsixfile.${PDY}${CYL}
#      export gribver=1

#     Option B
#     Uncomment and use this block to use the GRIB2 data files as they are
#     DEC 2022: We will use this option since the pgrb2 files are good enough
#     for what we need and are at the 0.25-deg resolution that we need.

      $g2ix ${DATA}/gfsgribfile.${PDY}${CYL} ${DATA}/gfsixfile.${PDY}${CYL}

    fi

####     done

    set +x 
    echo " "
    echo "Time after wgrib loop is `date`"
    echo " "
    set -x

#   ----------------------------------------

    # Now run through the work to get data for phase checking....

    catfile=${DATA}/${cmodel}.${PDY}${CYL}.catfile
    >${catfile}

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
      ifile=${DATA}/gfsixfile.${PDY}${CYL}

      if [ ${gribver} -eq 1 ]; then
        $gix $gfile $ifile
      else
        $g2ix $gfile $ifile
      fi

      # This next part is commented out for the GFS since we already
      # have the necessary GFS height and temperature data at 
      # 50-mb intervals.  However, we then still need to average the
      # temperature data to get the 300-500 mb mean temperature, and
      # that code is still un-commented below.

#      gparm=7
#      namelist=${DATA}/vint_input.${PDY}${CYL}.z
#      echo "&timein ifcsthour=${fhour},"       >${namelist}
#      echo "        iparm=${gparm},"          >>${namelist}
#      echo "        gribver=${gribver},"      >>${namelist}
#      echo "        g2_jpdtn=${g2_jpdtn}/"    >>${namelist}
#
#      ln -s -f ${gfile}                                   fort.11
#      ln -s -f ${rundir}/gfs_hgt_levs.txt                 fort.16
#      ln -s -f ${ifile}                                   fort.31
#      ln -s -f ${DATA}/${cmodel}.${PDY}${CYL}.z.f${fhour} fort.51
#
#      /usrx/local/bin/getrusage -a ${exectrkdir}/vint.x <${namelist}
#      rcc1=$?
#
#      gparm=11
#      namelist=${DATA}/vint_input.${PDY}${CYL}.t
#      echo "&timein ifcsthour=${fhour},"       >${namelist}
#      echo "        iparm=${gparm},"          >>${namelist}
#      echo "        gribver=${gribver},"      >>${namelist}
#      echo "        g2_jpdtn=${g2_jpdtn}/"    >>${namelist}
#
#      ln -s -f ${gfile}                                   fort.11
#      ln -s -f ${rundir}/gfs_tmp_levs.txt                 fort.16
#      ln -s -f ${ifile}                                   fort.31
#      ln -s -f ${DATA}/${cmodel}.${PDY}${CYL}.t.f${fhour} fort.51
#
#      /usrx/local/bin/getrusage -a ${exectrkdir}/vint.x <${namelist}
#      rcc2=$?
#
#      ffile=${DATA}/${cmodel}.${PDY}${CYL}.t.f${fhour}
#      ifile=${DATA}/${cmodel}.${PDY}${CYL}.t.f${fhour}.i

      gfile=${DATA}/gfsgribfile.${PDY}${CYL}
      ifile=${DATA}/gfsixfile.${PDY}${CYL}

      if [ ${gribver} -eq 1 ]; then
        $gix $gfile $ifile
      else
        $g2ix $gfile $ifile
      fi

      ffile=${gfile}
      rcc1=0
      rcc2=0

      gparm=11
      namelist=${DATA}/tave_input.${PDY}${CYL}
      echo "&timein ifcsthour=${fhour},"       >${namelist}
      echo "        iparm=${gparm},"          >>${namelist}
      echo "        gribver=${gribver},"      >>${namelist}
      echo "        g2_jpdtn=${g2_jpdtn}/"    >>${namelist}


#      if [ ${gribver} -eq 1 ]; then
#        $gix ${ffile} ${ifile}
#      else
#        $g2ix ${ffile} ${ifile}
#      fi

      ln -s -f ${ffile}                                      fort.11
      ln -s -f ${ifile}                                      fort.31
      ln -s -f ${DATA}/${cmodel}_tave.${PDY}${CYL}.f${fhour} fort.51

#      /usrx/local/bin/getrusage -a ${exectrkdir}/tave.x <${namelist}
#      /lfs/h2/emc/hur/save/timothy.marchok/trak/para/sorc/gettrk.fd/hafsbuild/exec/tave.x <${namelist}
      ${exectrkdir}/tave.x <${namelist}
      rcc3=$?

      if [ $rcc1 -eq 0 -a $rcc2 -eq 0 -a $rcc3 -eq 0 ]; then
        echo " "
      else
        mailfile=${DATA}/errmail.${cmodel}.${PDY}${CYL}
        echo "CPS/WC interp failure for $cmodel ${PDY}${CYL}" >${mailfile}
        mail -s "GFS Failure (CPS/WC int) $cmodel ${PDY}${CYL}" "${userid}@noaa.gov" <${mailfile}
        exit 8
      fi

      tavefile=${DATA}/${cmodel}_tave.${PDY}${CYL}.f${fhour}
      zfile=${DATA}/${cmodel}.${PDY}${CYL}.z.f${fhour}

###      cat ${tavefile} >>${catfile}
      cat ${zfile} ${tavefile} >>${catfile}
    
      set +x 
      echo " "
      echo "Date in interpolation for fhour= $fhour after = `date`"
      echo " "
      set -x

    done

    cat ${catfile} >>${gfile}

  fi

  gfile=${DATA}/gfsgribfile.${PDY}${CYL}
  ifile=${DATA}/gfsixfile.${PDY}${CYL}

  if [ ${gribver} -eq 1 ]; then
    $gix ${gfile} ${ifile}
  else
    $g2ix ${gfile} ${ifile}
  fi

  gribfile=${DATA}/gfsgribfile.${PDY}${CYL}
  ixfile=${DATA}/gfsixfile.${PDY}${CYL}

#  NOTE: Unblock the "export gribver=1" statement below if you have 
#        converted from grib2 to grib1 above.
#  echo " "
#  echo "NOTE: Converting gribver from 2 to 1, since we have converted from"
#  echo "      GRIB2 to GRIB1 in the above GFS block."
#  export gribver=1

fi


#------------------------------------------------------------------------#
#                         Now run the tracker                            #
#------------------------------------------------------------------------#

echo "At location for Now run the tracker"

ist=1
while [ $ist -le 15 ]
do
  if [ ${stormflag[${ist}]} -ne 1 ]
  then
    set +x; echo "Storm number $ist NOT selected for processing"; set -x
  else
    set +x; echo "Storm number $ist IS selected for processing...."; set -x
  fi
  (( ist++ ))
done

echo "At location B1"

# Load the forecast hours for this particular model into an array 
# that will be passed into the executable via a namelist....

last_fcst_hour=0
ifh=1
while [ $ifh -le ${maxtime} ]
do
  fh[${ifh}]=` echo ${fcsthrs} | awk '{print $n}' n=$ifh`
  fhr=`        echo ${fcsthrs} | awk '{print $n}' n=$ifh`
  if [ ${fhr} -ne 99 ]
  then
    last_fcst_hour=${fhr}
  fi
  (( ifh++ ))
done

if [ ! -s ${DATA}/last_fcst_hour.${atcfout}.${PDY}${CYL} ]
then
  echo ${last_fcst_hour} >${DATA}/last_fcst_hour.${atcfout}.${PDY}${CYL}
fi

namelist=${DATA}/input.${atcfout}.${PDY}${CYL}
ATCFNAME=` echo "${atcfname}" | tr '[a-z]' '[A-Z]'`

if [ ${cmodel} = 'sref' ]; then
  export atcfymdh=` $NDATE -3 ${scc}${syy}${smm}${sdd}${shh}`
else
  export atcfymdh=${scc}${syy}${smm}${sdd}${shh}
fi

if [ ${loopnum} -eq 8 -a ${cmodel} = 'gfs' ]; then
  # set it artificially high to effectively turn off the check and 
  # ensure it won't be triggered
  max_mslp_850=4000.0
else
  max_mslp_850=400.0
fi
export use_land_mask=${use_land_mask:-no}
contour_interval=100.0
radii_pctile=95.0
radii_free_pass_pctile=67.0
radii_width_thresh=15.0
write_vit=n
want_oci=.TRUE.
use_backup_mslp_grad_check=${use_backup_mslp_grad_check:-y}
use_backup_850_vt_check=${use_backup_850_vt_check:-y}

# Define which parameters to track:

user_wants_to_track_zeta850=y
user_wants_to_track_zeta700=y
user_wants_to_track_wcirc850=y
user_wants_to_track_wcirc700=y
user_wants_to_track_gph850=y
user_wants_to_track_gph700=y
user_wants_to_track_mslp=y
user_wants_to_track_wcircsfc=y
user_wants_to_track_zetasfc=y
user_wants_to_track_thick500850=n
user_wants_to_track_thick200500=n
user_wants_to_track_thick200850=n

set +x
echo " "
echo "After set perts ${pert}, user_wants_to_track_zeta850= ${user_wants_to_track_zeta850}"
echo "After set perts ${pert}, user_wants_to_track_zeta700= ${user_wants_to_track_zeta700}"
echo "After set perts ${pert}, user_wants_to_track_wcirc850= ${user_wants_to_track_wcirc850}"
echo "After set perts ${pert}, user_wants_to_track_wcirc700= ${user_wants_to_track_wcirc700}"
echo "After set perts ${pert}, user_wants_to_track_gph850= ${user_wants_to_track_gph850}"
echo "After set perts ${pert}, user_wants_to_track_gph700= ${user_wants_to_track_gph700}"
echo "After set perts ${pert}, user_wants_to_track_mslp= ${user_wants_to_track_mslp}"
echo "After set perts ${pert}, user_wants_to_track_wcircsfc= ${user_wants_to_track_wcircsfc}"
echo "After set perts ${pert}, user_wants_to_track_zetasfc= ${user_wants_to_track_zetasfc}"
echo "After set perts ${pert}, user_wants_to_track_thick500850= ${user_wants_to_track_thick500850}"
echo "After set perts ${pert}, user_wants_to_track_thick200500= ${user_wants_to_track_thick200500}"
echo "After set perts ${pert}, user_wants_to_track_thick200850= ${user_wants_to_track_thick200850}"
echo " "
set -x


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
echo "&cintinfo contint_grid_bound_check=${contint_grid_bound_check}/" >>${namelist}
echo "&waitinfo use_waitfor='n',"                                >>${namelist}
echo "          wait_min_age=10,"                                >>${namelist}
echo "          wait_min_size=100,"                              >>${namelist}
echo "          wait_max_wait=1800,"                             >>${namelist}
echo "          wait_sleeptime=5,"                               >>${namelist}
echo "          per_fcst_command=''/"                            >>${namelist}
echo "&netcdflist netcdfinfo%num_netcdf_vars=${ncdf_num_netcdf_vars}," >>${namelist}
echo "      netcdfinfo%netcdf_filename='${netcdffile}',"           >>${namelist}
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
echo "&verbose verb=3,verb_g2=1/"                                >>${namelist}
echo "&sheardiaginfo shearflag='${shear_calc_flag}'/"                  >>${namelist}
echo "&sstdiaginfo sstflag='${sstflag}'/"                              >>${namelist}
echo "&gendiaginfo genflag='${genflag}',"                              >>${namelist}
echo "             gen_read_rh_fields='${gen_read_rh_fields}',"        >>${namelist}
echo "             need_to_compute_rh_from_q='${need_to_compute_rh_from_q}',"  >>${namelist}
echo "             smoothe_mslp_for_gen_scan='${smoothe_mslp_for_gen_scan}',"  >>${namelist}
echo "             depth_of_mslp_for_gen_scan=${depth_of_mslp_for_gen_scan}/"  >>${namelist}
echo "&vortextiltinfo vortex_tilt_flag='${vortex_tilt_flag}',"                 >>${namelist}
echo "                vortex_tilt_parm='${vortex_tilt_parm}',"                 >>${namelist}
echo "                vortex_tilt_allow_thresh=${vortex_tilt_allow_thresh}/"   >>${namelist}

export pgm=gettrk
. prep_step

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

#ln -s -f ${DATA}/vitals.upd.${atcfout}.${PDY}${shh}                fort.12
#ln -s -f ${DATA}/genvitals.upd.${cmodel}.${atcfout}.${PDY}${CYL}   fort.14

if [ -s ${DATA}/vitals.upd.${atcfout}.${PDY}${shh} ]; then
  cp ${DATA}/vitals.upd.${atcfout}.${PDY}${shh} \
     ${DATA}/tcvit_rsmc_storms.txt
else
  >${DATA}/tcvit_rsmc_storms.txt
fi

if [ -s ${DATA}/genvitals.upd.${atcfout}.${PDY}${shh} ]; then
  cp ${DATA}/genvitals.upd.${atcfout}.${PDY}${shh} \
     ${DATA}/tcvit_genesis_storms.txt
else
  >${DATA}/tcvit_genesis_storms.txt
fi

ln -s -f ${rundir}/${cmodel}.tracker_leadtimes                     fort.15

if [ ${vortex_tilt_flag} = 'y' ]; then
  ln -s -f ${rundir}/gfs_vortex_tilt_levs_${vortex_tilt_parm}.txt   fort.18
  ln -s -f ${rundir}/gfs_vortex_tilt_vars_${vortex_tilt_parm}.txt   fort.33
fi

if [ ${inp_data_type} = 'grib' ]; then
  ln -s -f ${ixfile}                                               fort.31
fi

if [ ${trkrtype} = 'tracker' ]; then
  if [ ${atcfout} = 'gfdt' -o ${atcfout} = 'gfdl' -o \
       ${atcfout} = 'hwrf' -o ${atcfout} = 'hwft' ]; then
    ln -s -f ${DATA}/trak.${atcfout}.all.${stormenv}.${PDY}${CYL}       fort.61
    ln -s -f ${DATA}/trak.${atcfout}.atcf.${stormenv}.${PDY}${CYL}      fort.62
    ln -s -f ${DATA}/trak.${atcfout}.radii.${stormenv}.${PDY}${CYL}     fort.63
    ln -s -f ${DATA}/trak.${atcfout}.atcfunix.${stormenv}.${PDY}${CYL}  fort.64
    ln -s -f ${DATA}/trak.${atcfout}.atcf_gen.${stormenv}.${PDY}${CYL}  fort.66
    ln -s -f ${DATA}/trak.${atcfout}.atcf_sink.${stormenv}.${PDY}${CYL} fort.68
    ln -s -f ${DATA}/trak.${atcfout}.atcf_hfip.${stormenv}.${PDY}${CYL} fort.69
    ln -s -f ${DATA}/trak.${atcfout}.parmfix.${stormenv}.${PDY}${CYL}   fort.81
  else
    ln -s -f ${DATA}/trak.${atcfout}.all.${PDY}${CYL}       fort.61
    ln -s -f ${DATA}/trak.${atcfout}.atcf.${PDY}${CYL}      fort.62
    ln -s -f ${DATA}/trak.${atcfout}.radii.${PDY}${CYL}     fort.63
    ln -s -f ${DATA}/trak.${atcfout}.atcfunix.${PDY}${CYL}  fort.64
    ln -s -f ${DATA}/trak.${atcfout}.atcf_gen.${PDY}${CYL}  fort.66
    ln -s -f ${DATA}/trak.${atcfout}.atcf_sink.${PDY}${CYL} fort.68
    ln -s -f ${DATA}/trak.${atcfout}.atcf_hfip.${PDY}${CYL} fort.69
    ln -s -f ${DATA}/trak.${atcfout}.parmfix.${PDY}${CYL}   fort.81
  fi
else
  ln -s -f ${DATA}/trak.${atcfout}.all.${regtype}.${PDY}${CYL}       fort.61
  ln -s -f ${DATA}/trak.${atcfout}.atcf.${regtype}.${PDY}${CYL}      fort.62
  ln -s -f ${DATA}/trak.${atcfout}.radii.${regtype}.${PDY}${CYL}     fort.63
  ln -s -f ${DATA}/trak.${atcfout}.atcfunix.${regtype}.${PDY}${CYL}  fort.64
  ln -s -f ${DATA}/trak.${atcfout}.atcf_gen.${regtype}.${PDY}${CYL}  fort.66
  ln -s -f ${DATA}/trak.${atcfout}.atcf_sink.${regtype}.${PDY}${CYL} fort.68
  ln -s -f ${DATA}/trak.${atcfout}.atcf_hfip.${regtype}.${PDY}${CYL} fort.69
  ln -s -f ${DATA}/trak.${atcfout}.parmfix.${regtype}.${PDY}${CYL}   fort.81
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
  if [ ${atcfout} = 'gfdt' -o ${atcfout} = 'gfdl' -o \
       ${atcfout} = 'hwrf' -o ${atcfout} = 'hwft' ]; then
    ln -s -f ${DATA}/trak.${atcfout}.cps_parms.${stormenv}.${PDY}${CYL}          fort.71
  else
    ln -s -f ${DATA}/trak.${atcfout}.cps_parms.${PDY}${CYL}          fort.71
  fi
fi

if [ ${STRUCTFLAG} = 'y' ]; then
  if [ ${atcfout} = 'gfdt' -o ${atcfout} = 'gfdl' -o \
       ${atcfout} = 'hwrf' -o ${atcfout} = 'hwft' ]; then
    ln -s -f ${DATA}/trak.${atcfout}.structure.${stormenv}.${PDY}${CYL}          fort.72
    ln -s -f ${DATA}/trak.${atcfout}.fractwind.${stormenv}.${PDY}${CYL}          fort.73
    ln -s -f ${DATA}/trak.${atcfout}.pdfwind.${stormenv}.${PDY}${CYL}            fort.76
  else
    ln -s -f ${DATA}/trak.${atcfout}.structure.${PDY}${CYL}          fort.72
    ln -s -f ${DATA}/trak.${atcfout}.fractwind.${PDY}${CYL}          fort.73
    ln -s -f ${DATA}/trak.${atcfout}.pdfwind.${PDY}${CYL}            fort.76
  fi
fi

if [ ${IKEFLAG} = 'y' ]; then
  if [ ${atcfout} = 'gfdt' -o ${atcfout} = 'gfdl' -o \
       ${atcfout} = 'hwrf' -o ${atcfout} = 'hwft' ]; then
    ln -s -f ${DATA}/trak.${atcfout}.ike.${stormenv}.${PDY}${CYL}                fort.74
  else
    ln -s -f ${DATA}/trak.${atcfout}.ike.${PDY}${CYL}                fort.74
  fi
fi

if [ ${vortex_tilt_flag} = 'y' ]; then
  ln -s -f ${DATA}/trak.${atcfout}.vortex_tilt.${regtype}.${PDY}${CYL}          fort.82
fi

if [ ${trkrtype} = 'midlat' -o ${trkrtype} = 'tcgen' ]; then
  ln -s -f ${DATA}/trkrmask.${atcfout}.${regtype}.${PDY}${CYL}     fort.77
fi



set +x
echo " "
echo " -----------------------------------------------"
echo "           NOW EXECUTING TRACKER......"
echo " -----------------------------------------------"
echo " "
set -x

msg="$pgm start for $atcfout at ${CYL}z"
postmsg "$jlogfile" "$msg"

set +x
echo "+++ TIMING: BEFORE gettrk  ---> `date`"
set -x

${exectrkdir}/gettrk.x
gettrk_rcc=$?

set +x
echo "+++ TIMING: AFTER  gettrk  ---> `date`"
set -x

echo " "
echo "End of extrkr.sh script, before exit statement for loopnum= ${loopnum}, regtype= ${regtype}, atcfout= ${atcfout}, at `date`"

exit 0

