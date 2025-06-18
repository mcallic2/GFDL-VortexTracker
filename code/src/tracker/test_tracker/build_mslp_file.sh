#!/bin/bash

# run python script that creates netcdf file with testing data
export mslp_scr=../../../src/tracker/test_tracker
cd $mslp_scr
python create_mslp_data.py