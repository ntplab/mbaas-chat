#ifndef MB_DEF_H_H
#define MB_DEF_H_H

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <sys/select.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/mount.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <net/if.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include <math.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <stdarg.h>
#include <signal.h>
#include <dirent.h>

#include <semaphore.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/shm.h>
#include <pthread.h>

// for stl.
#include <string>
#include <vector>
#include <map>
#include <regex>
#include <chrono>


// for boost
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/ini_parser.hpp>
#include <boost/optional.hpp>
#include <boost/thread.hpp>

#include <util/c99defs.h>


/*! @name basic defineded... */
/* @{ */
#define		RET_OK			(0)						/*!< 処理結果：成功 */
#define		RET_NG			(-1)					/*!< 処理結果：エラー */


#ifndef INVALID_SOCKET
#define	INVALID_SOCKET	((int)0xffffffff)		/*!< ソケット：エラー */
#endif
#ifndef INVALID_HANDLE
#define	INVALID_HANDLE	((int)0xffffffff)		/*!< 汎用    ：エラー */
#endif
#ifndef INVALID_FILE
#define	INVALID_FILE	INVALID_HANDLE			/*!< ファイル：エラー */
#endif

#ifndef ULONGLONG
#define ULONGLONG unsigned long long		/*!< 64 bits ：整数値 */
#endif
#ifndef ULONG
#define ULONG unsigned long					/*!< 32 bits ：整数値 */
#endif
#define LISTENQ (256)

#ifndef MIN
#define MIN(a,b) (a<b?a:b)
#endif
#ifndef MAX
#define MAX(a,b) (a>b?a:b)
#endif

/* @} */


/////////////////////////////////////
// macro's
/////////////////////////////////////
#define PRINTPT			{pthread_t pt = pthread_self();unsigned char *pc = (unsigned char*)(void*)(&pt);for(size_t n=0;n<sizeof(pt);n++){printf("%02x",(unsigned)(pc[n]));}}

#define _DEBUG_PRINT
#define _INFO_PRINT
#define OSX
#ifdef OSX
#define LOGERR(args...)		{printf("%06d-%06d:",mbutil::yymmdd(),mbutil::hhmmss());printf("<ERR>  : " args);printf("<<");PRINTPT;printf(":%08u>>%s(%d)\n",getpid(),__FILE__,__LINE__);fflush(stdout);}
#define LOGWARN(args...)	{printf("%06d-%06d:",mbutil::yymmdd(),mbutil::hhmmss());printf("<WARN> : " args);printf("<<");PRINTPT;printf(":%08u>>%s(%d)\n",getpid(),__FILE__,__LINE__);fflush(stdout);}
#ifdef _INFO_PRINT
	#define LOGINFO(args...)	{printf("%06d-%06d:",mbutil::yymmdd(),mbutil::hhmmss());printf("<INFO> : " args);printf("<<");PRINTPT;printf("%08u>>%s(%d)\n",getpid(),__FILE__,__LINE__);fflush(stdout);}
#else
	#define LOGINFO(args...)	{void(0);}
#endif
#ifdef _DEBUG_PRINT
	#define LOGDEBUG(args...)	{printf("%06d-%06d:",mbutil::yymmdd(),mbutil::hhmmss());printf("<DEBUG>: " args);printf("<<");PRINTPT;printf("%08u>>\n",getpid());fflush(stdout);}
#else
	#define LOGDEBUG(args...)	{void(0);}
#endif
#endif

/////////////////////////////////////
// inline function's
/////////////////////////////////////

namespace mbutil{
// for thread safe..
	extern pthread_mutex_t	__global_str_safe_muex;
// for main loop flags.
	extern int __halt_process;
// モジュールハンドル
	typedef struct mb{
		char* 		cfg;
		char*		host;
		char*		db;
		char*		dbcon;
		uint16_t	port;
		int			thread;
		int			loglevel;
		pthread_t	threadid;
		void*		app;
		pid_t 		pid;
		char*		appid;
	}mb_t,*mb_ptr;

// 終了待機
	inline int is_halt(mb_ptr coco){
		pthread_join(coco->threadid, NULL);
		__halt_process = RET_NG;
		return(__halt_process);
	}

/**
   snprintf：スレッドセーフ：インライン\n
   *******************************************************************************

   *******************************************************************************
   @param[in]     str      snprintfと同一
   @param[in]     size     snprintfと同一
   @param[in]     fmt      snprintfと同一
   @return        snprintfと同一
 */
	inline int safe_snprintf(char* str,size_t size,const char* fmt,...){
		int ret = -1;
		pthread_mutex_lock(&__global_str_safe_muex);
		{
			va_list		args;
			va_start(args,fmt);
			ret = vsnprintf(str,size,fmt,args);
			va_end(args);
		}
		pthread_mutex_unlock(&__global_str_safe_muex);
		return(ret);
	}
/** *************************************************************
 * クロックタイマー
 * @result  sec * 1000 + msec / 1000
 ************************************************************* */
	inline double clock(void)
	{
		struct timeval	tv;
		gettimeofday(&tv,NULL);
		return((((double)tv.tv_sec * 1000.0e0) + ((double)tv.tv_usec * 0.001e0)));
	}

/** *************************************************************
 * 日付
 * @result  yymmdd
 ************************************************************* */
	inline int yymmdd(void)
	{
		time_t	tmt;
		struct tm stm;
		time(&tmt);
		memset(&stm,0,sizeof(struct tm));
		localtime_r(&tmt,&stm);
		return(((stm.tm_year + 1900) % 100) 	* 10000 +
			   (stm.tm_mon + 1) 	* 100 +
			   (stm.tm_mday));
	}

/** *************************************************************
 * 日付（yyyymm）
 * @result  yyyymm
 ************************************************************* */
	inline int yyyymm(void)
	{
		time_t	tmt;
		struct tm stm;
		time(&tmt);
		memset(&stm,0,sizeof(struct tm));
		localtime_r(&tmt,&stm);
		return(((stm.tm_year + 1900)) * 100 + (stm.tm_mon + 1));
	}
/** *************************************************************
 * 日付（yyyymm）を任意UNIX-TIME-STAMPで文字列取得
 * @param[in] trgttm   ユニックスタイムスタンプ
 * @result  yyyymm の文字列
 ************************************************************* */
	inline std::string yyyymm_with_unix_time(time_t trgttm){
		struct tm	stm;
		std::string	ret;
		char		bf[64] = {0x00};
		//
		memset(&stm,0,sizeof(struct tm));
		localtime_r(&trgttm,&stm);
		// 書式化
		safe_snprintf(bf,sizeof(bf) - 1,"%04d%02d",
					  stm.tm_year + 1900,
					  stm.tm_mon + 1
		);
		ret = bf;
		return(ret);
	}


/** *************************************************************
 * 日付（Y-M-d H:i:s） SQLでそのまま利用できる日付フォーマット
 * @param[in] trgttm   ユニックスタイムスタンプ
 * @result  Y-M-D H:i:s
 ************************************************************* */
	inline std::string sql_datetime_ymdhis(time_t trgttm){
		struct tm	stm;
		std::string	ret;
		char		bf[64] = {0x00};
		//
		memset(&stm,0,sizeof(struct tm));
		localtime_r(&trgttm,&stm);
		// 書式化
		safe_snprintf(bf,sizeof(bf) - 1,"'%04d-%02d-%02d %02d:%02d:%02d'",
					  stm.tm_year + 1900,
					  stm.tm_mon + 1,
					  stm.tm_mday,
					  stm.tm_hour,
					  stm.tm_min,
					  stm.tm_sec
		);
		ret = bf;
		return(ret);
	}

/** *************************************************************
 * SQL組み立て時の['"\] 等のエスケープ処理
 * @param[in]  src    ソース文字列
 * @result  エスケープ後の文字列
 ************************************************************* */
	inline std::string sql_addslashes(const char* src){
		std::string	ret;
		int			srclen,n;
		char		bf[8] = {0x00};

		// 引数チェック
		if (!src){ return(ret); }
		srclen = strlen(src);
		if (!srclen){ return(ret); }

		for(n = 0;n < srclen;n++){
			memset(bf,0,sizeof(bf));

			switch(src[n]){
				case '\0':
					bf[0] = '\\';
					bf[1] = '0';
					//
					ret	+= bf;
					break;
				case '\'':
				case '\"':
				case '\\':
					bf[0] = '\\';
					//
					ret	+= bf;
				default:
					bf[0] = src[n];
					ret	+= bf;
					break;
			}
		}
		return(ret);
	}


/** *************************************************************
 * 時刻
 * @result  hhmmss
 ************************************************************* */
	inline int hhmmss(void)
	{
		time_t	tmt;
		struct tm stm;
		time(&tmt);
		memset(&stm,0,sizeof(struct tm));
		localtime_r(&tmt,&stm);
		return((stm.tm_hour) 				* 10000 +
			   (stm.tm_min) 	* 100 +
			   (stm.tm_sec));
	}
/** *************************************************************
 * ファイル存在チェック＋サイズ取得
 * @param[in]     path  パス
 * @param[in,out] size  ファイルのサイズ
 * @result  RET_OK=存在、RET_OK!=見つからない
 ************************************************************* */
	inline int is_exists(const char* path,ULONGLONG* size){
		struct stat		st;
		if (!path || !size)	return(RET_NG);
		if (stat(path,&st) == INVALID_FILE){
			return(RET_NG);
		}
		(*size) = (ULONGLONG)st.st_size;
		return(RET_OK);
	}

/** *************************************************************
 * ディレクトリ存在チェック
 * @param[in]     path  パス
 * @result  RET_OK=存在、RET_OK!=見つからない（ファイルなし等）
 ************************************************************* */
	inline int is_exists_dir(const char* path){
		struct stat		st;
		if (!path)	return(RET_NG);
		if (stat(path,&st) == INVALID_FILE){
			return(RET_NG);
		}
		return(S_ISDIR(st.st_mode)?RET_OK:RET_NG);
	}
#define INIGET(t,k,v)   {if (boost::optional<t> val = pt.get_optional<t>(k)) { v = val.get();} }
/** *************************************************************
 * 実行時パラメータ
 * @result  mb_ptr
 ************************************************************* */
	inline mb_ptr init_mb(int argc, char* argv[]){
		ULONGLONG fsz = 0;
		char c,cfg[256] = {0x00};
		mb_ptr pmb = NULL;
		//
		while ((c = getopt(argc, argv,"c:")) != -1){
			switch(c) {
				case 'c':        // config file
					if (optarg) { strncpy(cfg, optarg, MIN(255, strlen(optarg))); }
					break;
				default:
					break;
			}
		}
		// required : config file
		if (is_exists(cfg, &fsz) != RET_OK) {
			LOGERR("failed. missing config file(%s)", cfg)
			return(NULL);
		}
		uint16_t port = 8080;
		uint16_t concurrency = 1;
		int loglevel = 0;
		std::string host = "127.0.0.1";
		std::string db = "sqlite";
		std::string dbcon = "sqlite.db";
		std::string appid = "appid-dummy";
		//
		boost::property_tree::ptree pt;
		read_ini(cfg, pt);
		//
		INIGET(uint16_t,"MB.PORT",port);
		INIGET(uint16_t,"MB.THREAD",concurrency);
		INIGET(std::string,"MB.HOST",host);
		INIGET(std::string,"MB.DB",db);
		INIGET(std::string,"MB.DBCON",dbcon);
		INIGET(std::string,"MB.APPID",appid);
		INIGET(int,"MB.LOGLEVEL",loglevel);


		pmb = (mb_ptr)malloc(sizeof(mb_t));
		memset(pmb, 0, sizeof(mb_t));
		pmb->cfg = strdup(cfg);
		pmb->host = strdup(host.c_str());
		pmb->db = strdup(db.c_str());
		pmb->dbcon = strdup(dbcon.c_str());
		pmb->appid = strdup(appid.c_str());
		pmb->port = port;
		pmb->thread = concurrency;
		pmb->loglevel = loglevel;
		pmb->pid = getpid();
		//
		return(pmb);
	}
	inline mb_ptr start_application(int argc,char* argv[]){
		pthread_mutex_init(&__global_str_safe_muex,NULL);
		mb_ptr p = init_mb(argc, argv);
		if (p){
			LOGINFO("host : %s", p->host);
			LOGINFO("db   : %s", p->db);
			LOGINFO("dbcn : %s", p->dbcon);
			LOGINFO("port : %d", p->port);
			LOGINFO("log  : %d", p->loglevel);
			LOGINFO("appid: %s", p->appid);
		}else{
			LOGERR("missing config.");
		}
		return(p);
	}
	inline void release_application(mb_ptr pmb){
		if (pmb){
			if (pmb->cfg){ free(pmb->cfg); }
			if (pmb->host){ free(pmb->host); }
			if (pmb->db){ free(pmb->db); }
			if (pmb->dbcon){ free(pmb->dbcon); }
			if (pmb->appid){ free(pmb->appid); }
			free(pmb);
		}
	}
	// パラメータコンテナ
	class MbPlaceHolder {
	public:
		enum MbPlaceHolderType{
			TypeDc,
			TypeInt,
			TypeStr,
			TypeDbl
		};
		std::map<std::string, std::tuple<MbPlaceHolderType,std::string, ULONGLONG, double> > placeholder_;
		typedef std::map<std::string, std::tuple<MbPlaceHolderType,std::string, ULONGLONG, double> >::iterator ITRTPL;
	public:
		MbPlaceHolder() { }
		~MbPlaceHolder() { }
	public:
		void clear(void){
			std::map<std::string, std::tuple<MbPlaceHolderType,std::string, ULONGLONG, double> > nullmap;
			placeholder_.swap(nullmap);
		}
		void set(const char *key, const char *val) {
			placeholder_[std::string(key)] = std::tuple<MbPlaceHolderType,std::string, ULONGLONG, double>(TypeStr,std::string(val), 0, 0.0e0);
		}
		void set(const char *key, int val) {
			placeholder_[std::string(key)] = std::tuple<MbPlaceHolderType,std::string, ULONGLONG, double>(TypeInt,std::string(""), val, 0.0e0);
		}
		void set(const char *key, double val) {
			placeholder_[std::string(key)] = std::tuple<MbPlaceHolderType,std::string, ULONGLONG, double>(TypeDbl,std::string(""), 0, val);
		}
		std::vector<std::string> getKeys(void){
			std::vector<std::string> keys;
			ITRTPL itr;
			for(itr = placeholder_.begin();itr != placeholder_.end();++itr){
				keys.push_back((itr->first));
			}
			return(keys);
		}
		MbPlaceHolderType getType(const char* key){
			ITRTPL itr;
			if ((itr = placeholder_.find(std::string(key))) == placeholder_.end()) {
				return (TypeDc);
			} else {
				return (std::get<0>(itr->second));
			}
		}
		std::string getS(const char *key) {
			ITRTPL itr;
			if ((itr = placeholder_.find(std::string(key))) == placeholder_.end()) {
				return (std::string(""));
			} else {
				return (std::get<1>(itr->second));
			}
		}

		ULONGLONG getN(const char *key) {
			ITRTPL itr;
			if ((itr = placeholder_.find(std::string(key))) == placeholder_.end()) {
				return (0);
			} else {
				return (std::get<2>(itr->second));
			}
		}
		double getF(const char *key) {
			ITRTPL itr;
			if ((itr = placeholder_.find(std::string(key))) == placeholder_.end()) {
				return (0.0e0);
			} else {
				return (std::get<3>(itr->second));
			}
		}
	};

};
#endif // MB_DEF_H_H

