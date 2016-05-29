#include "../include/mb_def.h"
#include "../include/mb_server.h"

//
namespace mbutil{
// for thread safe..
    pthread_mutex_t	__global_str_safe_muex;
// for main loop flags.
    int __halt_process = RET_OK;
};
// メインエントリ
int main(int argc, char* argv[]) {
    LOGINFO("start message board");
    mbutil::mb_ptr pmb = mbutil::start_application(argc, argv);
    if (!pmb){
        LOGERR("could not start.");
        return(RET_NG);
    }
    // メッセージボードサーバ開始
    mbserver::start_server(pmb);
    // 終了監視
    mbutil::is_halt(pmb);
    // リソースリリース
    mbutil::release_application(pmb);

    LOGINFO("stop message board");
    return 0;
}

