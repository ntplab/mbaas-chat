#include "../../include/mb_def.h"
#include "../../include/mb_server.h"
#include "../../include/mb_database.h"

int mbserver::get_message(void* req, char** out, size_t* outlen, MB_PLACEHOLDER placeholder, std::string body, size_t bodylen){
    auto gid = placeholder.getN("#gid");
    auto mid = placeholder.getN("#id");
    auto app = ref_context(req);
    int  idx = 0;
    crow::json::wvalue jsn;
    std::vector<crow::json::wvalue> arr;
    mbdatabase::FINDREC rec;
    // 最終取得済みメッセージid/グループidが引数
    // last-mid以降の掲示板メッセージを返却する

    // データベースインタフェイス（sqlite3:ローカル実装）
    // oracle/mysql等のDBインタフェイスを同様のDDL・SQLで切り替える
    auto db = mbdatabase::MbDatabaseInterface::getInstance(app);
    if (db == NULL){
        jsn["stat"] = MBRESULT_INTERNAL;
        goto RETURN_0;
    }
    rec = db->find_message(gid, mid);
    if (rec.empty()){
        jsn["stat"] = MBRESULT_NOTFOUND;
    }else{
        arr.clear();
        for(auto& r :rec){
            for(auto& c : r.getKeys()){
                if (r.getType(c.c_str())==mbutil::MbPlaceHolder::TypeInt){
                    jsn["messages"][idx][c] = r.getN(c.c_str());
                }else{
                    jsn["messages"][idx][c] = r.getS(c.c_str());
                }
            }
            idx++;
        }
        jsn["stat"] = MBRESULT_OK;
    }
RETURN_0:
    MB_MALLOC_RESULT(out, outlen, crow::json::dump(jsn).c_str());
    return(200);
}