add_library(${INFRA_TARGET_NAMESPACE}profile-compilation INTERFACE)

target_compile_options(
    ${INFRA_TARGET_NAMESPACE}profile-compilation
    INTERFACE -ftime-report $<$<CXX_COMPILER_ID:Clang>:-ftime-trace>
              $<$<CXX_COMPILER_ID:Clang>:-ftime-trace-granularity=10>)
