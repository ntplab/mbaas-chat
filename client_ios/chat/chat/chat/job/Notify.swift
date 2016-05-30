import Foundation


// イベント受信ジョブ
public class NotifyJob : BaseJob {
    var notifyjobDelegate_: JobDelegate!
    var dic_ : NSDictionary!
    var stat_: Int!
    //
    public class func start(dic: NSDictionary!, delegate: JobDelegate!) -> NotifyJob{
        let job = NotifyJob()
        job.notifyjobDelegate_ = delegate
        job.dic_ = dic
        job.stat_ = 0
        return job
    }
    public func pause(){
        self.stat_ = 0
    }
    public func resume(){
        if self.stat_ == 0{
            self.stat_ = 1
            JobQueue.instance.enqueue(self)
        }
    }
    public override func exec() -> Void {
        if self.stat_ == 0{
            NSLog("pause now.(%p)", self)
        }else{
            MbUtils.observeEvent(self, onEnd: {(job: AnyObject, response: NSDictionary!, error: NSError!) -> Void in
                if error == nil {
                    let stat = response.objectForKey("stat")
                    let mid  = response.objectForKey("lastid")
                    let gid  = response.objectForKey("gid")
                    
                    if stat is Int && mid is Int && gid is Int{
                        if (stat as! Int) == 3 && (mid as! Int) != 0{
                            let jobif = job as! NotifyJob
                            jobif.notifyjobDelegate_.notifyJobEvent(JobDelegateType.EventNotify,argtype: 0,opt: (gid as! Int),value: nil)
                        }
                    }
                }
                // 継続する
                JobQueue.instance.enqueue(job as! NotifyJob)
            })
        }
    }
}