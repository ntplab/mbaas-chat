import UIKit

public class MessageViewCell: UITableViewCell {
    public static let kMessageCellTopMargin: CGFloat = 14
    public static let kMessageCellBottomMargin: CGFloat = 0
    public static let kMessageCellLeftMargin: CGFloat = 12
    public static let kMessageFontSize: CGFloat = 14.0
    public static let kMessageBalloonTopPadding: CGFloat = 12
    public static let kMessageBalloonBottomPadding: CGFloat = 12
    public static let kMessageBalloonLeftPadding: CGFloat = 60
    public static let kMessageBalloonRightPadding: CGFloat = 12
    public static let kMessageMaxWidth: CGFloat = 248
    public static let kMessageProfileHeight: CGFloat = 36
    public static let kMessageProfileWidth: CGFloat = 36
    public static let kMessageDateTimeLeftMarign: CGFloat = 4
    public static let kMessageDateTimeFontSize: CGFloat = 10.0
    public static let kMessageNicknameFontSize: CGFloat = 10.0
    
    var messageImageView_: UIImageView?
    var messageBackImageView_: UIImageView?
    var messageLabel_: UILabel?
    var messageNicknameLabel_: UILabel?
    var messageUnreadLabel_: UILabel?
    private var topMargin: CGFloat?
    
    var groupId_: Int?
    var groupUnreadCount: Int = 0
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.topMargin = MessageViewCell.kMessageCellTopMargin
        self.initViews()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initViews() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.contentView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        
        // メッセージアイコン
        self.messageImageView_ = UIImageView()
        self.messageImageView_?.translatesAutoresizingMaskIntoConstraints = false
        self.messageImageView_?.clipsToBounds = true
        self.messageImageView_?.layer.cornerRadius = (MessageViewCell.kMessageProfileHeight / 2)
        self.messageImageView_?.contentMode = UIViewContentMode.ScaleAspectFill
        self.contentView.addSubview(self.messageImageView_!)
        
        // 吹き出し背景
        self.messageBackImageView_ = UIImageView()
        self.messageBackImageView_?.translatesAutoresizingMaskIntoConstraints = false
        self.messageBackImageView_?.image = UIImage.init(named: "_bg_chat_bubble_gray")
        self.addSubview(self.messageBackImageView_!)
        
        // ニックネームラベル
        self.messageNicknameLabel_ = UILabel()
        self.messageNicknameLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.messageNicknameLabel_?.font = UIFont.systemFontOfSize(MessageViewCell.kMessageNicknameFontSize)
        self.messageNicknameLabel_?.numberOfLines = 1
        self.messageNicknameLabel_?.textColor = MbUtils.UIColorFromRGB(0xa792e5)
        self.messageNicknameLabel_?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.addSubview(self.messageNicknameLabel_!)
        
        // メッセージラベル
        self.messageLabel_ = UILabel()
        self.messageLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel_?.font = UIFont.systemFontOfSize(MessageViewCell.kMessageFontSize)
        self.messageLabel_?.numberOfLines = 0
        self.messageLabel_?.textColor = MbUtils.UIColorFromRGB(0x3d3d3d)
        self.messageLabel_?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.addSubview(self.messageLabel_!)
        
        // 未読ラベル
        self.messageUnreadLabel_ = UILabel()
        self.messageUnreadLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.messageUnreadLabel_?.font = UIFont.systemFontOfSize(24.0)
        self.messageUnreadLabel_?.textColor = MbUtils.UIColorFromRGB(0x000000)
        self.messageUnreadLabel_?.textAlignment = NSTextAlignment.Left
        self.messageUnreadLabel_?.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.contentView.addSubview(self.messageUnreadLabel_!)
        //
        self.applyConstraints()
    }
    
    private func applyConstraints() {
        // Profile Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.messageImageView_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -MessageViewCell.kMessageCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageImageView_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: MessageViewCell.kMessageCellLeftMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageImageView_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: MessageViewCell.kMessageProfileWidth))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageImageView_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: MessageViewCell.kMessageProfileHeight))
        
        // Nickname Label
        self.addConstraint(NSLayoutConstraint.init(item: self.messageNicknameLabel_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageLabel_!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageNicknameLabel_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: MessageViewCell.kMessageBalloonLeftPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageNicknameLabel_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: MessageViewCell.kMessageMaxWidth))
        
        // Message Label
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -MessageViewCell.kMessageBalloonBottomPadding - MessageViewCell.kMessageCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: MessageViewCell.kMessageBalloonLeftPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: MessageViewCell.kMessageMaxWidth))
        
        // Message Background Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackImageView_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -MessageViewCell.kMessageCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackImageView_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: MessageViewCell.kMessageBalloonLeftPadding - 16))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackImageView_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.messageLabel_!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: MessageViewCell.kMessageBalloonRightPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackImageView_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.messageNicknameLabel_!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: MessageViewCell.kMessageBalloonRightPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackImageView_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.messageNicknameLabel_!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -MessageViewCell.kMessageBalloonTopPadding))
        
        
        // 未読数表示のイメージ
        self.addConstraint(NSLayoutConstraint.init(item: self.messageUnreadLabel_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageUnreadLabel_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageUnreadLabel_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 12))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageUnreadLabel_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 12))
    }
    func setModel(model: MessageModel) {
        self.messageNicknameLabel_?.text = model.getName()
        self.groupId_ = model.getId()
        let msg = model.get(MessageModel.MSG)
        self.messageLabel_?.text = msg as? String
        MbUtils.loadImage(model.getImg(), imageView: self.messageImageView_!, width: MessageViewCell.kMessageProfileWidth, height: MessageViewCell.kMessageProfileHeight)
    }
}
