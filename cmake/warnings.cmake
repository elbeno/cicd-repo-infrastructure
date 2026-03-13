add_library(${INFRA_TARGET_NAMESPACE}no-extension-warnings INTERFACE)

target_compile_options(
    ${INFRA_TARGET_NAMESPACE}no-extension-warnings
    INTERFACE
        $<$<CXX_COMPILER_ID:Clang>:-Wno-c99-extensions>
        $<$<CXX_COMPILER_ID:Clang>:-Wno-c11-extensions>
        $<$<CXX_COMPILER_ID:Clang>:-Wno-c2x-extensions>
        $<$<AND:$<CXX_COMPILER_ID:Clang>,$<VERSION_GREATER_EQUAL:${CMAKE_CXX_COMPILER_VERSION},19>>:-Wno-c2y-extensions>
        $<$<CXX_COMPILER_ID:Clang>:-Wno-c++11-extensions>
        $<$<CXX_COMPILER_ID:Clang>:-Wno-c++14-extensions>
        $<$<CXX_COMPILER_ID:Clang>:-Wno-c++17-extensions>
        $<$<CXX_COMPILER_ID:Clang>:-Wno-c++2a-extensions>
        $<$<CXX_COMPILER_ID:Clang>:-Wno-c++2b-extensions>
        $<$<AND:$<CXX_COMPILER_ID:Clang>,$<VERSION_GREATER_EQUAL:${CMAKE_CXX_COMPILER_VERSION},17>>:-Wno-c++26-extensions>
)

add_library(${INFRA_TARGET_NAMESPACE}warnings INTERFACE)

target_compile_options(
    ${INFRA_TARGET_NAMESPACE}warnings
    INTERFACE
        # warnings turned on
        -Wall
        $<$<CXX_COMPILER_ID:Clang>:-Warray-bounds-pointer-arithmetic>
        -Wcast-align
        -Wconversion
        -Wdouble-promotion
        $<$<CXX_COMPILER_ID:GNU>:-Wduplicated-branches>
        $<$<CXX_COMPILER_ID:GNU>:-Wduplicated-cond>
        -Werror
        -Wextra
        -Wextra-semi
        $<$<AND:$<CXX_COMPILER_ID:Clang>,$<VERSION_GREATER_EQUAL:${CMAKE_CXX_COMPILER_VERSION},8>>:-Wextra-semi-stmt>
        -Wfatal-errors
        -Wformat=2
        $<$<CXX_COMPILER_ID:Clang>:-Wgcc-compat>
        $<$<CXX_COMPILER_ID:Clang>:-Wheader-hygiene>
        $<$<CXX_COMPILER_ID:Clang>:-Widiomatic-parentheses>
        $<$<CXX_COMPILER_ID:Clang>:-Wimplicit-fallthrough>
        $<$<CXX_COMPILER_ID:GNU>:-Wlogical-op>
        $<$<CXX_COMPILER_ID:Clang>:-Wnewline-eof>
        $<$<AND:$<CXX_COMPILER_ID:Clang>,$<VERSION_GREATER_EQUAL:${CMAKE_CXX_COMPILER_VERSION},21>>:-Wnrvo>
        $<$<AND:$<CXX_COMPILER_ID:GNU>,$<VERSION_GREATER_EQUAL:${CMAKE_CXX_COMPILER_VERSION},14>>:-Wnrvo>
        -Wold-style-cast
        -Woverloaded-virtual
        $<$<CXX_COMPILER_ID:Clang>:-Wpedantic>
        -Wshadow
        $<$<CXX_COMPILER_ID:Clang>:-Wshift-sign-overflow>
        $<$<CXX_COMPILER_ID:GNU>:-Wuseless-cast>
        -Wunused)

target_link_libraries(${INFRA_TARGET_NAMESPACE}warnings
                      INTERFACE ${INFRA_TARGET_NAMESPACE}no-extension-warnings)
