# Copyright Siemens AG, 2014
# Copyright (c) 2004-2006, Applied Informatics Software Engineering GmbH.
# and Contributors.
#
# SPDX-License-Identifier:	BSL-1.0
#
# Collection of common functionality for CXKJ CMake

# Find the Microsoft mc.exe message compiler
#
#  CMAKE_MC_COMPILER - where to find mc.exe
if (WIN32)
  # cmake has CMAKE_RC_COMPILER, but no message compiler
  if ("${CMAKE_GENERATOR}" MATCHES "Visual Studio" OR "${CMAKE_GENERATOR}" MATCHES "MinGW")
    # this path is only present for 2008+, but we currently require PATH to
    # be set up anyway
    get_filename_component(sdk_dir "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]" REALPATH)
    get_filename_component(kit_dir "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot]" REALPATH)
    get_filename_component(kit81_dir "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot81]" REALPATH)
    get_filename_component(kit10_dir "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot10]" REALPATH)
    file(GLOB kit10_list ${kit10_dir}/bin/10.*)
    if (X64)
      set(sdk_bindir "${sdk_dir}/bin/x64")
      set(kit_bindir "${kit_dir}/bin/x64")
      set(kit81_bindir "${kit81_dir}/bin/x64")
      foreach (tmp_elem ${kit10_list})
        if (IS_DIRECTORY ${tmp_elem})
		  list(APPEND kit10_bindir "${tmp_elem}/x64")
        endif()
      endforeach()
    else (X64)
      set(sdk_bindir "${sdk_dir}/bin")
      set(kit_bindir "${kit_dir}/bin/x86")
      set(kit81_bindir "${kit81_dir}/bin/x86")
      foreach (tmp_elem ${kit10_list})
        if (IS_DIRECTORY ${tmp_elem})
		  list(APPEND kit10_bindir "${tmp_elem}/x86")
        endif()
      endforeach()
    endif (X64)
  endif ()
  find_program(CMAKE_MC_COMPILER mc.exe HINTS "${sdk_bindir}" "${kit_bindir}" "${kit81_bindir}" ${kit10_bindir}
    DOC "path to message compiler")
  if(NOT CMAKE_MC_COMPILER AND MSVC)
    message(FATAL_ERROR "message compiler not found: required to build")
  endif(NOT CMAKE_MC_COMPILER AND MSVC)
  if(CMAKE_MC_COMPILER)
    message(STATUS "Found message compiler: ${CMAKE_MC_COMPILER}")
    mark_as_advanced(CMAKE_MC_COMPILER)
  endif(CMAKE_MC_COMPILER)
endif(WIN32)

# Accept older ENABLE_<COMPONENT>, ENABLE_TESTS and ENABLE_SAMPLES and
# automatically set the appropriate CXKJ_ENABLE_* variable
#
get_cmake_property(all_variables VARIABLES)
foreach(variable_name ${all_variables})
  string(SUBSTRING ${variable_name} 0 7 variable_prefix)
  if(${variable_prefix} STREQUAL "ENABLE_")
    list(FIND all_variables "CXKJ_${variable_name}" variable_found)
    if(NOT variable_found EQUAL -1)
      message(DEPRECATION "${variable_name} is deprecated and will be removed! Use CXKJ_${variable_name} instead")
      set(CXKJ_${variable_name} ${${variable_name}} CACHE BOOL "Old value from ${variable_name}" FORCE)
      unset(${variable_name} CACHE)
    endif()
  endif()
endforeach()
unset(all_variables)

#===============================================================================
# Macros for Source file management
#
#  CXKJ_SOURCES_PLAT - Adds a list of files to the sources of a components
#    Usage: CXKJ_SOURCES_PLAT( out name platform sources)
#      INPUT:
#           out             the variable the sources are added to
#           name:           the name of the components
#           platform:       the platform this sources are for (ON = All, OFF = None, WIN32, UNIX ...)
#           sources:        a list of files to add to ${out}
#    Example: CXKJ_SOURCES_PLAT( SRCS Foundation ON src/Foundation.cpp )
#
#  CXKJ_SOURCES - Like CXKJ_SOURCES_PLAT with platform = ON (Built on all platforms)
#    Usage: CXKJ_SOURCES( out name sources)
#    Example: CXKJ_SOURCES( SRCS Foundation src/Foundation.cpp)
#
#  CXKJ_SOURCES_AUTO - Like CXKJ_SOURCES but the name is read from the file header // Package: X
#    Usage: CXKJ_SOURCES_AUTO( out sources)
#    Example: CXKJ_SOURCES_AUTO( SRCS src/Foundation.cpp)
#
#  CXKJ_SOURCES_AUTO_PLAT - Like CXKJ_SOURCES_PLAT but the name is read from the file header // Package: X
#    Usage: CXKJ_SOURCES_AUTO_PLAT(out platform sources)
#    Example: CXKJ_SOURCES_AUTO_PLAT( SRCS WIN32 src/Foundation.cpp)
#
#
#  CXKJ_HEADERS - Adds a list of files to the headers of a components
#    Usage: CXKJ_HEADERS( out name headers)
#      INPUT:
#           out             the variable the headers are added to
#           name:           the name of the components
#           headers:        a list of files to add to HDRSt
#    Example: CXKJ_HEADERS( HDRS Foundation include/CXKJ/Foundation.h )
#
#  CXKJ_HEADERS_AUTO - Like CXKJ_HEADERS but the name is read from the file header // Package: X
#    Usage: CXKJ_HEADERS_AUTO( out headers)
#    Example: CXKJ_HEADERS_AUTO( HDRS src/Foundation.cpp)
#
#
#  CXKJ_MESSAGES - Adds a list of files to the messages of a components
#                  and adds the generated headers to the header list of the component.
#                  On platforms other then Windows this does nothing
#    Usage: CXKJ_MESSAGES( out name messages)
#      INPUT:
#           out             the variable the message and the resulting headers are added to
#           name:           the name of the components
#           messages:       a list of files to add to MSGS
#    Example: CXKJ_MESSAGES( HDRS Foundation include/CXKJ/Foundation.mc )
#


macro(CXKJ_SOURCES_PLAT out name platform)
    source_group("${name}\\Source Files" FILES ${ARGN})
    list(APPEND ${out} ${ARGN})
    if(NOT (${platform}))
        set_source_files_properties(${ARGN} PROPERTIES HEADER_FILE_ONLY TRUE)
    endif()
endmacro()

macro(CXKJ_SOURCES out name)
    CXKJ_SOURCES_PLAT( ${out} ${name} ON ${ARGN})
endmacro()

macro(CXKJ_SOURCES_AUTO out)
    CXKJ_SOURCES_AUTO_PLAT( ${out} ON ${ARGN})
endmacro()

macro(CXKJ_SOURCES_AUTO_PLAT out platform)
    foreach( f ${ARGN})

        get_filename_component(fname ${f} NAME)

        # Read the package name from the source file
        file(STRINGS ${f} package REGEX "// Package: (.*)")
        if(package)
            string(REGEX REPLACE ".*: (.*)" "\\1" name ${package})

            # Files of the Form X_UNIX.cpp are treated as headers
            if(${fname} MATCHES ".*_.*\\..*")
                #message(STATUS "Platform: ${name} ${f} ${platform}")
                CXKJ_SOURCES_PLAT( ${out} ${name} OFF ${f})
            else()
                #message(STATUS "Source: ${name} ${f} ${platform}")
                CXKJ_SOURCES_PLAT( ${out} ${name} ${platform} ${f})
            endif()
        else()
            #message(STATUS "Source: Unknown ${f} ${platform}")
            CXKJ_SOURCES_PLAT( ${out} Unknown ${platform} ${f})
        endif()
    endforeach()
endmacro()


macro(CXKJ_HEADERS_AUTO out)
    foreach( f ${ARGN})

        get_filename_component(fname ${f} NAME)

        # Read the package name from the source file
        file(STRINGS ${f} package REGEX "// Package: (.*)")
        if(package)
            string(REGEX REPLACE ".*: (.*)" "\\1" name ${package})
            #message(STATUS "Header: ${name} ${f}")
            CXKJ_HEADERS( ${out} ${name} ${f})
        else()
            #message(STATUS "Header: Unknown ${f}")
            CXKJ_HEADERS( ${out} Unknown ${f})
        endif()
    endforeach()
endmacro()

macro(CXKJ_HEADERS out name)
    set_source_files_properties(${ARGN} PROPERTIES HEADER_FILE_ONLY TRUE)
    source_group("${name}\\Header Files" FILES ${ARGN})
    list(APPEND ${out} ${ARGN})
endmacro()


macro(CXKJ_MESSAGES out name)
    if (WIN32 AND CMAKE_MC_COMPILER)
        foreach(msg ${ARGN})
            get_filename_component(msg_name ${msg} NAME)
            get_filename_component(msg_path ${msg} ABSOLUTE)
            string(REPLACE ".mc" ".h" hdr ${msg_name})
            set_source_files_properties(${hdr} PROPERTIES GENERATED TRUE)
            add_custom_command(
                OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${hdr}
                DEPENDS ${msg}
                COMMAND ${CMAKE_MC_COMPILER}
                ARGS
                    -h ${CMAKE_CURRENT_BINARY_DIR}
                    -r ${CMAKE_CURRENT_BINARY_DIR}
                    ${msg_path}
                VERBATIM # recommended: p260
            )

            # Add the generated file to the include directory
            include_directories(${CMAKE_CURRENT_BINARY_DIR})

            # Add the generated headers to CXKJ_HEADERS of the component
            CXKJ_HEADERS( ${out} ${name} ${CMAKE_CURRENT_BINARY_DIR}/${hdr})

        endforeach()

        set_source_files_properties(${ARGN} PROPERTIES HEADER_FILE_ONLY TRUE)
        source_group("${name}\\Message Files" FILES ${ARGN})
        list(APPEND ${out} ${ARGN})

    endif (WIN32 AND CMAKE_MC_COMPILER)
endmacro()

#===============================================================================
# Macros for Package generation
#
#  CXKJ_GENERATE_PACKAGE - Generates *Config.cmake
#    Usage: CXKJ_GENERATE_PACKAGE(target_name)
#      INPUT:
#           target_name             the name of the target. e.g. Foundation for CXKJFoundation
#    Example: CXKJ_GENERATE_PACKAGE(Foundation)
macro(CXKJ_GENERATE_PACKAGE target_name)
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${CMAKE_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}${target_name}ConfigVersion.cmake"
  VERSION ${VERSION}
  COMPATIBILITY AnyNewerVersion
)
export(EXPORT "${target_name}Targets"
  FILE "${CMAKE_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}${target_name}Targets.cmake"
  NAMESPACE "${PROJECT_NAME}::"
)
configure_file("cmake/CXKJ${target_name}Config.cmake"
  "${CMAKE_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}${target_name}Config.cmake"
  @ONLY
)

# Set config script install location in a location that find_package() will
# look for, which is different on MS Windows than for UNIX
# Note: also set in root CMakeLists.txt
if (WIN32)
  set(CXKJConfigPackageLocation "cmake")
else()
  set(CXKJConfigPackageLocation "lib/cmake/${PROJECT_NAME}")
endif()

install(
    EXPORT "${target_name}Targets"
    FILE "${PROJECT_NAME}${target_name}Targets.cmake"
    NAMESPACE "${PROJECT_NAME}::"
    DESTINATION "${CXKJConfigPackageLocation}"
    )

install(
    FILES
        "${CMAKE_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}${target_name}Config.cmake"
        "${CMAKE_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}${target_name}ConfigVersion.cmake"
    DESTINATION "${CXKJConfigPackageLocation}"
    COMPONENT Devel
    )

endmacro()

#===============================================================================
# Macros for simplified installation
#
#  CXKJ_INSTALL - Install the given target
#    Usage: CXKJ_INSTALL(target_name)
#      INPUT:
#           target_name             the name of the target. e.g. Foundation for CXKJFoundation
#    Example: CXKJ_INSTALL(Foundation)
macro(CXKJ_INSTALL target_name)
install(
    DIRECTORY include/CXKJ
    DESTINATION include
    COMPONENT Devel
    PATTERN ".svn" EXCLUDE
    )

install(
    TARGETS "${target_name}" EXPORT "${target_name}Targets"
    LIBRARY DESTINATION lib${LIB_SUFFIX}
    ARCHIVE DESTINATION lib${LIB_SUFFIX}
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
    )

if (MSVC)
# install the targets pdb
  CXKJ_INSTALL_PDB(${target_name})
endif()

endmacro()

#===============================================================================
# Macros for simplified installation of package not following the CXKJ standard as CppUnit
#
#  SIMPLE_INSTALL - Install the given target
#    Usage: SIMPLE_INSTALL(target_name)
#      INPUT:
#           target_name             the name of the target. e.g. CppUnit
#    Example: SIMPLE_INSTALL(Foundation)
macro(SIMPLE_INSTALL target_name)
install(
    DIRECTORY include
    DESTINATION include
    COMPONENT Devel
    PATTERN ".svn" EXCLUDE
    )

install(
    TARGETS "${target_name}" EXPORT "${target_name}Targets"
    LIBRARY DESTINATION lib${LIB_SUFFIX}
    ARCHIVE DESTINATION lib${LIB_SUFFIX}
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
    )

if (MSVC)
# install the targets pdb
  CXKJ_INSTALL_PDB(${target_name})
endif()

endmacro()

#  CXKJ_INSTALL_PDB - Install the given target's companion pdb file (if present)
#    Usage: CXKJ_INSTALL_PDB(target_name)
#      INPUT:
#           target_name             the name of the target. e.g. Foundation for CXKJFoundation
#    Example: CXKJ_INSTALL_PDB(Foundation)
#
#    This is an internal macro meant only to be used by CXKJ_INSTALL.
macro(CXKJ_INSTALL_PDB target_name)

    get_property(type TARGET ${target_name} PROPERTY TYPE)
    if ("${type}" STREQUAL "SHARED_LIBRARY" OR "${type}" STREQUAL "EXECUTABLE")
        install(
            FILES $<TARGET_PDB_FILE:${target_name}>
            DESTINATION bin
            COMPONENT Devel
            OPTIONAL
            )
    endif()
endmacro()
