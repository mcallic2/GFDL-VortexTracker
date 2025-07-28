#!/bin/bash -x

# -------------------------------------------------------------------------------------------------
# SET UP PATHS

# print line numbers in std out
export PS4=' line $LINENO: '

# set directory paths
export home=/home/vortextracker
export workroot=${home}/work/allflags/tcgen_run2
export codedir=${home}/code
export execdir=${codedir}/exec
export rundir=${home}/run
export tcvit_date=${home}/files/bin/tcvit_date
export ndate=${home}/files/bin/ndate.x

# set model initialization variables
export curymdh=2023082900   # model initialization date
export pdy=`     echo ${curymdh} | cut -c1-8`
export yyyy=`    echo ${curymdh} | cut -c1-4`
export cyc=`     echo ${curymdh} | cut -c9-10`
export ymdh=${pdy}${cyc}

# set date stamp var
export date_stamp=$(date +"%a %b %d %H:%M:%S %Z %Y")

# set wdir path
wdir=${workroot}/${curymdh}
if [ ! -d ${wdir} ]; then mkdir -p ${wdir}; fi

# -------------------------------------------------------------------------------------------------
# BUILD & COMPILE TRACKER EXECUTABLES

# create build directory & move into it
export builddir=${codedir}/build
if [ ! -d ${builddir} ]; then mkdir -p ${builddir}; fi
cd ${builddir}

# remove contents of build dir for fresh compilation
if [ -d ${builddir} ]; then rm -rf {*,*}; fi

# build code
cmake ..

# compile code
make

# install executables
make install

# move back into run dir
cd ${rundir}

# -------------------------------------------------------------------------------------------------
# SET UP ENVIRONMENT VARIABLES

export ncdf_ls_mask_filename=		# used for other models, not needed for tshield
export gribver=1
export basin=al
export trkrtype=tcgen
export trkrebd=339.0   # boundary only if trkrtype = tcgen or midlat
export trkrwbd=260.0   # boundary only if trkrtype = tcgen or midlat
export trkrnbd=40.0    # boundary only if trkrtype = tcgen or midlat
export trkrsbd=7.0     # boundary only if trkrtype = tcgen or midlat
export regtype=altg    # This variable only needed if trkrtype = tcgen or midlat
export atcfnum=15
export atcfname="tshld"
export atcfout="tshld"
export atcfymdh=${pdy}${cyc}
export max_mslp_850=400.0
export mslpthresh=0.0015
export v850thresh=1.5000
export v850_qwc_thresh=1.0000
export cint_grid_bound_check=0.50
export modtyp='regional'
export nest_type='fixed'
export wcore_depth=1.0
export phaseflag=y
export phase_scheme=both
export structflag=y
export ikeflag=y
export genflag=y
export sstflag=y
export shear_calc_flag=y
export gen_read_rh_fields=n
export read_separate_land_mask_file=n
export need_to_compute_rh_from_q=y
export smoothe_mslp_for_gen_scan=y
export atcfnum=15
export atcffreq=600
export rundescr="xxxx"
export atcfdescr="xxxx"
export file_sequence="onebig"
export contour_interval=1.0
export radii_pctile=95.0
export radii_free_pass_pctile=67.0
export radii_width_thresh=15.0
export write_vit=n
export want_oci=.TRUE.

# add variables that aren't set but are in namelist
export scc=0
export syy=0
export smm=0
export sdd=0
export shh=0
export g1_mslp_parm_id=0
export g1_sfcwind_lev_typ=0
export g1_sfcwind_lev_val=0

export lead_time_units=' '   # stays blank b/c units are determinded during ncdump of file  
export g2_jpdtn=0
export inp_data_type=netcdf
export model=41

export use_land_mask=n
export use_land_mask=${use_land_mask:-no}
export use_backup_mslp_grad_check=${use_backup_mslp_grad_check:-y}  #caitlyn, use_backup_mslp_grad_check var isn't in the list yet
export use_backup_850_vt_check=${use_backup_850_vt_check:-y}	    #caitlyn, same thing for this


# -------------------------------------------------------------------------------------------------
# SET UP KNOWN TCVITALS FILE

export tcvit_logfile=${rundir}/tcvit_logfile.${yyyy}.txt
${tcvit_date} ${curymdh} | egrep "JTWC|NHC" | grep -v TEST | awk 'substr($0,6,1) !~ /8/ {print $0}' > ${wdir}/vitals.${curymdh}
export num_storms="$(cat ${wdir}/vitals.${curymdh} | wc -l)"

if [ ${num_storms} -gt 0 ]; then
  echo " "
  echo "${num_storms} Observed storms exist for ${curymdh}: " | tee -a ${tcvit_logfile}
  cat ${wdir}/vitals.${curymdh}
  cat ${wdir}/vitals.${curymdh} >> ${tcvit_logfile}
  echo " "
else
  touch ${wdir}/vitals.${curymdh}
fi

# -------------------------------------------------------------------------------------------------
# SET UP NETCDF VARIABLE DEFINITIONS

export ncdf_num_netcdf_vars=999
export ncdf_rv850name="X"
export ncdf_rv700name="X"
export ncdf_u850name="u850"
export ncdf_v850name="v850"
export ncdf_u700name="u700"
export ncdf_v700name="v700"
export ncdf_z850name="h850"
export ncdf_z700name="h700"
export ncdf_mslpname="PRMSL"
export ncdf_usfcname="UGRD10m"
export ncdf_vsfcname="VGRD10m"
export ncdf_u500name="u500"
export ncdf_v500name="v500"
export ncdf_u200name="u200"
export ncdf_v200name="v200"
export ncdf_tmean_300_500_name="TMP500_300"
export ncdf_z200name="X"
export ncdf_lmaskname="X"
export ncdf_z900name="h900"
export ncdf_z800name="h800"
export ncdf_z750name="h750"
export ncdf_z650name="h650"
export ncdf_z600name="h600"
export ncdf_z550name="h550"
export ncdf_z500name="h500"
export ncdf_z450name="h450"
export ncdf_z400name="h400"
export ncdf_z350name="h350"
export ncdf_z300name="h300"
export ncdf_time_name="time"
export ncdf_lon_name="grid_xt"
export ncdf_lat_name="grid_yt"
export ncdf_sstname="TMPsfc"
export ncdf_q850name="q850"
export ncdf_rh1000name="X"
export ncdf_rh925name="X"
export ncdf_rh800name="X"
export ncdf_rh750name="X"
export ncdf_rh700name="X"
export ncdf_rh650name="X"
export ncdf_rh600name="X"
export ncdf_spfh1000name="q1000"
export ncdf_spfh925name="q925"
export ncdf_spfh800name="q800"
export ncdf_spfh750name="q750"
export ncdf_spfh700name="q700"
export ncdf_spfh650name="q650"
export ncdf_spfh600name="q600"
export ncdf_temp1000name="t1000"
export ncdf_temp925name="t925"
export ncdf_temp800name="t800"
export ncdf_temp750name="t750"
export ncdf_temp700name="t700"
export ncdf_temp650name="t650"
export ncdf_temp600name="t600"
export ncdf_omega500name="omg500"

# -------------------------------------------------------------------------------------------------
# SET UP INPUT NETCDF DATA FILE

# define netcdf data file & set path
export data_dir=/home/vortextracker/tshield_data
export data_file=combined.2023082900.nc
export netcdffile=${data_dir}/combined.2023082900.nc

# get netcdf time units
ncdf_time_units="$(ncdump -h $netcdffile | grep "time:units" | awk -F= '{print $2}' | awk -F\" '{print $2}' | awk '{print $1}')"
export ${ncdf_time_units}
echo " "
echo "NetCDF time units pulled from data file = ${ncdf_time_units}"
echo " "

# -------------------------------------------------------------------------------------------------
# SET UP INPUT NETCDF DATA FILE

# create namelist file in work directory
export namelist=${wdir}/input.${atcfout}.${pdy}${cyc}		#caitlyn, still might want to delete the $atcfout flag, come back

# populate namelist file with defined variables
echo "&datein inp%bcc=${scc},inp%byy=${syy},inp%bmm=${smm},"      >${namelist}
echo "        inp%bdd=${sdd},inp%bhh=${shh},inp%model=${model}," >>${namelist}
echo "        inp%modtyp='${modtyp}',"                           >>${namelist}
echo "        inp%lt_units='${lead_time_units}',"                >>${namelist}
echo "        inp%file_seq='${file_sequence}',"                  >>${namelist}
echo "        inp%nesttyp='${nest_type}'/"                       >>${namelist}
echo "&atcfinfo atcfnum=${atcfnum},atcfname='${atcfname}',"      >>${namelist}
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
echo "&phaseinfo phaseflag='${phaseflag}',"                      >>${namelist}
echo "           phasescheme='${phase_scheme}',"                 >>${namelist}
echo "           wcore_depth=${wcore_depth}/"                    >>${namelist}
echo "&structinfo structflag='${structflag}',"                   >>${namelist}
echo "            ikeflag='${ikeflag}',"                         >>${namelist}
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
echo "      netcdfinfo%netcdf_filename='${netcdffile}',"                   >>${namelist}
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
echo "&verbose verb=3,verb_g2=0/"                                      >>${namelist}
echo "&sheardiaginfo shearflag='${shear_calc_flag}'/"                  >>${namelist}
echo "&sstdiaginfo sstflag='${sstflag}'/"                              >>${namelist}
echo "&gendiaginfo genflag='${genflag}',"                              >>${namelist}
echo "             gen_read_rh_fields='${gen_read_rh_fields}',"        >>${namelist}
echo "             need_to_compute_rh_from_q='${need_to_compute_rh_from_q}',"  >>${namelist}
echo "             smoothe_mslp_for_gen_scan='${smoothe_mslp_for_gen_scan}'/"  >>${namelist}

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
else	# if trkrtype=tcgen
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

# -------------------------------------------------------------------------------------------------
# PRINT TRACKER SETUP FINISHED MESSAGE

echo "TRACKER SET UP FINISHED"

# -------------------------------------------------------------------------------------------------
# EXECUTE TRACKER SOURCE CODE

echo " "
echo "INITIALIZE TRACKER EXECUTABLE"
echo " "

echo "gettrk start for $atcfout at ${cyc}z at ${date_stamp}"

echo "TIMING: BEFORE gettrk  ---> ${date_stamp}"

export for_dump_core_file=TRUE
ulimit -s unlimited

echo " "
echo "before gettrk, Output of ulimit command follows...."
ulimit -a
echo "before gettrk, Done: Output of ulimit command."
${execdir}/gettrk.x
export gettrk_rcc=$?

echo "   TIMING: AFTER  gettrk  ---> ${date_stamp}"
echo "   "
echo "   Return code from tracker= gettrk_rcc= ${gettrk_rcc}"
echo "   "

# -------------------------------------------------------------------------------------------------
# MOVE TRAK.* OUTPUT FILES INTO THEIR OWN DIRECTORY

# create directory to put atcf output files
export outputdir=${wdir}/output_files
if [ ! -d ${outputdir} ]; then mkdir -p ${outputdir}; fi

# move all output files from wdir to output_files dir
mv trak.* ${outputdir}
