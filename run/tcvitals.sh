#!/bin/bash

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

if [ -f ${tcvit_logfile} ]; then rm ${tcvit_logfile}; fi
