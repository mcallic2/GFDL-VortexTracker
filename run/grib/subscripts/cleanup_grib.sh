#!/bin/bash

set -x
# -------------------------------------------------------------------------------------------------
# CLEAN UP GRIB WORK DIRECTORY

# move into wdir
cd ${wdir}

# ---------- onebig ----------

if [ ${file_sequence} = 'onebig']; then

  # create output files directory
  export outputfiles=${trkrtype}-output
  mkdir ${outputfiles}

  



# fort.* files
# datafile
# datafile.ix
# atcfname.ymdh.t.fcsthrs + 22
# atcfname.ymdh.z.fcsthrs + 22
# input.atcfname.ymdh
# tcvit_*.txt
# vint_input.ymdh.t
# vint_input.ymdh.z
# vitals.ymdh ?

# ---------- multi ----------

# fort.* files
# datafile.fcsthrs + 22
# datafile.fcsthrs.ix + 22 
# atcfname.ymdh.t.fcsthrs + 22
# atcfname.ymdh.z.fcsthrs + 22
# input.atcfname.ymdh
# tcvit_*.txt
# create outputfiles directory
# move all trak.atcfname.* files into outputfiles directory
# vint_input.ymdh.t
# vint_input.ymdh.z
# vitals.ymdh ?

# -------------------------------------------------------------------------------------------------
set +x