#!/bin/bash

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
