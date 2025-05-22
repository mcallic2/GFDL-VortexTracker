#!/bin/ksh

# --------------------------------------------------------------
# This script uses wgrib to strip off the extra records beyond 
# record #725 that were added by vint.x and tave.x in previous
# runs of the tracker script.  Effectively, this then returns
# the ecgribfile back to its original state.

edir=/mnt/lfs1/HFIP/hfip-gfdl/cmout/2022092200/ecmwf
cd $edir

ecfile=ecgribfile.2022092200

wgrib -s ${ecfile}  | head -725 | wgrib -i ${ecfile} -grib -o newgrib
rcc=$?

if [ $rcc -eq 0 ]; then
  mv newgrib ${ecfile}
fi
