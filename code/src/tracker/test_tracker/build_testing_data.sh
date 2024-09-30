#!/bin/bash

# run python script that creates netcdf file with testing data
cd ../../../src/tracker/test_tracker
python create_testing_data.py

# move back into build dir
cd ../../../build