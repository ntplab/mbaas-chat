#include "../../include/mb_def.h"
#include "../../include/mb_server.h"
#include "../../include/mb_database.h"

int mbserver::get_info(void* req, char** out, size_t* outlen, MB_PLACEHOLDER placeholder, std::string body, size_t bodylen){
    auto gid = placeholder.getN("#gid");
    auto uid = placeholder.getN("#uid");
    auto mid = placeholder.getN("#mid");
    auto app = ref_context(req);
    int  idx = 0,unread = 0;
    crow::json::wvalue jsn;
    mbdatabase::FINDREC rec;

    auto db = mbdatabase::MbDatabaseInterface::getInstance(app);
    if (db == NULL){
        jsn["stat"] = MBRESULT_INTERNAL;
        goto RETURN_0;
    }
    // 最終メッセージ取得
    rec = db->find_lastmessage(gid, uid, &unread);
    if (rec.empty()){
        jsn["gid"] = gid;
        jsn["gname"] = "";
        jsn["lastmsg"] = "";
        jsn["unreadcnt"] = unread;
    }else {
        jsn["gid"] = gid;
        jsn["gname"] = rec[0].getS("gname");
        jsn["lastmsg"] = rec[0].getS("msg");
        jsn["unreadcnt"] = unread;
    }
    // グループ内ユーザサマリ取得
    rec = db->find_summary(gid);
    for(auto& r :rec){
        for(auto& c : r.getKeys()){
            if (r.getType(c.c_str())==mbutil::MbPlaceHolder::TypeInt){
                jsn["users"][idx][c] = r.getN(c.c_str());
            }else{
                jsn["users"][idx][c] = r.getS(c.c_str());
            }
        }
        idx++;
    }
    jsn["stat"] = MBRESULT_OK;
RETURN_0:
    MB_MALLOC_RESULT(out, outlen, crow::json::dump(jsn).c_str());
    return(200);
}