#!/bin/bash

# -------------------------------------------------------------------------------------------------
# BUILD & COMPILE TRACKER EXECUTABLES

# create build directory & move into it
export builddir=${codedir}/build
if [ ! -d ${builddir} ]; then mkdir -p ${builddir}; fi
cd ${builddir}

# remove contents of build dir for fresh compilation
if [ -d ${builddir} ]; then rm -rf {*,*}; fi

# loads any module/packages needed for cmake build (ANALYSIS SPECFIC FOR NOW)
cd ${modulesetup}
source jet-setup.sh  # figure out better way to do this 

module list

# build code
# possibly add if-statment like in run-cmake.sh
cmake .. -DCMAKE_Fortran_COMPILER=ifx -DCMAKE_C_COMPILER=icx

# compile code
make

# install executables
make install

# move back into run dir
cd ${rundir}
