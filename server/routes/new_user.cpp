#include "../../include/mb_def.h"
#include "../../include/mb_server.h"
#include "../../include/mb_database.h"

int mbserver::new_user(void* req, char** out, size_t* outlen, MB_PLACEHOLDER placeholder, std::string body, size_t bodylen){
    auto gid = placeholder.getN("#id");
    auto token = placeholder.getN("#nid");
    auto app = ref_context(req);
    crow::json::wvalue jsn;
    int lastid;

    auto rjsn = crow::json::load(body);
    if (!rjsn){ return(500); }
    if (!gid || !token ||
            !rjsn.has("name") || !rjsn["name"].s().s_ ||
            !rjsn.has("image") || !rjsn["image"].s().s_){ return(403); }
    //
    auto db = mbdatabase::MbDatabaseInterface::getInstance(app);
    if (db == NULL){
        return(500);
    }
    if (!db->create_user(gid, token, rjsn["name"].s().s_, rjsn["image"].s().s_, &lastid)){
        return(401);
    }
    jsn["stat"] = MBRESULT_OK;
    jsn["lastid"] = lastid;
    MB_MALLOC_RESULT(out, outlen, crow::json::dump(jsn).c_str());

    UNUSED_PARAMETER(bodylen);
    return(200);
}