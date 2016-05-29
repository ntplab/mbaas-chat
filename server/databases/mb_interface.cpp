#include "../../include/mb_database.h"
#include "plugins/mb_sqlite3.h"

namespace mbdatabase {
    MbDatabaseInterface* MbDatabaseInterface::self_ = NULL;
    boost::mutex MbDatabaseInterface::dbmtx_;

    MbDatabaseInterface* MbDatabaseInterface::getInstance(mbutil::mb_ptr mb){
        if(MbDatabaseInterface::self_ == NULL){
            boost::mutex::scoped_lock lock(dbmtx_);
            // TODO: データベース切り替え：mysql,oracle,postgres等をここで切り替える
            MbDatabaseInterface::self_ = new MbDatabaseSqlite(mb->dbcon);
        }
        return(MbDatabaseInterface::self_);
    }
    void MbDatabaseInterface::releaseInstance(void){
        boost::mutex::scoped_lock lock(dbmtx_);
        if (MbDatabaseInterface::self_){
            delete (MbDatabaseSqlite*)MbDatabaseInterface::self_;
            MbDatabaseInterface::self_ = NULL;
        }
    }

}
