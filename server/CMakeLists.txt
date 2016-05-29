cmake_minimum_required(VERSION 3.5)
project(server)

# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++1y")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -std=c++1y -g")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -std=c++1y -O3")
find_package( Boost 1.52 COMPONENTS date_time filesystem system thread REQUIRED )

include_directories( ${Boost_INCLUDE_DIR} )

if (SQLITE3_LIBRARIES AND SQLITE3_INCLUDE_DIRS)
    # in cache already
    set(SQLITE3_FOUND TRUE)
else (SQLITE3_LIBRARIES AND SQLITE3_INCLUDE_DIRS)
    # use pkg-config to get the directories and then use these values
    # in the FIND_PATH() and FIND_LIBRARY() calls
    if (${CMAKE_MAJOR_VERSION} EQUAL 2 AND ${CMAKE_MINOR_VERSION} EQUAL 4)
        include(UsePkgConfig)
        pkgconfig(sqlite3 _SQLITE3_INCLUDEDIR _SQLITE3_LIBDIR _SQLITE3_LDFLAGS _SQLITE3_CFLAGS)
    else (${CMAKE_MAJOR_VERSION} EQUAL 2 AND ${CMAKE_MINOR_VERSION} EQUAL 4)
        find_package(PkgConfig)
        if (PKG_CONFIG_FOUND)
            pkg_check_modules(_SQLITE3 sqlite3)
        endif (PKG_CONFIG_FOUND)
    endif (${CMAKE_MAJOR_VERSION} EQUAL 2 AND ${CMAKE_MINOR_VERSION} EQUAL 4)
    find_path(SQLITE3_INCLUDE_DIR
            NAMES
            sqlite3.h
            PATHS
            ${_SQLITE3_INCLUDEDIR}
            /usr/include
            /usr/local/include
            /opt/local/include
            /sw/include
            )

    find_library(SQLITE3_LIBRARY
            NAMES
            sqlite3
            PATHS
            ${_SQLITE3_LIBDIR}
            /usr/lib
            /usr/local/lib
            /opt/local/lib
            /sw/lib
            )

    if (SQLITE3_LIBRARY)
        set(SQLITE3_FOUND TRUE)
    endif (SQLITE3_LIBRARY)

    set(SQLITE3_INCLUDE_DIRS
            ${SQLITE3_INCLUDE_DIR}
            )

    if (SQLITE3_FOUND)
        set(SQLITE3_LIBRARIES
                ${SQLITE3_LIBRARIES}
                ${SQLITE3_LIBRARY}
                )
    endif (SQLITE3_FOUND)

    if (SQLITE3_INCLUDE_DIRS AND SQLITE3_LIBRARIES)
        set(SQLITE3_FOUND TRUE)
    endif (SQLITE3_INCLUDE_DIRS AND SQLITE3_LIBRARIES)

    if (SQLITE3_FOUND)
        if (NOT Sqlite3_FIND_QUIETLY)
            message(STATUS "Found Sqlite3: ${SQLITE3_LIBRARIES}")
        endif (NOT Sqlite3_FIND_QUIETLY)
    else (SQLITE3_FOUND)
        if (Sqlite3_FIND_REQUIRED)
            message(FATAL_ERROR "Could not find Sqlite3")
        endif (Sqlite3_FIND_REQUIRED)
    endif (SQLITE3_FOUND)

    # show the SQLITE3_INCLUDE_DIRS and SQLITE3_LIBRARIES variables only in the advanced view
    mark_as_advanced(SQLITE3_INCLUDE_DIRS SQLITE3_LIBRARIES)

endif (SQLITE3_LIBRARIES AND SQLITE3_INCLUDE_DIRS)
FIND_PATH(SQLITE3_INCLUDE_DIR NAMES sqlite3.h)
FIND_LIBRARY(SQLITE3_LIBRARY NAMES sqlite3)

## main source's
set(SOURCE_FILES entry.cpp)
## setup
set(SOURCE_FILES ${SOURCE_FILES}
        setup/start_server.cpp
        setup/notify_server.cpp
        )

## routing
set(SOURCE_FILES ${SOURCE_FILES}
        routes/new_message.cpp
        routes/get_message.cpp
        routes/del_message.cpp
        routes/new_user.cpp
        routes/upd_user.cpp
        routes/get_user.cpp
        routes/del_user.cpp
        routes/new_group.cpp
        routes/get_group.cpp
        routes/del_group.cpp
        routes/get_info.cpp
        )
## database
set(SOURCE_FILES ${SOURCE_FILES}
        databases/mb_interface.cpp
        databases/plugins/mb_sqlite3.cpp
        databases/plugins/mb_sqlite3_message.cpp
        databases/plugins/mb_sqlite3_user.cpp
        databases/plugins/mb_sqlite3_group.cpp
        databases/plugins/mb_sqlite3_info.cpp
        )

message("SQLITE3_LIBRARIES:  ${SQLITE3_LIBRARIES}")

add_subdirectory(test)

add_executable(server ${SOURCE_FILES})
target_link_libraries(server boost_system ${SQLITE3_LIBRARIES})
