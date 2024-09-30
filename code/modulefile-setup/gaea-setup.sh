# set up module environment on gaea

module use /ncrc/proj/epic/spack-stack/spack-stack-1.6.0/envs/unified-env/install/modulefiles/Core
module load stack-intel/2023.1.0

module load cray-hdf5
module load cray-netcdf
module load python

module load libpng
module load jasper
module load zlib
module load g2
module load g2tmpl
module load bacio
module load w3emc
module load w3nco

module load nco
module load cdo

export ncdump=/opt/cray/pe/netcdf/4.9.0.3/bin/ncdump
export LD_PRELOAD=/opt/cray/pe/gcc/12.2.0/snos/lib64/libstdc++.so.6

# for grib data
module load grib-util
module load wgrib
module load wgrib2
