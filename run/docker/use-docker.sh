#!/bin/bash

set -x
# -------------------------------------------------------------------------------------------------

# Check if the directory exists and is not empty
if [[ -n ${rundir} && -d ${rundir} ]]; then
  echo "Your run directory is: ${rundir}"
  export usencdf=${homedir}/run/netcdf
  export usegrib=${homedir}/run/grib
else
  echo "The run directory does not exist or is empty"
fi

if [ ${rundir} == ${usencdf} ]; then
  echo "RUNNING WITH NETCDF DATA"
else
  echo "RUNNING WITH GRIB DATA"
fi

set +x