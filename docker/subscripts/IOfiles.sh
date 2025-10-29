#!/bin/bash -x

# -------------------------------------------------------------------------------------------------
# SET UP INPUT/OUTPUT FILES

# go into work dir to add files
cd ${wdir}

# link various files that are either needed as input to the tracker, or are output from the tracker
cp ${namelist} namelist.gettrk
ln -s -f namelist.gettrk                               fort.555

cp ${netcdffile} ${wdir}
ln -s -f ${data_file}                                  fort.11

if [ -s ${wdir}/vitals.${curymdh} ]; then
  cp ${wdir}/vitals.${curymdh} ${wdir}/tcvit_rsmc_storms.txt
else
  > ${wdir}/tcvit_rsmc_storms.txt
fi

if [ -s ${wdir}/genvitals.upd.${atcfout}.${pdy} ]; then   #caitlyn, removing shh var from these
  cp ${DATA}/genvitals.upd.${atcfout}.${pdy} ${wdir}/tcvit_genesis_storms.txt
else
  > ${DATA}/tcvit_genesis_storms.txt
fi

cp ${rundir}/tracker_leadtimes ${wdir}/tracker_leadtimes
ln -s -f tracker_leadtimes                             fort.15

if [ ${trkrtype} = 'tracker' ]; then
  ln -s -f ${wdir}/trak.${atcfout}.all.${pdy}          fort.61
  ln -s -f ${wdir}/trak.${atcfout}.atcf.${pdy}         fort.62
  ln -s -f ${wdir}/trak.${atcfout}.radii.${pdy}        fort.63
  ln -s -f ${wdir}/trak.${atcfout}.atcfunix.${pdy}     fort.64
  ln -s -f ${wdir}/trak.${atcfout}.atcf_gen.${pdy}     fort.66
  ln -s -f ${wdir}/trak.${atcfout}.atcfunix_ext.${pdy} fort.68
  ln -s -f ${wdir}/trak.${atcfout}.atcf_hfip.${pdy}    fort.69
  ln -s -f ${wdir}/trak.${atcfout}.parmfix.${pdy}      fort.81
else    # if trkrtype=tcgen
  ln -s -f ${wdir}/trak.${atcfout}.all.${pdy}          fort.61
  ln -s -f ${wdir}/trak.${atcfout}.atcf.${pdy}         fort.62
  ln -s -f ${wdir}/trak.${atcfout}.radii.${pdy}        fort.63
  ln -s -f ${wdir}/trak.${atcfout}.atcfunix.${pdy}     fort.64
  ln -s -f ${wdir}/trak.${atcfout}.atcf_gen.${pdy}     fort.66
  ln -s -f ${wdir}/trak.${atcfout}.atcfunix_ext.${pdy} fort.68
  ln -s -f ${wdir}/trak.${atcfout}.atcf_hfip.${pdy}    fort.69
  ln -s -f ${wdir}/trak.${atcfout}.parmfix.${pdy}      fort.81
fi

if [ ${phaseflag} = 'y' ]; then
  ln -s -f ${wdir}/trak.${atcfout}.cps_parms.${pdy}    fort.71
fi

if [ ${structflag} = 'y' ]; then
  ln -s -f ${wdir}/trak.${atcfout}.structure.${pdy}    fort.72
  ln -s -f ${wdir}/trak.${atcfout}.fractwind.${pdy}    fort.73
  ln -s -f ${wdir}/trak.${atcfout}.pdfwind.${pdy}      fort.76
fi

if [ ${ikeflag} = 'y' ]; then
  ln -s -f ${wdir}/trak.${atcfout}.ike.${pdy}          fort.74
fi

if [ ${trkrtype} = 'midlat' -o ${trkrtype} = 'tcgen' -o ${trkrtype} = 'tracker' ]; then
  ln -s -f ${wdir}/trkrmask.${atcfout}.${pdy}          fort.77
fi
