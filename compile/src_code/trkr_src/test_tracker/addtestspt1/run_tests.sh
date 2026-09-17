#!/bin/bash
#************************************************
# Comprehensive Test Runner Script
# Runs all unit tests and reports results
#
# Created by: GitHub Copilot Testing Suite
#************************************************

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test
run_test() {
    local test_name=$1
    local test_executable=$2
    
    echo -e "${BLUE}Running test: $test_name${NC}"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ -f "$test_executable" ]; then
        if $test_executable; then
            echo -e "${GREEN}✓ PASS: $test_name${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}✗ FAIL: $test_name${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo -e "${YELLOW}⚠ SKIP: $test_name (executable not found: $test_executable)${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo
}

# Main test runner
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}  GFDL Vortex Tracker - Test Suite${NC}"
echo -e "${BLUE}===========================================${NC}"
echo

# Check if we're in the right directory
if [ ! -d "test_tracker" ] && [ ! -f "CMakeLists.txt" ]; then
    echo -e "${RED}Error: Please run this script from the tracker directory${NC}"
    exit 1
fi

# Set the executable directory
EXEC_DIR="../../build/src/tracker/exec"
if [ ! -d "$EXEC_DIR" ]; then
    echo -e "${YELLOW}Warning: Build directory not found at $EXEC_DIR${NC}"
    echo -e "${YELLOW}Trying current directory...${NC}"
    EXEC_DIR="."
fi

# Run existing tests
echo -e "${BLUE}Running existing tests...${NC}"
run_test "Average Calculation" "$EXEC_DIR/test_avgcalc.x"
run_test "Vector Magnitude Calculation" "$EXEC_DIR/test_calc_vmag.x"
run_test "Correlation Calculation" "$EXEC_DIR/calccorr.x"
run_test "Get Correlation" "$EXEC_DIR/test_getcorr.x"
run_test "Standard Deviation Calculation" "$EXEC_DIR/test_stdevcalc.x"
run_test "Weighted Average" "$EXEC_DIR/test_wtavrg.x"
run_test "Weighted Average Longitude" "$EXEC_DIR/test_wtavrg_lon.x"

# Run new comprehensive tests
echo -e "${BLUE}Running comprehensive tests...${NC}"
run_test "Distance and Bearing" "$EXEC_DIR/test_distbear.x"
run_test "Bilinear Interpolation Uneven" "$EXEC_DIR/test_bilin_int_uneven.x"
run_test "Calculate Distance" "$EXEC_DIR/test_calcdist.x"
run_test "Get Radial/Tangential Velocity" "$EXEC_DIR/test_getvrvt.x"
run_test "Sort Storms by Pressure" "$EXEC_DIR/test_sort_storms_by_pressure.x"
run_test "Relative Vorticity Calculation" "$EXEC_DIR/test_rvcal.x"
run_test "Barnes Analysis" "$EXEC_DIR/test_barnes.x"

# Print summary
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}===========================================${NC}"
echo -e "Total Tests:  $TOTAL_TESTS"
echo -e "${GREEN}Passed Tests: $PASSED_TESTS${NC}"
echo -e "${RED}Failed Tests: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed! ✗${NC}"
    exit 1
fi
