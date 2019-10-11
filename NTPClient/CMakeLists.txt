set(PROJECT_EXENAME "NTPClient")

# Headers
file(GLOB_RECURSE HDRS_G "src/*.h" )
CXKJ_HEADERS_AUTO( SRCS ${HDRS_G})

# Sources
file(GLOB SRCS_G "src/*.cpp")
CXKJ_SOURCES_AUTO( SRCS ${SRCS_G})

include_directories($ENV{USERSDK}/include/CXKJ)
link_directories($ENV{USERSDK}/lib)

add_executable(${PROJECT_EXENAME} ${SRCS} )
set_target_properties(NTPClient
    PROPERTIES
    OUTPUT_NAME ${PROJECT_EXENAME}
    )
	
target_link_libraries(${PROJECT_EXENAME} debug CXKJG3Logd)
target_link_libraries(${PROJECT_EXENAME} optimized CXKJG3Log)
		
install(
	TARGETS "${PROJECT_EXENAME}" EXPORT "${PROJECT_EXENAME}Targets"
    LIBRARY DESTINATION lib${LIB_SUFFIX}
    ARCHIVE DESTINATION lib${LIB_SUFFIX}
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
    )
if (POCO_ENABLE_SAMPLES)
#    add_subdirectory(samples)
endif ()
