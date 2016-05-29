#include <sqlite3.h>
#include "../../../include/mb_database.h"
#include "mb_sqlite3.h"

namespace mbdatabase {
    using lock = boost::mutex::scoped_lock;
    // グループ最終メッセージ取得
    FINDREC MbDatabaseSqlite::find_lastmessage(int gid, int uid,int* unread){
        lock autolock(dbmtx_);
        int err;
        std::vector<mbutil::MbPlaceHolder>  rec;
        std::vector<mbutil::MbPlaceHolder>  rec_ur;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedFindLastMsg];
        sqlite3_stmt* pstmt_ur = (sqlite3_stmt*)prepared_[PreparedUnreadCount];
        sqlite3_reset(pstmt);
        sqlite3_reset(pstmt_ur);
        //
        if ((err = sqlite3_bind_int(pstmt, 1, gid)) != SQLITE_OK) {LOGERR("sqlite3_bind_int(%d)", err); }
        while((err = sqlite3_step(pstmt)) == SQLITE_ROW){
            rec.push_back(sqliteToPlaceHolder(pstmt));
        }
        if (err != SQLITE_DONE){
            LOGERR("failed.find_lastmessage(%d)", err);
            rec.clear();
            return(rec);
        }
        //
        if ((err = sqlite3_bind_int(pstmt_ur, 1, gid)) != SQLITE_OK) {LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_int(pstmt_ur, 2, uid)) != SQLITE_OK) {LOGERR("sqlite3_bind_int(%d)", err); }
        while((err = sqlite3_step(pstmt_ur)) == SQLITE_ROW){
            rec_ur.push_back(sqliteToPlaceHolder(pstmt_ur));
        }
        if (err != SQLITE_DONE || rec_ur.empty()){
            LOGERR("failed.find_lastmessage/unread count(%d)", err);
            rec.clear();
            return(rec);
        }
        (*unread) = rec_ur[0].getN("cnt");
        //
        LOGINFO("find_lastmessage(%d)", err);
        return(rec);
    }
    FINDREC MbDatabaseSqlite::find_summary(int gid){
        lock autolock(dbmtx_);
        int err;
        std::vector<mbutil::MbPlaceHolder>  rec;
        std::vector<mbutil::MbPlaceHolder>::iterator itr;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedFindUserOnly];
        sqlite3_stmt* pstmt_lm = (sqlite3_stmt*)prepared_[PreparedFindLastMsg];
        sqlite3_reset(pstmt);
        // ユーザ一覧取得
        if ((err = sqlite3_bind_int(pstmt, 1, gid)) != SQLITE_OK) {LOGERR("sqlite3_bind_int(%d)", err); }
        while((err = sqlite3_step(pstmt)) == SQLITE_ROW){
            rec.push_back(sqliteToPlaceHolder(pstmt));
        }
        if (err != SQLITE_DONE){
            LOGERR("failed.find_summary(%d)", err);
            rec.clear();
            return(rec);
        }
        // ユーザ毎の最終メッセージ取得
        for(itr = rec.begin();itr != rec.end();++itr){
            uint64_t uid = (*itr).getN("id");
            std::vector<mbutil::MbPlaceHolder>  rec_lm;

            if (uid){
                sqlite3_reset(pstmt_lm);
                if ((err = sqlite3_bind_int(pstmt_lm, 1, uid)) != SQLITE_OK) {LOGERR("sqlite3_bind_int(%d)", err); }
                while((err = sqlite3_step(pstmt_lm)) == SQLITE_ROW){
                    rec_lm.push_back(sqliteToPlaceHolder(pstmt_lm));
                }
                if (!rec_lm.empty()){
                    (*itr).set("lastmsg" ,rec_lm[0].getS("msg").c_str());
                }
            }
        }
        LOGINFO("find_summary(%d)", err);
        return(rec);
    }
}
