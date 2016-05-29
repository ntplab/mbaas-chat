#include <sqlite3.h>
#include "../../../include/mb_database.h"
#include "mb_sqlite3.h"

namespace mbdatabase {
    using lock = boost::mutex::scoped_lock;
    // ユーザ検索
    FINDREC MbDatabaseSqlite::find_user(int gid, int uid){
        lock autolock(dbmtx_);
        int err;
        std::vector<mbutil::MbPlaceHolder>  rec;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedFindUser];
        //
        sqlite3_reset(pstmt);
        if ((err = sqlite3_bind_int(pstmt, 1, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_int(pstmt, 2, uid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        //
        while((err = sqlite3_step(pstmt)) == SQLITE_ROW){
            rec.push_back(sqliteToPlaceHolder(pstmt));
        }
        LOGINFO("find_user(%d)", err);
        return(rec);
    }
    // ユーザ作成
    bool MbDatabaseSqlite::create_user(int gid, int token, const char* name, const char* img, int* lastid){
        lock autolock(dbmtx_);
        int err,tmpid;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedCreateUser];
        sqlite3_stmt* pstmt_lastid = (sqlite3_stmt*)prepared_[PreparedLastIdUser];
        sqlite3_stmt* pstmt_geo = (sqlite3_stmt*)prepared_[PreparedCreateGeometry];
        sqlite3_stmt* pstmt_uq = (sqlite3_stmt*)prepared_[PreparedFindUqUser];
        //
        sqlite3_reset(pstmt);
        //
        if ((err = sqlite3_bind_int(pstmt, 1, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_int(pstmt, 2, token)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_text(pstmt, 3, name,strlen(name),NULL)) != SQLITE_OK){ LOGERR("sqlite3_bind_text(%d)", err); }
        if ((err = sqlite3_bind_text(pstmt, 4, img,strlen(img),NULL)) != SQLITE_OK){ LOGERR("sqlite3_bind_text(%d)", err); }
        while((err = sqlite3_step(pstmt)) == SQLITE_BUSY){ };
        LOGINFO("create_user(%d)", err);

        (*lastid) = -1;
        // 同一ユニークユーザの場合
        if (err == SQLITE_CONSTRAINT){
            sqlite3_reset(pstmt_uq);
            if ((err = sqlite3_bind_int(pstmt_uq, 1, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
            if ((err = sqlite3_bind_int(pstmt_uq, 2, token)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
            while((err = sqlite3_step(pstmt_uq)) == SQLITE_ROW){
                (*lastid) = sqlite3_column_int(pstmt_uq, 0);
                LOGINFO("create_user - lastid(%d : %d)", err, (*lastid));
            }
            // ニックネームを更新
            if ((*lastid) >0){
                if (!update_user_img_unsafe(gid, (*lastid), img, name, &tmpid)){
                    LOGINFO("update_user_img - lastid(%d : %d)", tmpid, (*lastid));
                }
            }
            return((*lastid)<0?false:true);
        }else if (err != SQLITE_DONE){
            LOGERR("failed.create_user(%d:%s)", err, sqlite3_errmsg((sqlite3*)con_));
            return(false);
        }
        sqlite3_reset(pstmt_lastid);
        while((err = sqlite3_step(pstmt_lastid)) == SQLITE_ROW){
            (*lastid) = sqlite3_column_int(pstmt_lastid, 0);
            LOGINFO("create_user - lastid(%d : %d)", err, (*lastid));
        }
        // ユーザに紐付くgeometryレコードを準備
        sqlite3_reset(pstmt_geo);
        if ((err = sqlite3_bind_int(pstmt_geo, 1, token)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_text(pstmt_geo, 2, "",0,NULL)) != SQLITE_OK){ LOGERR("sqlite3_bind_text(%d)", err); }
        while((err = sqlite3_step(pstmt_geo)) == SQLITE_BUSY);
        //
        if (err != SQLITE_DONE){
            LOGERR("failed.create_user/geo(%d)", err);
            return(false);
        }
        return(true);
    }
    // ユーザ削除
    bool MbDatabaseSqlite::remove_user(int gid, int uid, int* lastid){
        lock autolock(dbmtx_);
        int err;
        sqlite3_stmt* pstmt = (sqlite3_stmt*)prepared_[PreparedRemoveUser];
        sqlite3_stmt* pstmt_geo = (sqlite3_stmt*)prepared_[PreparedRemoveGeometry];
        //
        sqlite3_reset(pstmt);
        sqlite3_reset(pstmt_geo);
        LOGINFO("remove_user(%d)", err);

        (*lastid) = -1;

        if ((err = sqlite3_bind_int(pstmt, 1, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        if ((err = sqlite3_bind_int(pstmt, 2, uid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        while((err = sqlite3_step(pstmt)) == SQLITE_BUSY){};
        //
        if (err != SQLITE_DONE){
            LOGERR("failed.remove_user(%d)", err);
            return(false);
        }
        if ((err = sqlite3_bind_int(pstmt_geo, 1, uid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        while((err = sqlite3_step(pstmt_geo)) == SQLITE_BUSY){};
        if (err != SQLITE_DONE){
            LOGERR("failed.remove_user/geo(%d)", err);
            return(false);
        }
        return(true);
    }
    // ユーザジオ情報更新
    bool MbDatabaseSqlite::update_user_geo(int token, const char* disp, int* lastid){
        lock autolock(dbmtx_);
        int err;
        sqlite3_stmt* pstmt_geo = (sqlite3_stmt*)prepared_[PreparedUpdateGeometry];
        //
        sqlite3_reset(pstmt_geo);
        LOGINFO("update_user(%d)", err);

        (*lastid) = -1;
        //
        if (err != SQLITE_DONE){
            LOGERR("failed.update_user(%d)", err);
            return(false);
        }
        if ((err = sqlite3_bind_text(pstmt_geo, 1, disp,strlen(disp),NULL)) != SQLITE_OK){ LOGERR("sqlite3_bind_text(%d)", err); }
        if ((err = sqlite3_bind_int(pstmt_geo, 2, token)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
        //
        while((err = sqlite3_step(pstmt_geo)) == SQLITE_BUSY){};
        if (err != SQLITE_DONE){
            LOGERR("failed.update_user/geo(%d)", err);
            return(false);
        }
        return(true);
    }
    bool MbDatabaseSqlite::update_user_img_unsafe(int gid, int uid, const char* img, const char* nicknm, int* lastid){
        int err;
        sqlite3_stmt* pstmt_usr = (sqlite3_stmt*)prepared_[PreparedUpdateUser];
        sqlite3_stmt* pstmt_usrimg = (sqlite3_stmt*)prepared_[PreparedUpdateUserImg];
        sqlite3_stmt* pstmt_usrnm = (sqlite3_stmt*)prepared_[PreparedUpdateUserName];
        sqlite3_reset(pstmt_usr);
        sqlite3_reset(pstmt_usrimg);
        sqlite3_reset(pstmt_usrnm);
        LOGINFO("update_user_img(%d)", err);

        (*lastid) = 0;
        if (img && nicknm){
            if ((err = sqlite3_bind_text(pstmt_usr, 1, img,strlen(img),NULL)) != SQLITE_OK){ LOGERR("sqlite3_bind_text(%d)", err); }
            if ((err = sqlite3_bind_text(pstmt_usr, 2, nicknm,strlen(nicknm),NULL)) != SQLITE_OK){ LOGERR("sqlite3_bind_text(%d)", err); }
            if ((err = sqlite3_bind_int(pstmt_usr, 3, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
            if ((err = sqlite3_bind_int(pstmt_usr, 4, uid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
            //
            while((err = sqlite3_step(pstmt_usr)) == SQLITE_BUSY){};
            if (err != SQLITE_DONE){
                LOGERR("failed.update_user_img(%d)", err);
                return(false);
            }
        }else if (img){
            if ((err = sqlite3_bind_text(pstmt_usrimg, 1, img,strlen(img),NULL)) != SQLITE_OK){ LOGERR("sqlite3_bind_text(%d)", err); }
            if ((err = sqlite3_bind_int(pstmt_usrimg, 2, gid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
            if ((err = sqlite3_bind_int(pstmt_usrimg, 3, uid)) != SQLITE_OK){ LOGERR("sqlite3_bind_int(%d)", err); }
            //
            while((err = sqlite3_step(pstmt_usrimg)) == SQLITE_BUSY){};
            if (err != SQLITE_DONE){
                LOGERR("failed.update_user_img(%d)", err);
                return(false);
            }
        }else if (nicknm) {
            if ((err = sqlite3_bind_text(pstmt_usrnm, 1, nicknm, strlen(nicknm), NULL)) != SQLITE_OK) {
                LOGERR("sqlite3_bind_text(%d)", err);
            }
            if ((err = sqlite3_bind_int(pstmt_usrnm, 2, gid)) != SQLITE_OK) {LOGERR("sqlite3_bind_int(%d)", err); }
            if ((err = sqlite3_bind_int(pstmt_usrnm, 3, uid)) != SQLITE_OK) {LOGERR("sqlite3_bind_int(%d)", err); }
            //
            while ((err = sqlite3_step(pstmt_usrnm)) == SQLITE_BUSY) { };
            if (err != SQLITE_DONE) {
                LOGERR("failed.update_user_img(%d)", err);
                return (false);
            }
        }else{
            LOGERR("failed.update_user_img(invalid parameters)");
            return(false);
        }
        return(true);
    }
    bool MbDatabaseSqlite::update_user_img(int gid, int uid, const char* img, const char* nicknm, int* lastid){
        lock autolock(dbmtx_);
        return (update_user_img_unsafe(gid, uid, img, nicknm, lastid));
    }
}
