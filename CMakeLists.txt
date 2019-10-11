# CMake 最低版本号要求
cmake_minimum_required (VERSION 2.8)
#设置项目语言
ENABLE_LANGUAGE(CXX)
#设置项目名字
PROJECT(CXKJOProject)
#判断系统位数
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
   # 64-bit project
   SET(64_BIT_OS TRUE)
     MESSAGE(STATUS "64-bit OS detected")
 else()
   SET(64_BIT_OS FALSE)
   MESSAGE(STATUS "32-bit OS detected")
endif()
#打开显示版本号
option(CXKJO_VERBOSE_MESSAGES "Enable informational messages during configure" ON)
#设置动态库版本
file(STRINGS "${PROJECT_SOURCE_DIR}/libversion" SHARED_LIBRARY_VERSION)
#设置版本号
SET(MAJOR_VERSION 0)
IF ( NOT VERSION )
   IF ( "${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows" )
      message("windows: Extracting git software version")
      execute_process(COMMAND powershell "(git rev-list --branches HEAD | Measure-Object -line).Lines" OUTPUT_VARIABLE GIT_VERSION WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
   ELSE()
      IF(UNIX OR ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
         message( STATUS "nix: Extracting git software version" )
      ELSE()
         message( STATUS "unknown platform: extracting git software version" )
      ENDIF()
      execute_process(COMMAND bash "-c" "git rev-list --branches HEAD | wc -l | tr -d ' ' | tr -d '\n'" OUTPUT_VARIABLE GIT_VERSION WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
   ENDIF()

   SET(MINOR_VERSION 1)
   math(EXPR VERSION-BASE ${GIT_VERSION}/255)
   math(EXPR VERSION-REMAINDER ${GIT_VERSION}%255)
   #message( STATUS "git build version: ${GIT_VERSION}" )
   #message( STATUS "version base: ${VERSION-BASE}" )
   #message( STATUS "version remainder: ${VERSION-REMAINDER}" )
   #SET(BUILD_NUMBER ${GIT_VERSION})
   SET(BUILD_NUMBER ${VERSION-BASE})
   SET(VERSION ${MAJOR_VERSION}.${MINOR_VERSION}.${BUILD_NUMBER}-${VERSION-REMAINDER})
ENDIF()
if(CXKJO_VERBOSE_MESSAGES)
    message(STATUS "Software Version: ${VERSION}")
endif()
#设置cmake常规目录
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
#设置cmake模块路径
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
#################################################################################
# Setup C/C++ compiler options
#设置c++ 选项
#################################################################################
option(DISABLE_CPP14 "Disable C++14 if available" OFF)

if (DISABLE_CPP14)
    add_definitions(-DCXKJO_DISABLE_CPP14)
else()
  # C++14 compiler flags
  include(CXX1x)
  check_for_cxx14_compiler(CXX14_COMPILER)

  # If a C++14 compiler is available, then set the appropriate flags
  if(CXX14_COMPILER)
    enable_cxx14()
  endif()
endif()

if (CMAKE_BUILD_TYPE STREQUAL "")
    set( CMAKE_BUILD_TYPE "RelWithDebInfo" )
endif()
# 添加cmake方法
include(CXKJOProjectMacros)
#设置项目编译开关
option(CXKJO_NTPClient "Enable NTP Client" OFF)
#设置编译选项 （runtime library）
if(MSVC)
    option(CXKJO_MT
      "Set to OFF|ON (default is OFF) to control build of CXKJO as /MT instead of /MD" OFF)

    option(CXKJO_ENABLE_MSVC_MP
      "Set to OFF|ON (default is OFF) to control parallel build of CXKJO with MSVC" OFF)
endif()
#添加项目
set(CXKJO_COMPONENTS "")
if (CXKJO_NTPClient)
    add_subdirectory(NTPClient)
    list(APPEND CXKJO_COMPONENTS "NTP Client")
endif ()

#############################################################
# Uninstall stuff see: http://www.vtk.org/Wiki/CMake_FAQ
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")

#############################################################

include(InstallRequiredSystemLibraries)

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "CXKJO Libraries")
set(CPACK_PACKAGE_VENDOR "Applied Informatics Software Engineering GmbH")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "/usr/local")

include(CPack)
#############################################################
# cmake config files

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${VERSION}
    COMPATIBILITY AnyNewerVersion
)

# Set config script install location in a location that find_package() will
# look for, which is different on MS Windows than for UNIX
# Note: also set in CXKJO_GENERATE_PACKAGE macro in cmake/CXKJoMacros.cmake
if (WIN32)
  set(CXKJoConfigPackageLocation "cmake")
else()
  set(CXKJoConfigPackageLocation "lib/cmake/${PROJECT_NAME}")
endif()

configure_file(cmake/${PROJECT_NAME}Config.cmake.in "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}Config.cmake" @ONLY)
install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}Config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION
        "${CXKJoConfigPackageLocation}"
    COMPONENT
        Devel
)

# in tree build settings
#configure_file(PocoBuildTreeSettings.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/PocoBuildTreeSettings.cmake @ONLY)

# Install pkg-config files
install(FILES ${CXKJO_PKG_CONFIG_FILES}
        DESTINATION lib${LIB_SUFFIX}/pkgconfig)

if(CXKJO_VERBOSE_MESSAGES)
        message(STATUS "")
        message(STATUS "CMake ${CMAKE_VERSION} successfully configured ${PROJECT_NAME} using ${CMAKE_GENERATOR} generator")
        message(STATUS "Installation target path: ${CMAKE_INSTALL_PREFIX}")
    
        message(STATUS "")
        message(STATUS "Generated with config types: ${CMAKE_CONFIGURATION_TYPES}")
        message(STATUS "Setting Poco build type - ${CMAKE_BUILD_TYPE}")
        message(STATUS "")
    
        message(STATUS "C_FLAGS:  =${CMAKE_C_FLAGS}")
        message(STATUS "CMAKE_C_FLAGS_DEBUG:=${CMAKE_C_FLAGS_DEBUG}")
        message(STATUS "CMAKE_C_FLAGS_RELEASE:=${CMAKE_C_FLAGS_RELEASE}")
        message(STATUS "CMAKE_C_FLAGS_MINSIZEREL:=${CMAKE_C_FLAGS_MINSIZEREL}")
        message(STATUS "CMAKE_C_FLAGS_RELWITHDEBINFO:=${CMAKE_C_FLAGS_RELWITHDEBINFO}")
        message(STATUS "")
        message(STATUS "")
        message(STATUS "CXX_FLAGS:=${CMAKE_CXX_FLAGS}")
        message(STATUS "CMAKE_CXX_FLAGS_DEBUG:=${CMAKE_CXX_FLAGS_DEBUG}")
        message(STATUS "CMAKE_CXX_FLAGS_RELEASE:=${CMAKE_CXX_FLAGS_RELEASE}")
        message(STATUS "CMAKE_CXX_FLAGS_MINSIZEREL:=${CMAKE_CXX_FLAGS_MINSIZEREL}")
        message(STATUS "CMAKE_CXX_FLAGS_RELWITHDEBINFO:=${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
    
        foreach(component ${CXKJO_COMPONENTS})
            message(STATUS "Building: ${component}")
        endforeach()
    endif()
