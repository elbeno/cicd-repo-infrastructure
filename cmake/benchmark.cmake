add_custom_target(${INFRA_TARGET_NAMESPACE}benchmarks)
add_custom_target(${INFRA_TARGET_NAMESPACE}build_benchmarks)

function(get_nanobench)
    if(NOT TARGET nanobench)
        add_versioned_package("gh:martinus/nanobench@4.3.11")
    endif()
endfunction()

function(add_benchmark name)
    set(options NANO)
    set(multiValueArgs FILES INCLUDE_DIRECTORIES LIBRARIES SYSTEM_LIBRARIES)
    cmake_parse_arguments(BM "${options}" "" "${multiValueArgs}" ${ARGN})

    set(tgt_name "${INFRA_TARGET_NAMESPACE}${name}")
    add_executable(${tgt_name} EXCLUDE_FROM_ALL ${BM_FILES})
    target_compile_options(${tgt_name} PRIVATE -O3 -march=native)
    target_include_directories(${tgt_name} PRIVATE ${BM_INCLUDE_DIRECTORIES})
    target_link_libraries(${tgt_name} PRIVATE ${BM_LIBRARIES})
    target_link_libraries_system(${tgt_name} PRIVATE ${BM_SYSTEM_LIBRARIES})
    add_dependencies(${INFRA_TARGET_NAMESPACE}build_benchmarks ${tgt_name})

    if(BM_NANO)
        get_nanobench()
        target_link_libraries_system(${tgt_name} PRIVATE nanobench)
    endif()

    add_custom_command(
        OUTPUT ${tgt_name}.results
        COMMAND $<TARGET_FILE:${tgt_name}> > "${tgt_name}.results"
        DEPENDS ${tgt_name})
    add_custom_target(${INFRA_TARGET_NAMESPACE}run_${name}
                      DEPENDS ${tgt_name}.results)
    add_dependencies(${INFRA_TARGET_NAMESPACE}benchmarks
                     "${INFRA_TARGET_NAMESPACE}run_${name}")
endfunction()
