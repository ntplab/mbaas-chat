import Foundation

// データプレースホルダの基本クラス
public class BaseModel : NSObject{
    private var id_: Int = 0
    private var name_: String = ""
    private var img_: String = ""
    private var chan_: String = ""
    private var ts_: Int = 0
    private var height_: Float = 0.0
    
    public override init(){
        super.init()
    }
    private init(id: Int, name: String, img: String, chan: String, ts: Int){
        id_ = id
        ts_ = ts
        height_ = 0.0
        name_ = name
        img_ = img
        chan_ = chan
        super.init()
    }
    public init(dic: NSDictionary!){
        super.init()
        update(dic)
    }
    // 汎用インタフェイス(オーバーライド用)
    public func get(typeid: Int) -> AnyObject{ return 0 }
    public func set(typeid: Int, value: AnyObject){}
    // 共通関数群
    public func getImg() -> String { return img_ }
    public func getName() -> String { return name_ }
    public func getId() -> Int { return id_ }
    public func getChan() -> String { return chan_ }
    public func getTs() -> Int { return ts_ }
    public func setHeight(height: Float){ height_ = height }
    public func getHeight() -> Float { return height_ }
    public func update(dic: NSDictionary){
        if dic["id"] != nil{
            id_ = dic.valueForKey("id") as! Int
        }else{
            id_ = 0
        }
        if dic["name"] != nil{
            name_ = dic.valueForKey("name") as! String
        }else{
            name_ = ""
        }
        if dic["img"] != nil{
            img_ = dic.valueForKey("img") as! String
        }else{
            img_ = ""
        }
        if dic["chan"] != nil{
            chan_ =  dic.valueForKey("chan") as! String
        }else{
            chan_ = ""
        }
        if dic["ts"] != nil{
            ts_ = dic.valueForKey("ts") as! Int
        }else{
            ts_ = 0
        }
        height_ = 0.0
    }
}
