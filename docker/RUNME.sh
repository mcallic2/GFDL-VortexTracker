#!/bin/bash -l
#SBATCH  -o output/3data.out
#SBATCH  -J tshld
#SBATCH  --time=30       # time limit in minutes
#SBATCH  --ntasks=1
#SBATCH  --partition=xjet
#SBATCH  -A hfip-gfdl

# print line numbers in std out
export PS4=' line $LINENO: '
set -x

# -------------------------------------------------------------------------------------------------
# SET UP PATHS

# set directory paths
export home=/mnt/lfs5/HFIP/hfip-gfdl/Caitlyn.Mcallister/runtshld
export datadir=/mnt/lfs5/HFIP/hfip-gfdl/Caitlyn.Mcallister/tshd_data
export rundir=${home}/docker
export workdir=${rundir}/work/runtshld
export codedir=${home}/code
export modulesetup=${codedir}/modulefile-setup
export execdir=${codedir}/exec
export vitalsdir=${home}/files/vitals
export knowntcvitals=  # add path to tcvitals file if user already created it
export initymdh=2023082912

# slice init date/time to use later in script
export pdy=`     echo $initymdh | cut -c1-8`
export yyyy=`    echo $initymdh | cut -c1-4`
export cc=`      echo $initymdh | cut -c1-2`
export yy=`      echo $initymdh | cut -c3-4`
export mm=`      echo $initymdh | cut -c5-6`
export dd=`      echo $initymdh | cut -c7-8`
export hh=`      echo $initymdh | cut -c9-10`
export ymdh=${pdy}${hh}

# set date stamp var
export date_stamp=$(date +"%a %b %d %H:%M:%S %Z %Y")

# set wdir path
wdir=${workdir}/${initymdh}
if [ ! -d ${wdir} ]; then mkdir -p ${wdir}; fi

set +x
# -------------------------------------------------------------------------------------------------
# INVOKE SCRIPTS

# compile source code
export compilescript=${rundir}/subscripts/compile.sh
source ${compilescript}

# export & run variables code
export varscript=${rundir}/subscripts/variables.sh
source ${varscript}

# export & run known tcvitals script
export knowntcvitscript=${rundir}/subscripts/tcvitals.sh
source ${knowntcvitscript}

# export & run ncvariables script
export ncvarscript=${rundir}/subscripts/ncvariables.sh
source ${ncvarscript}

# export & run input data script, use this script if there is only 1 data file
#export datascript1=${rundir}/subscripts/inputdata_single.sh
#source ${datascript1}

# export & run input data script, use this script if there are multiple data files
export datascript2=${rundir}/subscripts/inputdata_multiple.sh
source ${datascript2}

# export & run populate namelist script
export popnamelist=${rundir}/subscripts/populatenamelist.sh
#source ${popnamelist}

# export & run input/output files script
export ioscript=${rundir}/subscripts/IOfiles.sh
#source ${ioscript}

# print tracker set up is finished
echo "TRACKER SET UP FINISHED"

# -------------------------------------------------------------------------------------------------
# EXECUTE TRACKER SOURCE CODE

echo "INITIALIZE TRACKER EXECUTABLE"
echo "Running tracker for $atcfname at ${hh}z at ${date_stamp}"

#${execdir}/gettrk.x
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
# CLEAN UP WORK DIRECTORY

# export & run clean work directory script
export cleanup=${rundir}/subscripts/cleanworkdir.sh
#source ${cleanup}
