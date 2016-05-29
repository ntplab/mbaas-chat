#include "../../include/mb_def.h"
#include "../../include/mb_server.h"
#include "../../include/mb_database.h"

int mbserver::new_group(void* req, char** out, size_t* outlen, MB_PLACEHOLDER placeholder, std::string body, size_t bodylen){
    auto app = ref_context(req);
    crow::json::wvalue jsn;
    int lastid,lastuid,lastmid;
    char bf[128] = {0};

    auto rjsn = crow::json::load(body);
    if (!rjsn){ return(500); }
    if (!rjsn.has("name") || !rjsn["name"].s().s_){ return(403); }
    if (!rjsn.has("uname") || !rjsn["uname"].s().s_){ return(403); }
    if (!rjsn.has("image") || !rjsn["image"].s().s_){ return(403); }
    if (!rjsn.has("uimage") || !rjsn["uimage"].s().s_){ return(403); }
    if (!rjsn.has("creator") || !rjsn["creator"].i()){ return(403); }
    //
    auto db = mbdatabase::MbDatabaseInterface::getInstance(app);
    if (db == NULL){
        LOGERR("failed.MbDatabaseInterface::getInstance")
        return(500);
    }
    if (!db->create_group(rjsn["name"].s().s_,rjsn["image"].s().s_, &lastid)){
        return(401);
    }
    // グループ生成したユーザを自動的にcreatorとして登録する
    if (!db->create_user(lastid, rjsn["creator"].i(), rjsn["uname"].s().s_,rjsn["uimage"].s().s_, &lastuid)){
        return(401);
    }
    snprintf(bf,sizeof(bf)-1,"<#$00$#>group created(creator : %s)", rjsn["uname"].s().s_);
    if (!db->create_message(lastid, lastuid, bf, &lastmid)){
        return(401);
    }
    jsn["stat"] = MBRESULT_OK;
    jsn["lastid"] = lastid;
    MB_MALLOC_RESULT(out, outlen, crow::json::dump(jsn).c_str());

    UNUSED_PARAMETER(placeholder);
    UNUSED_PARAMETER(bodylen);
    return(200);
}