if(TARGET ${INFRA_TARGET_NAMESPACE}quality)
    return()
endif()

if(NOT DEFINED INFRA_PYTHON_FORMATTER)
    set(INFRA_PYTHON_FORMATTER black)
endif()

if(PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    add_custom_target(${INFRA_TARGET_NAMESPACE}quality)
    add_custom_target(${INFRA_TARGET_NAMESPACE}ci-quality)

    get_filename_component(CT_ROOT ${CMAKE_CXX_COMPILER} DIRECTORY)

    include(${CMAKE_CURRENT_LIST_DIR}/branch_diff.cmake)

    include(${CMAKE_CURRENT_LIST_DIR}/sanitizers.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/test.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/benchmark.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/metabench.cmake)

    include(${CMAKE_CURRENT_LIST_DIR}/warnings.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/profile.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/diagnostics.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/coverage.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/mull.cmake)

    include(${CMAKE_CURRENT_LIST_DIR}/format.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/clang-tidy.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/mypy.cmake)

    include(${CMAKE_CURRENT_LIST_DIR}/black.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/ruff.cmake)

    add_dependencies(
        ${INFRA_TARGET_NAMESPACE}quality
        ${INFRA_TARGET_NAMESPACE}check-${INFRA_PYTHON_FORMATTER}-format)
    add_dependencies(
        ${INFRA_TARGET_NAMESPACE}ci-quality
        ${INFRA_TARGET_NAMESPACE}check-${INFRA_PYTHON_FORMATTER}-format)
endif()
