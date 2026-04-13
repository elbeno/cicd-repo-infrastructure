find_program(CLANG_FORMAT_PROGRAM "clang-format" HINTS ${CT_ROOT})
if(CLANG_FORMAT_PROGRAM)
    message(STATUS "clang-format found: ${CLANG_FORMAT_PROGRAM}")
endif()

add_versioned_package(URI "gh:TheLartians/Format.cmake@1.7.3" OPTIONS
                      "CMAKE_FORMAT_EXCLUDE cmake/get_cpm.cmake")

if(NOT "${INFRA_TARGET_NAMESPACE}" STREQUAL "")
    add_custom_target(${INFRA_TARGET_NAMESPACE}clang-format
                      DEPENDS clang-format)
    add_custom_target(${INFRA_TARGET_NAMESPACE}check-clang-format
                      DEPENDS check-clang-format)
    add_custom_target(${INFRA_TARGET_NAMESPACE}fix-clang-format
                      DEPENDS fix-clang-format)
    add_custom_target(${INFRA_TARGET_NAMESPACE}cmake-format
                      DEPENDS cmake-format)
    add_custom_target(${INFRA_TARGET_NAMESPACE}check-cmake-format
                      DEPENDS check-cmake-format)
    add_custom_target(${INFRA_TARGET_NAMESPACE}fix-cmake-format
                      DEPENDS fix-cmake-format)
endif()

add_dependencies(
    ${INFRA_TARGET_NAMESPACE}quality
    ${INFRA_TARGET_NAMESPACE}check-clang-format
    ${INFRA_TARGET_NAMESPACE}check-cmake-format)
add_dependencies(
    ${INFRA_TARGET_NAMESPACE}ci-quality
    ${INFRA_TARGET_NAMESPACE}check-clang-format
    ${INFRA_TARGET_NAMESPACE}check-cmake-format)
