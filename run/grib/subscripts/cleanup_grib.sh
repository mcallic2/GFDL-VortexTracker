#!/bin/bash

set -x
# -------------------------------------------------------------------------------------------------
# CLEAN UP GRIB WORK DIRECTORY

# move into wdir
cd ${wdir}

# ---------- onebig ----------

if [ ${file_sequence} = 'onebig' ]; then

  # create output files directory
  export outputdir=${trkrtype}-output
  if [ ! -d ${outputdir} ]; then mkdir -p ${outputdir}; fi
  
  # move all trak.atcfname.* files into tracker_output directory
  mv trak.${atcfname}.* ${outputdir}/.

  # move tracker mask file for genesis runs in output file directory
  if [ ${trkrtype} = 'tcgen' ]; then
    mv trkrmask.${atcfname}.${ymdh} ${outputdir}/.
  fi

  # remove symlink fort files now that actual output files have been populated
  rm fort.*

  # remove extra namelist file; keep namelist.gettrk for reference
  rm input.${atcfname}.${ymdh}

  # keep vitals.ymdh, remove any other vitals file in work directory
  rm tcvit_*_storms.txt
  
  # remove copied input grib data file and grib index file that was created to save space
  rm ${gribfile}; rm ${ixfile}

  # if interpolation code used, remove excess files created from calculations
  if [ ${need_to_use_vint_or_tave} = 'y' ]; then
    for fhour in ${fcsthrs}
    do
      # remove files created from vint.f and tave.f for each indiviual forecast hr
      rm ${filebase}.z.f${fhour}
      rm ${filebase}.t.f${fhour}
    done
  fi
fi
      
# vint_input.ymdh.t & vint_input.ymdh.z --> keeping for now

# ---------- multi ----------

if [ ${file_sequence} = 'multi' ]; then

  # create output files directory
  export outputdir=${trkrtype}-output
  if [ ! -d ${outputdir} ]; then mkdir -p ${outputdir}; fi

  # move all trak.atcfname.* files into tracker_output directory
  mv trak.${atcfname}.* ${outputdir}/.

  # move tracker mask file for genesis runs in output file directory
  if [ ${trkrtype} = 'tcgen' ]; then
    mv trkrmask.${atcfname}.${ymdh} ${outputdir}/.
  fi

  # remove symlink fort files now that actual output files have been populated
  rm fort.*

  # remove extra namelist file; keep namelist.gettrk for reference
  rm input.${atcfname}.${ymdh}

  # keep vitals.ymdh, remove any other vitals file in work directory
  rm tcvit_*_storms.txt

  # if interpolation code used, remove excess files created from calculations
  if [ ${need_to_use_vint_or_tave} = 'y' ]; then
    for fhour in ${fcsthrs}
    do
      let min=fhour*60
      export min5=` echo ${min} | awk '{printf ("%5.5d\n",$0)}'`
      # remove copied input grib data file and grib index file that was created to save space
      rm ${filebase}.f${min5}
      rm ${filebase}.f${min5}.ix
      # remove files created from vint.f and tave.f for each indiviual forecast hr
      rm ${filebase}.z.f${fhour}
      rm ${filebase}.t.f${fhour}
    done
  fi
fi

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