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

# set flags for different compilers in prod mode
get_filename_component (Fortran_COMPILER_NAME ${CMAKE_Fortran_COMPILER} NAME)

if (Fortran_COMPILER_NAME MATCHES "ifx.*")
  # ifx fortran compiler flags
  set (CMAKE_Fortran_FLAGS "-fp-model=precise -i4 -r8")
elseif (Fortran_COMPILER_NAME MATCHES "gfortran.*")
  # gcc fortran compiler flags
  set (CMAKE_Fortran_FLAGS "-ffp-contract=off -fno-unsafe-math-optimizations -fno-finite-math-only -fno-rounding-math -fno-signed-zeros")
endif()

# set flags for different compilers in debug mode
if (Fortran_COMPILER_NAME MATCHES "ifx.*")
  # ifx debugging fortran compiler flags
  set (CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} -O0")
elseif (Fortran_COMPILER_NAME MATCHES "gfortran.*")
  # gfortran debugging compiler flags
  set (CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} -Wall -Wextra")
endif()


target_link_libraries(
  gettrk.x
  g2::g2_d
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
  NetCDF::NetCDF_Fortran
  ${JASPER_LIBRARIES}
  ${PNG_LIBRARIES})

# create test executables
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/src/tracker/exec) # put any build executables in exec directory

add_executable(calccorr.x test_tracker/test_calccorr.F90)
target_link_libraries(calccorr.x PRIVATE subroutine_lib)

add_executable(test_avgcalc.x test_tracker/test_avgcalc.F90)
target_link_libraries(test_avgcalc.x PRIVATE subroutine_lib)

add_executable(test_calc_vmag.x test_tracker/test_calc_vmag.F90)
target_link_libraries(test_calc_vmag.x PRIVATE subroutine_lib)

add_executable(test_getcorr.x test_tracker/test_getcorr.F90)
target_link_libraries(test_getcorr.x PRIVATE subroutine_lib)

add_executable(test_stdevcalc.x test_tracker/test_stdevcalc.F90)
target_link_libraries(test_stdevcalc.x PRIVATE subroutine_lib)

add_executable(test_wtavrg_lon.x test_tracker/test_wtavrg_lon.F90)
target_link_libraries(test_wtavrg_lon.x PRIVATE subroutine_lib)

add_executable(test_wtavrg.x test_tracker/test_wtavrg.F90)
target_link_libraries(test_wtavrg.x PRIVATE subroutine_lib)

add_executable(test_distbear.x test_tracker/test_distbear.F90)
target_link_libraries(test_distbear.x PRIVATE subroutine_lib)

add_executable(test_calcdist.x test_tracker/test_calcdist.F90)
target_link_libraries(test_calcdist.x PRIVATE subroutine_lib)

add_executable(test_lin_int.x test_tracker/test_lin_int.F90)
target_link_libraries(test_lin_int.x PRIVATE subroutine_lib)

add_executable(test_qsort.x test_tracker/test_qsort.F90)
target_link_libraries(test_qsort.x PRIVATE subroutine_lib)

add_executable(test_bitmapchk.x test_tracker/test_bitmapchk.F90)
target_link_libraries(test_bitmapchk.x PRIVATE subroutine_lib)

add_executable(test_conv1d2d.x test_tracker/test_conv1d2d.F90)
target_link_libraries(test_conv1d2d.x PRIVATE subroutine_lib)

add_executable(test_get_ijplus1_check_wrap.x test_tracker/test_get_ijplus1_check_wrap.F90)
target_link_libraries(test_get_ijplus1_check_wrap.x PRIVATE subroutine_lib)

add_executable(test_sort_storms_by_pressure.x test_tracker/test_sort_storms_by_pressure.F90)
target_link_libraries(test_sort_storms_by_pressure.x PRIVATE subroutine_lib)

add_executable(test_getvrvt.x test_tracker/test_getvrvt.F90)
target_link_libraries(test_getvrvt.x PRIVATE subroutine_lib)

add_executable(test_bilin_int_uneven.x test_tracker/test_bilin_int_uneven.F90)
target_link_libraries(test_bilin_int_uneven.x PRIVATE subroutine_lib)

add_executable(test_rvcal.x test_tracker/test_rvcal.F90)
target_link_libraries(test_rvcal.x PRIVATE subroutine_lib)

add_executable(test_barnes.x test_tracker/test_barnes.F90)
target_link_libraries(test_barnes.x PRIVATE subroutine_lib)

# test_getdata_grib is a REGRESSION test (see the file header comment):
# it runs getgridinfo_grib/getdata_grib against a real, checked-in GRIB2
# fixture (test_tracker/test_data/) rather than verifying behavior from
# first principles. It needs the real NCEPLIBS-g2/g2c/bacio/w3emc stack
# (already linked into subroutine_lib below) and a longer free-form
# line limit for the compile-time test-data-path macro.
add_executable(test_getdata_grib.x test_tracker/test_getdata_grib.F90)
target_link_libraries(test_getdata_grib.x PRIVATE subroutine_lib)
target_compile_definitions(test_getdata_grib.x PRIVATE
  TEST_DATA_FILE="${CMAKE_CURRENT_SOURCE_DIR}/test_tracker/test_data/single_trimmed_test_grib.grib2")
if (Fortran_COMPILER_NAME MATCHES "gfortran.*")
  set_source_files_properties(test_tracker/test_getdata_grib.F90
    PROPERTIES COMPILE_OPTIONS "-ffree-line-length-none")
endif()

# test_getdata_netcdf is the NetCDF-side counterpart to
# test_getdata_grib above (same regression-test caveats apply): runs
# getgridinfo_netcdf/getdata_netcdf against a real, checked-in T-SHiELD
# NetCDF fixture cropped around Hurricane Idalia.
add_executable(test_getdata_netcdf.x test_tracker/test_getdata_netcdf.F90)
target_link_libraries(test_getdata_netcdf.x PRIVATE subroutine_lib)
target_compile_definitions(test_getdata_netcdf.x PRIVATE
  TEST_DATA_FILE="${CMAKE_CURRENT_SOURCE_DIR}/test_tracker/test_data/trimmed_test_file.nc")
if (Fortran_COMPILER_NAME MATCHES "gfortran.*")
  set_source_files_properties(test_tracker/test_getdata_netcdf.F90
    PROPERTIES COMPILE_OPTIONS "-ffree-line-length-none")
endif()

# test_read_nlists uses the project's real production namelist files
# (test_data/g2namelist.gettrk, test_data/ncdfnamelist.gettrk) as
# regression fixtures. read_nlists hardcodes "namelist.gettrk" in the
# current working directory (no filename argument), so this test
# copies each fixture there at runtime via execute_command_line --
# it will leave a namelist.gettrk file behind in whatever directory
# it's run from.
add_executable(test_read_nlists.x test_tracker/test_read_nlists.F90)
target_link_libraries(test_read_nlists.x PRIVATE subroutine_lib)
target_compile_definitions(test_read_nlists.x PRIVATE
  G2_NAMELIST_FILE="${CMAKE_CURRENT_SOURCE_DIR}/test_tracker/test_data/g2namelist.gettrk"
  NCDF_NAMELIST_FILE="${CMAKE_CURRENT_SOURCE_DIR}/test_tracker/test_data/ncdfnamelist.gettrk"
  VTILT_LEVELS_FILE="${CMAKE_CURRENT_SOURCE_DIR}/test_tracker/test_data/vtilt_levels.txt")
if (Fortran_COMPILER_NAME MATCHES "gfortran.*")
  set_source_files_properties(test_tracker/test_read_nlists.F90
    PROPERTIES COMPILE_OPTIONS "-ffree-line-length-none")
endif()

# test_read_fhours uses a real production lead-times file as a
# regression fixture. read_fhours hardcodes reading from Fortran unit
# 15 with no OPEN statement in the source (relies on the "fort.15"
# default naming convention; a real run's script is responsible for
# placing the actual lead-times file there before invoking gettrk.x).
# This test copies the fixture to a literal "fort.15" at runtime, same
# workaround as test_read_nlists.F90 uses for "namelist.gettrk".
add_executable(test_read_fhours.x test_tracker/test_read_fhours.F90)
target_link_libraries(test_read_fhours.x PRIVATE subroutine_lib)
target_compile_definitions(test_read_fhours.x PRIVATE
  LEADTIMES_FILE="${CMAKE_CURRENT_SOURCE_DIR}/test_tracker/test_data/leadtimes.txt")
if (Fortran_COMPILER_NAME MATCHES "gfortran.*")
  set_source_files_properties(test_tracker/test_read_fhours.F90
    PROPERTIES COMPILE_OPTIONS "-ffree-line-length-none")
endif()

add_executable(test_check_bounds.x test_tracker/test_check_bounds.F90)
target_link_libraries(test_check_bounds.x PRIVATE subroutine_lib)

add_executable(test_bilin_int_even.x test_tracker/test_bilin_int_even.F90)
target_link_libraries(test_bilin_int_even.x PRIVATE subroutine_lib)

add_executable(test_get_grib_file_name.x test_tracker/test_get_grib_file_name.F90)
target_link_libraries(test_get_grib_file_name.x PRIVATE subroutine_lib)

add_executable(test_output_tcvitals.x test_tracker/test_output_tcvitals.F90)
target_link_libraries(test_output_tcvitals.x PRIVATE subroutine_lib)

add_executable(test_check_valid_point.x test_tracker/test_check_valid_point.F90)
target_link_libraries(test_check_valid_point.x PRIVATE subroutine_lib)

add_executable(test_compute_q_from_rh.x test_tracker/test_compute_q_from_rh.F90)
target_link_libraries(test_compute_q_from_rh.x PRIVATE subroutine_lib)

add_executable(test_check_land_mask.x test_tracker/test_check_land_mask.F90)
target_link_libraries(test_check_land_mask.x PRIVATE subroutine_lib)

add_executable(test_divcal.x test_tracker/test_divcal.F90)
target_link_libraries(test_divcal.x PRIVATE subroutine_lib)

# unit test suit
add_test(test_calccorr ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/calccorr.x)
add_test(test_avgcalc ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_avgcalc.x)
add_test(test_calc_vmag ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_calc_vmag.x)
add_test(test_getcorr ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_getcorr.x)
add_test(test_stdevcalc ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_stdevcalc.x)
add_test(test_wtavrg_lon ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_wtavrg_lon.x)
add_test(test_wtavrg ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_wtavrg.x)
add_test(test_distbear ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_distbear.x)
add_test(test_calcdist ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_calcdist.x)
add_test(test_lin_int ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_lin_int.x)
add_test(test_qsort ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_qsort.x)
add_test(test_bitmapchk ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_bitmapchk.x)
add_test(test_conv1d2d ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_conv1d2d.x)
add_test(test_get_ijplus1_check_wrap ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_get_ijplus1_check_wrap.x)
add_test(test_sort_storms_by_pressure ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_sort_storms_by_pressure.x)
add_test(test_getvrvt ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_getvrvt.x)
add_test(test_bilin_int_uneven ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_bilin_int_uneven.x)
add_test(test_rvcal ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_rvcal.x)
add_test(test_barnes ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_barnes.x)
add_test(test_getdata_grib ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_getdata_grib.x)
add_test(test_getdata_netcdf ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_getdata_netcdf.x)
add_test(test_read_nlists ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_read_nlists.x)
add_test(test_read_fhours ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_read_fhours.x)
add_test(test_check_bounds ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_check_bounds.x)
add_test(test_bilin_int_even ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_bilin_int_even.x)
add_test(test_get_grib_file_name ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_get_grib_file_name.x)
add_test(test_output_tcvitals ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_output_tcvitals.x)
add_test(test_check_valid_point ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_check_valid_point.x)
add_test(test_compute_q_from_rh ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_compute_q_from_rh.x)
add_test(test_check_land_mask ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_check_land_mask.x)
add_test(test_divcal ${subroutine_lib} ${CMAKE_BINARY_DIR}/src/tracker/exec/test_divcal.x)