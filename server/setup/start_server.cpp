#include "../../include/mb_def.h"
#include "../../include/mb_server.h"
#include "../../crow/include/crow.h"
#include "../../crow/include/mustache.h"


// サーバ実装
int mbserver::start_server(mbutil::mb_ptr pmb){
    return (pthread_create(&pmb->threadid, NULL,
                           [](void* arg)->void*{
                               mbutil::mb_ptr pmb = (mbutil::mb_ptr)arg;

                               crow::App<mbserver::MbMiddleware> app;
                               crow::mustache::set_base(".");
                               app.get_middleware<mbserver::MbMiddleware>().set_mb(pmb);

                               // ログレベルの設定
                               crow::logger::setLogLevel(crow::LogLevel(pmb->loglevel));
                               // ルーティングコンパイル
                               compile_routes(app);
                               // アプリケーション開始
                               app.port(pmb->port).concurrency(pmb->thread).run();
                               LOGINFO("exit server thread.");
                               return(NULL);
                           }, pmb));
}
// ルーティング
void mbserver::compile_routes(crow::App<mbserver::MbMiddleware>& app){
    CROW_ROUTE(app, "/v1/mb/user/<int>/<int>").methods("GET"_method, "DELETE"_method, "POST"_method, "PUT"_method)([=](const crow::request& req, int id, int nid){
        MB_ROUTE_START_2("#id", id, "#nid", nid);
            if (req.method == crow::HTTPMethod::GET){
                MB_ROUTE_JSON(mbserver::get_user);
            }else if (req.method == crow::HTTPMethod::DELETE){
                MB_ROUTE_JSON(mbserver::del_user);
            }else if (req.method == crow::HTTPMethod::POST) {
                MB_ROUTE_JSON(mbserver::new_user);
            }else if (req.method == crow::HTTPMethod::PUT){
                MB_ROUTE_JSON(mbserver::upd_user);
            }
            MB_ROUTE_OK();
        MB_ROUTE_END()
    });
    CROW_ROUTE(app, "/v1/mb/group").methods("POST"_method, "GET"_method)([=](const crow::request& req){
        MB_ROUTE_START_0();
            if (req.method == crow::HTTPMethod::GET) {
                MB_ROUTE_JSON(mbserver::get_group);
            }else{
                MB_ROUTE_JSON(mbserver::new_group);
            }
            MB_ROUTE_OK();
        MB_ROUTE_END()
    });
    CROW_ROUTE(app, "/v1/mb/group/<int>").methods("DELETE"_method, "GET"_method)([=](const crow::request& req, int gid){
        MB_ROUTE_START_1("#gid", gid);
            if (req.method == crow::HTTPMethod::GET){
                MB_ROUTE_JSON(mbserver::get_group);
            }else{
                MB_ROUTE_JSON(mbserver::del_group);
            }
            MB_ROUTE_OK();
        MB_ROUTE_END()
    });
    CROW_ROUTE(app, "/v1/mb/chat/<int>/<int>").methods("POST"_method, "GET"_method)([=](const crow::request& req, int gid, int id){
        MB_ROUTE_START_2("#gid", gid, "#id", id);
            if (req.method == crow::HTTPMethod::GET){
                MB_ROUTE_JSON(mbserver::get_message);
            }else{
                MB_ROUTE_JSON(mbserver::new_message);
            }
            MB_ROUTE_OK();
        MB_ROUTE_END()
    });
    CROW_ROUTE(app, "/v1/mb/chat/<int>/<int>/<int>").methods("DELETE"_method)([=](const crow::request& req,int gid, int uid, int mid){
        MB_ROUTE_START_3("#gid", gid, "#uid", uid, "#mid", mid); MB_ROUTE_JSON(mbserver::del_message); MB_ROUTE_OK(); MB_ROUTE_END()
    });
    CROW_ROUTE(app, "/v1/mb/info/<int>/<int>/<int>").methods("GET"_method)([=](const crow::request& req,int gid, int uid, int mid){
        MB_ROUTE_START_3("#gid", gid, "#uid", uid, "#mid", mid); MB_ROUTE_JSON(mbserver::get_info); MB_ROUTE_OK(); MB_ROUTE_END()
    });
    CROW_ROUTE(app, "/v1/mb/notify/<int>").methods("GET"_method)([=](const crow::request& req,crow::response& res,int topic){
        mbserver::boradcast_append(&res, topic);
    });
    CROW_ROUTE(app, "/v1/mb/notify").methods("GET"_method)([=](const crow::request& req,crow::response& res){
        mbserver::boradcast_append(&res, 0);
    });
}
