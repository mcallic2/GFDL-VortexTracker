import xarray as xr
import pandas as pd

# open netcdf file
ds = xr.opendataset('wrfout_combined.nc')

# uncomment below print statements if these variables and units are unknown
#print (ds.dims)  # ds.dims shows time variable & units
#print (ds.sizes['time']  # ds.sizes['time'] will print the amount of forecast hrs in file
#print (pd.date_range(start='2024-05-25', end='2024-05-29'))  # change dates if needed, this will print dates as datetimeindex range
#print (pd.date_range(start='2024-05-25', periods=27, freq='3h'))  # print this to double check times are in your chosen format

# save number of forecast hrs for later use
periods = ds.sizes['time']

# save units and times in the correct format
new_times = pd.date_range(start='2024-05-25', periods=27, freq='3h')

# assign new times to file
ds['time'] = new_times

# save and create new nc file with new time format
ds.to_netcdf('newtimes_wrfout_combined.nc')
