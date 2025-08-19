#!/bin/bash

# -------------------------------------------------------------------------------------------------
# SET UP FOR SINGLE INPUT NETCDF DATA FILE

# define netcdf data file & set path
export data_dir=${home}/tshield_data
export data_file=combined.2023082900.nc
export netcdffile=${data_dir}/combined.2023082900.nc

# get netcdf time units
ncdf_time_units="$(ncdump -h $netcdffile | grep "time:units" | awk -F= '{print $2}' | awk -F\" '{print $2}' | awk '{print $1}')"
export ${ncdf_time_units}
echo " "
echo "NetCDF time units pulled from data file = ${ncdf_time_units}"
echo " "
