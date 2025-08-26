#!/bin/bash

# -------------------------------------------------------------------------------------------------
# SET UP FOR SINGLE INPUT NETCDF DATA FILE

# define netcdf data file & set path
export data_dir=${home}/wrfdata
export data_file=fixtimes_wrfout_combined.nc
export netcdffile=${data_dir}/fixtimes_wrfout_combined.nc

# get netcdf time units
ncdf_time_units="$(ncdump -h $netcdffile | grep "time:units" | awk -F= '{print $2}' | awk -F\" '{print $2}' | awk '{print $1}')"
#| tr '[A-Z]' '[a-z]')"  # needed this to the above command to change "Hours" to "hours" for time:units
export ${ncdf_time_units}

echo " "
echo "NetCDF time units pulled from data file = ${ncdf_time_units}"
echo " "
