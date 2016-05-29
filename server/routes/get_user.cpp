#include "../../include/mb_def.h"
#include "../../include/mb_server.h"
#include "../../include/mb_database.h"

int mbserver::get_user(void* req, char** out, size_t* outlen, MB_PLACEHOLDER placeholder, std::string body, size_t bodylen){
    auto gid = placeholder.getN("#id");
    auto uid = placeholder.getN("#nid");
    auto app = ref_context(req);
    int  idx = 0;

    crow::json::wvalue jsn;
    std::vector<crow::json::wvalue> arr;
    mbdatabase::FINDREC rec;
    //
    auto db = mbdatabase::MbDatabaseInterface::getInstance(app);
    if (db == NULL){
        jsn["stat"] = MBRESULT_INTERNAL;
        goto RETURN_0;
    }
    rec = db->find_user(gid, uid);
    if (rec.empty()){
        jsn["stat"] = MBRESULT_NOTFOUND;
    }else{
        arr.clear();
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
    }
RETURN_0:
    MB_MALLOC_RESULT(out, outlen, crow::json::dump(jsn).c_str());
    UNUSED_PARAMETER(body);
    UNUSED_PARAMETER(bodylen);
    return(200);
}