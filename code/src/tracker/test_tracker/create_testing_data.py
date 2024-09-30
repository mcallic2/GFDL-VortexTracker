from netCDF4 import Dataset
import numpy as np

# create file
ncfile = Dataset('testfile.nc',mode='w')

# create dimensions
lat_dim = ncfile.createDimension('grid_yt', 73)
lon_dim = ncfile.createDimension('grid_xt', 144)
time_dim = ncfile.createDimension('time', None)

# create variables of dimensions
time = ncfile.createVariable('time', np.float32, ('time'))
time.axis = 'T'
time.calendar = 'julian'
time.calendar_type = 'JULIAN'
time.long_name = 'time'
#time.units = WHAT SHOULD GO HERE?

lat = ncfile.createVariable('grid_yt', np.float32, ('grid_yt'))
lat.units = 'degrees_N'
lat.long_name = 'latitude'
lat.axis = 'Y'

lon = ncfile.createVariable('grid_xt', np.float32, ('grid_xt'))
lon.units = 'degrees_E'
lon.long_name = 'longitude'
lon.axis = 'X'


# create variables needed for tracker input

# sea level pressure
mslp = ncfile.createVariable('MSLP', np.float32, ('time', 'grid_yt', 'grid_xt'))
mslp.units = 'mb'
mslp.long_name = 'sea-level pressure'

# 10m winds
u10m = ncfile.createVariable('UGRD10m', np.float32, ('time', 'grid_yt', 'grid_xt'))
u10m.units = 'm/s'
u10m.long_name = '10 meter u wind [m/s]'

v10m = ncfile.createVariable('VGRD10m', np.float32, ('time', 'grid_yt', 'grid_xt'))
v10m.units = 'm/s'
v10m.long_name = '10 meter v wind [m/s]'

# 850m geopotential height
z850 = ncfile.createVariable('z850', np.float32, ('time', 'grid_yt', 'grid_xt'))
z850.units = 'm'
z850.long_name = '850-mb geopotential height'

# 850m u & v components of wind
u850 = ncfile.createVariable('u850', np.float32, ('time', 'grid_yt', 'grid_xt'))
u850.units = 'm/s'
u850.long_name = '850-mb u component of wind'

v850 = ncfile.createVariable('v850', np.float32, ('time', 'grid_yt', 'grid_xt'))
v850.units = 'm/s'
v850.long_name = '850-mb v component of wind'

# 700m u & v components of wind
u700 = ncfile.createVariable('u700', np.float32, ('time', 'grid_yt', 'grid_xt'))
u700.units = 'm/s'
u700.long_name = '700-mb u component of wind'

v700 = ncfile.createVariable('v700', np.float32, ('time', 'grid_yt', 'grid_xt'))
v700.units = 'm/s'
v700.long_name = '700-mb v component of wind'

# 500m u & v component of the wind
u500 = ncfile.createVariable('u500', np.float32, ('time', 'grid_yt', 'grid_xt'))
u500.units = 'm/s'
u500.long_name = '500-mb u component of wind'

v500 = ncfile.createVariable('v500', np.float32, ('time', 'grid_yt', 'grid_xt'))
v500.units = 'm/s'
v500.long_name = '500-mb v component of wind'

# fill in data
nlats = len(lat_dim) ; nlons= len(lon_dim) ; ntimes = 3
lat[:] = 5.015152 + (5.0 / nlats) * np.arange(nlats)
lon[:] = 257.0151 + (5.0 / nlons) * np.arange(nlons)

random_arr = np.random.uniform(low=750.0, high=1050.3, size=(ntimes,nlats,nlons))
mslp[:,:,:] = random_arr



ncfile.close()