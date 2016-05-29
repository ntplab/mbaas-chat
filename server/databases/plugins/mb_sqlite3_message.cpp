#include <sqlite3.h>
#include "../../../include/mb_database.h"
#include "mb_sqlite3.h"

namespace mbdatabase {
    using lock = boost::mutex::scoped_lock;

    // 掲示板メッセージの取得
    std::vector<mbutil::MbPlaceHolder> MbDatabaseSqlite::find_message(int gid, int lastid){
        lock autolock(dbmtx_);
        // --
        std::vector<mbutil::MbPlaceHolder>  rec;
        int err;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedFindMsg];
        //
        sqlite3_reset(pstmt);
        if ((err = sqlite3_bind_int(pstmt, 1, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_int(pstmt, 2, lastid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        //
        while((err = sqlite3_step(pstmt)) == SQLITE_ROW){
            rec.push_back(sqliteToPlaceHolder(pstmt));
        }
        LOGINFO("find_message(%d)", err);

        return(rec);
    }
    // 掲示板メッセージの作成
    bool MbDatabaseSqlite::create_message(int gid, int uid, const char* msg, int* lastid){
        lock autolock(dbmtx_);
        int err;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedCreateMsg];
        sqlite3_stmt* pstmt_lastid = (sqlite3_stmt*)prepared_[PreparedLastIdMsg];
        sqlite3_stmt* pstmt_access = (sqlite3_stmt*)prepared_[PreparedCreateAccess];
        //
        sqlite3_reset(pstmt);
        if ((err = sqlite3_bind_int(pstmt, 1, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_int(pstmt, 2, uid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_text(pstmt, 3, msg,strlen(msg),NULL)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        while((err = sqlite3_step(pstmt)) == SQLITE_BUSY){};
        //
        if (err != SQLITE_DONE){
            LOGERR("failed.create_message(%d)", err);
            return(false);
        }
        //
        (*lastid) = -1;
        sqlite3_reset(pstmt_lastid);
        while((err = sqlite3_step(pstmt_lastid)) == SQLITE_ROW){
            (*lastid) = sqlite3_column_int(pstmt_lastid, 0);
            LOGINFO("create_message - lastid(%d : %d)", err, (*lastid));
        }
        if ((*lastid) > 0){
            sqlite3_reset(pstmt_access);
            if ((err = sqlite3_bind_int(pstmt_access, 1, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
            if ((err = sqlite3_bind_int(pstmt_access, 2, uid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
            if ((err = sqlite3_bind_int(pstmt_access, 3, (*lastid))) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
            if ((err = sqlite3_bind_int(pstmt_access, 4, 1)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
            while((err = sqlite3_step(pstmt_access)) == SQLITE_BUSY){};
            //
            if (err != SQLITE_DONE){
                LOGERR("failed.create_message:access(%d)", err);
                return(false);
            }
        }
        return(true);
    }
    // 掲示板メッセージの削除
    bool MbDatabaseSqlite::remove_message(int gid, int uid, int mid, int* lastid){
        lock autolock(dbmtx_);
        int err;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedRemoveMsg];
        //
        sqlite3_reset(pstmt);
        if ((err = sqlite3_bind_int(pstmt, 1, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_int(pstmt, 2, uid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_int(pstmt, 3, mid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        while((err = sqlite3_step(pstmt)) == SQLITE_BUSY){};
        LOGINFO("remove_message(%d)", err);
        //
        if (err != SQLITE_DONE){
            LOGERR("failed.remove_message(%d)", err);
            return(false);
        }
        return(true);
    }
}
