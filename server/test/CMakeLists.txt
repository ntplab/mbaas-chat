cmake_minimum_required(VERSION 3.3)

project(unit_test)

set(SOURCE_FILES
        ../databases/plugins/mb_sqlite3.cpp
        ../databases/plugins/mb_sqlite3_message.cpp
        ../databases/plugins/mb_sqlite3_user.cpp
        ../databases/plugins/mb_sqlite3_group.cpp
        ../databases/plugins/mb_sqlite3_info.cpp
        ../databases/mb_interface.cpp
        ../routes/new_user.cpp
        ../routes/new_group.cpp
        ../routes/get_user.cpp
        ../routes/get_group.cpp
        ../routes/del_group.cpp
        ../routes/del_user.cpp
        unit_test/mbdatabase_sqlite_test.cpp
        unit_test/route_new_user_test.cpp
        unit_test/route_new_user_test_to_find.cpp
        unit_test/route_user_rm_test.cpp
)
set(GTEST_ROOT $ENV{HOME}/gtest/googletest/googletest)
include_directories(${GTEST_ROOT}/include)
add_executable(unit_test ${SOURCE_FILES} )
target_link_libraries(unit_test
        pthread
        ${GTEST_ROOT}/build/libgtest.a
        ${GTEST_ROOT}/build/libgtest_main.a
        boost_system ${SQLITE3_LIBRARIES})
