#include "../../include/mb_def.h"
#include "../../include/mb_server.h"
#include "../../crow/include/crow.h"
#include "../../crow/include/mustache.h"

static std::vector<std::pair<mbserver::BroadCaster*, decltype(std::chrono::steady_clock::now())>> broadcast_;

// イベント通知接続の保持
int mbserver::boradcast_append(void* pres,int topic){
    crow::response& res = *(crow::response*)pres;
    std::vector<std::pair<mbserver::BroadCaster*, decltype(std::chrono::steady_clock::now())>> filtered;
    //
    for(auto p : broadcast_) {
        auto* br = p.first;
        crow::response* pres = (crow::response*)br->handle_;
        if (pres->is_alive() && std::chrono::steady_clock::now() - p.second < std::chrono::seconds(30)){
            filtered.push_back(p);
        } else {
            pres->end();
        }
    }
    broadcast_.swap(filtered);
    broadcast_.push_back({BroadCaster::create(pres, topic), std::chrono::steady_clock::now()});
    CROW_LOG_DEBUG << &res << " stored " << broadcast_.size();
    return(RET_OK);
}
// イベントをブロードキャスト
int mbserver::broadcast_notify(const char* msg, int topic){
    for(auto p:broadcast_) {
        auto* br = p.first;
        crow::response* pres = (crow::response*)br->handle_;
        CROW_LOG_DEBUG << pres << " replied: " << msg << " topic: " << topic << " / " << br->topic_;
        // トピック全体監視
        if (br->topic_ == 0){
            pres->end(msg);
        // 指定トピック監視
        }else if (br->topic_ == topic){
            pres->end(msg);
        }
        BroadCaster::broadcaster_free(br);
    }
    broadcast_.clear();

    return(RET_OK);
}
