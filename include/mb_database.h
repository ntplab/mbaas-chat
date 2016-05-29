#ifndef SERVER_DATABASE_H
#define SERVER_DATABASE_H

#include "../include/mb_def.h"

namespace mbdatabase {
	typedef std::vector<mbutil::MbPlaceHolder> FINDREC;
	class MbDatabaseInterface{
		static MbDatabaseInterface* self_;
	protected:
		static boost::mutex dbmtx_;
	public:
		static MbDatabaseInterface* getInstance(mbutil::mb_ptr mb);
		static void releaseInstance(void);
	public:
		virtual FINDREC find_message(int gid, int lastid) = 0;
		virtual bool create_message(int gid, int uid, const char* msg, int* lastid) = 0;
		virtual bool remove_message(int gid, int uid, int mid, int* lastid) = 0;
		virtual FINDREC find_lastmessage(int gid, int uid, int* unread) = 0;
		virtual FINDREC find_summary(int gid) = 0;

		virtual FINDREC find_user(int gid, int uid) = 0;
		virtual bool update_user_geo(int token, const char* disp, int* lastid) = 0;
		virtual bool update_user_img(int gid, int uid, const char* img, const char* nicknm, int* lastid) = 0;
		virtual bool create_user(int gid, int token, const char* name, const char* img, int* lastid) = 0;
		virtual bool remove_user(int gid, int uid, int* lastid) = 0;

		virtual FINDREC find_group(int gid) = 0;
		virtual bool create_group(const char* name, const char* img, int* lastid) = 0;
		virtual bool remove_group(int gid, int* lastid) = 0;
	};
}

#endif

