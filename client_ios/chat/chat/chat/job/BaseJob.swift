import Foundation

public enum JobDelegateType{
    case FoundUserId
    case FoundGroupModel
    case FoundGroupModelCompleted
    case FoundGroupSummary
    case FoundGroupSummryCompleted
    case FoundMessage
    case FoundMessageCompleted
    case CreatedMessageCompleted
    case CreateGroupCompleted
    case EventNotify
}
public protocol JobDelegate {
    func notifyJobEvent(eventtype: JobDelegateType, argtype: Int, opt: Int, value: AnyObject? )
}

// ジョブがインプリメントすべきインタフェイス
protocol JobProtocol{
    func prepare() -> Void
    func exec() -> Void
    func post() -> Void
}
// ジョブの基本クラス
public class BaseJob : NSObject,JobProtocol{
    private var nextjob_: BaseJob?
    
    public override init(){
        super.init()
    }
    public func nextJob()->BaseJob?{
        return nextjob_
    }
    public func addChild(nextjob :BaseJob){
        nextjob_ = nextjob
    }
    func prepare() -> Void{  }
    func post() -> Void{  }
    func exec() -> Void{  }
}
