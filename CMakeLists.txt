cmake_minimum_required(VERSION 3.27)

# this change is inconsequential just to get a new commit to test self-update

if(NOT PROJECT_NAME)
    project(cicd)
endif()

find_program(GIT_PROGRAM "git")
if(NOT GIT_PROGRAM)
    message(FATAL_ERROR "git not found!")
endif()

function(cicd_check_self_update)
    # trivial early-out if:
    if(NOT DEFINED CPM_ARGS_NAME) # not being CPM-included
        return()
    endif()
    if(NOT DEFINED CPM_ARGS_GIT_REPOSITORY) # working with local copy
        return()
    endif()
    if(DEFINED ${CPM_ARGS_NAME}_ADDED) # already fetched
        return()
    endif()
    if(NOT DEFINED ${CPM_ARGS_NAME}_SOURCE_DIR) # no source directory?
        return()
    endif()

    # only update if we're actually processing this repo
    file(REAL_PATH ${${CPM_ARGS_NAME}_SOURCE_DIR} my_path)
    if(NOT CMAKE_CURRENT_LIST_DIR STREQUAL my_path)
        return()
    endif()

    # if you asked for the actual hash I'm already at, we're good: this is the
    # case whenever you pin to a hash
    execute_process(
        COMMAND ${GIT_PROGRAM} rev-parse HEAD
        WORKING_DIRECTORY ${my_path}
        OUTPUT_VARIABLE head_hash
        RESULT_VARIABLE hash_ok
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT hash_ok EQUAL 0)
        message(
            FATAL_ERROR
                "CICD: error discovering the current hash (`${GIT_PROGRAM} rev-parse HEAD`) in ${my_path}"
        )
        return()
    endif()
    string(FIND ${head_hash} ${CPM_ARGS_GIT_TAG} hash_pos)
    if(hash_pos EQUAL 0)
        return()
    endif()

    message(
        STATUS
            "CICD: cached version (${head_hash}) is not requested version (${CPM_ARGS_GIT_TAG}); checking upstream"
    )

    # what's the hash for what you asked for?
    execute_process(
        COMMAND ${GIT_PROGRAM} ls-remote ${CPM_ARGS_GIT_REPOSITORY}
                ${CPM_ARGS_GIT_TAG}
        COMMAND cut -f1
        WORKING_DIRECTORY ${my_path}
        OUTPUT_VARIABLE remote_hash
        RESULT_VARIABLE hash_ok
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT hash_ok EQUAL 0)
        message(
            FATAL_ERROR
                "CICD: error discovering the remote hash (`${GIT_PROGRAM} ls-remote ${CPM_ARGS_GIT_REPOSITORY} ${CPM_ARGS_GIT_TAG}`) in ${my_path}"
        )
        return()
    else()
        # success and empty output from git ls-remote probably means we asked
        # for a hash, not a branch/tag
        if(remote_hash STREQUAL "")
            set(remote_hash ${CPM_ARGS_GIT_TAG})
        endif()
    endif()
    message(STATUS "CICD: requested version hash is ${remote_hash}")

    # do we already fulfil that hash?
    execute_process(
        COMMAND ${GIT_PROGRAM} merge-base --is-ancestor ${remote_hash}
                ${head_hash}
        WORKING_DIRECTORY ${my_path}
        RESULT_VARIABLE hash_ok
        ERROR_QUIET)
    if(hash_ok EQUAL 0)
        message(
            STATUS
                "CICD: cached version (${head_hash}) fulfils requested version hash (${remote_hash})"
        )
    else()
        message(
            STATUS
                "CICD: cached version (${head_hash}) out of date; fetching (${remote_hash})"
        )
        execute_process(COMMAND ${GIT_PROGRAM} fetch ${CPM_ARGS_GIT_REPOSITORY}
                                ${remote_hash} WORKING_DIRECTORY ${my_path})
        execute_process(
            COMMAND ${GIT_PROGRAM} reset --hard ${remote_hash}
            WORKING_DIRECTORY ${my_path}
            RESULT_VARIABLE reset_ok)
        if(NOT reset_ok EQUAL 0)
            message(
                FATAL_ERROR
                    "CICD: Couldn't update to ${remote_hash} - check the repository at ${my_path}."
            )
        endif()
        message(STATUS "CICD: cached version is now at ${remote_hash}")
    endif()
endfunction()

option(INFRA_SELF_UPDATE "Check and update CICD repository automatically" ON)
if(INFRA_SELF_UPDATE)
    cicd_check_self_update()
endif()
include(cmake/main.cmake)
