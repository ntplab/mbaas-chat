import Foundation

// ユーザ：モデル
public class UserModel : BaseModel {
    public static let DISP: Int = 0
    private var disp_: String = ""

    public class func create(dic: NSDictionary!) -> UserModel!{
        return UserModel(dic: dic)
    }
    override public init(dic: NSDictionary!){
        var swdic: Dictionary = dic as Dictionary
        self.disp_ = swdic["disp"] as! String
        super.init(dic: dic)
    }
    
    // ユーザモデルでのオーバーライド
    public override func get(typeid: Int) -> AnyObject{
        if typeid == UserModel.DISP{
            return disp_
        }
        return 0
    }
    public override func set(typeid: Int, value: AnyObject){
        if typeid == UserModel.DISP{
            if value is String{
                disp_ = value as! String
            }
        }
    }
}