#include <sqlite3.h>
#include "../../../include/mb_database.h"
#include "mb_sqlite3.h"

namespace mbdatabase {
    using lock = boost::mutex::scoped_lock;
    // グループ検索
    FINDREC MbDatabaseSqlite::find_group(int gid){
        lock autolock(dbmtx_);
        int err;
        std::vector<mbutil::MbPlaceHolder>  rec;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedFindGroup];

        if (gid == 0){
            pstmt = (sqlite3_stmt*)prepared_[PreparedFindAllGroup];
        }
        //
        sqlite3_reset(pstmt);
        if (gid != 0) {
            if ((err = sqlite3_bind_int(pstmt, 1, gid)) != SQLITE_OK) {LOGERR("sqlite3_bind_int(%d)", err); }
        }
        //
        while((err = sqlite3_step(pstmt)) == SQLITE_ROW){
            rec.push_back(sqliteToPlaceHolder(pstmt));
        }
        LOGINFO("find_group(%d/%d)", err, gid);
        return(rec);
    }
    // グループ作成
    bool MbDatabaseSqlite::create_group(const char* name, const char* img, int* lastid){
        lock autolock(dbmtx_);
        int err;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedCreateGroup];
        sqlite3_stmt* pstmt_lastid = (sqlite3_stmt*)prepared_[PreparedLastIdGroup];
        //
        sqlite3_reset(pstmt);
        //
        if ((err = sqlite3_bind_text(pstmt, 1, name,strlen(name),NULL)) != SQLITE_OK){ LOGERR("sqlite3_bind_text(%d)", err); }
        if ((err = sqlite3_bind_text(pstmt, 2, img,strlen(img),NULL)) != SQLITE_OK){ LOGERR("sqlite3_bind_text(%d)", err); }
        while((err = sqlite3_step(pstmt)) == SQLITE_BUSY);
        //
        if (err != SQLITE_DONE){
            LOGERR("failed.create_group(%d)", err);
            return(false);
        }
        LOGINFO("create_group(%d)", err);
        (*lastid) = -1;
        sqlite3_reset(pstmt_lastid);
        while((err = sqlite3_step(pstmt_lastid)) == SQLITE_ROW){
            (*lastid) = sqlite3_column_int(pstmt_lastid, 0);
            LOGINFO("create_user - lastid(%d : %d)", err, (*lastid));
        }
        return(true);
    }
    // グループ削除
    bool MbDatabaseSqlite::remove_group(int gid, int* lastid){
        lock autolock(dbmtx_);
        int err;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedRemoveGroup];
        //
        sqlite3_reset(pstmt);
        LOGINFO("remove_group(%d)", err);
        if ((err = sqlite3_bind_int(pstmt, 1, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        while((err = sqlite3_step(pstmt)) == SQLITE_BUSY);
        //
        if (err != SQLITE_DONE){
            LOGERR("failed.remove_group(%d)", err);
            return(false);
        }
        UNUSED_PARAMETER(lastid);
        return(true);

    }
}
