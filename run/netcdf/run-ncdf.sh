#!/bin/bash --login
#SBATCH  -o output/shldtrk.out
#SBATCH  -J shtrk
#SBATCH  --time=30       # time limit in minutes
#SBATCH  --ntasks=1
#SBATCH  --partition=xjet
#SBATCH  -A hfip-gfdl

# print line numbers in std out
export PS4=' line $LINENO: '
set -x

# -------------------------------------------------------------------------------------------------
# USER - ALL CODE IN THE SECTION BELOW WILL NEED TO BE MODIFIED;
# PLEASE TAKE TIME TO READ COMMENTS AND EDIT ACCORDINGLY

# Set directory paths
export homedir=/mnt/lfs5/HFIP/hfip-gfdl/Caitlyn.Mcallister/genericscripts/dec1

# After adding the name of your data file & the path to it, please make sure to
# navigate into subscripts/name_ncdfvars.sh and follow the directions
export ncdf_filename='shieldcombined.nc'
export datadir=/mnt/lfs5/HFIP/hfip-gfdl/Caitlyn.Mcallister/ncdfdata/combined

# If you already have a tcvitals file, add path and name below.
# If the file has not been created yet, leave this blank and the tcvitals_ncdf.sh script will create one
# Please note, our archived vitals information contains data up until 03/21/2025
export tcvitals_file=

export rundir=${homedir}/run/netcdf
export codedir=${homedir}/code
export arcvitals=${homedir}/archived_vitals
export execdir=${codedir}/exec
export workdir=${rundir}/work/shld

# Name of rdhpc system (gaea, analysis, wcoss2, etc.), docker, or blank if on personal system
export which_system='jet'

if [ ${which_system} = 'docker' ]; then
  export dockerdir=${homedir}/run/docker
  source ${dockerdir}/use-docker.sh
fi

# Initialization forecast date/time matching your data
export initymdh=2024092500

# trkrtype=tracker for known storms, trkrtype=tcgen for genesis runs
export trkrtype='tracker'

# ATCF name of model (4 char long)
export atcfname='shld'

# Variables to declare the model's grid and nesting configurations
export modtyp='global'         # 'global' or 'regional'
export nest_type='fixed'      # 'moveable' or 'fixed'

# Set 'use_land_mask' = 'y' AND 'read_serperate_land_mask_file' = 'y' if landmask file is needed.
export use_land_mask='y'
export read_separate_land_mask_file='y'
# Add path to landmask file below if 'y' to above variables, leave blank if 'n'
export ncdf_ls_mask_filename=${datadir}/SLMSKsfc_SHiELD_C768.RT2020a_GFSv16.nc

# 'vortex_tilt_flag' = 'y'/'n'
# if developer wants to run vortex tilt diagnostics, set to 'y'. If set to 'n', the following if-statement will set
# the tilt_parm and threshold variables values automatically
export vortex_tilt_flag='n'
export vortex_tilt_parm=''
export vortex_tilt_allow_thresh=

if [ ${vortex_tilt_flag} = 'n' ]; then
  export vortex_tilt_parm=''
  export vortex_tilt_allow_thresh=''
else
  echo "vortex tilt diagnostics enabled"
  echo "vortex tilt parameter = ${vortex_tilt_parm}"
  echo "vortex tilt threshold = ${vortex_tilt_allow_thresh}"
fi

# -------------------------------------------------------------------------------------------------
# ADDITIONAL VARIABLE DECLARINING, DOES NOT NEED TO BE EDITED BY USER

# slice init date/time to use later in script
export pdy=`     echo ${initymdh} | cut -c1-8`
export yyyy=`    echo ${initymdh} | cut -c1-4`
export cc=`      echo ${initymdh} | cut -c1-2`
export yy=`      echo ${initymdh} | cut -c3-4`
export mm=`      echo ${initymdh} | cut -c5-6`
export dd=`      echo ${initymdh} | cut -c7-8`
export hh=`      echo ${initymdh} | cut -c9-10`
export ymdh=${initymdh}

# set date stamp vars
export date_stamp=$(date +"%a %b %d %H:%M:%S %Z %Y")
export today=$(date +"%a-%b%d")

# set wdir path
export wdir=${workdir}/${today}
if [ ! -d ${wdir} ]; then mkdir -p ${wdir}; fi

set +x
# -------------------------------------------------------------------------------------------------
# INVOKE SCRIPTS

# compile source code
export compile=${rundir}/subscripts/compile_ncdf.sh
source ${compile}

# export & run variables code
export env_vars=${rundir}/subscripts/ncdf_env_vars.sh
source ${env_vars}

# export & run tcvitals script; this will either produce tcvitals file or use developer's tcvitals file
export tcvitals=${rundir}/subscripts/tcvitals_ncdf.sh
source ${tcvitals}

# export & run ncvariables script
export ncvarscript=${rundir}/subscripts/name_ncdfvars.sh
source ${ncvarscript}

# export & run populate namelist script
export populatenamelist=${rundir}/subscripts/namelist_ncdf.sh
source ${populatenamelist}

# export & run input/output files script
export ioscript=${rundir}/subscripts/IOfiles_ncdf.sh
source ${ioscript}

# print tracker set up is finished
echo "TRACKER SET UP FINISHED"

# -------------------------------------------------------------------------------------------------
# EXECUTE TRACKER SOURCE CODE

echo "INITIALIZE TRACKER EXECUTABLE"
echo "Running tracker for ${atcfname} at ${hh}z at ${date_stamp}"

${execdir}/gettrk.x
export gettrk_rcc=$?

echo "After tracker source code run  ---> ${date_stamp}"
echo "Return code from tracker= gettrk_rcc= ${gettrk_rcc}"

# add print statement if tracker completed successfully
if [ ${gettrk_rcc} -gt 0 ]; then
  echo "TRACKER DID NOT RUN TO COMPLETION"
  exit 1
else
  echo "TRACKER RAN SUCCESSFULLY"
fi

# -------------------------------------------------------------------------------------------------
# RUN CLEAN UP SCRIPT
export runcleanup=${rundir}/subscripts/cleanup_ncdf.sh
source ${runcleanup}