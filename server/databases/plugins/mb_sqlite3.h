#ifndef SERVER_MB_SQLITE3_H
#define SERVER_MB_SQLITE3_H

#include "../../../include/mb_database.h"

namespace mbdatabase {
// SQLITE3：インスタンス
    class MbDatabaseSqlite:public MbDatabaseInterface {
        void* con_;
    public:
        MbDatabaseSqlite(const char*);
        virtual ~MbDatabaseSqlite();
    public:
        virtual std::vector<mbutil::MbPlaceHolder> find_message(int gid, int lastid);
        virtual bool create_message(int gid, int uid, const char* msg, int* lastid);
        virtual bool remove_message(int gid, int uid, int mid, int* lastid);
        virtual FINDREC find_lastmessage(int gid,int uid,int* unread);
        virtual FINDREC find_summary(int gid);

        virtual FINDREC find_user(int gid, int uid);
        virtual bool create_user(int gid, int token, const char* name, const char* img, int* lastid);
        virtual bool update_user_geo(int token, const char* disp, int* lastid);
        virtual bool update_user_img(int gid, int uid, const char* img, const char* nicknm, int* lastid);
        virtual bool remove_user(int gid, int uid, int* lastid);

        virtual FINDREC find_group(int gid);
        virtual bool create_group(const char* name, const char* img, int* lastid);
        virtual bool remove_group(int gid, int* lastid);
    public:
        typedef enum PreparedType{
            PreparedDc,
            PreparedFindMsg,
            PreparedFindMsgLast,
            PreparedCreateMsg,
            PreparedRemoveMsg,
            PreparedFindUser,
            PreparedCreateUser,
            PreparedRemoveUser,
            PreparedUpdateUser,
            PreparedUpdateUserImg,
            PreparedUpdateUserName,
            PreparedFindUqUser,
            PreparedFindUserOnly,
            PreparedFindGroup,
            PreparedFindAllGroup,
            PreparedFindLastMsg,
            PreparedUnreadCount,
            PreparedCreateGroup,
            PreparedRemoveGroup,
            PreparedCreateGeometry,
            PreparedRemoveGeometry,
            PreparedUpdateGeometry,
            PreparedCreateAccess,
            PreparedRemoveAccess,
            PreparedUpdateAccess,
            PreparedLastIdMsg,
            PreparedLastIdUser,
            PreparedLastIdGroup,
            PreparedLastIdGeometry,
            PreparedLastIdAccess,
            PreparedMax
        }_PreparedType;
        void* prepared_[PreparedMax];
    private:
        mbutil::MbPlaceHolder sqliteToPlaceHolder(void* parg);
        bool initPrepared(const char* sql, _PreparedType idx);
        bool initTable(const char* sql);
        bool releaseTable(void);
    private:
        bool update_user_img_unsafe(int gid, int uid, const char* img, const char* nicknm, int* lastid);
    };
}


#endif //SERVER_MB_SQLITE3_H
