#!/bin/bash

set -x
# -------------------------------------------------------------------------------------------------
# SET UP MUTIPLE INPUT DATA FILES (i.e. files that only include a single forecast hour)

# move into wdir so fort.* files go into correct place
cd ${wdir}

for fhour in ${fcsthrs}
do
  let min=fhour*60
  export min5=` echo ${min} | awk '{printf ("%5.5d\n",$0)}'`

  cp ${datadir}/${atcfname}.${rundescr}.${atcfdescr}.${initymdh}.f${min5} ${wdir}/.

  export gribfile=${wdir}/${atcfname}.${rundescr}.${atcfdescr}.${initymdh}.f${min5}
  export ixfile=${wdir}/${atcfname}.${rundescr}.${atcfdescr}.${initymdh}.f${min5}.ix

  if [ ${gribver} -eq 1 ]; then
    grbindex ${gribfile} ${ixfile}
  elif [ ${gribver} -eq 2 ]; then
    grb2index ${gribfile} ${ixfile}
  else
    echo "ERROR: gribver is not equal to 1 or 2.  gribver = ${gribver} EXITING"
    exit 94
  fi
done

# -------------------------------------------------------------------------------------------------
# EXECUTE SUPPLMENTAL SOURCE CODE (tave and/or vint) TO AVERAGE DATA

# interpolate and average data for phase checking
if [ ${need_to_use_vint_or_tave} = 'y' ]; then

  for fhour in ${fcsthrs}
  do

    echo "Now processing hour ${fhour} for GP height & temperture data"

    # adding to see if it fixes SIG error
    let min=fhour*60
    export min5=` echo ${min} | awk '{printf ("%5.5d\n",$0)}'`

    export gribfile=${wdir}/${atcfname}.${rundescr}.${atcfdescr}.${ymdh}.f${min5}
    export ixfile=${wdir}/${atcfname}.${rundescr}.${atcfdescr}.${ymdh}.f${min5}.ix

    export gfile=${gribfile}
    export ifile=${ixfile}

    if [ ${gribver} -eq 1 ]; then
      grbindex ${gfile} ${ifile}
    else
      grb2index ${gfile} ${ifile}
    fi

    export rcc1=77
    export rcc2=77
    export rcc3=77

# call vint source code to vertically interpolate the geopotential height data to 50-mb intervals from 300-900 mb
    if [ ${need_to_interpolate_height} = 'y' ]; then

      export gparm=7
      export namelist=${wdir}/vint_input.${pdy}${hh}.z
      echo "&timein ifcsthour=${fhour},"       > ${namelist}
      echo "        iparm=${gparm},"          >> ${namelist}
      echo "        gribver=${gribver},"      >> ${namelist}
      echo "        g2_jpdtn=${g2_jpdtn}/"    >> ${namelist}

      ln -s -f ${gfile}                                    fort.11
      ln -s -f ${rundir}/hgt_levs.txt                      fort.16
      ln -s -f ${ifile}                                    fort.31
      ln -s -f ${wdir}/${atcfname}.${pdy}${hh}.z.f${fhour} fort.51

      ${execdir}/vint.x < ${namelist}
      exoprt rcc1=$?

      if [ ${rcc1} -eq 0 ]; then
        export zfile=${wdir}/${atcfname}.${pdy}${hh}.z.f${fhour}
      else
        echo "ERROR tave.x failure for fhour= ${fhour}"
      fi
    
    fi

# call vint source code to vertically interpolate the temperature data to 50-mb intervals from 300-500 mb
    if [ ${need_to_interpolate_temperature} = 'y' ]; then

      export gparm=11
      export namelist=${wdir}/vint_input.${pdy}${hh}.t
      echo "&timein ifcsthour=${fhour},"       > ${namelist}
      echo "        iparm=${gparm},"          >> ${namelist}
      echo "        gribver=${gribver},"      >> ${namelist}
      echo "        g2_jpdtn=${g2_jpdtn}/"    >> ${namelist}

      ln -s -f ${gfile}                                    fort.11
      ln -s -f ${rundir}/tmp_levs.txt                      fort.16
      ln -s -f ${ifile}                                    fort.31
      ln -s -f ${wdir}/${atcfname}.${pdy}${hh}.t.f${fhour} fort.51

      ${execdir}/vint.x < ${namelist}
      export rcc2=$?

# if vint was successful, then average the temperature in those levels to get a mean 300-500 mb temperature
      if [ ${rcc2} -eq 0 ]; then

        export ffile=${wdir}/${atcfname}.${pdy}${hh}.t.f${fhour}
        export ifile=${wdir}/${atcfname}.${pdy}${hh}.t.f${fhour}.i

        if [ ${gribver} -eq 1 ]; then
          grbindex ${ffile} ${ifile}
        else
          grb2index ${ffile} ${ifile}
        fi

        export gparm=11
        export namelist=${wdir}/tave_input.${pdy}${hh}
        echo "&timein ifcsthour=${fhour},"       > ${namelist}
        echo "        iparm=${gparm},"          >> ${namelist}
        echo "        gribver=${gribver},"      >> ${namelist}
        echo "        g2_jpdtn=${g2_jpdtn}/"    >> ${namelist}

        ln -s -f ${ffile}                                       fort.11
        ln -s -f ${ifile}                                       fort.31
        ln -s -f ${wdir}/${atcfname}_tave.${pdy}${hh}.f${fhour} fort.51

        ${execdir}/tave.x < ${namelist}
        export rcc3=$?

        if [ $rcc3 -eq 0 ]; then
          export tavefile=${wdir}/${atcfname}_tave.${pdy}${hh}.f${fhour}
        else
          echo "ERROR tave.x failure for fhour= ${fhour}"
        fi

      else
        echo "ERROR running vint.x for fhour= ${fhour}"

      fi
    fi

    if [ ${rcc1} -eq 0 ]; then
      cat ${zfile} >> ${gribfile}
    fi

    if [ ${rcc3} -eq 0 ]; then
      cat ${tavefile} >> ${gribfile}
    fi

  done
fi

# adding to see if it fixes SIG error
for fhour in ${fcsthrs}
do

  echo "Now creating GRIB index file for hour ${fhour}"

  let min=fhour*60
  export min5=` echo ${min} | awk '{printf ("%5.5d\n",$0)}'`

  export gribfile=${wdir}/${atcfname}.${rundescr}.${atcfdescr}.${ymdh}.f${min5}
  export ixfile=${wdir}/${atcfname}.${rundescr}.${atcfdescr}.${ymdh}.f${min5}.ix

  if [ ${gribver} -eq 1 ]; then
    grbindex ${gribfile} ${ixfile}
  else
    grb2index ${gribfile} ${ixfile}
  fi

done

# -------------------------------------------------------------------------------------------------
set +x