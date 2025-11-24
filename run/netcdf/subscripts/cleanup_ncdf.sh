#!/bin/bash

set -x
# -------------------------------------------------------------------------------------------------
# CLEAN UP WORK DIRECTORY

# move into wdir
cd ${wdir}

# create output files directory
export outputfiles='tracker_output'
mkdir ${outputfiles}

# move all trak.atcfname.* files into tracker_output directory
mv trak.${atcfname}.* ${outputfiles}/.

# fort.* files
# input.atcfname.ymdh --> namelist.gettrk
  # remove input.atcfname.ymdh; no reason to have 2 of the same files
# datafile
# figure out what tcvit_*.txt files are
  # tcvit_genesis.txt has nothing in it, probably shouldn't be created if not in tcgen mode
  # tcvit_rsmc.txt == vitals.ymdh; remove tcvit_rsmc.txt
# create outputfiles directory
# move trak.atcfname.* files into outputfiles directory
# vitals.ymdh --> keep, especially since developer may be using their own file

# -------------------------------------------------------------------------------------------------
set +x