cmake_minimum_required(VERSION 3.21)
project(test_lib)

if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 23)
endif()

set(INFRA_PYTHON_FORMATTER ruff)

include(cmake/get_cpm.cmake)
cpmaddpackage(NAME infra SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../.." GIT_TAG
              HEAD)

add_library(test_lib INTERFACE)
target_compile_features(test_lib INTERFACE cxx_std_20)
target_sources(
    test_lib
    INTERFACE FILE_SET
              test_lib
              TYPE
              HEADERS
              BASE_DIRS
              include
              FILES
              include/test_lib/test.hpp)
target_sources(
    test_lib
    INTERFACE FILE_SET
              exclusions
              TYPE
              HEADERS
              BASE_DIRS
              include
              FILES
              include/test_lib/exclude.hpp
              include/exclude/bad.hpp)

if(PROJECT_IS_TOP_LEVEL)
    add_docs(docs)
    clang_tidy_interface(TARGET test_lib EXCLUDE_FILESETS exclusions)
    include(CTest)
    add_subdirectory(test)
endif()
