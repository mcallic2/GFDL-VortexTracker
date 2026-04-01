#!/bin/bash

#------------------------------------------------------------------------------
# function to display a spinning wheel while a command is in progress
spin()
{
  spinner="\\|/-\\|/-"
  while :
  do
    for i in `seq 0 7`
    do
      echo -n "${spinner:$i:1}"
      echo -en "\010"
      sleep 1
    done
  done
}
# end function
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# BUILD PARAMETERS

#system
which_system="analysis"
#compiler
compiler="intel"
#clean (cleanall=rm all build contnets & executables, clean=clean make, noclean=no recompile)
clean="cleanall"
#mode (reg or debug)
mode="prog"
#verbose?


#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# parse arguments
for arg in "$@"
do
  case $arg in
    #system
    analysis|gaea|hera|hercules|mercury|orion|ursa|wcoss2|container|personal)
    	which_system="${arg#*=}"
    	# if-statements go here if needed
			shift # remove "which_system" from processing CAITLYN-not sure what this does
      ;;
    #compiler
		intel|gcc)
			compiler="${arg#*=}"
			shift # remove "compiler" from proccessing
			;;
  	#clean
		noclean|clean|cleanall)
			clean="${arg#*=}"
			shift # remove "clean" from processing
			;;
		#mode
		prod|debug)
			mode="${arg#*=}"
			shift # remove "mode" from processing
			;;
	#verbose
  	# catch
    *)
    	if [ ${arg#} != '--help' ] && [ ${arg#} != '-h' ] ; then
      	echo "option "${arg#}" not found"
      fi
			echo -e ' '
      echo -e "valid options are:"
      echo -e "\t[put system options here]\t\t\t\t --> system options"
			echo -e "\t[ intel(D) | gcc ]\t\t\t\t\t\t\t\t --> for compiler options"
      echo -e "\t[ prod(D) | debug ]\t\t\t\t\t\t\t --> for mode setting"
      echo -e "\t[ cleanall(D) | clean | noclean ] --> for clean exec area options"
      echo -e "\n"
      exit
      ;;
  esac
done

# if there are options that cannot be used together, for instance if there's no
# gcc on wcoss2, put if statements underneath here


#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# default paths?
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# load environment
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# output before build & compile

# output build setup
echo -e ' '
echo -e "Compilation will continue in five seconds with"
echo -e "\tconfig   = $which_system"
echo -e "\tcompiler = $compiler"
echo -e "\tclean    = $clean"
echo -e "\tmode     = $mode"
echo -e "\n"
sleep 5

# start the spinner
spin &
SPIN_PID=$!
trap "kill -9 $SPIN_PID" `seq 0 15`
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# clean build directory if needed
if [ ${clean} = "cleanall" ]; then
	echo "WILL DO SOMETHING AT SOME POINT"
	sleep 2
	# add rm rf * build directory code here
	# then add elif clean code
fi
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# build and compile

echo -e "  building vortex tracker on ${which_system} with ${compiler} \t `date`"
#add "cmake .." command here

# compile
# add "make" command here

# install executables
# add "make install" command here
#------------------------------------------------------------------------------


# test and report on build success
#if [ $? -ne 0 ] ; then
#  echo ">>> ${config_name} build ${hydro} ${comp} ${bit} ${compiler} failed"
#  exit 6
#else
#  echo " ${config_name} build ${hydro} ${comp} ${bit} ${compiler} successful"
#fi

exit 0
