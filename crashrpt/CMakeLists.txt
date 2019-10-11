# Sources
file(GLOB SRCS_G "src/*.cpp")
CXKJ_SOURCES_AUTO( SRCS ${SRCS_G})

# Headers
file(GLOB_RECURSE HDRS_G "include/*.*" )
CXKJ_HEADERS_AUTO( SRCS ${HDRS_G})
file(GLOB_RECURSE HDRS_G "src/*.h" )
CXKJ_HEADERS_AUTO( SRCS ${HDRS_G})

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include/CXKJ/Crashrpt)
include_directories($ENV{HOME}/include/CXKJ/g3log)

add_executable(Crashrpt ${SRCS})
#target_link_libraries(Cryptopp PUBLIC X::JSON)
set_target_properties(Crashrpt
    PROPERTIES
    VERSION ${SHARED_LIBRARY_VERSION} SOVERSION ${SHARED_LIBRARY_VERSION}
	OUTPUT_NAME Crashrpt
    )

CXKJ_INSTALL(Crashrpt)