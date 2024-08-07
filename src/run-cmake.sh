#!/bin/bash

# adds $target variable to identify which rdhpc system you're on
source machine-setup.sh

# loads any module/packages needed for cmake build
cd ../modulefile-setup
source $target-setup.sh
module list

# sets environment variables
if [ $target = hera ]; then
  export FC=ifort
  export F90=ifort
  export CC=icc
elif [ $target = orion ]; then
  export FC=ifort
  export F90=ifort
  export CC=icc
elif [ $target = hercules ]; then
  export FC=ifort
  export F90=ifort
  export CC=icc
elif [ $target = jet ]; then
  export FC=ifort
  export F90=ifort
  export CC=icc
elif [ $target = wcoss_cray ] || [ $target = wcoss2 ] ; then
  export FC=ftn
  export F90=ftn
  export CC=icc
elif [ $target = wcoss_dell_p3 ]; then
  export FC=ifort
  export F90=ifort
  export CC=icc
elif [ $target = gaea ]; then
  export FC=ftn
  export F90=ftn
  export CC=icc
elif [ $target = ppan ]; then
  export FC=ifort
  export F90=ifort
  export CC=icc
else
  echo "Unknown machine = $target"
  exit 1
fi

# makes and enters build directory
cd ..
if [ -d "build" ]; then
   rm -rf build
fi
mkdir build
cd build

# build
if [ $target = wcoss_cray ]; then
  cmake .. -DCMAKE_Fortran_COMPILER=ftn -DCMAKE_C_COMPILER=cc
elif [ $target = gaea ]; then
  cmake .. -DCMAKE_Fortran_COMPILER=ftn -DCMAKE_C_COMPILER=cc
else
  cmake .. -DCMAKE_Fortran_COMPILER=ifort -DCMAKE_C_COMPILER=icc
fi

# compile
make

# install executables in exec/ directory
make install

# back out of build directory
cd ..
exit
