import Foundation


public class JobQueue: NSObject{
    static var JOB_QUEUE_: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    private var queue_: NSMutableArray?
    // 
    class var instance: JobQueue{
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : JobQueue? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = JobQueue()
        }
        return Static.instance!
    }
    public override init(){
        super.init()
        //
        objc_sync_enter(self);
        self.queue_ = NSMutableArray()
        objc_sync_exit(self);
    }
    public func enqueue(job: BaseJob) {
        objc_sync_enter(self);
        self.queue_?.addObject(job)
        objc_sync_exit(self);
        //
        dequeue({(dqjob:BaseJob!)->Void in
            dqjob.exec()
        })
    }
    private func dequeue(onJob: ((item: BaseJob!) -> Void)!) {
        dispatch_async(JobQueue.JOB_QUEUE_,{
            objc_sync_enter(self);
            let job = self.queue_?.objectAtIndex(0)
            if job != nil{
                self.queue_?.removeObjectAtIndex(0)
            }
            objc_sync_exit(self);
            onJob(item: job as! BaseJob)
        })
    }
}

