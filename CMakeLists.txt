cmake_minimum_required(VERSION 3.15.0 FATAL_ERROR)

# Define the project name and language
project(crow_ex1
    LANGUAGES CXX
    VERSION 1.0.0
)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# Export compile commands for IDE support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Default to Release build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
    message(STATUS "No build type selected, default to Release")
endif()

# Include compiler options
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/compiler_options.cmake)

# Find required packages
find_package(PkgConfig REQUIRED)
find_package(Threads REQUIRED)

# Find MySQL
pkg_check_modules(MYSQL REQUIRED mysqlclient)
find_library(MYSQL_LIBRARY NAMES mysqlclient libmysqlclient REQUIRED)

# Find yaml-cpp
find_package(PkgConfig REQUIRED)
pkg_check_modules(YAML_CPP REQUIRED yaml-cpp)

# Set yaml-cpp library path for macOS
if(APPLE)
    set(YAML_CPP_LIBRARIES "/opt/homebrew/Cellar/yaml-cpp/0.8.0/lib/libyaml-cpp.dylib")
endif()

# Add Crow as subdirectory
add_subdirectory(Crow)

# Create source library
add_subdirectory(src)

# Create main executable
add_executable(${PROJECT_NAME} src/main.cpp)

# Disable problematic warnings for Crow framework
target_compile_options(${PROJECT_NAME} PRIVATE 
    -Wno-cast-qual
    -Wno-implicit-int-conversion
    -Wno-sign-conversion
    -Wno-switch-default
    -Wno-unused-lambda-capture
)

add_warnings_optimizations(${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME} 
    PRIVATE 
        crow_ex1_lib
        Crow::Crow
        Threads::Threads
        ${YAML_CPP_LIBRARIES}
        ${MYSQL_LIBRARY}
)

# Add include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${MYSQL_INCLUDE_DIRS}
    ${YAML_CPP_INCLUDE_DIRS}
)

# Add compile definitions
target_compile_definitions(${PROJECT_NAME} PRIVATE
    ${MYSQL_CFLAGS_OTHER}
    ${YAML_CPP_CFLAGS_OTHER}
)

# Add tests if enabled
option(BUILD_TESTS "Build tests" ON)
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Add benchmarks if enabled
option(BUILD_BENCHMARKS "Build benchmarks" ON)
if(BUILD_BENCHMARKS)
    add_subdirectory(tests/bench)
endif()

# Installation
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
)

# Print configuration summary
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Build tests: ${BUILD_TESTS}")
message(STATUS "Build benchmarks: ${BUILD_BENCHMARKS}")
