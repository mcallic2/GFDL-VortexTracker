# GFDL Vortex Tracker - Test Suite

This directory contains a comprehensive unit testing suite for the GFDL Vortex Tracker Fortran code.

## Overview

The test suite covers key subroutines in the tracker system, ensuring code reliability and correctness through automated testing.

## Test Structure

### Existing Tests
- `test_avgcalc.F90` - Tests average calculation subroutine
- `test_calc_vmag.F90` - Tests wind magnitude calculation
- `test_calccorr.F90` - Tests correlation calculation and related subroutines
- `test_getcorr.F90` - Tests correlation retrieval
- `test_stdevcalc.F90` - Tests standard deviation calculation
- `test_wtavrg.F90` - Tests weighted averaging
- `test_wtavrg_lon.F90` - Tests weighted averaging for longitude

### New Comprehensive Tests
- `test_distbear.F90` - Tests distance and bearing calculations
- `test_bilin_int_uneven.F90` - Tests bilinear interpolation on uneven grids
- `test_calcdist.F90` - Tests distance calculation between geographic points
- `test_getvrvt.F90` - Tests radial/tangential wind component calculation
- `test_sort_storms_by_pressure.F90` - Tests storm sorting by pressure
- `test_rvcal.F90` - Tests relative vorticity calculation
- `test_barnes.F90` - Tests Barnes analysis/interpolation

## Subroutines Covered

### Mathematical Functions
- `avgcalc` - Calculate average of valid data points
- `stdevcalc` - Calculate standard deviation
- `wtavrg` - Weighted average calculation
- `wtavrg_lon` - Weighted average for longitude values
- `calccorr` - Calculate correlation coefficient
- `getcorr` - Get correlation from residuals
- `getmean` - Calculate mean value
- `getdiff` - Calculate differences from mean
- `getslope` - Calculate linear regression slope
- `getyestim` - Calculate estimated y values
- `getresid` - Calculate residuals

### Geometric and Geographic Functions
- `distbear` - Calculate distance and bearing between points
- `calcdist` - Calculate great circle distance
- `bilin_int_uneven` - Bilinear interpolation on uneven grids
- `getvrvt` - Calculate radial and tangential wind components

### Meteorological Functions
- `calc_vmag` - Calculate wind magnitude from u,v components
- `rvcal` - Calculate relative vorticity
- `barnes` - Barnes objective analysis
- `sort_storms_by_pressure` - Sort storms by minimum pressure

## Building and Running Tests

### Prerequisites
- CMake 3.10 or higher
- Fortran compiler (gfortran or Intel Fortran)
- NetCDF libraries
- GRIB2 libraries (g2clib)
- JASPER and PNG libraries

### Build Process
```bash
# From the src directory
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)
```

### Running Tests

#### Method 1: Using CTest
```bash
cd build
ctest --output-on-failure --verbose
```

#### Method 2: Using the Test Runner Script
```bash
cd tracker
chmod +x run_tests.sh
./run_tests.sh
```

#### Method 3: Running Individual Tests
```bash
cd build/src/tracker/exec
./test_avgcalc.x
./test_calccorr.x
# ... etc
```

## Test Categories

### Unit Tests
- Test individual subroutines with known inputs/outputs
- Verify mathematical correctness
- Check boundary conditions
- Validate error handling

### Integration Tests
- Test combinations of subroutines
- Verify data flow between functions
- Check consistency of results

### Performance Tests
- Measure execution time of critical functions
- Monitor memory usage
- Identify optimization opportunities

## Continuous Integration

### GitHub Actions Workflows

The project includes automated testing through GitHub Actions:

1. **Main Test Suite** (`.github/workflows/tests.yml`)
   - Tests with multiple Fortran compilers
   - Runs on Ubuntu latest
   - Includes dependency installation
   - Generates coverage reports

2. **Tracker-Specific Tests** (`.github/workflows/tracker-tests.yml`)
   - Focused on tracker module changes
   - Performance benchmarking
   - Quick feedback for tracker development

### Workflow Triggers
- Push to main/develop branches
- Pull requests
- Manual workflow dispatch
- Changes to tracker source files

## Test Results and Reporting

### Artifacts Generated
- Test execution logs
- Coverage reports (lcov format)
- Performance benchmarks
- Documentation (FORD generated)

### Test Output Format
Tests use a consistent output format:
- `✓ PASS: Test Name` - Test passed
- `✗ FAIL: Test Name` - Test failed with error details
- `⚠ SKIP: Test Name` - Test skipped (executable not found)

## Adding New Tests

### Step 1: Create Test File
Create a new test file in `test_tracker/` directory:
```fortran
program test_subroutine_yourfunction
  use access_subroutines
  implicit none
  
  ! Test setup
  ! Test execution
  ! Result validation
  
  write(*,*) "All yourfunction tests passed!"
end program test_subroutine_yourfunction
```

### Step 2: Update CMakeLists.txt
Add the new test executable and test:
```cmake
add_executable(test_yourfunction.x test_tracker/test_yourfunction.F90)
target_link_libraries(test_yourfunction.x PRIVATE subroutine_lib)
add_test(test_yourfunction ${CMAKE_BINARY_DIR}/src/tracker/exec/test_yourfunction.x)
```

### Step 3: Update Test Runner
Add the new test to `run_tests.sh`:
```bash
run_test "Your Function Test" "$EXEC_DIR/test_yourfunction.x"
```

## Best Practices for Testing

### Test Design
- Use descriptive test names
- Test both normal and edge cases
- Include boundary value testing
- Verify error conditions
- Use appropriate tolerances for floating-point comparisons

### Test Data
- Use simple, verifiable test cases
- Include both positive and negative test cases
- Test with realistic data ranges
- Document expected results clearly

### Error Handling
- Test should exit with status 0 on success
- Use `error stop` for test failures
- Provide clear failure messages
- Include actual vs expected values in error messages

## Coverage Analysis

### Generating Coverage Reports
```bash
mkdir -p build_coverage && cd build_coverage
cmake .. -DCMAKE_Fortran_FLAGS="-fprofile-arcs -ftest-coverage -O0 -g" -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)
ctest
lcov --capture --directory . --output-file coverage.info
lcov --remove coverage.info '/usr/*' --output-file coverage_filtered.info
genhtml coverage_filtered.info --output-directory coverage_html
```

### Target Coverage Goals
- Unit test coverage: >80% of subroutines
- Line coverage: >70% of executable lines
- Branch coverage: >60% of conditional branches

## Troubleshooting

### Common Issues

1. **Compiler Errors**
   - Ensure Fortran compiler is properly installed
   - Check module dependencies
   - Verify library paths

2. **Linking Errors**
   - Install required libraries (NetCDF, GRIB2, etc.)
   - Check library versions compatibility
   - Verify CMake configuration

3. **Test Failures**
   - Check tolerance values for floating-point comparisons
   - Verify test data is correct
   - Review subroutine logic for edge cases

4. **Performance Issues**
   - Use optimized compiler flags for performance tests
   - Consider parallel execution for large test suites
   - Monitor memory usage for large data structures

## Contributing

When contributing new tests:
1. Follow the existing test structure and naming conventions
2. Document test purpose and expected behavior
3. Update this README with new test descriptions
4. Ensure tests pass in CI environment
5. Include performance considerations for computationally intensive tests

## Future Enhancements

### Planned Additions
- Integration tests with realistic meteorological data
- Regression tests against known storm tracks
- Property-based testing for mathematical functions
- Parameterized tests for different grid configurations
- Mock data generation for comprehensive testing

### Testing Infrastructure
- Automated test data generation
- Test result database for historical comparisons
- Performance regression detection
- Automated documentation updates
