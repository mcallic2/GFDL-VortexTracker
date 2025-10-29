#!/bin/bash
set -x

# -------------------------------------------------------------------------------------------------
# SET UP ENVIRONMENT VARIABLES

export ncdf_ls_mask_filename=           # used for other models, not needed for tshield
export gribver=1
export basin=al
export trkrtype=tracker
export trkrebd=339.0   # boundary only if trkrtype = tcgen or midlat
export trkrwbd=260.0   # boundary only if trkrtype = tcgen or midlat
export trkrnbd=40.0    # boundary only if trkrtype = tcgen or midlat
export trkrsbd=7.0     # boundary only if trkrtype = tcgen or midlat
export regtype=altg    # This variable only needed if trkrtype = tcgen or midlat
export atcfnum=15
export atcfname="tshd"
export atcfout="tshd"
export atcfymdh=${pdy}${hh}
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

export g2_jpdtn=0
export inp_data_type=netcdf
export model=41

export use_land_mask=n
export use_backup_mslp_grad_check=y  #caitlyn, use_backup_mslp_grad_check var isn't in the list yet
export use_backup_850_vt_check=y        #caitlyn, same thing for this

set +x