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
#export compilescript=${rundir}/compile.sh
#source ${compilescript}

# export & run variables code
export varscript=${rundir}/variables.sh
source ${varscript}

# export & run known tcvitals script
export knowntcvitscript=${rundir}/tcvitals.sh
source ${knowntcvitscript}

# export & run ncvariables script
export ncvarscript=${rundir}/ncvariables.sh
source ${ncvarscript}

# export & run input data script
export datascript=${rundir}/inputdata.sh
source ${datascript}
