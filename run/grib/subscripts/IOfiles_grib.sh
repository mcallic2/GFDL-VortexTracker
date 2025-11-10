#!/bin/bash

set -x
# -------------------------------------------------------------------------------------------------
# SET UP INPUT/OUTPUT FILES

# go into work dir to add files
cd ${wdir}

# link various files that are either needed as input to the tracker or are output from the tracker
cp ${namelist} namelist.gettrk
ln -s -f namelist.gettrk                                       fort.555

if [ ${file_sequence} = 'onebig' ]; then
  ln -s -f ${gribfile}                                         fort.11
  ln -s -f ${ixfile}                                           fort.31
fi

if [ -s ${wdir}/vitals.${initymdh} ]; then
  cp ${wdir}/vitals.${initymdh} ${wdir}/tcvit_rsmc_storms.txt
else
  > ${wdir}/tcvit_rsmc_storms.txt
fi

if [ -s ${wdir}/genvitals.upd.${atcfname}.${pdy}${hh} ]; then
  cp ${wdir}/genvitals.upd.${atcfname}.${pdy}${hh} ${wdir}/tcvit_genesis_storms.txt
else
  > ${wdir}/tcvit_genesis_storms.txt
fi

ln -s -f ${rundir}/leadtimes.txt                               fort.15

if [ ${vortex_tilt_flag} = 'y' ]; then
  ln -s -f ${rundir}/vortex_tilt_levs.txt  fort.18
  ln -s -f ${wdir}/trak.${atcfname}.vortex_tilt.${pdy}${hh}    fort.82
fi

if [ ${trkrtype} = 'tracker' ]; then
  ln -s -f ${wdir}/trak.${atcfname}.all.${pdy}${hh}            fort.61
  ln -s -f ${wdir}/trak.${atcfname}.atcf.${pdy}${hh}           fort.62
  ln -s -f ${wdir}/trak.${atcfname}.atcfunix.${pdy}${hh}       fort.64
  ln -s -f ${wdir}/trak.${atcfname}.atcfunix_ext.${pdy}${hh}   fort.68
  ln -s -f ${wdir}/trak.${atcfname}.atcf_hfip.${pdy}${hh}      fort.69
  ln -s -f ${wdir}/trak.${atcfname}.parmfix.${pdy}${hh}        fort.81
else  # trkrtype = tcgen
  ln -s -f ${wdir}/trak.${atcfname}.all.${pdy}${hh}            fort.61
  ln -s -f ${wdir}/trak.${atcfname}.atcf.${pdy}${hh}           fort.62
  ln -s -f ${wdir}/trak.${atcfname}.atcfunix.${pdy}${hh}       fort.64
  ln -s -f ${wdir}/trak.${atcfname}.atcf_gen.${pdy}${hh}       fort.66
  ln -s -f ${wdir}/trak.${atcfname}.atcfunix_ext.${pdy}${hh}   fort.68
  ln -s -f ${wdir}/trak.${atcfname}.atcf_hfip.${pdy}${hh}      fort.69
  ln -s -f ${wdir}/trak.${atcfname}.parmfix.${pdy}${hh}        fort.81
fi

if [ ${atcfname} = 'aear' ]
then
  ln -s -f ${wdir}/trak.${atcfname}.initvitl.${pdy}${hh}       fort.65
fi

if [ ${write_vit} = 'y' ]
then
  ln -s -f ${wdir}/output_genvitals.${atcfname}.${pdy}${hh}    fort.67
fi

if [ ${phaseflag} = 'y' ]; then
  ln -s -f ${wdir}/trak.${atcfname}.cps_parms.${pdy}${hh}      fort.71
fi

if [ ${structflag} = 'y' ]; then
  ln -s -f ${wdir}/trak.${atcfname}.structure.${pdy}${hh}      fort.72
  ln -s -f ${wdir}/trak.${atcfname}.fractwind.${pdy}${hh}      fort.73
  ln -s -f ${wdir}/trak.${atcfname}.pdfwind.${pdy}${hh}        fort.76
fi

if [ ${ikeflag} = 'y' ]; then
  ln -s -f ${wdir}/trak.${atcfname}.ike.${pdy}${hh}            fort.74
fi

if [ ${trkrtype} = 'midlat' -o ${trkrtype} = 'tcgen' -o ${trkrtype} = 'tracker' ]; then
  ln -s -f ${wdir}/trkrmask.${atcfname}.${pdy}${hh}            fort.77
fi

# -------------------------------------------------------------------------------------------------
set +x