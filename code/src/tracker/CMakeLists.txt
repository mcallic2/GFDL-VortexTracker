#----------------------------------------------------------
# Last edited by: Caitlyn Mcallister
# Originated by: Biju Thomas
# Email: caitlyn.mcallister@noaa.gov
#        timothy.marchok@noaa.gov
#----------------------------------------------------------

set(tracker_src
  gettrk_subroutines.f
  gettrk_modules.f
  module_waitfor.f
  cwaitfor.c
  CACHE INTERNAL "")

add_executable(gettrk.x gettrk_main.f ${tracker_src})

set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -O2 -fp-model precise -i4 -r8")

target_link_libraries(
  gettrk.x
  g2::g2_d
  bacio::bacio_4
  w3emc::w3emc_d
  w3nco::w3nco_d
  NetCDF::NetCDF_Fortran
  ${JASPER_LIBRARIES}
  ${PNG_LIBRARIES})

install(TARGETS gettrk.x DESTINATION ${CMAKE_SOURCE_DIR}/exec)

#------------------------------------------------
# Everything below this is set up for unit testing


# create a different library for test executables
add_library(subroutine_lib ${tracker_src})

target_link_libraries(
  subroutine_lib
  g2::g2_d
  bacio::bacio_4
  w3emc::w3emc_d
  w3nco::w3nco_d
  NetCDF::NetCDF_Fortran
  ${JASPER_LIBRARIES}
  ${PNG_LIBRARIES})

# create test executables
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/src/tracker/exec) # put any build executables in exec directory

add_executable(calccorr.x test_tracker/test_calccorr.F90)
target_link_libraries(calccorr.x PRIVATE subroutine_lib)

add_executable(open_ncfile.x test_tracker/test_open_ncfile.F90)
target_link_libraries(open_ncfile.x PRIVATE subroutine_lib)

# unit test suit
add_test(test_calccorr ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/calccorr.x)
add_test(run_python_script ${CMAKE_SOURCE_DIR}/src/tracker/test_tracker/build_testing_data.sh) # these could possibly be 1 file
add_test(move_ncfile_script ${CMAKE_SOURCE_DIR}/src/tracker/test_tracker/move_open_ncfile.sh)
add_test(test_open_ncfile ${subroutine_lib} ${CMAKE_SOURCE_DIR}/src/tracker/test_tracker/open_ncfile.x)
#set_tests_properties(test_open_ncfile
#    DIRECTORY ${CMAKE_SOURCE_DIR}/src/tracker/test_tracker/open_ncfile.x
#    PROPERTIES 
#    PASS_REGULAR_EXPRESSION "Test Passed"
#    FAIL_REGULAR_EXPRESSION "Test Failed"
#)
