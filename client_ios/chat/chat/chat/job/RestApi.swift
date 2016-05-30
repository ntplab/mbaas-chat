import Foundation


// RestApiジョブ
public class RestApiJob : BaseJob {
    var restapijobDelegate_: JobDelegate!
    var callback_: ((dic: NSDictionary!, job: RestApiJob!) -> Void)!
    var dic_ : NSDictionary!
    //
    public class func start(dic: NSDictionary!, delegate: JobDelegate!, callback: ((dic: NSDictionary!, job: RestApiJob!) -> Void)!) -> RestApiJob{
        let job = RestApiJob()
        job.restapijobDelegate_ = delegate
        job.callback_ = callback
        job.dic_ = dic
        JobQueue.instance.enqueue(job)
        return job
    }
    public override func exec() -> Void {
        self.callback_(dic: dic_, job: self)
    }
    // ユーザid取得
    public class func findUserId(job: RestApiJob, userToken: String, userNickname: String, userImage: String){
        MbUtils.getUserIdAtMainThread(job, token: userToken, nickname: userNickname, image: userImage, onEnd: {(job: AnyObject, response: NSDictionary!, error: NSError!) -> Void in
            if error == nil {
                let stat = response.objectForKey("stat") as! Int
                let uid  = response.objectForKey("lastid")as! Int
                if stat == 0 && uid != 0{
                    MbUtils.userid(uid)
                    let jobif = job as! RestApiJob
                    jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.FoundUserId,argtype: 0,opt: uid,value: nil)
                }
            }
        })
    }
    // グループ取得
    public class func findGroups(job: RestApiJob){
        MbUtils.getGroupsAtMainThread(job, onEnd: {(job: AnyObject, response: NSDictionary!, error: NSError!) -> Void in
            if error == nil {
                let groups = response.objectForKey("groups")
                let groups_arr = groups as? NSArray
                if (groups_arr != nil){
                    let jobif = job as! RestApiJob
                    for group in groups_arr!{
                        let grpmdl = GroupModel.create(group as! NSDictionary)
                        jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.FoundGroupModel,argtype: 0,opt: 0,value: grpmdl)
                    }
                    jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.FoundGroupModelCompleted,argtype: 0,opt: 0,value: nil)
                }
            }
        })
    }
    // グループサマリ取得
    public class func findGroupSummary(job: RestApiJob, gid: Int){
        let uid = MbUtils.userid()
        MbUtils.getGroupSummaryAtMainThread(job, gid: gid, uid: uid, mid: 0, onEnd: {(job: AnyObject, response: NSDictionary!, error: NSError!) -> Void in
            if error == nil {
                print(response)
                let stat = response.objectForKey("stat") as! Int
                let unread  = response.objectForKey("unreadcnt")as! Int
                let lastmsg  = response.objectForKey("lastmsg")as! String
                var users = [NSDictionary]()
                if response.objectForKey("users") is [NSDictionary]{
                    users = response.objectForKey("users") as! [NSDictionary]
                }
                //
                if stat == 0{
                    let jobif = job as! RestApiJob
                    jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.FoundGroupSummary,argtype: GroupModel.LASTMSG, opt: gid,value: lastmsg)
                    jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.FoundGroupSummary,argtype: GroupModel.UNREADCNT, opt: gid,value: unread)
                    for user in users{
                        jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.FoundGroupSummary,argtype: GroupModel.USER, opt: gid,value: UserModel.create(user))
                    }
                    let seconds = 1.0
                    let delay = seconds * Double(NSEC_PER_SEC)
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.FoundGroupSummryCompleted,argtype: 0, opt: gid,value: nil)
                    })
                }
            }
        })
    }
    // メッセージ取得
    public class func findMessage(job: RestApiJob, gid: Int, mid: Int){
        MbUtils.getMessagesAtMainThread(job, gid: gid, mid: mid, onEnd: {(job: AnyObject, response: NSDictionary!, error: NSError!) -> Void in
            if error == nil {
                print(response)
                let stat = response.objectForKey("stat") as! Int
                var messages = [NSDictionary]()
                if response.objectForKey("messages") is [NSDictionary]{
                    messages = response.objectForKey("messages") as! [NSDictionary]
                }
                //
                if stat == 0{
                    let jobif = job as! RestApiJob
                    for message in messages{
                        print(message)
                        jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.FoundMessage,argtype: 0, opt: gid,value: MessageModel.create(message))
                    }
                    jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.FoundMessageCompleted,argtype: 0, opt: gid,value: nil)
                }
            }
        })
    }
    // メッセージ発言
    public class func createMessage(job: RestApiJob, gid: Int, msg: String){
        let uid = MbUtils.userid()
        MbUtils.createMessagesAtMainThread(job, gid: gid, uid: uid, msg: msg, onEnd: {(job: AnyObject, response: NSDictionary!, error: NSError!) -> Void in
            if error == nil {
                print(response)
                let stat = response.objectForKey("stat") as! Int
                let lastid = response.objectForKey("lastid") as! Int
                // TODO: 自分自身でviewへ追加することも可能
                if stat == 0{
                    let jobif = job as! RestApiJob
                    jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.CreatedMessageCompleted,argtype: 0, opt: lastid,value: nil)
                }
            }
        })
    }
    // グループ作成
    public class func createGroup(job: RestApiJob, name: String, image: String, uname: String, uimage: String){
        let token = MbUtils.usertoken()
        MbUtils.createGroupsAtMainThread(job, token: token, name: name, image: image, uname: uname, uimage: uimage, onEnd: {(job: AnyObject, response: NSDictionary!, error: NSError!) -> Void in
            if error == nil {
                print(response)
                let stat = response.objectForKey("stat") as! Int
                let lastid = response.objectForKey("lastid") as! Int
                if stat == 0{
                    let jobif = job as! RestApiJob
                    jobif.restapijobDelegate_.notifyJobEvent(JobDelegateType.CreateGroupCompleted,argtype: 0, opt: lastid,value: nil)
                }
            }
        })
    }
}