#!/bin/bash
set -x

# -------------------------------------------------------------------------------------------------
# SET UP KNOWN TCVITALS FILE

if [ -z ${knowntcvitals} ]; then  # need to record tcvitals
  echo "tcvitals not known; running tcvitals code"

  export find_vitals_data="$(grep "${yyyy}${mm}${dd} ${hh}" ${vitalsdir}/syndat_tcvitals.${yyyy} | \
          sort -k2 -k4 -n -k5 -n -u | sort -k4 -n -k5 -n | egrep "JTWC|NHC"                       | \
          awk 'substr($0,6,1) !~ /8/ {print $0}' > ${wdir}/vitals.${initymdh})"

else  # tcvitals file already created; copy to work dir
  echo "tcvitals files already created; copying to work dir"
  cp ${knowntcvitals} ${wdir}/vitals.${initymdh}

fi

export num_storms="$(cat ${wdir}/vitals.${initymdh} | wc -l)"

if [ ${num_storms} -gt 0 ]; then
  echo "${num_storms} Observed storms exist for ${initymdh}: "
  cat ${wdir}/vitals.${initymdh}
else
  touch ${wdir}/vitals.${initymdh}
fi

set +x