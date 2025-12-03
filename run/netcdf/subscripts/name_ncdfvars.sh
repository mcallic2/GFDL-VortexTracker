# -------------------------------------------------------------------------------------------------
# DEFINE NETCDF VARIABLE DEFINITIONS
set -x

# The variables declared below are common meteorlogical variables that the source code uses to
# produce the cyclone(s) path. Please carefully go through your data file to match the variables
# listed below with the correct name they are recorded with in your file.
# All of the variables are defaulted to = 'X' because netcdf files vary with naming conventions.
# If your file does not include the variable, for example, temperature at 600mb (ncdf_temp600name)
# leave that set to = 'X'

export ncdf_num_netcdf_vars=999
export ncdf_time_name='time'             # time (hours, mins, etc.)
export ncdf_lon_name='grid_xt'              # longitude (degrees_east)
export ncdf_lat_name='grid_yt'              # latitude (degrees_north)
export ncdf_sstname='TMPsfc'               # sea surface temperature (K)
export ncdf_mslpname='PRMSL'              # mean sea level pressure (mb)
export ncdf_usfcname='UGRD10m'              # u-wind at 10m (m/s)
export ncdf_vsfcname='VGRD10m'              # v-wind at 10m (m/s)
export ncdf_u850name='u850'              # 850mb u-wind/x-wind component (m/s)
export ncdf_u700name='u700'              # 700mb u-wind/x-wind component (m/s)
export ncdf_u500name='u500'              # 500mb u-wind/x-wind component (m/s)
export ncdf_u200name='u200'              # 200mb u-wind/x-wind component (m/s)
export ncdf_v850name='v850'              # 850mb v-wind/y-wind component (m/s)
export ncdf_v700name='v700'              # 700mb v-wind/y-wind component (m/s)
export ncdf_v500name='v500'              # 500mb v-wind/y-wind component (m/s)
export ncdf_v200name='v200'              # 200mb v-wind/y-wind component (m/s)
export ncdf_z900name='h900'              # 900mb geopotential height (m)
export ncdf_z850name='h850'              # 850mb geopotential height (m)
export ncdf_z800name='h800'              # 800mb geopotential height (m)
export ncdf_z750name='h750'              # 750mb geopotential height (m)
export ncdf_z700name='h700'              # 700mb geopotential height (m)
export ncdf_z650name='h650'              # 650mb geopotential height (m)
export ncdf_z600name='h600'              # 600mb geopotential height (m)
export ncdf_z550name='h550'              # 550mb geopotential height (m)
export ncdf_z500name='h500'              # 500mb geopotential height (m)
export ncdf_z450name='h450'              # 450mb geopotential height (m)
export ncdf_z400name='h400'              # 400mb geopotential height (m)
export ncdf_z350name='h350'              # 350mb geopotential height (m)
export ncdf_z300name='h300'              # 300mb geopotential height (m)
export ncdf_z200name='X'              # 200mb geopotential height (m)
export ncdf_temp1000name='t1000'          # 1000mb temperature (K)
export ncdf_temp925name='t925'           # 925mb temperature (K)
export ncdf_temp800name='t800'           # 800mb temperature (K)
export ncdf_temp750name='t750'           # 750mb temperature (K)
export ncdf_temp700name='t700'           # 500mb temperature (K)
export ncdf_temp650name='t650'           # 650mb temperature (K)
export ncdf_temp600name='t600'           # 600mb temperature (K)
export ncdf_tmean_300_500_name='TMP500_300'    # averaged 300mb-500mb temperature (K)
export ncdf_spfh1000name='q1000'          # 1000mb specific humidity (kg/kg)
export ncdf_spfh925name='q925'           # 925mb specific humidity (kg/kg)
export ncdf_q850name='q850'              # 850mb specific humidity (kg/kg)
export ncdf_spfh800name='q800'           # 800mb specific humidity (kg/kg)
export ncdf_spfh750name='q750'           # 750mb specific humidity (kg/kg)
export ncdf_spfh700name='q700'           # 700mb specific humidity (kg/kg)
export ncdf_spfh650name='q650'           # 650mb specific humidity (kg/kg)
export ncdf_spfh600name='q600'           # 600mb specific humidity (kg/kg)
export ncdf_rh1000name='X'            # 1000mb relative humidity (%)
export ncdf_rh925name='X'             # 925mb relative humidity (%)
export ncdf_rh800name='X'             # 800mb relative humidity (%)
export ncdf_rh750name='X'             # 750mb relative humidity (%)
export ncdf_rh700name='X'             # 700mb relative humidity (%)
export ncdf_rh650name='X'             # 650mb relative humidity (%)
export ncdf_rh600name='X'             # 600mb relative humidity (%)
export ncdf_omega500name='omg500'          # 500mb vertical velocity (Pa/s)
export ncdf_rv850name='X'             # 850mb relative vorticity (s-1)
export ncdf_rv700name='X'             # 700mb relative vorticity (s-1)
export ncdf_lmaskname=''             # land mask variable name (N/A)

# -------------------------------------------------------------------------------------------------
set +x