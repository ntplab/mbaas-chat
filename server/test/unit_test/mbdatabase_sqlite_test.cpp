#include "gtest/gtest.h"
#include "../../../include/mb_def.h"
#include "../../../include/mb_server.h"
#include "../../../include/mb_database.h"
#include "../../databases/plugins/mb_sqlite3.h"

using namespace mbserver;
using namespace mbdatabase;

TEST(db_message, new_message){
    const char* testdb = "./test.db";
    ULONGLONG fsz = 0;
    int lastid = 0;
    unlink(testdb);
    {
        mbdatabase::MbDatabaseSqlite ss(testdb);
        EXPECT_EQ(mbutil::is_exists(testdb, &fsz),RET_OK);

        EXPECT_EQ(ss.create_message(1,1,"msg1",&lastid),true);
        EXPECT_EQ(lastid,1);

        EXPECT_EQ(ss.create_message(1,1,"msg2",&lastid),true);
        EXPECT_EQ(lastid,2);

        EXPECT_EQ(ss.remove_message(1,1,1,&lastid),true);
    }
    unlink(testdb);
    EXPECT_EQ(mbutil::is_exists(testdb, &fsz),RET_NG);
    {
        mbdatabase::MbDatabaseSqlite ss(testdb);
        EXPECT_EQ(mbutil::is_exists(testdb, &fsz),RET_OK);
    }
}
TEST(db_user, create_user){
    const char* testdb = "./test.db";
    const char* usernm = "test-user";
    const char* groupnm = "test-group";
    int lastid = 0;
    unlink(testdb);
    //
    mbdatabase::MbDatabaseSqlite ss(testdb);
    EXPECT_EQ(ss.create_user(1,123456,usernm,&lastid),true);
    EXPECT_EQ(lastid,1);

    EXPECT_EQ(ss.create_group(groupnm,"hogeimg",&lastid),true);
    EXPECT_EQ(lastid,1);

    auto r = ss.find_user(1,1);
    EXPECT_EQ(r.empty(),false);
    EXPECT_EQ(r.size(),1);
    if (r.size()==1){
        EXPECT_EQ(r[0].getS("uname"),usernm);
        EXPECT_EQ(r[0].getS("gname"),groupnm);
    }
}

TEST(db_message, find_message){
    const char* testdb = "./test.db";
    const char* usernm = "test-user";
    const char* usernm2 = "test-user2";
    const char* groupnm = "test-group";
    const char* msg = "msg-g1-u2";
    const int utoken = 1234567;
    const char* img = "hoge.png";
    int lastid = 0;
    unlink(testdb);
    //
    mbdatabase::MbDatabaseSqlite ss(testdb);
    EXPECT_EQ(ss.create_user(1,utoken,usernm,&lastid),true);
    EXPECT_EQ(lastid,1);
    EXPECT_EQ(ss.create_user(2,utoken,usernm2,&lastid),true);
    EXPECT_EQ(lastid,2);

    EXPECT_EQ(ss.create_group(groupnm,img,&lastid),true);
    EXPECT_EQ(lastid,1);

    auto rg = ss.find_group(1);
    EXPECT_EQ(rg.empty(),false);
    EXPECT_EQ(rg.size(),1);
    if (rg.size()==1){
        EXPECT_EQ(rg[0].getS("gname"),groupnm);
    }
    EXPECT_EQ(ss.create_message(1,1,msg,&lastid),true);
    EXPECT_EQ(lastid,1);

    auto r = ss.find_message(1,0);
    EXPECT_EQ(r.empty(),false);
    EXPECT_EQ(r.size(),1);
    if (r.size()==1){
        EXPECT_EQ(r[0].getS("uname"),usernm);
        EXPECT_EQ(r[0].getS("gname"),groupnm);
        EXPECT_EQ(r[0].getS("msg"),msg);
    }
    auto r2 = ss.find_message(1,1);
    EXPECT_EQ(r2.empty(),true);

    auto r3 = ss.find_message(2,0);
    EXPECT_EQ(r2.empty(),true);

    EXPECT_EQ(ss.remove_group(1,&lastid),true);
    auto r4 = ss.find_message(1,0);
    EXPECT_EQ(r4.empty(),true);
}