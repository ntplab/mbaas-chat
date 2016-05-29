#include <sqlite3.h>
#include "../../../include/mb_database.h"
#include "mb_sqlite3.h"

namespace mbdatabase {
    using lock = boost::mutex::scoped_lock;
    static const char* SQL_MSG = ""
            "CREATE TABLE IF NOT EXISTS messages"
            "("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "gid INTEGER, "
            "uid INTEGER, "
            "msg TEXT  NOT NULL CHECK(LENGTH(msg) <= 128),"
            "created TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
            ")";
    static const char* SQL_DROP_MSG = ""
            "DROP TABLE IF EXISTS messages";
    static const char* SQL_DROP_USER = ""
            "DROP TABLE IF EXISTS users";
    static const char* SQL_DROP_GROUP = ""
            "DROP TABLE IF EXISTS groups";
    static const char* SQL_MSG_IDX = ""
            "CREATE INDEX IF NOT EXISTS MSGIDX ON messages(gid,uid)";
    static const char* SQL_USER_IDX = ""
            "CREATE UNIQUE INDEX IF NOT EXISTS USERIDX ON users(gid,token)";
    static const char* SQL_DROP_USER_IDX = ""
            "DROP INDEX IF EXISTS USERIDX";
    static const char* SQL_DROP_MSG_IDX = ""
            "DROP INDEX IF EXISTS MSGIDX";
    static const char* SQL_GEOMRTRY_IDX = ""
            "CREATE INDEX IF NOT EXISTS GEOIDX ON geometries(utoken)";
    static const char* SQL_DROP_GEOMETRY_IDX = ""
            "DROP INDEX IF EXISTS GEOIDX";
    static const char* SQL_DROP_GEOMETY = ""
            "DROP TABLE IF EXISTS geometries";
    static const char* SQL_DROP_ACCESS = ""
            "DROP TABLE IF EXISTS access";
    static const char* SQL_ACCESS_IDX = ""
            "CREATE INDEX IF NOT EXISTS ACCESSIDX ON access(gid,uid,mid,stat)";
    static const char* SQL_DROP_ACCESS_IDX = ""
            "DROP INDEX IF EXISTS ACCESSIDX";
    static const char* SQL_USER = ""
            "CREATE TABLE IF NOT EXISTS users"
            "("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "gid INTERGER NOT NULL,"
            "token INTERGER NOT NULL,"
            "name TEXT NOT NULL CHECK(LENGTH(name) <= 32),"
            "img TEXT NOT NULL CHECK(LENGTH(name) <= 128),"
            "created TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
            ""
            ")";
    static const char* SQL_GROUP = ""
            "CREATE TABLE IF NOT EXISTS groups"
            "("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "name TEXT NOT NULL CHECK(LENGTH(name) <= 32),"
            "img TEXT NOT NULL CHECK(LENGTH(name) <= 128),"
            "created TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
            ")";
    static const char* SQL_GEOMETRY = ""
            "CREATE TABLE IF NOT EXISTS geometries"
            "("
            "utoken INTEGER PRIMARY KEY NOT NULL,"
            "disp TEXT NOT NULL CHECK(LENGTH(disp) <= 64),"
            "created TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
            ")";
    static const char* SQL_ACCESS = ""
            "CREATE TABLE IF NOT EXISTS access"
            "("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "gid INTEGER, "
            "uid INTEGER, "
            "mid INTEGER, "
            "stat INTEGER, "
            "created TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
            ")";
    static const char* SQL_FIND_MSG = ""
            "SELECT m.id,m.gid,g.name AS gname,g.img,m.uid,u.name AS uname,m.msg,gn.disp, u.img AS uimg "
            " FROM messages m INNER JOIN users u ON(m.uid = u.id AND m.gid = u.gid) "
            " INNER JOIN groups g ON(m.gid = g.id) "
            " INNER JOIN geometries gn ON(u.token = gn.utoken)"
            " WHERE m.gid = ?1 AND m.id > ?2 "
            " ORDER BY m.gid ASC, m.id ASC LIMIT 1000"
            "";
    static const char* SQL_FIND_USER = ""
            "SELECT u.id,u.gid,g.name AS gname,g.img,u.name AS uname,gn.disp, u.img AS uimg  "
            " FROM users u INNER JOIN groups g ON(u.gid = g.id) "
            " INNER JOIN geometries gn ON(u.token = gn.utoken)"
            " WHERE u.gid = ?1 AND u.id = ?2 "
            " ORDER BY u.gid ASC, u.id ASC"
            "";
    static const char* SQL_FIND_GROUP = ""
            "SELECT u.id,u.gid,g.name AS gname, g.img,u.name AS uname,gn.disp, u.img AS uimg  "
            " FROM users u INNER JOIN groups g ON(u.gid = g.id) "
            " INNER JOIN geometries gn ON(u.token = gn.utoken)"
            " WHERE u.gid = ?1 "
            " ORDER BY u.gid ASC, u.id ASC"
            "";
    static const char* SQL_FIND_ALLGROUP = ""
            "SELECT g.id,g.name AS gname,g.img "
            " FROM groups g "
            " ORDER BY g.id ASC"
            "";
    static const char* SQL_FIND_LASTMSG = ""
            "SELECT m.id,m.gid,g.name AS gname,g.img,m.uid,u.name AS uname,m.msg,gn.disp, u.img AS uimg  "
            " FROM messages m INNER JOIN users u ON(m.uid = u.id AND m.gid = u.gid) "
            " INNER JOIN groups g ON(m.gid = g.id) "
            " INNER JOIN geometries gn ON(u.token = gn.utoken)"
            " WHERE m.gid = ?1 "
            " ORDER BY m.id DESC LIMIT 1"
            "";
    static const char* SQL_FIND_UNREADCNT = ""
            "SELECT COUNT(m.id) AS cnt "
            " FROM messages m "
            " INNER JOIN users u ON(m.gid=u.gid) "
            " LEFT JOIN access a ON(u.gid=a.gid AND u.id=a.uid AND m.id=a.mid) "
            " WHERE u.gid = ?1 AND u.id= ?2  AND a.id IS NULL "
            "";

    static const char* SQL_FIND_UQUSER = ""
            "SELECT u.id FROM users u WHERE u.gid=?1 AND u.token=?2"
            "";
    static const char* SQL_FIND_USERONLY = ""
            "SELECT u.id,u.name,u.img, gn.disp "
            " FROM users u INNER JOIN geometries gn ON(u.token = gn.utoken) "
            " WHERE u.gid = ?"
            "";
    static const char* SQL_FIND_MSG_LAST = ""
            "SELECT id,msg,created FROM messages WHERE uid = ?1 ORDER BY id DESC LIMIT 1"
            "";
    static const char* SQL_CREATE_MSG = ""
            "INSERT INTO messages(gid,uid,msg) VALUES(?,?,?)";
    static const char* SQL_REMOVE_MSG = ""
            "DELETE FROM messages WHERE gid=?1 AND uid=?2 AND id=?3";
    static const char* SQL_CREATE_USER = ""
            "INSERT INTO users(gid,token,name,img) VALUES(?,?,?,?)";
    static const char* SQL_REMOVE_USER = ""
            "DELETE FROM users WHERE gid=?1 AND id=?2";
    static const char* SQL_UPDATE_USER = ""
            "UPDATE users SET img=?1,name=?2 WHERE gid=?3 AND id=?4";
    static const char* SQL_UPDATE_USER_IMG = ""
            "UPDATE users SET img=?1 WHERE gid=?2 AND id=?3";
    static const char* SQL_UPDATE_USER_NAME = ""
            "UPDATE users SET name=?1 WHERE gid=?2 AND id=?3";
    static const char* SQL_CREATE_GROUP = ""
            "INSERT INTO groups(name, img) VALUES(?,?)";
    static const char* SQL_REMOVE_GROUP = ""
            "DELETE FROM groups WHERE id=?1";
    static const char* SQL_CREATE_GEOMETRY = ""
            "INSERT OR REPLACE INTO geometries(utoken,disp) VALUES(?,?)";
    static const char* SQL_REMOVE_GEOMETRY = ""
            "DELETE FROM geometries WHERE utoken=?1";
    static const char* SQL_UPDATE_GEOMETRY = ""
            "UPDATE geometries SET disp=?1 WHERE utoken=?2";
    static const char* SQL_CREATE_ACCESS = ""
            "INSERT INTO access(gid,uid,mid,stat) VALUES(?,?,?,?)";
    static const char* SQL_REMOVE_ACCESS = ""
            "DELETE FROM access WHERE gid=?1 AND uid=?2 AND mid=?3";
    static const char* SQL_UPDATE_ACCESS = ""
            "UPDATE access SET stat=?1 WHERE gid=?1 AND uid=?2 AND mid=?3";

    static const char* SQL_LASTID_MSG = ""
            "SELECT id FROM messages WHERE ROWID = LAST_INSERT_ROWID()";
    static const char* SQL_LASTID_USER = ""
            "SELECT id FROM users WHERE ROWID = LAST_INSERT_ROWID()";
    static const char* SQL_LASTID_GROUP = ""
            "SELECT id FROM groups WHERE ROWID = LAST_INSERT_ROWID()";
    static const char* SQL_LASTID_GEOMETRY = ""
            "SELECT utoken FROM geometries WHERE ROWID = LAST_INSERT_ROWID()";
    static const char* SQL_LASTID_ACCESS = ""
            "SELECT id FROM access WHERE ROWID = LAST_INSERT_ROWID()";

    enum setup_table_type{
        InitTable,
        Prepared,
        DropTable,
    };

    typedef struct setup_tables{
        const char* sql;
        setup_table_type   setuptype;
        MbDatabaseSqlite::_PreparedType preparedtype;
    }setup_tables_t,*setup_tables_ptr;

    static const setup_tables_t SETUP_TABLES[] = {
            {SQL_MSG,           InitTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_USER,          InitTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_GROUP,         InitTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_GEOMETRY,      InitTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_ACCESS,        InitTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_MSG_IDX,       InitTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_GEOMRTRY_IDX,  InitTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_ACCESS_IDX,    InitTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_USER_IDX,      InitTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_FIND_MSG,      Prepared,   MbDatabaseSqlite::PreparedFindMsg},
            {SQL_CREATE_MSG,    Prepared,   MbDatabaseSqlite::PreparedCreateMsg},
            {SQL_REMOVE_MSG,    Prepared,   MbDatabaseSqlite::PreparedRemoveMsg},
            {SQL_FIND_USER,     Prepared,   MbDatabaseSqlite::PreparedFindUser},
            {SQL_CREATE_USER,   Prepared,   MbDatabaseSqlite::PreparedCreateUser},
            {SQL_REMOVE_USER,   Prepared,   MbDatabaseSqlite::PreparedRemoveUser},
            {SQL_UPDATE_USER,   Prepared,   MbDatabaseSqlite::PreparedUpdateUser},
            {SQL_UPDATE_USER_IMG,Prepared,  MbDatabaseSqlite::PreparedUpdateUserImg},
            {SQL_UPDATE_USER_NAME,Prepared, MbDatabaseSqlite::PreparedUpdateUserName},
            {SQL_FIND_GROUP,    Prepared,   MbDatabaseSqlite::PreparedFindGroup},
            {SQL_FIND_ALLGROUP, Prepared,   MbDatabaseSqlite::PreparedFindAllGroup},
            {SQL_CREATE_GROUP,   Prepared,   MbDatabaseSqlite::PreparedCreateGroup},
            {SQL_REMOVE_GROUP,   Prepared,   MbDatabaseSqlite::PreparedRemoveGroup},
            {SQL_CREATE_GEOMETRY,Prepared,   MbDatabaseSqlite::PreparedCreateGeometry},
            {SQL_REMOVE_GEOMETRY,Prepared,   MbDatabaseSqlite::PreparedRemoveGeometry},
            {SQL_UPDATE_GEOMETRY,Prepared,  MbDatabaseSqlite::PreparedUpdateGeometry},
            {SQL_CREATE_ACCESS, Prepared,   MbDatabaseSqlite::PreparedCreateAccess},
            {SQL_REMOVE_ACCESS, Prepared,   MbDatabaseSqlite::PreparedRemoveAccess},
            {SQL_UPDATE_ACCESS, Prepared,   MbDatabaseSqlite::PreparedUpdateAccess},

            {SQL_LASTID_MSG,    Prepared,   MbDatabaseSqlite::PreparedLastIdMsg},
            {SQL_LASTID_USER,   Prepared,   MbDatabaseSqlite::PreparedLastIdUser},
            {SQL_LASTID_GROUP,  Prepared,   MbDatabaseSqlite::PreparedLastIdGroup},
            {SQL_LASTID_GEOMETRY,Prepared,  MbDatabaseSqlite::PreparedLastIdGeometry},
            {SQL_LASTID_ACCESS, Prepared,   MbDatabaseSqlite::PreparedLastIdAccess},

            {SQL_FIND_LASTMSG,  Prepared,   MbDatabaseSqlite::PreparedFindLastMsg},
            {SQL_FIND_UNREADCNT,Prepared,   MbDatabaseSqlite::PreparedUnreadCount},
            {SQL_FIND_UQUSER,   Prepared,   MbDatabaseSqlite::PreparedFindUqUser},
            {SQL_FIND_USERONLY, Prepared,   MbDatabaseSqlite::PreparedFindUserOnly},
            {SQL_FIND_MSG_LAST, Prepared,   MbDatabaseSqlite::PreparedFindMsgLast},
            {SQL_DROP_MSG,      DropTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_DROP_GROUP,    DropTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_DROP_USER,     DropTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_DROP_GEOMETY,  DropTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_DROP_MSG_IDX,  DropTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_DROP_GEOMETRY_IDX,  DropTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_DROP_ACCESS_IDX,DropTable, MbDatabaseSqlite::PreparedDc},
            {SQL_DROP_ACCESS,   DropTable,  MbDatabaseSqlite::PreparedDc},
            {SQL_DROP_USER_IDX, DropTable,  MbDatabaseSqlite::PreparedDc},
    };
    MbDatabaseSqlite::MbDatabaseSqlite(const char* dbcon){
        sqlite3* pdb = NULL;
        bool isok = true;
        //
        auto err = sqlite3_open(dbcon, &pdb);
        if (err != SQLITE_OK){
            con_ = NULL;
        }else{
            con_ = (void*)pdb;
            for(auto s : SETUP_TABLES){
                if (s.setuptype == InitTable){
                    if (!initTable(s.sql)){ isok = false; break; }
                }else if (s.setuptype == Prepared){
                    if (!initPrepared(s.sql, s.preparedtype)){ isok = false; break; }
                }
            }
            if (!isok) {
                releaseTable();
            }
        }
        if (!con_){
            throw std::runtime_error("failed.MbDatabaseSqlite");
        }
    }
    MbDatabaseSqlite::~MbDatabaseSqlite(){
        releaseTable();
    }
    bool MbDatabaseSqlite::initTable(const char *sql){
        int err = 0;
        char *errmsg = NULL;
        auto db = (sqlite3*)con_;
        if (db){
            if ((err = sqlite3_exec(db, sql, NULL, NULL, &errmsg)) != SQLITE_OK){
                LOGERR("MbDatabaseSqlite::initTable(%d:%s)", err, errmsg);
                sqlite3_free(errmsg);
                sqlite3_close(db);
                return(false);
            }
        }
        return(true);
    }
    bool MbDatabaseSqlite::initPrepared(const char* sql, _PreparedType idx){
        auto db = (sqlite3*)con_;
        sqlite3_stmt* pstmt = NULL;
        if (sqlite3_prepare_v2(db, sql, strlen(sql), &pstmt, NULL) != SQLITE_OK){
            LOGERR("initPrepared(%s)", sql);
            sqlite3_close(db);
            return(false);
        }
        prepared_[idx] = pstmt;
        return(true);
    }

    bool MbDatabaseSqlite::releaseTable(void){
        int err;
        auto db = (sqlite3*)con_;
        char *errmsg = NULL;
        if (db){
            for(auto s : SETUP_TABLES) {
                if (s.setuptype == DropTable) {
                    if ((err = sqlite3_exec(db, s.sql, NULL, NULL, &errmsg)) != SQLITE_OK){
                        LOGERR("MbDatabaseSqlite::releaseTable(%s:%d/%s)", s.sql, err, errmsg);
                        sqlite3_free(errmsg);
                    }
                }else if (s.setuptype == Prepared){
                    sqlite3_finalize((sqlite3_stmt*)(prepared_[s.preparedtype]));
                }
            }
            sqlite3_close(db);
        }
        con_=NULL;
        return(true);
    }
    mbutil::MbPlaceHolder MbDatabaseSqlite::sqliteToPlaceHolder(void* parg){
        sqlite3_stmt* pstmt = (sqlite3_stmt*)parg;
        int colcnt,n;
        mbutil::MbPlaceHolder   reci;
        if ((colcnt = sqlite3_column_count(pstmt)) > 0){
            for(n = 0;n < colcnt;n++){
                auto coltype = sqlite3_column_type(pstmt,n);
                auto colname = sqlite3_column_name(pstmt,n);
                if (coltype == SQLITE_INTEGER) {
                    auto val = sqlite3_column_int(pstmt,n);
                    reci.set(colname, val);
                }else if (coltype == SQLITE_FLOAT){
                    auto val = sqlite3_column_double(pstmt,n);
                    reci.set(colname, val);
                }else if (coltype == SQLITE_TEXT || coltype == SQLITE3_TEXT){
                    auto val = sqlite3_column_text(pstmt, n);
                    reci.set(colname, (const char*)val);
                }
            }
        }
        return(reci);
    }
}
