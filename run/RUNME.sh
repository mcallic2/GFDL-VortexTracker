#!/bin/bash -x

# -------------------------------------------------------------------------------------------------
# SET UP PATHS

# print line numbers in std out
export PS4=' line $LINENO: '

# set directory paths
export home=$PWD/..
export workroot=${home}/work
export codedir=${home}/code
export execdir=${codedir}/exec
export rundir=${home}/run
export tcvit_date=${home}/files/bin/tcvit_date
export ndate=${home}/files/bin/ndate.x

# set model initialization variables
export curymdh=2023082900   # model initialization date
export pdy=`     echo ${curymdh} | cut -c1-8`
export yyyy=`    echo ${curymdh} | cut -c1-4`
export cyc=`     echo ${curymdh} | cut -c9-10`
export ymdh=${pdy}${cyc}

# set date stamp var
export date_stamp=$(date +"%a %b %d %H:%M:%S %Z %Y")

# set wdir path
wdir=${workroot}/${curymdh}
if [ ! -d ${wdir} ]; then mkdir -p ${wdir}; fi


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

# export & run input data script
export datascript=${rundir}/subscripts/inputdata.sh
source ${datascript}

# export & run populate namelist script
export popnamelist=${rundir}/subscripts/populatenamelist.sh
source ${popnamelist}

# export & run input/output files script
export ioscript=${rundir}/subscripts/IOfiles.sh
source ${ioscript}

# print tracker set up is finished
echo "TRACKER SET UP FINISHED"

# -------------------------------------------------------------------------------------------------
# EXECUTE TRACKER SOURCE CODE

echo " "
echo "INITIALIZE TRACKER EXECUTABLE"
echo " "

echo "gettrk start for $atcfout at ${cyc}z at ${date_stamp}"

echo "TIMING: BEFORE gettrk  ---> ${date_stamp}"

export for_dump_core_file=TRUE
ulimit -s unlimited

echo " "
echo "before gettrk, Output of ulimit command follows...."
ulimit -a
echo "before gettrk, Done: Output of ulimit command."
${execdir}/gettrk.x
export gettrk_rcc=$?

echo "   TIMING: AFTER  gettrk  ---> ${date_stamp}"
echo "   "
echo "   Return code from tracker= gettrk_rcc= ${gettrk_rcc}"
echo "   "

# -------------------------------------------------------------------------------------------------
# CLEAN UP WORK DIRECTORY

# export & run clean work directory script
export cleanup=${rundir}/subscripts/cleanworkdir.sh
source ${cleanup}
