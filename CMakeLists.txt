cmake_minimum_required(VERSION 3.26)
project(MiniCmakeDemoLib)


option(ENABLE_CORE "Enable Core, required by all components" ON)
option(ENABLE_ADD "Enable Add" ON)
option(ENABLE_ECHO "Enable Echo" ON)
option(ENABLE_TESTS "Enable tests & samples" ON)
option(ENABLE_AUTODOWNLOAD_VCPKG "Enable tests & samples" ON)
set(BUILD_SHARED_LIBS ON)

if(ENABLE_AUTODOWNLOAD_VCPKG)
    cmake_policy(SET CMP0135 NEW)
    if(PROJECT_IS_TOP_LEVEL)
        include(FetchContent)
        message(STATUS "Fetching vcpkg...")
        FetchContent_Declare(vcpkg URL "https://github.com/microsoft/vcpkg/archive/master.zip")
        FetchContent_MakeAvailable(vcpkg)
        include("${vcpkg_SOURCE_DIR}/scripts/buildsystems/vcpkg.cmake")
    endif()
endif ()


# auto upgrade
#execute_process(COMMAND get_version.sh OUTPUT_VARIABLE VERSION_INFO)
#MESSAGE(STATUS "${VERSION_INFO}")
#SET_TARGET_PROPERTIES(taos PROPERTIES VERSION ${VERSION_INFO} SOVERSION 1)


# Read the version information from the VERSION file
file(STRINGS "${PROJECT_SOURCE_DIR}/VERSION" PACKAGE_VERSION)
string(REGEX REPLACE "([0-9]+)\\.[0-9]+\\.[0-9]+.*" "\\1" CPACK_PACKAGE_VERSION_MAJOR ${PACKAGE_VERSION})
string(REGEX REPLACE "[0-9]+\\.([0-9]+)\\.[0-9]+.*" "\\1" CPACK_PACKAGE_VERSION_MINOR ${PACKAGE_VERSION})
string(REGEX REPLACE "[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" CPACK_PACKAGE_VERSION_PATCH ${PACKAGE_VERSION})

set(PROJECT_VERSION ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH})
set(PROJECT_MODULE_EXPORT_NAMESPACE "${PROJECT_NAME}::")

# Put the libaries and binaries that get built into directories at the
# top of the build tree rather than in hard-to-find leaf
# directories. This simplifies manual testing and the use of the build
# tree rather than installed Boost libraries.
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
# Windows DLLs are "runtime" for CMake. Output them to "bin" like the Visual Studio projects do.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Reset output dirs for multi-config builds
foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/lib)
endforeach(OUTPUTCONFIG)


#configure_file(
#        "${PROJECT_SOURCE_DIR}/DLLVersion.rc"
#        "${CMAKE_BINARY_DIR}/DLLVersion.rc"
#        IMMEDIATE @ONLY)


# Append our module directory to CMake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# C++11/14 compiler flags
include(CXX1x)
check_for_cxx20_compiler(CXX20_COMPILER)

# If a C++14 compiler is available, then set the appropriate flags
if(CXX20_COMPILER)
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
else()
    message(FATAL_ERROR "Compiler does not support C++20.")
endif()

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo")
endif()

# Enable standard installation directories
include(GNUInstallDirs)



# Include some common macros to simpilfy the Poco CMake files
include(PocoMacros)


if(MSVC)
    option(POCO_MT "Set to OFF|ON (default is OFF) to control build of POCO as /MT instead of /MD" OFF)

    if(BUILD_SHARED_LIBS AND POCO_MT)
        message(FATAL_ERROR "Cannot have both BUILD_SHARED_LIBS and POCO_MT")
    endif()

    if(POCO_SANITIZE_ASAN)
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /fsanitize=address")
    endif()
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:__cplusplus")
endif()


if(ENABLE_TESTS)
    include(CTest)
    enable_testing()

    find_package(GTest CONFIG REQUIRED)
    message(STATUS "Building with unittests & samples")
else()
    message(STATUS "Building without tests & samples")
endif()


include(DefinePlatformSpecifc)

# Collect the built libraries and include dirs, the will be used to create the PocoConfig.cmake file
set(Poco_COMPONENTS "")


if(ENABLE_TESTS)
#    add_subdirectory(CppUnit)
    set(ENABLE_ADD ON CACHE BOOL "Enable Add" FORCE)
    set(ENABLE_ECHO ON CACHE BOOL "Enable Echo" FORCE)
endif()

if(ENABLE_CORE)
    add_subdirectory(modules/Core)
endif()

if(ENABLE_ADD)
    add_subdirectory(modules/Add)
    list(APPEND Poco_COMPONENTS "${PROJECT_NAME}::Add")
endif()

#if(ENABLE_ECHO)
#    add_subdirectory(modules/Echo)
#    list(APPEND Poco_COMPONENTS "${PROJECT_NAME}::Echo")
#endif()



##############################################################
## Uninstall stuff see: http://www.vtk.org/Wiki/CMake_FAQ
#configure_file(
#        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
#        "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
#        IMMEDIATE @ONLY)
#
#add_custom_target(uninstall
#        "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
#)

#############################################################
# cmake config files

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY AnyNewerVersion
)

# Set config script install location in a location that find_package() will
# look for, which is different on MS Windows than for UNIX
# Note: also set in POCO_GENERATE_PACKAGE macro in cmake/PocoMacros.cmake
#if(WIN32)
#    set(PocoConfigPackageLocation "cmake")
#else()
#    set(PocoConfigPackageLocation "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
#endif()
set(PocoConfigPackageLocation "${CMAKE_INSTALL_PREFIX}/cmake/${PROJECT_NAME}")

configure_file(cmake/${PROJECT_NAME}Config.cmake.in "${PocoConfigPackageLocation}/${PROJECT_NAME}Config.cmake" @ONLY)
install(
        FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}Config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake
        DESTINATION
        "${PocoConfigPackageLocation}"
        COMPONENT
        Devel
)

#mark_as_advanced(
#        gtest_force_shared_crt
#        gtest_build_tests
#        gtest_build_samples
#        gtest_disable_pthreads
#        gtest_hide_internal_symbols)

message(STATUS "CMake ${CMAKE_VERSION} successfully configured ${PROJECT_NAME} using ${CMAKE_GENERATOR} generator")
message(STATUS "${PROJECT_NAME} package version: ${PROJECT_VERSION}")
if(BUILD_SHARED_LIBS)
    message(STATUS "[cmake] Build dynamic libraries")
else()
    message(STATUS "[cmake] Build static libraries")
endif()
message(STATUS "[cmake] Installation target path: ${CMAKE_INSTALL_PREFIX}")
if(CMAKE_TOOLCHAIN_FILE)
    message(STATUS "[cmake] Use toolchain file:		${CMAKE_TOOLCHAIN_FILE}")
endif()
message(STATUS "[cmake] Build for OS type:      ${CMAKE_SYSTEM_NAME}")
message(STATUS "[cmake] Build for OS version:   ${CMAKE_SYSTEM_VERSION}")
message(STATUS "[cmake] Build for CPU type:     ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "[cmake] Build type:             ${CMAKE_BUILD_TYPE}")
string(TOUPPER "${CMAKE_BUILD_TYPE}" BUILD_TYPE)
message(STATUS "[cmake] Build with cxx flags:   ${CMAKE_CXX_FLAGS_${BUILD_TYPE}} ${CMAKE_CXX_FLAGS}")
message(STATUS "[cmake] Build with c flags:     ${CMAKE_C_FLAGS_${BUILD_TYPE}} ${CMAKE_C_FLAGS}")

foreach(component ${Poco_COMPONENTS})
    message(STATUS "Building: ${component}")
endforeach()



add_library(${PROJECT_NAME}
        modules/MiniCmakeDemoLib.h
        modules/MiniCmakeDemoLib.cpp)

target_link_libraries(${PROJECT_NAME} PUBLIC ${Poco_COMPONENTS})

if (ENABLE_TESTS)
    add_subdirectory(tests)
    add_subdirectory(samples)
endif ()


#function(install_project)
#    if(INSTALL_GTEST)
#        install(DIRECTORY "${PROJECT_SOURCE_DIR}/include/"
#                COMPONENT "${PROJECT_NAME}"
#                DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
#        # Install the project targets.
#        install(TARGETS ${ARGN}
#                EXPORT ${targets_export_name}
#                COMPONENT "${PROJECT_NAME}"
#                RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
#                ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
#                LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}")
#        if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
#            # Install PDBs
#            foreach(t ${ARGN})
#                get_target_property(t_pdb_name ${t} COMPILE_PDB_NAME)
#                get_target_property(t_pdb_name_debug ${t} COMPILE_PDB_NAME_DEBUG)
#                get_target_property(t_pdb_output_directory ${t} PDB_OUTPUT_DIRECTORY)
#                install(FILES
#                        "${t_pdb_output_directory}/\${CMAKE_INSTALL_CONFIG_NAME}/$<$<CONFIG:Debug>:${t_pdb_name_debug}>$<$<NOT:$<CONFIG:Debug>>:${t_pdb_name}>.pdb"
#                        COMPONENT "${PROJECT_NAME}"
#                        DESTINATION ${CMAKE_INSTALL_LIBDIR}
#                        OPTIONAL)
#            endforeach()
#        endif()
#        # Configure and install pkgconfig files.
#        foreach(t ${ARGN})
#            set(configured_pc "${generated_dir}/${t}.pc")
#            configure_file("${PROJECT_SOURCE_DIR}/cmake/${t}.pc.in"
#                    "${configured_pc}" @ONLY)
#            install(FILES "${configured_pc}"
#                    COMPONENT "${PROJECT_NAME}"
#                    DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
#        endforeach()
#    endif()
#endfunction()
#
#install_project(${PROJECT_NAME} ${Poco_COMPONENTS})