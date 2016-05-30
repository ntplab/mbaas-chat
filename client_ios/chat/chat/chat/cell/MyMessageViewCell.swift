import UIKit

public class MyMessageViewCell: UITableViewCell {
    public static let kMyMessageCellTopMargin: CGFloat = 14
    public static let kMyMessageCellBottomMargin: CGFloat = 0
    public static let kMyMessageCellLeftMargin: CGFloat = 12
    public static let kMyMessageBalloonRightMargin: CGFloat = 12
    public static let kMyMessageCellRightMargin: CGFloat = 32
    public static let kMyMessageFontSize: CGFloat = 14.0
    public static let kMyMessageBalloonTopPadding: CGFloat = 12
    public static let kMyMessageBalloonBottomPadding: CGFloat = 12
    public static let kMyMessageBalloonLeftPadding: CGFloat = 12
    public static let kMyMessageBalloonRightPadding: CGFloat = 12
    public static let kMyMessageMaxWidth: CGFloat = 168
    public static let kMyMessageDateTimeRightMarign: CGFloat = 4
    public static let kMyMessageDateTimeFontSize: CGFloat = 10.0
    public static let kMyMessageUnreadFontSize: CGFloat = 10.0
    
    var messageBackImageView_: UIImageView?
    var messageLabel_: UILabel?
    var messageUnreadLabel_: UILabel?
    private var topMargin: CGFloat?
    
    var groupId_: Int?
    var groupUnreadCount: Int = 0
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.topMargin = MyMessageViewCell.kMyMessageCellTopMargin
        self.initViews()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initViews() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.contentView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        
        // 吹き出し背景
        self.messageBackImageView_ = UIImageView()
        self.messageBackImageView_?.translatesAutoresizingMaskIntoConstraints = false
        self.messageBackImageView_?.image = UIImage.init(named: "_bg_chat_bubble_purple")
        self.addSubview(self.messageBackImageView_!)
        
        // メッセージラベル
        self.messageLabel_ = UILabel()
        self.messageLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel_?.font = UIFont.systemFontOfSize(MyMessageViewCell.kMyMessageFontSize)
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
        // メッセージ
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackImageView_!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -MyMessageViewCell.kMyMessageBalloonBottomPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -MyMessageViewCell.kMyMessageCellRightMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: MyMessageViewCell.kMyMessageMaxWidth))
        
        // 吹き出し背景
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackImageView_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -MyMessageViewCell.kMyMessageCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackImageView_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.messageLabel_!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -MyMessageViewCell.kMyMessageBalloonLeftPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackImageView_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -MyMessageViewCell.kMyMessageBalloonRightMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackImageView_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.messageLabel_!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -MyMessageViewCell.kMyMessageBalloonTopPadding))
        
        // 未読数表示のイメージ
        self.addConstraint(NSLayoutConstraint.init(item: self.messageUnreadLabel_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageUnreadLabel_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageUnreadLabel_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 12))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageUnreadLabel_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 12))
    }
    func setModel(model: MessageModel) {
        self.groupId_ = model.getId()
        let msg = model.get(MessageModel.MSG)
        self.messageLabel_?.text = msg as? String
    }
}
