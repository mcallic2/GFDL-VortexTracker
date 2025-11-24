#!/bin/bash

set -x
# -------------------------------------------------------------------------------------------------
# CLEAN UP NETCDF WORK DIRECTORY

# move into wdir
cd ${wdir}

# create output files directory
export outputdir=${trkrtype}-output
mkdir ${outputdir}

# move all trak.atcfname.* files into tracker_output directory
mv trak.${atcfname}.* ${outputdir}/.

# remove symlink fort files now that actual output files have been populated
rm fort.*

# remove extra namelist file; keep namelist.gettrk for reference
rm input.${atcfname}.${ymdh}

# keep vitals.ymdh, remove any other vitals file in work directory
rm tcvit_*_storms.txt

# remove copied datafile from work directory to save space
rm ${ncdf_filename}

# -------------------------------------------------------------------------------------------------
set +x