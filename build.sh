#!/bin/bash

# Build script for crow_ex1 project
# Usage: ./build.sh [debug|release|clean|test|benchmark]

set -e

# Default values
BUILD_TYPE="Release"
BUILD_DIR="build"
CLEAN=false
RUN_TESTS=false
RUN_BENCHMARK=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        debug)
            BUILD_TYPE="Debug"
            BUILD_DIR="build-debug"
            shift
            ;;
        release)
            BUILD_TYPE="Release"
            BUILD_DIR="build-release"
            shift
            ;;
        clean)
            CLEAN=true
            shift
            ;;
        test)
            RUN_TESTS=true
            shift
            ;;
        benchmark)
            RUN_BENCHMARK=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [debug|release|clean|test|benchmark]"
            echo "  debug     - Build debug version"
            echo "  release   - Build release version"
            echo "  clean     - Clean build directory"
            echo "  test      - Run tests after build"
            echo "  benchmark - Run benchmarks after build"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Clean build directory if requested
if [ "$CLEAN" = true ]; then
    echo "Cleaning build directory..."
    rm -rf build build-debug build-release
    echo "Clean complete."
    exit 0
fi

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake
echo "Configuring with CMake (Build type: $BUILD_TYPE)..."
cmake .. \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DBUILD_TESTS=OFF \
    -DBUILD_BENCHMARKS=OFF

# Build
echo "Building..."
cmake --build . --parallel $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Run tests if requested
if [ "$RUN_TESTS" = true ]; then
    echo "Running tests..."
    ctest --output-on-failure
fi

# Run benchmarks if requested
if [ "$RUN_BENCHMARK" = true ]; then
    echo "Running benchmarks..."
    ./tests/bench/benchmark_test
fi

echo "Build complete!"
echo "Executable: $BUILD_DIR/crow_ex1"
