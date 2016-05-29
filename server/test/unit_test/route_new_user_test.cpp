#include "gtest/gtest.h"
#include "../../../include/mb_def.h"
#include "../../../include/mb_server.h"
#include "../../../include/mb_database.h"

using namespace mbserver;
using namespace mbdatabase;


namespace {
    class MbTest : public ::testing::Test {
    protected:
        MbTest() {
            unlink(testdb);
            mb.dbcon = strdup(testdb);
            ctx.mb = &mb;
            req.middleware_context = &ctx;
        }
        virtual ~MbTest() {
            free(mb.dbcon);
            MbDatabaseInterface::releaseInstance();
        }
        const char *testdb = "./test.db";
        mbutil::mb_t mb;
        MbMiddleware::context ctx;
        crow::request req;
    };
    TEST_F(MbTest, new_usertest0) {
        const int token = 1234566;
        char *out = NULL;
        size_t outlen = 0;
        std::string body("{\"name\":\"oreuser\"}");

        MB_PLACEHOLDER ph;
        ph.set("#id", 1);
        ph.set("#nid",token);
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
    }
    TEST_F(MbTest, new_usertest1) {
        char *out = NULL;
        size_t outlen = 0;
        std::string body("{\"dame-name\":\"oreuser\"}");

        MB_PLACEHOLDER ph;
        ph.set("#id", 1);
        //
        EXPECT_NE(new_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_EQ(out, (char *) NULL);
        EXPECT_EQ(outlen, 0);
    }
    TEST_F(MbTest, new_usertest2) {
        char *out = NULL;
        size_t outlen = 0;
        std::string body("{\"name\":\"oreuser\"}");

        MB_PLACEHOLDER ph;
        ph.set("#dame-gid", 1);
        //
        EXPECT_NE(new_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_EQ(out, (char *) NULL);
        EXPECT_EQ(outlen, 0);
    }
    TEST_F(MbTest, new_usertest3) {
        char *out = NULL;
        size_t outlen = 0;
        std::string body("{{\"name\":\"dame-json format\"}");

        MB_PLACEHOLDER ph;
        ph.set("#id", 1);
        //
        EXPECT_NE(new_user(&req, &out, &outlen, ph, body, body.length()), 200);
        EXPECT_EQ(out, (char *) NULL);
        EXPECT_EQ(outlen, 0);
    }
}
