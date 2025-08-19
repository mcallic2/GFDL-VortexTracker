#!/bin/bash

# -------------------------------------------------------------------------------------------------
# SET UP INPUT NETCDF FOR MULTIPLE DATA FILES

export data_dir=${home}/docker/tshield_data/${pdy}/${cyc}Z
export data_file1=atmos_sos.nest02.tile7_nested_ltd.nc
export data_file2=nggps2d.nest02.tile7_nested_ltd.nc

export netcdf_temp_file_1=${wdir}/atmos_temp.${pdy}${cyc}.nc
export netcdf_temp_file_2=${wdir}/nggps2d_temp.${pdy}${cyc}.nc
export netcdf_combined_file=${wdir}/combined.${pdy}${cyc}.nc   # leave combined file named as is

if [ -s ${netcdf_temp_file_1} ]; then rm ${netcdf_temp_file_1}; fi
if [ -s ${netcdf_temp_file_2} ]; then rm ${netcdf_temp_file_2}; fi
if [ -s ${netcdf_combined_file} ]; then rm ${netcdf_combined_file}; fi

# all variables will have to be listed below. One line/ncks function for each data file
ncks --fl_fmt=64bit -F -v u850,u700,u500,u200,v850,v700,v500,v200,h900,h850,h800,h750,h700,h650,h600,h550,h500,h450,h400,h350,h300,h200,TMP500_300,q1000,q925,q850,q800,q750,q700,q650,q600,t1000,t925,t800,t750,t700,t650,t600,PRMSL,omg500 ${data_dir}/${data_file1} ${netcdf_combined_file} || exit 1
ncks --fl_fmt=64bit -F -A -v UGRD10m,VGRD10m,TMPsfc ${data_dir}/${data_file2} ${netcdf_combined_file} || exit 1

export netcdffile=${wdir}/combined.${pdy}${cyc}.nc

# get netcdf time units
ncdf_time_units="$(ncdump -h $netcdffile | grep "time:units" | awk -F= '{print $2}' | awk -F\" '{print $2}' | awk '{print $1}')"
export ${ncdf_time_units}
echo " "
echo "NetCDF time units pulled from data file = ${ncdf_time_units}"
echo " "
