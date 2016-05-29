#include "../../include/mb_def.h"
#include "../../include/mb_server.h"
#include "../../include/mb_database.h"

int mbserver::new_message(void* req, char** out, size_t* outlen, MB_PLACEHOLDER placeholder, std::string body, size_t bodylen){
    auto gid = placeholder.getN("#gid");
    auto uid = placeholder.getN("#id");
    auto app = ref_context(req);
    crow::json::wvalue jsn;
    crow::json::wvalue jsnbcast;
    int lastid;

    auto rjsn = crow::json::load(body);
    if (!rjsn){ return(500); }
    if (!rjsn.has("message") || !rjsn["message"].s().s_){ return(403); }
    //
    auto db = mbdatabase::MbDatabaseInterface::getInstance(app);
    if (db == NULL){
        return(500);
    }
    if (!db->create_message(gid, uid, rjsn["message"].s().s_, &lastid)){
        return(401);
    }
    jsn["stat"] = MBRESULT_OK;
    jsn["lastid"] = lastid;
    MB_MALLOC_RESULT(out, outlen, crow::json::dump(jsn).c_str());

    //
    jsnbcast["stat"] = MBRESULT_NOTIFY;
    jsnbcast["lastid"] = lastid;
    jsnbcast["gid"] = gid;
    mbserver::broadcast_notify(crow::json::dump(jsnbcast).c_str(), gid);

    UNUSED_PARAMETER(bodylen);
    return(200);
}