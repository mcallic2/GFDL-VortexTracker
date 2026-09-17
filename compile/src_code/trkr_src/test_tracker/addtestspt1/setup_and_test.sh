#!/bin/bash
#************************************************
# GFDL Vortex Tracker - Setup and Test Script
# Comprehensive build and test setup
#
# Created by: GitHub Copilot Testing Suite
#************************************************

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored headers
print_header() {
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}================================================${NC}"
}

print_step() {
    echo -e "${BLUE}→ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Main setup function
main() {
    print_header "GFDL Vortex Tracker - Setup and Test"
    echo
    
    # Check if we're in the right directory
    if [ ! -f "CMakeLists.txt" ] || [ ! -d "tracker" ]; then
        print_error "Please run this script from the code/src directory"
        exit 1
    fi
    
    # Parse command line arguments
    BUILD_TYPE="Debug"
    RUN_TESTS=true
    CLEAN_BUILD=false
    COMPILER="gfortran"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --release)
                BUILD_TYPE="Release"
                shift
                ;;
            --no-tests)
                RUN_TESTS=false
                shift
                ;;
            --clean)
                CLEAN_BUILD=true
                shift
                ;;
            --compiler)
                COMPILER="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --release     Build in Release mode (default: Debug)"
                echo "  --no-tests    Skip running tests after build"
                echo "  --clean       Clean build directory before building"
                echo "  --compiler    Specify compiler (default: gfortran)"
                echo "  -h, --help    Show this help message"
                exit 0
                ;;
            *)
                print_warning "Unknown option: $1"
                shift
                ;;
        esac
    done
    
    print_step "Configuration:"
    echo "  Build Type: $BUILD_TYPE"
    echo "  Compiler: $COMPILER"
    echo "  Run Tests: $RUN_TESTS"
    echo "  Clean Build: $CLEAN_BUILD"
    echo
    
    # Step 1: Check dependencies
    print_step "Checking dependencies..."
    
    check_command() {
        if command -v $1 &> /dev/null; then
            print_success "$1 found"
        else
            print_error "$1 not found - please install $1"
            return 1
        fi
    }
    
    DEPS_OK=true
    check_command cmake || DEPS_OK=false
    check_command $COMPILER || DEPS_OK=false
    check_command make || DEPS_OK=false
    
    if [ "$DEPS_OK" = false ]; then
        print_error "Missing dependencies. Please install required packages."
        exit 1
    fi
    
    # Step 2: Check libraries
    print_step "Checking libraries..."
    
    check_library() {
        if pkg-config --exists $1 2>/dev/null; then
            print_success "$1 found"
        else
            print_warning "$1 not found via pkg-config"
        fi
    }
    
    check_library netcdf
    check_library netcdf-fortran
    
    # Step 3: Setup build directory
    print_step "Setting up build directory..."
    
    if [ "$CLEAN_BUILD" = true ] && [ -d "build" ]; then
        print_step "Cleaning existing build directory..."
        rm -rf build
        print_success "Build directory cleaned"
    fi
    
    mkdir -p build
    cd build
    
    # Step 4: Configure with CMake
    print_step "Configuring with CMake..."
    
    CMAKE_ARGS=(
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE
        -DCMAKE_Fortran_COMPILER=$COMPILER
    )
    
    if [ "$BUILD_TYPE" = "Release" ]; then
        CMAKE_ARGS+=(-DCMAKE_Fortran_FLAGS="-O3 -march=native")
    fi
    
    if cmake "${CMAKE_ARGS[@]}" ..; then
        print_success "CMake configuration completed"
    else
        print_error "CMake configuration failed"
        exit 1
    fi
    
    # Step 5: Build the project
    print_step "Building the project..."
    
    if make -j$(nproc); then
        print_success "Build completed successfully"
    else
        print_error "Build failed"
        exit 1
    fi
    
    # Step 6: Run tests if requested
    if [ "$RUN_TESTS" = true ]; then
        print_step "Running tests..."
        
        # Run CTest
        print_step "Running CTest suite..."
        if ctest --output-on-failure; then
            print_success "CTest suite passed"
        else
            print_warning "Some CTest tests failed"
        fi
        
        # Run custom test runner
        print_step "Running custom test runner..."
        cd ../tracker
        if [ -x run_tests.sh ]; then
            if ./run_tests.sh; then
                print_success "Custom test runner completed successfully"
            else
                print_warning "Some custom tests failed"
            fi
        else
            print_warning "Custom test runner not found or not executable"
        fi
        cd ../build
    fi
    
    # Step 7: Summary
    print_header "Setup Complete"
    
    echo "Build completed successfully!"
    echo
    echo "Available executables:"
    if [ -d "src/tracker/exec" ]; then
        ls -la src/tracker/exec/*.x 2>/dev/null | while read -r line; do
            echo "  $(basename $(echo $line | awk '{print $9}'))"
        done
    fi
    
    echo
    echo "To run tests manually:"
    echo "  cd build && ctest --output-on-failure"
    echo "  cd tracker && ./run_tests.sh"
    echo
    echo "To run the main tracker:"
    echo "  cd build/src/tracker/exec && ./gettrk.x"
    echo
    
    print_success "All done!"
}

# Run main function
main "$@"
