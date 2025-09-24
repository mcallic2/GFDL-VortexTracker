from netCDF4 import Dataset, num2date
import datetime

# open netcdf file
nc_file = Dataset('wrfout_combined.nc', 'r')

# get the time variable
time_var = nc_file.variables['time']

# get the units attribute
units = time_var.units

# convert numeric time values to datetime objects
dates = num2date(time_var[:], units)

# print the converted dates
for date in dates:
    print(date)

# close file
nc_file.close()

