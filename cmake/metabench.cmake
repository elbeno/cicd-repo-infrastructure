if(COMMAND add_metabench_profile)
    return()
endif()

add_custom_target(${INFRA_TARGET_NAMESPACE}metabench_tests)

macro(get_metabench)
    if(NOT COMMAND metabench_add_chart)
        metabench_recipe(3322ce7)
    endif()
endmacro()

function(add_mb_profile)
    set(singleValueArgs TARGET RANGE)
    set(multiValueArgs TEMPLATES INCLUDE_DIRECTORIES LIBRARIES DS_ARGS
                       CHART_ARGS)
    cmake_parse_arguments(MB "" "${singleValueArgs}" "${multiValueArgs}"
                          ${ARGN})

    foreach(template ${MB_TEMPLATES})
        string(REPLACE "/" "_" dataset ${template})
        set(dataset "${INFRA_TARGET_NAMESPACE}${dataset}")
        metabench_add_dataset(${dataset} "${template}" "${MB_RANGE}" NAME
                              ${dataset} ${MB_DS_ARGS})
        target_include_directories(${dataset} PRIVATE ${MB_INCLUDE_DIRECTORIES})
        target_link_libraries(${dataset} PRIVATE ${MB_LIBRARIES})
        list(APPEND datasets ${dataset})
    endforeach()

    metabench_add_chart(${MB_TARGET} DATASETS ${datasets} ${MB_CHART_ARGS})
    add_dependencies(${INFRA_TARGET_NAMESPACE}metabench_tests ${MB_TARGET})
endfunction()

macro(add_metabench_profile)
    get_metabench()
    add_mb_profile(${ARGN})
endmacro()

function(add_mb_comparison)
    set(singleValueArgs
        TARGET
        RANGE
        TEMPLATE
        LIBRARY
        REMOTE
        BRANCH
        OPTIONS)
    set(multiValueArgs INCLUDE_DIRECTORIES LIBRARIES DS_ARGS CHART_ARGS)
    cmake_parse_arguments(MB "" "${singleValueArgs}" "${multiValueArgs}"
                          ${ARGN})

    if(NOT PROJECT_IS_TOP_LEVEL)
        message(
            FATAL_ERROR
                "add_mb_comparison() must be used only against a top-level project."
        )
    endif()

    if(NOT DEFINED ${MB_LIBRARY}_SOURCE_DIR)
        message(
            FATAL_ERROR
                "add_mb_comparison(${ARGN}): no source directory for ${MB_LIBRARY}"
        )
    endif()
    set(my_path ${${MB_LIBRARY}_SOURCE_DIR})

    string(TOUPPER ${MB_LIBRARY} ulib_name)
    if(NOT DEFINED ${ulib_name}_ALT)
        message(
            FATAL_ERROR
                "add_mb_comparison(${ARGN}): ${MB_LIBRARY} does not define a ${ulib_name}_ALT option."
        )
    endif()

    if(NOT DEFINED MB_REMOTE)
        set(MB_REMOTE "origin")
    endif()
    if(NOT DEFINED MB_BRANCH)
        set(MB_BRANCH "main")
    endif()

    # get the hash the remote branch is at
    execute_process(
        COMMAND ${GIT_PROGRAM} ls-remote -h ${MB_REMOTE} ${MB_BRANCH}
        WORKING_DIRECTORY ${my_path}
        OUTPUT_VARIABLE remote_hash
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REGEX REPLACE "\t.*" "" remote_hash ${remote_hash})

    # get the remote repository
    execute_process(
        COMMAND ${GIT_PROGRAM} remote -v
        COMMAND awk "/^${MB_REMOTE}\\s.*\\(fetch\\)$/ { print $2 }"
        WORKING_DIRECTORY ${my_path}
        OUTPUT_VARIABLE gh_repo
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REGEX REPLACE "^.*:" "" gh_repo ${gh_repo})
    string(REGEX REPLACE "\.git$" "" gh_repo ${gh_repo})

    # get the library at that hash
    set(orig_lib "${MB_LIBRARY}_alt")
    add_versioned_package(
        NAME
        ${orig_lib}
        GITHUB_REPOSITORY
        ${gh_repo}
        GIT_TAG
        ${remote_hash}
        OPTIONS
        ${MB_OPTIONS}
        "${ulib_name}_ALT ON")

    if(NOT TARGET ${orig_lib})
        message(
            FATAL_ERROR
                "add_mb_comparison(${ARGN}): ${MB_LIBRARY} with ${ulib_name}_ALT ON did not define a ${orig_lib} target."
        )
    endif()

    string(REPLACE "/" "_" dataset ${MB_TEMPLATE})
    foreach(alt in ITEMS ${INFRA_TARGET_NAMESPACE}old
                         ${INFRA_TARGET_NAMESPACE}new)
        metabench_add_dataset(
            "${alt}_${dataset}" "${MB_TEMPLATE}" "${MB_RANGE}" NAME
            "${alt}_${dataset}" ${MB_DS_ARGS})
        target_include_directories("${alt}_${dataset}"
                                   PRIVATE ${MB_INCLUDE_DIRECTORIES})
        target_link_libraries("${alt}_${dataset}" PRIVATE ${MB_LIBRARIES})
    endforeach()
    target_link_libraries("${INFRA_TARGET_NAMESPACE}old_${dataset}"
                          PRIVATE ${orig_lib})
    target_link_libraries("${INFRA_TARGET_NAMESPACE}new_${dataset}"
                          PRIVATE ${MB_LIBRARY})

    metabench_add_chart(
        ${MB_TARGET} DATASETS ${INFRA_TARGET_NAMESPACE}old_${dataset}
        ${INFRA_TARGET_NAMESPACE}new_${dataset} ${MB_CHART_ARGS})
    add_dependencies(${INFRA_TARGET_NAMESPACE}metabench_tests ${MB_TARGET})
endfunction()

macro(add_metabench_comparison)
    get_metabench()
    add_mb_comparison(${ARGN})
endmacro()
