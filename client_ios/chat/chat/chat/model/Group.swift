import Foundation


// グループ：モデル
public class GroupModel : BaseModel {
    public static let LASTMSG: Int = 0
    public static let UNREADCNT: Int = 1
    public static let USER: Int = 2
    private var gname_: String = ""
    private var unread_: Int = 0
    private var lastmsg_: String = ""
    private var users_:[UserModel] = []
    //
    public override init(){
        super.init()
    }
    override public init(dic: NSDictionary!){
        var swdic: Dictionary = dic as Dictionary
        self.gname_ = swdic["gname"] as! String
        super.init(dic: dic)
    }
    public class func create(dic: NSDictionary!) -> GroupModel!{
        return GroupModel(dic: dic)
    }
    // グループモデルでのオーバーライド
    public override func getHeight() -> Float {
        let h = super.getHeight()
        return (h + (Float(users_.count) * (h/2.0)))
    }
    public override func get(typeid: Int) -> AnyObject{
        // グループ最終メッセージ、グループメッセージ未読数の個別取得
        if typeid == GroupModel.LASTMSG{
            return lastmsg_
        }else if typeid == GroupModel.UNREADCNT{
            return unread_
        }else if typeid == GroupModel.USER{
            return users_
        }
        return 0
    }
    public override func set(typeid: Int, value: AnyObject){
        // グループ最終メッセージ、グループメッセージ未読数の個別更新
        if typeid == GroupModel.LASTMSG{
            if value is String{
                lastmsg_ = value as! String
            }
        }else if typeid == GroupModel.UNREADCNT{
            if value is Int{
                unread_ = value as! Int
            }
        }else if typeid == GroupModel.USER{
            if value is UserModel{
                let usermodel = value as! UserModel
                for i in 0..<users_.count {
                    if users_[i].getId() == usermodel.getId(){
                        users_[i] = usermodel
                        return
                    }
                }
                users_.append(value as! UserModel)
            }
        }
    }
    public override func getName() -> String { return gname_ }
    public override func update(dic: NSDictionary){
        super.update(dic)
        var swdic: Dictionary = dic as Dictionary
        if let unread = swdic["unread"]{
            if unread is Int{
                self.unread_ = unread as! Int
            }
        }
        if let lastmsg = swdic["lastmsg"]{
            if lastmsg is String{
                self.lastmsg_ = lastmsg as! String
            }
        }
    }
}
