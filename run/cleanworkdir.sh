#!/bin/bash

# -------------------------------------------------------------------------------------------------
# CLEAN UP WORK DIRECTORY

# create directory to put atcf output files
export outputdir=${wdir}/output_files
if [ ! -d ${outputdir} ]; then mkdir -p ${outputdir}; fi

# move all output files from wdir to output_files dir
mv trak.* ${outputdir}

cd ${wdir}
# remove fort files
rm fort.*

# remove repeated files
rm vitals.${curymdh}
rm tracker_leadtimes
rm input.${atcfout}.${pdy}${cyc}
