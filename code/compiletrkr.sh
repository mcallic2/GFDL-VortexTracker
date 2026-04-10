#!/bin/bash

# ------------------------------------------------------------------------------
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
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# DECLARE DEFAULT VARIABLES & PATHS

# declare default arguments
system=""					# system being used
compiler="intel"	# compiler
clean="fresh" 		# cleaning mode
mode="prod" 			# build mode

export codedir=${PWD}
export execdir=${codedir}/exec
export builddir=${codedir}/build
export logdir=${codedir}/logfiles
export date_stamp=$(date +"%a %b %d %H:%M:%S %Z %Y")
export today_stamp=$(date +"%m.%d-%H.%M%p")
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# PARSE ARGS
for arg in "$@"
do
  case $arg in
    #system
    ppan|gaea|hera|hercules|orion|ursa|wcoss2|container|personal)
    	system="${arg#*=}"
    	# if-statements go here if needed
			shift # remove "system" from processing
      ;;
    #compiler
		intel|gcc)
			compiler="${arg#*=}"
			shift # remove "compiler" from proccessing
			;;
  	#clean
		fresh|clean|noclean)
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
      	echo " "${arg#}" OPTION NOT FOUND"
      fi
			echo -e " "
      echo -e "Valid options for system configureation are: "
			echo -e "\t[ gaea | hera | hercules | orion | ppan | ursa | wcoss2 | container | personal ] "
      echo -e "Valid options for compilers are: "
			echo -e "\t[ intel(D) | gcc ] "
      echo -e "Valid options compilations modes are: "
			echo -e "\t[ prod(D) | debug ] "
			echo -e "Valid cleaning optiona are: " 
			echo -e "\t[ fresh(D) | clean | noclean ] "
			echo -e "\n"
      exit
      ;;
  esac
done

# 'system' cannot be empty when script is run
if [ -z "${system}" ]; then
	echo -e " "
	echo -e "System option required for compilation to continue"
	echo -e "If you are unsure of possible arguments please run this command:"
	echo -e "\t./compiletrkr.sh --help"
	echo -e "\n"
	exit 0
fi

# no gcc environment available on gaea or wcoss2
if [[ (${system} == "gaea" || ${system} == "wcoss2") && ${compiler} = "gcc" ]]; then
  echo -e "There is currently no ${compiler} environment available on ${system}"
  echo -e "Please try using different compiler"
  echo -e "\n"
  exit 1
fi
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# START SCRIPT & CREATE STDOUT FILE

spin &
SPIN_PID=$!
trap "kill -9 $SPIN_PID" `seq 0 15`

if [ ! -d ${logdir} ]; then mkdir -p ${logdir}; fi
export logfile="${logdir}/build_${compiler}_${system}_${today_stamp}.log"
exec > >(tee -a "${logfile}") 2>&1
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# LOAD ENVIRONMENT

echo -e "Loading environment for ${system} with ${compiler} compiler"
sleep 2

# load modules 
. ${codedir}/system-envs/${compiler}/${system}.sh

# list modules
echo -e " "
module list
echo -e "\n"
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# PRINT BEFORE COMPILATION

# output build setup
echo -e " "
echo -e "Compilation initiated with the following: "
echo -e "\tsystem   = ${system}"
echo -e "\tcompiler = ${compiler}"
echo -e "\tclean    = ${clean}"
echo -e "\tmode     = ${mode}"
echo -e "\n"
sleep 3

# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# INITIATE CMAKE SYSTEM

echo -e " "
echo -e "Creating executables on ${system} with ${compiler} on ${date_stamp}"
echo -e "\n"

if [ ${clean} = "fresh" ]; then
	echo -e " "
	echo -e "Creating build directory and compiling"
	sleep 2
	if [ -d ${builddir} ]; then
		echo -e " "
		echo "\tpreexisting build directory found;"
		echo "\tnew build directory being generated"
		echo -e "\n"
		sleep 2
		rm -rf ${builddir}
	fi
	mkdir -p ${builddir}
	cd ${builddir}
	cmake ..
	make
	make install
elif [ ${clean} = "clean" ]; then
	echo -e " "
	echo "Cleaning build directory then recompiling"
	echo -e "\n"
	sleep 2
	cd ${builddir}
	cmake --build . --clean-first
	make install
else # "noclean"
	echo -e " "
	echo "Checking that the executables exist before moving on"
	echo -e "\n"
	sleep 2
	export trkrx="${execdir}/gettrk.x"
	export supvitx="${execdir}/supvit.x"
	export tavex="${execdir}/tave.x"
	export vintx="${execdir}/vint.x"
  if [ ! -x ${trkrx} ] && [ ! -x ${supvitx} ] && [ ! -x ${tavex} ] && [ ! -x ${vintx} ]; then
		echo -e " "
		echo -e "Executables were not found"
		echo -e "Please run compile script again using different cleaning option"
		echo -e "If you are unsure of possible arguments please run this command:"
		echo -e "\t./compile.sh --help"
		echo -e "\n"
		sleep 2
	else	
		echo -e " "
		echo "All necssary executables exist; nothing to do"
		echo -e "\n"
		sleep 2
  fi
fi

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# REPORT ON COMPILE FUNCTIONALLITY
if [ $? -ne 0 ] ; then
	echo -e " "
  echo "COMPILATION FAILED"
  exit 3
else
	echo -e " "
  echo "COMPILATION SUCCESSFUL"
fi

echo -e "Log from this compilation can be found here:"
echo -e "\t${logfile}"
echo -e "\n"
# ------------------------------------------------------------------------------

exit 0
