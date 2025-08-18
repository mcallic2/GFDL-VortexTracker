#!/usr/bin/ksh
# LEW - change these to the correct #SBATCH commands if you haven't already
#PBS -j oe -o /scratch4/AOML/aoml-hafs1/role.aoml-hafs1/scrub/HAFSV2.1M_2025_RT/GenesisTracker/2024080812
#PBS -N hfsm_trk
#PBS -A aoml-hafs1
#PBS -l 1:ppn=1:mem=16GB
#PBS -q batch
#PBS -V
#PBS -l walltime=01:00:00

#cd $PBS_O_WORKDIR  # LEW - not sure if this is needed/will break the run
cd /scratch4/AOML/aoml-hafs1/role.aoml-hafs1/scrub/HAFSV2.1M_2025_RT/GenesisTracker/2024080812/

echo " "
echo "date at top of script is `date`"
echo " "

#cd $modulesetup
cd /scratch3/AOML/aoml-hafs1/role.aoml-hafs1/software/GenesisTracker_hafs_scripts/code/modulefile-setup
source ursa-setup.sh	# LEW - replace "jet" corresponding rdhpc system you're using

echo " " 
module list
echo " "

set -x

loopnum=1

stormid=09l
export YMDH=2024092812
CMODEL=hfsm
# trkrtype=tracker
trkrtype=tcgen

export ymdh=${YMDH}
export atcfymdh=${YMDH}

export PS4=' + run_hfsm_track_test.sh line $LINENO: '

export wgrib2=$WGRIB2
export cnvgrib=$CNVGRIB
cgb=$COPYGB
cgb2=$COPYGB2

echo " "
module list
echo " "

#export rundir=/lfs/h2/emc/hur/save/timothy.marchok/trak/para/scripts/hfsm_trak_2025
#export exectrkdir=/lfs/h2/emc/hur/save/timothy.marchok/trak/para/sorc/gettrk.fd/20250704/code/exec
export rundir=/scratch3/AOML/aoml-hafs1/role.aoml-hafs1/software/GenesisTracker_hafs_scripts
export exectrkdir=/scratch3/AOML/aoml-hafs1/role.aoml-hafs1/software/GenesisTracker_hafs_scripts/code/exec

export gix=$GRBINDEX
export g2ix=$GRB2INDEX

export gymdh=${YMDH:-2018101106}
export autosub=${AUTOSUB:-NO}
export cmodel=${CMODEL:-nam}
export stormid=${stormid:-stormid}
export blockid=${BLOCKID:-blockid}

set +x
echo " "
echo "At top of runtrak.sh at `date`"
echo "  AUTOSUB= $AUTOSUB"
echo "  BLOCKID= $BLOCKID"
echo "  STORMID= $STORMID"
echo "  YMDH=    $YMDH"
echo "  CMODEL=  $CMODEL"
echo "  gfsdir=  $gfsdir"
set -x

yyyy=` echo $gymdh | cut -c1-4`
scc=` echo $gymdh | cut -c1-2`
syy=` echo $gymdh | cut -c3-4`
smm=` echo $gymdh | cut -c5-6`
sdd=` echo $gymdh | cut -c7-8`
shh=` echo $gymdh | cut -c9-10`

export PDY=` echo $gymdh | cut -c1-8`
export cyc=` echo $gymdh | cut -c9-10`

export ymdh=${PDY}${cyc}
export CYL=${cyc}

#fcsthrs=' 000 006 012 018 024 030 036 
#          042 048 054 060 066 072 
#          078 084 090 096 102 108 114
#          120 126'

fcsthrs=' 000 003 006 009 012 015 018 021 024 027 030 033 036 
          039 042 045 048 051 054 057 060 063 066 069 072 075
          078 081 084 087 090 093 096 099 102 105 108 111 114
          117 120 123 126'

atcfnum=15
export ATCFNAME="HFSM"
export atcfout=` echo ${ATCFNAME} | tr '[A-Z]' '[a-z]'`
export atcfname=` echo ${ATCFNAME} | tr '[A-Z]' '[a-z]'`
export trkrebd=345.0
export trkrwbd=226.0
export trkrnbd=45.0
export trkrsbd=1.0
regtype=altg
atcffreq=300
rundescr="multistorm"
atcfdescr="trkcut"
file_sequence="multi"
export contour_interval=100.0
max_mslp_850=400.0
mslpthresh=0.0015
v850thresh=1.5000
v850_qwc_thresh=1.0000
cint_grid_bound_check=0.50
modtyp='regional'
nest_type='fixed'
lead_time_units='hours'
export PHASEFLAG=y
export PHASE_SCHEME=both
export WCORE_DEPTH=1.0
export STRUCTFLAG=y
export IKEFLAG=y
export sstflag=y
export shear_calc_flag=y
export genflag=y
export use_land_mask=y
# export read_separate_land_mask_file=y
export read_separate_land_mask_file=n
export gen_read_rh_fields=n
export need_to_compute_rh_from_q=y
export smoothe_mslp_for_gen_scan=y
export depth_of_mslp_for_gen_scan=0.50
export vortex_tilt_flag=n
export vortex_tilt_parm=zeta
# export vortex_tilt_parm=wcirc
# export vortex_tilt_parm=temp
# export vortex_tilt_parm=hgt
export vortex_tilt_allow_thresh=1.0
# g2_jpdtn sets the variable that will be used as "JPDTN" for
# the call to getgb2, if gribver=2.  jpdtn=1 for ens data,
# jpdtn=0 for deterministic data.
g2_jpdtn=0
inp_data_type=grib
gribver=2
#       g2_mslp_parm_id=1
g2_mslp_parm_id=192
#       g1_mslp_parm_id=102
g1_mslp_parm_id=130
g1_sfcwind_lev_typ=105
g1_sfcwind_lev_val=10
model=1                                 

# export hfsmdir=/lfs/h1/ops/prod/com/hafs/v1.0/hfsa.${PDY}/${cyc}
export hfsmdir=/lfs/h2/emc/ptmp/timothy.marchok/trakout3/${PDY}${CYL}/hfsm
export DATA=${hfsmdir}

if [ ! -d ${DATA} ]; then
  mkdir -p ${DATA}
fi

cd ${DATA}

#---------------------------------------------------------
# Soft-link the files to file names that will work with 
# the required format.
#---------------------------------------------------------

if [ ${loopnum} -eq 1 ]
then

  if [ -s ${DATA}/hfsmcutfile ]; then
    rm ${DATA}/hfsmcutfile
  fi

  for fhour in ${fcsthrs}
  do

    if [ ${fhour} -eq 999 ]
    then
      continue
    else
      set +x
      echo "+++ TIMING: BEFORE hfsm cut for fhour= $fhour  ---> `date`"
      set -x
    fi

    let min=fhour*60
    min5=` echo ${min} | awk '{printf ("%5.5d\n",$0)}'`

#    hfsmgfile=${hfsmdir}/${stormid}.${ymdh}.hafs.grid01.f${fhour}.grb2
#    hfsmgfile=${hfsmdir}/${atcfname}.${rundescr}.${atcfdescr}.${gymdh}.f${min5}
#    hfsm_orig_file=${hfsmdir}/${stormid}.${ymdh}.hfsa.parent.trk.f${fhour}.grb2
#    hfsm_renamed_file=${hfsmdir}/${atcfout}.parent.${stormid}.${ymdh}.f${min5}
    hfsm_orig_file=${hfsmdir}/00l.${ymdh}.hfsb_multistorm.parent.atm.f${fhour}.grb2
    hfsm_renamed_file=${hfsmdir}/${atcfout}.multistorm.trkcut.${ymdh}.f${min5}

    if [ -s ${hfsm_orig_file} ]
    then

      origfile=${hfsm_orig_file}

      let min=fhour*60
      min5=` echo ${min} | awk '{printf ("%5.5d\n",$0)}'`

      >${hfsm_renamed_file}

      echo "before wgrib2 for fhour= $fhour at `date`"

#      $wgrib2 -s ${hfsm_orig_file} | egrep "(HGT:900 mb)|(HGT:850 mb)|(HGT:800 mb)|(HGT:750 mb)|(HGT:700 mb)|(HGT:650 mb)|(HGT:600 mb)|(HGT:550 mb)|(HGT:500 mb)|(HGT:450 mb)|(HGT:400 mb)|(HGT:350 mb)|(HGT:300 mb)|(UGRD:850 mb)|(UGRD:700 mb)|(UGRD:500 mb)|(UGRD:200 mb)|(UGRD:10 m )|(VGRD:850 mb)|(VGRD:700 mb)|(VGRD:500 mb)|(VGRD:200 mb)|(VGRD:10 m )|(ABSV:850 mb)|(ABSV:700 mb)|(TMP:500 mb)|(TMP:450 mb)|(TMP:400 mb)|(TMP:350 mb)|(TMP:300 mb)|(MSLET:mean)|(VVEL:500 mb)|(RH:1000)|(RH:925)|(RH:800)|(RH:700)|(RH:650)|(RH:600)|(LAND:surface)|(:TMP:surface)" | $wgrib2 -i ${hfsm_orig_file} -append -grib ${hfsm_renamed_file}

      $wgrib2 -s ${hfsm_orig_file} | egrep "(HGT:900 mb)|(HGT:850 mb)|(HGT:800 mb)|(HGT:750 mb)|(HGT:700 mb)|(HGT:650 mb)|(HGT:600 mb)|(HGT:550 mb)|(HGT:500 mb)|(HGT:450 mb)|(HGT:400 mb)|(HGT:350 mb)|(HGT:300 mb)|(UGRD:850 mb)|(UGRD:700 mb)|(UGRD:500 mb)|(UGRD:200 mb)|(UGRD:10 m )|(VGRD:850 mb)|(VGRD:700 mb)|(VGRD:500 mb)|(VGRD:200 mb)|(VGRD:10 m )|(ABSV:850 mb)|(ABSV:700 mb)|(TMP:500 mb)|(TMP:450 mb)|(TMP:400 mb)|(TMP:350 mb)|(TMP:300 mb)|(MSLET:mean)|(VVEL:500 mb)|(RH:1000)|(RH:925)|(RH:800)|(RH:700)|(RH:650)|(RH:600)|(LAND:surface)|(:TMP:surface)|(TMP:1000)|(TMP:925)|(TMP:800)|(TMP:700)|(TMP:650)|(TMP:600)|(SPFH:1000)|(SPFH:925)|(SPFH:800)|(SPFH:700)|(SPFH:650)|(SPFH:600)" | $wgrib2 -i ${hfsm_orig_file} -append -grib ${hfsm_renamed_file}

      $g2ix ${hfsm_renamed_file} ${hfsm_renamed_file}.ix

      if [ ${PHASEFLAG} = 'y' ]; then

        set +x
        echo " "
        echo "Date in vint temperature interpolation for fhour= $fhour before = `date`"
        echo " "
        set -x

#        gfile=${hfsm_renamed_file}
#        ifile=${hfsm_renamed_file}.ix
#        $g2ix $gfile $ifile
#
##       ----------------------------------------------------
##       First, interpolate height data to get data from
##       300 to 900 mb, every 50 mb....
#
#        gparm=7
#        namelist=${DATA}/vint_input.${PDY}${CYL}.f${fhour}.z
#        echo "&timein ifcsthour=${fhour},"       >${namelist}
#        echo "        iparm=${gparm},"          >>${namelist}
#        echo "        gribver=${gribver},"      >>${namelist}
#        echo "        g2_jpdtn=${g2_jpdtn}/"    >>${namelist}
#
#        ln -s -f ${gfile}                                   fort.11
#        ln -s -f ${rundir}/hfsm_hgt_levs.txt                fort.16
#        ln -s -f ${ifile}                                   fort.31
#        ln -s -f ${DATA}/${cmodel}.${PDY}${CYL}.z.f${fhour} fort.51
#
#        ${exectrkdir}/vint.x <${namelist}
#        rcc=$?
#
#        if [ $rcc -ne 0 ]; then
#          set +x
#          echo " "
#          echo "ERROR in call to vint for GPH at fhour= $fhour"
#          echo "cmodel= $cmodel     rcc= $rcc      EXITING.... "
#          echo " "
#          set -x
##          exit 91
#        fi


#       ----------------------------------------------------
#       Now average the temperature data that we just
#       interpolated to get the mean 300-500 mb temperature...
 
        ffile=${hfsm_renamed_file}
        ifile=${hfsm_renamed_file}.ix
        $g2ix ${ffile} ${ifile}

        gparm=11
        namelist=${DATA}/tave_input.${PDY}${CYL}.f${fhour}
        echo "&timein ifcsthour=${fhour},"       >${namelist}
        echo "        iparm=${gparm},"          >>${namelist}
        echo "        gribver=${gribver},"      >>${namelist}
        echo "        g2_jpdtn=${g2_jpdtn}/"    >>${namelist}

        ln -s -f ${ffile}                                      fort.11
        ln -s -f ${ifile}                                      fort.31
        ln -s -f ${DATA}/${cmodel}_tave.${PDY}${CYL}.f${fhour} fort.51

        set +x
        echo " "
        echo "Timing: date before tave.x for fhour= $fhour is `date`"
        echo " "
        set -x

        ${exectrkdir}/tave.x <${namelist}
        rcc=$?

        if [ $rcc -ne 0 ]; then
          set +x
          echo " "
          echo "ERROR in call to tave for T at fhour= $fhour"
          echo "cmodel= $cmodel    rcc= $rcc      EXITING.... "
          echo " "
          set -x
#          exit 91
        fi

        set +x
        echo " "
        echo "Timing: date after tave.x for fhour= $fhour is `date`"
        echo " "
        set -x

        tavefile=${DATA}/${cmodel}_tave.${PDY}${CYL}.f${fhour}
#        zfile=${DATA}/${cmodel}.${PDY}${CYL}.z.f${fhour}
#        cat ${zfile} ${tavefile} >>${catfile}
        cat ${tavefile} >>${ffile}

        $g2ix ${ffile} ${ffile}.ix

        set +x
        echo " "
        echo "Date in interpolation for fhour= $fhour after = `date`"
        echo " "
        set -x

#      gfile=${DATA}/namlatlon.pgrb.${PDY}${CYL}
#      cat ${catfile} >>${gfile}
 
      fi

    else

      set +x
      echo " "
      echo "ERROR: Original file ${hfsm_orig_file} is missing...."
      echo " "
      set -x

    fi

  done

  gribfile=NULL_USING_MULTI_OPTION
  ixfile=NULL_USING_MULTI_OPTION
#  $gix ${gribfile} ${ixfile}

fi


#----------------------------------------
# Get TC Vitals for this date
#----------------------------------------

#/lfs/h2/emc/hur/save/timothy.marchok/bin/tcvit_date ${gymdh} >${DATA}/vitals.${gymdh}.temp
/scratch3/AOML/aoml-hafs1/role.aoml-hafs1/software/GenesisTracker_hafs_scripts/files/bin/tcvit_date ${gymdh} >${DATA}/vitals.${gymdh}.temp
# cat ${DATA}/vitals.${gymdh}.temp | grep NHC >${DATA}/vitals.${gymdh}
cat ${DATA}/vitals.${gymdh}.temp  >${DATA}/vitals.${gymdh}

if [ -s ${DATA}/vitals.${gymdh} ]; then
  cp ${DATA}/vitals.${gymdh} ${DATA}/tcvit_rsmc_storms.txt
else
  set +x
  echo " "
  echo "!!! ERROR: There are no TC vitals for this date: ${gymdh}"
  echo "!!! EXITING...."
  echo " "
  exit 95
  set -x
fi


#----------------------------------------
#
#----------------------------------------

set -x

user_wants_to_track_zeta850=y                   
user_wants_to_track_zeta700=y                   
user_wants_to_track_wcirc850=y                 
user_wants_to_track_wcirc700=y                
user_wants_to_track_gph850=y                 
user_wants_to_track_gph700=y                
user_wants_to_track_mslp=y                 
user_wants_to_track_wcircsfc=y            
user_wants_to_track_zetasfc=y            
user_wants_to_track_thick500850=n
user_wants_to_track_thick200850=n
user_wants_to_track_thick200500=n

set +x
echo " "
echo "After set perts ${pert}, user_wants_to_track_zeta850= ${user_wants_to_track_zeta850}"
echo "After set perts ${pert}, user_wants_to_track_zeta700= ${user_wants_to_track_zeta700}"
echo "After set perts ${pert}, user_wants_to_track_wcirc850= ${user_wants_to_track_wcirc850}"
echo "After set perts ${pert}, user_wants_to_track_wcirc700= ${user_wants_to_track_wcirc700}"
echo "After set perts ${pert}, user_wants_to_track_gph850= ${user_wants_to_track_gph850}"
echo "After set perts ${pert}, user_wants_to_track_gph700= ${user_wants_to_track_gph700}"
echo "After set perts ${pert}, user_wants_to_track_mslp= ${user_wants_to_track_mslp}"
echo "After set perts ${pert}, user_wants_to_track_wcircsfc= ${user_wants_to_track_wcircsfc}"
echo "After set perts ${pert}, user_wants_to_track_zetasfc= ${user_wants_to_track_zetasfc}"
echo "After set perts ${pert}, user_wants_to_track_thick500850= ${user_wants_to_track_thick500850}"
echo "After set perts ${pert}, user_wants_to_track_thick200500= ${user_wants_to_track_thick200500}"
echo "After set perts ${pert}, user_wants_to_track_thick200850= ${user_wants_to_track_thick200850}"
echo " "
set -x

radii_pctile=95.0
radii_free_pass_pctile=67.0
radii_width_thresh=15.0
write_vit=n
want_oci=.TRUE.
use_backup_mslp_grad_check=${use_backup_mslp_grad_check:-y}      
use_backup_850_vt_check=${use_backup_850_vt_check:-y}            

namelist=${DATA}/input.hfsm_track_test

echo "&datein inp%bcc=${scc},inp%byy=${syy},inp%bmm=${smm},"      >${namelist}
echo "        inp%bdd=${sdd},inp%bhh=${shh},inp%model=${model}," >>${namelist}
echo "        inp%modtyp='${modtyp}',"                           >>${namelist}
echo "        inp%lt_units='${lead_time_units}',"                >>${namelist}
echo "        inp%file_seq='${file_sequence}',"                  >>${namelist}
echo "        inp%nesttyp='${nest_type}'/"                       >>${namelist}
echo "&atcfinfo atcfnum=${atcfnum},atcfname='${ATCFNAME}',"      >>${namelist}
echo "          atcfymdh=${atcfymdh},atcffreq=${atcffreq}/"      >>${namelist}
echo "&trackerinfo trkrinfo%westbd=${trkrwbd},"                  >>${namelist}
echo "      trkrinfo%eastbd=${trkrebd},"                         >>${namelist}
echo "      trkrinfo%northbd=${trkrnbd},"                        >>${namelist}
echo "      trkrinfo%southbd=${trkrsbd},"                        >>${namelist}
echo "      trkrinfo%type='${trkrtype}',"                        >>${namelist}
echo "      trkrinfo%mslpthresh=${mslpthresh},"                  >>${namelist}
echo "      trkrinfo%use_backup_mslp_grad_check='${use_backup_mslp_grad_check}',"  >>${namelist}
echo "      trkrinfo%max_mslp_850=${max_mslp_850},"              >>${namelist}
echo "      trkrinfo%v850thresh=${v850thresh},"                  >>${namelist}
echo "      trkrinfo%v850_qwc_thresh=${v850_qwc_thresh},"        >>${namelist}
echo "      trkrinfo%use_backup_850_vt_check='${use_backup_850_vt_check}',"  >>${namelist}
echo "      trkrinfo%gridtype='${modtyp}',"                      >>${namelist}
echo "      trkrinfo%enable_timing=1,"                           >>${namelist}
echo "      trkrinfo%contint=${contour_interval},"               >>${namelist}
echo "      trkrinfo%want_oci=${want_oci},"                      >>${namelist}
echo "      trkrinfo%out_vit='${write_vit}',"                    >>${namelist}
echo "      trkrinfo%use_land_mask='${use_land_mask}',"          >>${namelist}
echo "      trkrinfo%read_separate_land_mask_file='${read_separate_land_mask_file}',"   >>${namelist}
echo "      trkrinfo%inp_data_type='${inp_data_type}',"          >>${namelist}
echo "      trkrinfo%gribver=${gribver},"                        >>${namelist}
echo "      trkrinfo%g2_jpdtn=${g2_jpdtn},"                      >>${namelist}
echo "      trkrinfo%g2_mslp_parm_id=${g2_mslp_parm_id},"        >>${namelist}
echo "      trkrinfo%g1_mslp_parm_id=${g1_mslp_parm_id},"        >>${namelist}
echo "      trkrinfo%g1_sfcwind_lev_typ=${g1_sfcwind_lev_typ},"  >>${namelist}
echo "      trkrinfo%g1_sfcwind_lev_val=${g1_sfcwind_lev_val}/"  >>${namelist}
echo "&phaseinfo phaseflag='${PHASEFLAG}',"                      >>${namelist}
echo "           phasescheme='${PHASE_SCHEME}',"                 >>${namelist}
echo "           wcore_depth=${WCORE_DEPTH}/"                    >>${namelist}
echo "&structinfo structflag='${STRUCTFLAG}',"                   >>${namelist}
echo "            ikeflag='${IKEFLAG}',"                         >>${namelist}
echo "            radii_pctile=${radii_pctile},"                 >>${namelist}
echo "            radii_free_pass_pctile=${radii_free_pass_pctile},"  >>${namelist}
echo "            radii_width_thresh=${radii_width_thresh}/"     >>${namelist}
echo "&fnameinfo  gmodname='${atcfname}',"                       >>${namelist}
echo "            rundescr='${rundescr}',"                       >>${namelist}
echo "            atcfdescr='${atcfdescr}'/"                     >>${namelist}
echo "&cintinfo contint_grid_bound_check=${cint_grid_bound_check}/" >>${namelist}
echo "&waitinfo use_waitfor='n',"                                >>${namelist}
echo "          wait_min_age=10,"                                >>${namelist}
echo "          wait_min_size=100,"                              >>${namelist}
echo "          wait_max_wait=1800,"                             >>${namelist}
echo "          wait_sleeptime=5,"                               >>${namelist}
echo "          per_fcst_command=''/"                            >>${namelist}
echo "&netcdflist netcdfinfo%num_netcdf_vars=${ncdf_num_netcdf_vars}," >>${namelist}
echo "      netcdfinfo%netcdf_filename='${netcdffile}',"           >>${namelist}
echo "      netcdfinfo%netcdf_lsmask_filename='${ncdf_ls_mask_filename}'," >>${namelist}
echo "      netcdfinfo%rv850name='${ncdf_rv850name}',"             >>${namelist}
echo "      netcdfinfo%rv700name='${ncdf_rv700name}',"             >>${namelist}
echo "      netcdfinfo%u850name='${ncdf_u850name}',"               >>${namelist}
echo "      netcdfinfo%v850name='${ncdf_v850name}',"               >>${namelist}
echo "      netcdfinfo%u700name='${ncdf_u700name}',"               >>${namelist}
echo "      netcdfinfo%v700name='${ncdf_v700name}',"               >>${namelist}
echo "      netcdfinfo%z850name='${ncdf_z850name}',"               >>${namelist}
echo "      netcdfinfo%z700name='${ncdf_z700name}',"               >>${namelist}
echo "      netcdfinfo%mslpname='${ncdf_mslpname}',"               >>${namelist}
echo "      netcdfinfo%usfcname='${ncdf_usfcname}',"               >>${namelist}
echo "      netcdfinfo%vsfcname='${ncdf_vsfcname}',"               >>${namelist}
echo "      netcdfinfo%u500name='${ncdf_u500name}',"               >>${namelist}
echo "      netcdfinfo%v500name='${ncdf_v500name}',"               >>${namelist}
echo "      netcdfinfo%u200name='${ncdf_u200name}',"               >>${namelist}
echo "      netcdfinfo%v200name='${ncdf_v200name}',"               >>${namelist}
echo "      netcdfinfo%tmean_300_500_name='${ncdf_tmean_300_500_name}',"  >>${namelist}
echo "      netcdfinfo%z500name='${ncdf_z500name}',"               >>${namelist}
echo "      netcdfinfo%z200name='${ncdf_z200name}',"               >>${namelist}
echo "      netcdfinfo%lmaskname='${ncdf_lmaskname}',"             >>${namelist}
echo "      netcdfinfo%z900name='${ncdf_z900name}',"               >>${namelist}
echo "      netcdfinfo%z850name='${ncdf_z850name}',"               >>${namelist}
echo "      netcdfinfo%z800name='${ncdf_z800name}',"               >>${namelist}
echo "      netcdfinfo%z750name='${ncdf_z750name}',"               >>${namelist}
echo "      netcdfinfo%z700name='${ncdf_z700name}',"               >>${namelist}
echo "      netcdfinfo%z650name='${ncdf_z650name}',"               >>${namelist}
echo "      netcdfinfo%z600name='${ncdf_z600name}',"               >>${namelist}
echo "      netcdfinfo%z550name='${ncdf_z550name}',"               >>${namelist}
echo "      netcdfinfo%z500name='${ncdf_z500name}',"               >>${namelist}
echo "      netcdfinfo%z450name='${ncdf_z450name}',"               >>${namelist}
echo "      netcdfinfo%z400name='${ncdf_z400name}',"               >>${namelist}
echo "      netcdfinfo%z350name='${ncdf_z350name}',"               >>${namelist}
echo "      netcdfinfo%z300name='${ncdf_z300name}',"               >>${namelist}
echo "      netcdfinfo%time_name='${ncdf_time_name}',"             >>${namelist}
echo "      netcdfinfo%lon_name='${ncdf_lon_name}',"               >>${namelist}
echo "      netcdfinfo%lat_name='${ncdf_lat_name}',"               >>${namelist}
echo "      netcdfinfo%time_units='${ncdf_time_units}',"           >>${namelist}
echo "      netcdfinfo%sstname='${ncdf_sstname}',"                 >>${namelist}
echo "      netcdfinfo%q850name='${ncdf_q850name}',"               >>${namelist}
echo "      netcdfinfo%rh1000name='${ncdf_rh1000name}',"           >>${namelist}
echo "      netcdfinfo%rh925name='${ncdf_rh925name}',"             >>${namelist}
echo "      netcdfinfo%rh800name='${ncdf_rh800name}',"             >>${namelist}
echo "      netcdfinfo%rh750name='${ncdf_rh750name}',"             >>${namelist}
echo "      netcdfinfo%rh700name='${ncdf_rh700name}',"             >>${namelist}
echo "      netcdfinfo%rh650name='${ncdf_rh650name}',"             >>${namelist}
echo "      netcdfinfo%rh600name='${ncdf_rh600name}',"             >>${namelist}
echo "      netcdfinfo%spfh1000name='${ncdf_spfh1000name}',"       >>${namelist}
echo "      netcdfinfo%spfh925name='${ncdf_spfh925name}',"         >>${namelist}
echo "      netcdfinfo%spfh800name='${ncdf_spfh800name}',"         >>${namelist}
echo "      netcdfinfo%spfh750name='${ncdf_spfh750name}',"         >>${namelist}
echo "      netcdfinfo%spfh700name='${ncdf_spfh700name}',"         >>${namelist}
echo "      netcdfinfo%spfh650name='${ncdf_spfh650name}',"         >>${namelist}
echo "      netcdfinfo%spfh600name='${ncdf_spfh600name}',"         >>${namelist}
echo "      netcdfinfo%temp1000name='${ncdf_temp1000name}',"       >>${namelist}
echo "      netcdfinfo%temp925name='${ncdf_temp925name}',"         >>${namelist}
echo "      netcdfinfo%temp800name='${ncdf_temp800name}',"         >>${namelist}
echo "      netcdfinfo%temp750name='${ncdf_temp750name}',"         >>${namelist}
echo "      netcdfinfo%temp700name='${ncdf_temp700name}',"         >>${namelist}
echo "      netcdfinfo%temp650name='${ncdf_temp650name}',"         >>${namelist}
echo "      netcdfinfo%temp600name='${ncdf_temp600name}',"         >>${namelist}
echo "      netcdfinfo%omega500name='${ncdf_omega500name}'/"       >>${namelist}
echo "&parmpreflist user_wants_to_track_zeta850='${user_wants_to_track_zeta850}'," >>${namelist}
echo "      user_wants_to_track_zeta700='${user_wants_to_track_zeta700}',"         >>${namelist}
echo "      user_wants_to_track_wcirc850='${user_wants_to_track_wcirc850}',"       >>${namelist}
echo "      user_wants_to_track_wcirc700='${user_wants_to_track_wcirc700}',"       >>${namelist}
echo "      user_wants_to_track_gph850='${user_wants_to_track_gph850}',"           >>${namelist}
echo "      user_wants_to_track_gph700='${user_wants_to_track_gph700}',"           >>${namelist}
echo "      user_wants_to_track_mslp='${user_wants_to_track_mslp}',"               >>${namelist}
echo "      user_wants_to_track_wcircsfc='${user_wants_to_track_wcircsfc}',"       >>${namelist}
echo "      user_wants_to_track_zetasfc='${user_wants_to_track_zetasfc}',"         >>${namelist}
echo "      user_wants_to_track_thick500850='${user_wants_to_track_thick500850}'," >>${namelist}
echo "      user_wants_to_track_thick200500='${user_wants_to_track_thick200500}'," >>${namelist}
echo "      user_wants_to_track_thick200850='${user_wants_to_track_thick200850}'/" >>${namelist}
echo "&verbose verb=3,verb_g2=0/"                                >>${namelist}
echo "&sheardiaginfo shearflag='${shear_calc_flag}'/"                  >>${namelist}
echo "&sstdiaginfo sstflag='${sstflag}'/"                              >>${namelist}
echo "&gendiaginfo genflag='${genflag}',"                              >>${namelist}
echo "             gen_read_rh_fields='${gen_read_rh_fields}',"        >>${namelist}
echo "             need_to_compute_rh_from_q='${need_to_compute_rh_from_q}',"  >>${namelist}
echo "             smoothe_mslp_for_gen_scan='${smoothe_mslp_for_gen_scan}',"  >>${namelist}
echo "             depth_of_mslp_for_gen_scan=${depth_of_mslp_for_gen_scan}/"  >>${namelist}
echo "&vortextiltinfo vortex_tilt_flag='${vortex_tilt_flag}',"                 >>${namelist}
echo "                vortex_tilt_parm='${vortex_tilt_parm}',"                 >>${namelist}
echo "                vortex_tilt_allow_thresh=${vortex_tilt_allow_thresh}/"   >>${namelist}


gribfile=${gribfile}
ixfile=${ixfile}
# gribfile=NULL
# ixfile=NULL

cp ${namelist} ${DATA}/namelist.gettrk

ln -s -f namelist.gettrk                                   fort.555

ln -s -f ${gribfile}                                       fort.11
ln -s -f ${rundir}/${cmodel}.tracker_leadtimes             fort.15
ln -s -f ${ixfile}                                         fort.31

ln -s -f ${DATA}/trak.${atcfout}.all.${PDY}${CYL}          fort.61
ln -s -f ${DATA}/trak.${atcfout}.atcf.${PDY}${CYL}         fort.62
ln -s -f ${DATA}/trak.${atcfout}.radii.${PDY}${CYL}        fort.63
ln -s -f ${DATA}/trak.${atcfout}.atcfunix.${PDY}${CYL}     fort.64
ln -s -f ${DATA}/trak.${atcfout}.atcf_gen.${PDY}${CYL}     fort.66
ln -s -f ${DATA}/trak.${atcfout}.atcfunix_ext.${PDY}${CYL} fort.68
ln -s -f ${DATA}/trak.${atcfout}.atcf_hfip.${PDY}${CYL}    fort.69
ln -s -f ${DATA}/trak.${atcfout}.parmfixes.${PDY}${CYL}    fort.81

if [ ${write_vit} = 'y' ]
then
  ln -s -f ${DATA}/output_genvitals.${atcfout}.${PDY}${shh}        fort.67
fi

if [ ${PHASEFLAG} = 'y' ]; then
  ln -s -f ${DATA}/trak.${atcfout}.cps_parms.${PDY}${CYL}          fort.71
fi

if [ ${STRUCTFLAG} = 'y' ]; then
  ln -s -f ${DATA}/trak.${atcfout}.structure.${PDY}${CYL}          fort.72
  ln -s -f ${DATA}/trak.${atcfout}.fractwind.${PDY}${CYL}          fort.73
  ln -s -f ${DATA}/trak.${atcfout}.pdfwind.${PDY}${CYL}            fort.76
fi

if [ ${IKEFLAG} = 'y' ]; then
  ln -s -f ${DATA}/trak.${atcfout}.ike.${PDY}${CYL}                fort.74
fi

if [ ${trkrtype} = 'midlat' -o ${trkrtype} = 'tcgen' ]; then
  ln -s -f ${DATA}/trkrmask.${atcfout}.${regtype}.${PDY}${CYL}     fort.77
fi

# export HD_PATH=/cluster/machine/centos-6.8-x86_64/image/apps/hdf5/1.8.9-intel/lib
# export LD_LIBRARY_PATH=${HD_PATH}:${LD_LIBRARY_PATH}

set +x
echo " "
echo "TIMING: Date before running gettrk = `date`"
echo " "
set -x

${exectrkdir}/gettrk.x

set +x
echo " "
echo "TIMING: Date after running gettrk = `date`"
echo " "
set -x
