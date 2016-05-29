#include "gtest/gtest.h"
#include "../../../include/mb_def.h"
#include "../../../include/mb_server.h"
#include "../../../include/mb_database.h"

using namespace mbserver;
using namespace mbdatabase;


namespace {
    class MbTest3 : public ::testing::Test {
    protected:
        MbTest3() {
            unlink(testdb);
            mb.dbcon = strdup(testdb);
            ctx.mb = &mb;
            req.middleware_context = &ctx;
        }
        virtual ~MbTest3() {
            free(mb.dbcon);
            MbDatabaseInterface::releaseInstance();
        }
        const char *testdb = "./test.db";
        mbutil::mb_t mb;
        MbMiddleware::context ctx;
        crow::request req;
    };
    TEST_F(MbTest3, user_rm_test) {
        char *out = NULL;
        size_t outlen = 0;
        std::string body("{\"name\":\"oreuser33\"}");

        MB_PLACEHOLDER ph;
        ph.set("#id", 1);
        ph.set("#nid", 123456);
        //
        EXPECT_EQ(new_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);

        auto x0 = crow::json::load(std::string(out,outlen));
        if (!x0) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x0["lastid"].i(), 1);
        free(out);
        //
        body = "{\"name\":\"ore-user34\"}";
        ph.clear();
        ph.set("#id", 2);
        ph.set("#nid", 123456);
        EXPECT_EQ(new_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x1 = crow::json::load(std::string(out, outlen));
        if (!x1) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x1["lastid"].i(),2);
        free(out);

        //
        body = "{\"name\":\"ore-group33\",\"image\":\"ore-group33.png\", \"uname\":\"oreuname33\", \"creator\":123456 }";
        ph.clear();
        EXPECT_EQ(new_group(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x2 = crow::json::load(std::string(out, outlen));
        if (!x2) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x2["lastid"].i(),1);
        free(out);
        //
        body = "{\"name\":\"ore-group34\",\"image\":\"ore-group34.png\", \"uname\":\"oreuname34\", \"creator\":123456 }";
        ph.clear();
        EXPECT_EQ(new_group(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x3 = crow::json::load(std::string(out, outlen));
        if (!x3) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x3["lastid"].i(),2);
        free(out);
        //
        body = "";
        ph.clear();
        ph.set("#gid", 1);
        EXPECT_EQ(get_group(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x4 = crow::json::load(std::string(out, outlen));
        if (!x4) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x4["stat"].i(),MBRESULT_OK);
        EXPECT_EQ(x4.count("users"),1);
        EXPECT_EQ(x4["users"][0]["uname"],"oreuser33");
        EXPECT_EQ(x4["users"][0]["gname"],"ore-group33");
        free(out);
        //
        body = "";
        ph.clear();
        ph.set("#gid", 2);
        EXPECT_EQ(get_group(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x5 = crow::json::load(std::string(out, outlen));
        if (!x5) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x5["stat"].i(),MBRESULT_OK);
        EXPECT_EQ(x5.count("users"),1);
        EXPECT_EQ(x5["users"][0]["uname"],"ore-user34");
        EXPECT_EQ(x5["users"][0]["gname"],"ore-group34");
        free(out);
        //
        body = "";
        ph.clear();
        ph.set("#gid", 2);
        ph.set("#uid", 2);
        EXPECT_EQ(del_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x6 = crow::json::load(std::string(out, outlen));
        if (!x6) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x6["stat"].i(),MBRESULT_OK);
        free(out);
        //
        body = "";
        ph.clear();
        ph.set("#gid", 1);
        EXPECT_EQ(del_group(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x7 = crow::json::load(std::string(out, outlen));
        if (!x7) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x7["stat"].i(),MBRESULT_OK);
        free(out);
        //
        body = "";
        ph.clear();
        ph.set("#gid", 1);
        EXPECT_EQ(get_group(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x8 = crow::json::load(std::string(out, outlen));
        if (!x8) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x8["stat"].i(),MBRESULT_NOTFOUND);
        free(out);

        //
        body = "";
        ph.clear();
        ph.set("#gid", 2);
        EXPECT_EQ(get_group(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_NE(out, (char *) NULL);
        EXPECT_NE(outlen, 0);
        auto x9 = crow::json::load(std::string(out, outlen));
        if (!x9) {
            GTEST_FATAL_FAILURE_("json format.");
        }
        EXPECT_EQ(x9["stat"].i(),MBRESULT_OK);
        EXPECT_EQ(x9.count("users"),1);
        free(out);

    }
}
