from netCDF4 import Dataset
import numpy as np

# --------------------------------------------------------------------------------------- #
# CREATE NETCDF FILE BELOW

# create file
ncfile = Dataset('test_mslp.nc',mode='w')

# create dimensions
lat_dim = ncfile.createDimension('grid_yt', 101)
lon_dim = ncfile.createDimension('grid_xt', 101)
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
# --------------------------------------------------------------------------------------- #

# --------------------------------------------------------------------------------------- #
# CREATE VARIABLES NEEDED FOR TRACKER INPUT

# sea level pressure
mslp = ncfile.createVariable('MSLP', np.float32, ('time', 'grid_yt', 'grid_xt'))
mslp.units = 'mb'
mslp.long_name = 'sea-level pressure'

# --------------------------------------------------------------------------------------- #

# --------------------------------------------------------------------------------------- #
# ------------------- GENERATE LAT&LON DATA AND MSLP DATA BELOW ------------------------- #


# ROUTINE GENERATE_LATS_LONS
def create_lats_lons(imax, jmax, dx, dy, xstartlon, ystartlat):

  # initialize arrays
  xlon = [-999.0] * imax
  ylat = [-999.0] * jmax

  # populate arrays with lats and lons
  for i in range (1, imax+1):      # python uses zero based indexing unlike fortran
    xlon[i-1] = xstartlon + ((i-1) * dx)
    for j in range (1, jmax+1):
      ylat[j-1] = ystartlat - ((j-1) * dy)

  return np.array([xlon,ylat])

imax = 101
jmax = 101
dx = 0.25
dy = 0.25
xstartlon = 275.0
ystartlat = 50.0
lat_lon_arr = create_lats_lons(imax, jmax, dx, dy, xstartlon, ystartlat)
xlon = lat_lon_arr[0,:]
ylat = lat_lon_arr[1,:]

# ROUTINE CALCDIST
def calcdist(rlonb, rlatb, rlonc, rlatc):

  # numpy calculates pi and deg2rad differently than is done in fortran
  dtr = np.float32(np.pi / 180.0)

  if rlatb < 0.0 or rlatc < 0.0:
    pole = -90.0
  else:
    pole = 90.0

  distlatb = (pole - rlatb) * dtr
  distlatb = round(distlatb, 15)

  distlatc = (pole - rlatc) * dtr
  distlatc = round(distlatc, 15)

  difflon = np.abs((rlonb - rlonc) * dtr)

  cosanga = ( np.cos(distlatb) * (round(np.cos(distlatc),15)) + round(np.sin(distlatb),15) 
            * round(np.sin(distlatc),15) * round(np.cos(difflon),15) )
  cosanga = round(cosanga,15)

  if cosanga > 1.0:
    cosanga = 1.0

  calc_degrees = round(round(np.arccos(cosanga),14) / dtr, 14) # closest we're gonna get
  circ_fract = round(calc_degrees / 360.0, 16) # closest were gonna get

  ecircum = 40030.20   # earth's circumference (km) using erad
  xdist = round(circ_fract * ecircum, 12)

  calc_degrees = round(np.float32(calc_degrees), 6)
  xdist = np.float32(xdist)

  return xdist, calc_degrees

# ROUTINE GENERATE MSLP ARRAY
efold   = 250.0   # e-folding distance for weighting
efoldsq = efold**2

# set the value for the min mslp at the center of the sotrm 
# & the max mslp at the periphery of the storm
xmslp_center = 98500.0
xmslp_outer  = 101300.0

# set the # of point to increment to either side 
# of the grid center point in the loop
xincr = float(imax-1) / 2.0
nincr = int(xincr)

# set the indices for the center point & then set its mslp value to the value specified above with xmslp_center
icenter = nincr + 1
jcenter = nincr + 1

xmslp = np.full((imax,jmax), 0.0)
xmslp[icenter-1,jcenter-1] = xmslp_center

jix = 0
for j in range (-nincr, nincr+1):
  jix = jix + 1

  iix = 0
  for i in range (-nincr, nincr+1):
    iix = iix + 1

    distance, degrees = calcdist(xlon[iix-1], ylat[jix-1], xlon[icenter-1], ylat[jcenter-1])

    wt = np.float32(np.exp(round((-1.0 * distance * distance / efoldsq) ,5)))
    xmslp[iix-1,jix-1] = np.float32(xmslp_center + ((xmslp_outer - xmslp_center) * (1.0 - wt)))
    xmslp[iix-1,jix-1] = round(xmslp[iix-1,jix-1], 1)
# --------------------------------------------------------------------------------------- #

# --------------------------------------------------------------------------------------- #
# --------------------------------- FILL NETCDF DATA ------------------------------------ #

# lats and lons
nlats = len(lat_dim) ; nlons = len(lon_dim)
lat[:] = ylat
lon[:] = xlon

# mslp
mslp[:,:,:] = xmslp



# --------------------------------------------------------------------------------------- #

ncfile.close()