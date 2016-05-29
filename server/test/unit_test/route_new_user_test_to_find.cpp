#include "gtest/gtest.h"
#include "../../../include/mb_def.h"
#include "../../../include/mb_server.h"
#include "../../../include/mb_database.h"

using namespace mbserver;
using namespace mbdatabase;


namespace {
    class MbTest2 : public ::testing::Test {
    protected:
        MbTest2() {
                unlink(testdb);
                mb.dbcon = strdup(testdb);
                ctx.mb = &mb;
                req.middleware_context = &ctx;
        }
        virtual ~MbTest2() {
                free(mb.dbcon);
            MbDatabaseInterface::releaseInstance();
        }
        const char *testdb = "./test.db";
        mbutil::mb_t mb;
        MbMiddleware::context ctx;
        crow::request req;
    };
    TEST_F(MbTest2, new_user_to_find_test0) {
        char *out = NULL;
        size_t outlen = 0;
        std::string body("{\"name\":\"oreuser\"}");
        const int token = 12345;

        MB_PLACEHOLDER ph;
        ph.set("#id", 1);
        ph.set("#nid", token);
        //
        EXPECT_EQ(new_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);

        auto x = crow::json::load(std::string(out,outlen));
        if (!x) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x["lastid"].i(), 1);
        free(out);
        //
        body = "{\"name\":\"ore-group\", \"image\":\"ore-group-imgae.png\", \"uname\":\"ore-group-uname\", \"creator\":12345}";
        ph.clear();
        EXPECT_EQ(new_group(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x2 = crow::json::load(std::string(out, outlen));
        if (!x2) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x2["lastid"].i(),1);

        //
        body = "";
        ph.clear();
        ph.set("#id", 1);
        ph.set("#nid", 1);
        EXPECT_EQ(get_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x3 = crow::json::load(std::string(out, outlen));
        if (!x3) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x3["stat"].i(),MBRESULT_OK);
        EXPECT_EQ(x3.count("users"),1);
        EXPECT_EQ(x3["users"][0]["uname"],"oreuser");
        EXPECT_EQ(x3["users"][0]["gname"],"ore-group");

        //
        body = "";
        ph.clear();
        ph.set("#id", 2);
        ph.set("#nid", 1);
        EXPECT_EQ(get_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x4 = crow::json::load(std::string(out, outlen));
        if (!x4) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x4["stat"].i(),MBRESULT_NOTFOUND);
    }
    TEST_F(MbTest2, new_user_to_find_test1) {
        char *out = NULL;
        size_t outlen = 0;
        std::string body("{\"name\":\"oreuser22\"}");
        const int token = 123123;

        MB_PLACEHOLDER ph;
        ph.set("#id", 1);
        ph.set("#nid", token);
        //
        EXPECT_EQ(new_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);

        auto x = crow::json::load(std::string(out, outlen));
        if (!x) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x["lastid"].i(), 1);
        free(out);
        //
        body = "{\"name\":\"ore-oreuser23\"}";
        ph.clear();
        ph.set("#id", 1);
        ph.set("#nid", token+1);
        EXPECT_EQ(new_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x2 = crow::json::load(std::string(out, outlen));
        if (!x2) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x2["lastid"].i(), 2);
        //
        body = "{\"name\":\"ore-group22\", \"image\":\"ore-group-imgae22.png\", \"uname\":\"ore-group-uname22\", \"creator\":123124 }";
        ph.clear();
        EXPECT_EQ(new_group(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        LOGINFO("%s", std::string(out, outlen).c_str());
        auto x21 = crow::json::load(std::string(out, outlen));
        if (!x21) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x21["lastid"].i(), 1);

        //
        body = "";
        ph.clear();
        ph.set("#gid", 1);
        EXPECT_EQ(get_group(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        LOGINFO("%s", std::string(out, outlen).c_str());
        auto x3 = crow::json::load(std::string(out, outlen));
        if (!x3) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x3["stat"].i(), MBRESULT_OK);
        EXPECT_EQ(x3["users"].size(),2);
        EXPECT_EQ(x3["users"][0]["uname"], "oreuser22");
        EXPECT_EQ(x3["users"][0]["gname"], "ore-group22");
        EXPECT_EQ(x3["users"][1]["uname"], "ore-oreuser23");
        EXPECT_EQ(x3["users"][1]["gname"], "ore-group22");
    }
}
