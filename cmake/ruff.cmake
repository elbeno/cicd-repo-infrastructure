function(ruff_format)
    message(STATUS "ruff_format(...) is disabled because ruff was not found.")
endfunction()

find_program(RUFF_PROGRAM "ruff")
if(RUFF_PROGRAM)
    message(STATUS "ruff found at ${RUFF_PROGRAM}")
else()
    message(STATUS "ruff not found. Adding dummy target.")
    set(RUFF_NOT_FOUND_COMMAND_ARGS
        COMMAND ${CMAKE_COMMAND} -E echo
        "Cannot run ruff because ruff not found." COMMAND ${CMAKE_COMMAND} -E
        false)
    add_custom_target(${INFRA_TARGET_NAMESPACE}check-ruff-format
                      ${RUFF_NOT_FOUND_COMMAND_ARGS})
    add_custom_target(${INFRA_TARGET_NAMESPACE}fix-ruff-format
                      ${RUFF_NOT_FOUND_COMMAND_ARGS})
    return()
endif()

function(add_ruff_format_target name)
    execute_process(
        COMMAND ${GIT_PROGRAM} rev-parse --show-prefix
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(
        COMMAND ${GIT_PROGRAM} rev-parse --show-toplevel
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE BASE_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    add_custom_target(
        "${INFRA_TARGET_NAMESPACE}${name}-ruff-format"
        COMMAND
            ${CMAKE_COMMAND} "-DGIT_PROGRAM=${GIT_PROGRAM}"
            "-DRUFF_PROGRAM=${RUFF_PROGRAM}" "-DFORMAT_FUNC=${name}"
            "-DWORKING_DIR=${BASE_DIR}/${PREFIX}" "-P"
            "${CMAKE_CURRENT_LIST_DIR}/scripts/ruff.cmake")
endfunction()

add_ruff_format_target("check")
add_ruff_format_target("fix")
