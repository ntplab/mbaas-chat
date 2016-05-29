#include "../../include/mb_def.h"
#include "../../include/mb_server.h"
#include "../../include/mb_database.h"

int mbserver::del_user(void* req, char** out, size_t* outlen, MB_PLACEHOLDER placeholder, std::string body, size_t bodylen){
    auto gid = placeholder.getN("#id");
    auto uid = placeholder.getN("#nid");
    auto app = ref_context(req);
    crow::json::wvalue jsn;
    int lastid;

    auto db = mbdatabase::MbDatabaseInterface::getInstance(app);
    if (db == NULL){
        return(500);
    }
    if (!db->remove_user(gid, uid, &lastid)){
        return(401);
    }
    jsn["stat"] = MBRESULT_OK;
    jsn["lastid"] = lastid;
    MB_MALLOC_RESULT(out, outlen, crow::json::dump(jsn).c_str());

    UNUSED_PARAMETER(body);
    UNUSED_PARAMETER(bodylen);
    return(200);
}