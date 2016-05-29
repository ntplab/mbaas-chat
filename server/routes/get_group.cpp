#include "../../include/mb_def.h"
#include "../../include/mb_server.h"
#include "../../include/mb_database.h"

int mbserver::get_group(void* req, char** out, size_t* outlen, MB_PLACEHOLDER placeholder, std::string body, size_t bodylen){
    auto gid = placeholder.getN("#gid");
    auto app = ref_context(req);
    int  idx = 0;

    crow::json::wvalue jsn;
    std::vector<crow::json::wvalue> arr;
    mbdatabase::FINDREC rec;
    //
    auto db = mbdatabase::MbDatabaseInterface::getInstance(app);
    if (db == NULL){
        jsn["stat"] = MBRESULT_INTERNAL;
        LOGERR("failed.MbDatabaseInterface::getInstance");
        goto RETURN_0;
    }
    if (gid){
        rec = db->find_group(gid);
    }else{
        rec = db->find_group(0);
    }
    if (rec.empty()){
        jsn["stat"] = MBRESULT_NOTFOUND;
    }else{
        arr.clear();
        for(auto& r :rec){
            for(auto& c : r.getKeys()){
                if (r.getType(c.c_str())==mbutil::MbPlaceHolder::TypeInt){
                    jsn[gid?"users":"groups"][idx][c] = r.getN(c.c_str());
                }else{
                    jsn[gid?"users":"groups"][idx][c] = r.getS(c.c_str());
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