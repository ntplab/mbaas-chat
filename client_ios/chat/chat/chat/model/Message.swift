import Foundation
import UIKit

// メッセージ：モデル
public class MessageModel : BaseModel {
    public static let MSG: Int = 0
    public static let UID: Int = 1
    
    private var uimg_: String = ""
    private var msg_: String = ""
    private var name_: String = ""
    private var uid_: Int = 0
    
    public class func create(dic: NSDictionary!) -> MessageModel!{
        return MessageModel(dic: dic)
    }
    //
    override public init(dic: NSDictionary!){
        var swdic: Dictionary = dic as Dictionary
        self.uimg_ = swdic["uimg"] as! String
        self.msg_ = swdic["msg"] as! String
        self.name_ = swdic["uname"] as! String
        self.uid_ = swdic["uid"] as! Int
        super.init(dic: dic)
    }
    public override func getImg() -> String { return uimg_ }
    public override func getName() -> String { return name_ }
    public override func get(typeid: Int) -> AnyObject{
        if typeid == MessageModel.MSG{
            return msg_
        }else if typeid == MessageModel.UID{
            return uid_
        }
        return 0
    }
    public func buildMessage() -> NSAttributedString {
        let messageAttribute: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(MessageViewCell.kMessageFontSize), NSForegroundColorAttributeName: MbUtils.UIColorFromRGB(0x3d3d3d)]
        let urlAttribute: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(MessageViewCell.kMessageFontSize), NSForegroundColorAttributeName: MbUtils.UIColorFromRGB(0x2981e1)]
        let blockMark: String = ""
        
        let messageLbl: String = self.msg_
        var message: NSString = NSString.init(format: "%@%@", messageLbl, blockMark).stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}")
        let url = MbUtils.getUrlFromstring(messageLbl)
        var urlRange: NSRange?
        if url.characters.count > 0 {
            urlRange = message.rangeOfString(url)
        }
        message = message.stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}")
        message = message.stringByReplacingOccurrencesOfString("-", withString: "\u{2011}")
        
        let attributedMessage: NSMutableAttributedString = NSMutableAttributedString.init(string: message as String)
        let messageRange: NSRange = NSMakeRange(0, messageLbl.characters.count)
        
        attributedMessage.beginEditing()
        attributedMessage.setAttributes(messageAttribute, range: messageRange)
        if url.characters.count > 0 {
            attributedMessage.setAttributes(urlAttribute, range: urlRange!)
        }
        attributedMessage.endEditing()
        
        return attributedMessage
    }
    public func getViewCellHeight() -> CGFloat{
        let nickname: String = self.name_
        var messageRect: CGRect?
        var nicknameRect: CGRect?
        let attributedMessage: NSAttributedString = self.buildMessage()
        let nicknameAttribute: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(12.0)]
        let attributedNickname: NSAttributedString = NSAttributedString.init(string: nickname, attributes: nicknameAttribute)
        
        messageRect = attributedMessage.boundingRectWithSize(CGSizeMake(MessageViewCell.kMessageMaxWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        nicknameRect = attributedNickname.boundingRectWithSize(CGSizeMake(MessageViewCell.kMessageMaxWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        let height: CGFloat = nicknameRect!.size.height + messageRect!.size.height + MessageViewCell.kMessageCellTopMargin + MessageViewCell.kMessageCellBottomMargin + MessageViewCell.kMessageBalloonBottomPadding + MessageViewCell.kMessageBalloonTopPadding
        return height
    }
    
}