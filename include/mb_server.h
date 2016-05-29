#ifndef SERVER_SERVER_H
#define SERVER_SERVER_H

#include "../include/mb_def.h"
#include "../crow/include/crow.h"

namespace mbserver {
    enum MbHeader {
        MbHeaderDc,
        MbHeaderJson,
        MbHeaderHtml,
        MbHeaderImagePng,
        MbHeaderImageJpg,
        MbHeaderMax
    };
    class MbMiddleware {
        mbutil::mb_ptr mb_;
    public:
        MbMiddleware() { }

        struct context {
            MbHeader type;
            mbutil::mb_ptr mb;
        };

        void set_mb(mbutil::mb_ptr mb) {
            mb_ = mb;
        }
        mbutil::mb_ptr ref_mb(){
            return(mb_);
        }
        void before_handle(crow::request &req, crow::response &res, context &ctx) {
            ctx.mb = mb_;
        }

        void after_handle(crow::request &req, crow::response &res, context &ctx) {
            if (ctx.type == MbHeaderJson) {
                res.add_header("Content-Type", "application/json; charset=utf-8");
            } else if (ctx.type == MbHeaderImagePng) {
                res.add_header("Content-Type", "image/png");
            } else if (ctx.type == MbHeaderImageJpg) {
                res.add_header("Content-Type", "image/jpeg");
            } else {
                res.add_header("Content-Type", "text/html; charset=utf-8");
            }
        }
    };
}
// for routing(crow) defined
typedef mbutil::MbPlaceHolder MB_PLACEHOLDER;
#define MB_ROUTE_START_0()   { int __ret = 0; char *__respbf = NULL; size_t __respsize = 0; MB_PLACEHOLDER __placeholder;
#define MB_ROUTE_START_1(k,v)   { int __ret = 0; char *__respbf = NULL; size_t __respsize = 0; MB_PLACEHOLDER __placeholder; __placeholder.set(k,v);
#define MB_ROUTE_START_2(k0,v0,k1,v1)   { int __ret = 0; char *__respbf = NULL; size_t __respsize = 0; MB_PLACEHOLDER __placeholder; __placeholder.set(k0,v0); __placeholder.set(k1,v1);
#define MB_ROUTE_START_3(k0,v0,k1,v1,k2,v2)   { int __ret = 0; char *__respbf = NULL; size_t __respsize = 0; MB_PLACEHOLDER __placeholder; __placeholder.set(k0,v0); __placeholder.set(k1,v1); __placeholder.set(k2,v2);
#define MB_ROUTE_END()     }
#define MB_ROUTE_JSON(f) {\
                          auto __ctx = (mbserver::MbMiddleware::context*)req.middleware_context;\
                          __ctx->type = mbserver::MbHeaderJson;\
                          auto appid = req.get_header_value("appid");\
                          if (strcmp(appid.c_str(), __ctx->mb->appid)!=0){\
                            return(crow::response(401));\
                          }\
                          if ((__ret = f((void*)&req, &__respbf, &__respsize, __placeholder, req.body.c_str(), req.body.length())) != 200){\
                            return(crow::response(__ret));\
                          }\
                        }
#define MB_ROUTE_OK()   { if (__respbf) {\
                                std::string __resp(__respbf, __respsize);\
                                free(__respbf);\
                                return crow::response(__resp);\
                             } else { \
                                return(crow::response(""));\
                             }}

#define MB_MALLOC_RESULT(b,l,s)    {\
        if (((*b) = (char*)malloc(strlen(s))) == NULL){\
            LOGERR("failed. allocation.");\
            return(500);\
        }\
        (*l) = strlen(s);\
        memcpy((*b),s, strlen(s));\
        }

// メッセージボードサーバ
namespace mbserver{
    enum MBRESULT{
        MBRESULT_OK,
        MBRESULT_NOTFOUND,
        MBRESULT_INTERNAL,
        MBRESULT_NOTIFY,
    };
    class BroadCaster{
    public:
        void* handle_;
        int topic_;
    public:
        BroadCaster(void* handle, int topic){
            handle_ = handle;
            topic_ = topic;
        }
        static BroadCaster* create(void* handle, int topic){
            return(new BroadCaster(handle, topic));
        }
        static void broadcaster_free(void* pbr){
            free(pbr);
        }
    };

    // サーバ開始
    extern int start_server(mbutil::mb_ptr pmb);
    extern int broadcast_notify(const char* msg,int topic);
    extern int boradcast_append(void* pres,int topic);
    //
    extern void compile_routes(crow::App<mbserver::MbMiddleware>& app);
    //
    inline static mbutil::mb_ptr ref_context(void* req){
        auto creq = (crow::request*)req;
        auto ctx = (mbserver::MbMiddleware::context*)creq->middleware_context;
        auto app = ctx->mb;
        return(app);
    }
    // ルーティング
    extern int new_user(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
    extern int upd_user(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
    extern int get_user(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
    extern int del_user(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
    extern int new_message(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
    extern int get_message(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
    extern int del_message(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
    extern int new_group(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
    extern int get_group(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
    extern int del_group(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
    extern int get_info(void* req, char** out, size_t* outlen, MB_PLACEHOLDER, std::string body, size_t bodylen);
};



#endif //SERVER_COCOSERVER_H

