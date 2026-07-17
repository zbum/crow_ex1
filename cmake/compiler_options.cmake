# Compiler options and warnings
function(add_warnings_optimizations target)
    # Set compiler-specific options
    if(MSVC)
        target_compile_options(${target} PRIVATE /W4 /WX)
    else()
        # GCC and Clang - Disable all problematic warnings for Crow framework
        target_compile_options(${target} PRIVATE 
            -Wno-cast-qual
            -Wno-implicit-int-conversion
            -Wno-sign-conversion
            -Wno-switch-default
            -Wno-switch-enum
            -Wno-unused-lambda-capture
            -Wno-logical-op
            -Wno-strict-aliasing
            -Wno-strict-overflow
            -Wno-conversion
            -Wno-pedantic
            -Wno-error
        )
        
        # Basic warnings (safe ones)
        target_compile_options(${target} PRIVATE 
            -Wall 
            -Wextra 
            -Wformat=2
            -Wformat-nonliteral
            -Wformat-security
            -Wmissing-declarations
            -Wmissing-field-initializers
            -Wmissing-format-attribute
            -Wmissing-include-dirs
            -Wmissing-noreturn
            -Wno-long-long
            -Wno-unused-parameter
            -Wpointer-arith
            -Wredundant-decls
            -Wshadow
            -Wstack-protector
            -Wundef
            -Wunreachable-code
            -Wunused
            -Wvariadic-macros
            -Wwrite-strings
        )
        
        # No additional strict warnings to avoid conflicts with Crow framework
        
        # No compiler-specific warnings to avoid conflicts
    endif()

    # Set optimization flags based on build type
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        target_compile_options(${target} PRIVATE 
            -g3 
            -O0
            -DDEBUG
        )
        if(NOT MSVC)
            target_compile_options(${target} PRIVATE -fno-omit-frame-pointer)
        endif()
    elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
        target_compile_options(${target} PRIVATE 
            -O3 
            -DNDEBUG
        )
        if(NOT MSVC)
            target_compile_options(${target} PRIVATE 
                -flto
                -fno-fat-lto-objects
            )
        endif()
    elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
        target_compile_options(${target} PRIVATE 
            -O2 
            -g
            -DNDEBUG
        )
    elseif(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
        target_compile_options(${target} PRIVATE 
            -Os 
            -DNDEBUG
        )
    endif()

    # Set position independent code
    set_target_properties(${target} PROPERTIES
        POSITION_INDEPENDENT_CODE ON
    )
endfunction()
