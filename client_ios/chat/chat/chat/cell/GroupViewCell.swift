import UIKit

public class UserInGroupContainer: NSObject{
    public static let kUserIconSz_: CGFloat = 32.0
    var trgtUiView_: UIView?
    var userImageView_: UIImageView?
    var userDispLabel_: UILabel?
    var userMessageLabel_: UILabel?
    var userModel_: UserModel?
    class func create(usermodel: UserModel, trgt:UIView)->UserInGroupContainer{
        let ret = UserInGroupContainer(trgt:trgt)
        ret.setModel(usermodel)
        ret.trgtUiView_ = trgt
        return ret
    }
    //
    init(trgt:UIView){
        self.userImageView_ = UIImageView()
        self.userImageView_?.translatesAutoresizingMaskIntoConstraints = false
        self.userImageView_?.clipsToBounds = true
        self.userImageView_?.layer.cornerRadius = (UserInGroupContainer.kUserIconSz_ / 2)
        self.userImageView_?.contentMode = UIViewContentMode.ScaleAspectFill
        trgt.addSubview(self.userImageView_!)
        
        self.userDispLabel_ = UILabel()
        self.userDispLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.userDispLabel_?.font = UIFont.systemFontOfSize(16.0)
        self.userDispLabel_?.textColor = MbUtils.UIColorFromRGB(0x646464)
        self.userDispLabel_?.textAlignment = NSTextAlignment.Left
        self.userDispLabel_?.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        trgt.addSubview(self.userDispLabel_!)
        
        self.userMessageLabel_ = UILabel()
        self.userMessageLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.userMessageLabel_?.font = UIFont.systemFontOfSize(12.0)
        self.userMessageLabel_?.textColor = MbUtils.UIColorFromRGB(0x646464)
        self.userMessageLabel_?.textAlignment = NSTextAlignment.Left
        self.userMessageLabel_?.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        trgt.addSubview(self.userMessageLabel_!)
        //
        super.init()
    }
    func applyConstraint(trgt: UIView, usercnt:Int, bottom: UIView){
        // ユーザ数に応じた比率を算出
        let userrate: CGFloat = UserInGroupContainer.kUserIconSz_ / (100.0 + (UserInGroupContainer.kUserIconSz_ * CGFloat(usercnt)))
        
        // アイコン
        trgt.addConstraint(NSLayoutConstraint.init(item: self.userImageView_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: bottom, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        trgt.addConstraint(NSLayoutConstraint.init(item: self.userImageView_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.trgtUiView_!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 12))
        trgt.addConstraint(NSLayoutConstraint.init(item: self.userImageView_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: UserInGroupContainer.kUserIconSz_))
        trgt.addConstraint(NSLayoutConstraint.init(item: self.userImageView_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: UserInGroupContainer.kUserIconSz_))
        // ユーザ住所
        trgt.addConstraint(NSLayoutConstraint.init(item: self.userDispLabel_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.userImageView_, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        trgt.addConstraint(NSLayoutConstraint.init(item: self.userDispLabel_!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.userImageView_, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 12))
        trgt.addConstraint(NSLayoutConstraint.init(item: self.userDispLabel_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.trgtUiView_!, attribute: NSLayoutAttribute.Height, multiplier: (userrate * 0.6), constant: 0))
        // ユーザ名
        trgt.addConstraint(NSLayoutConstraint.init(item: self.userMessageLabel_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.userDispLabel_!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        trgt.addConstraint(NSLayoutConstraint.init(item: self.userMessageLabel_!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.userImageView_, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 24))
        trgt.addConstraint(NSLayoutConstraint.init(item: self.userMessageLabel_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.trgtUiView_!, attribute: NSLayoutAttribute.Height, multiplier: (userrate * 0.4), constant: 0))
    }
    //
    func removeFromSuperView(){
        self.userImageView_?.removeFromSuperview()
        self.userDispLabel_?.removeFromSuperview()
        self.userMessageLabel_?.removeFromSuperview()
    }
    func setModel(usermodel: UserModel){
        let disp = usermodel.get(UserModel.DISP)
        //
        self.userDispLabel_?.text = disp as? String
        self.userMessageLabel_?.text = usermodel.getName()
        if usermodel.getImg().isEmpty{
            self.userImageView_?.image = UIImage(named: "_guest.jpeg")
            
        }else{
            MbUtils.loadImage(usermodel.getImg(), imageView: self.userImageView_!, width: UserInGroupContainer.kUserIconSz_, height: UserInGroupContainer.kUserIconSz_)
        }
    }
}

class GroupViewCell: UITableViewCell {
    
    var groupImageView_: UIImageView?
    var groupUnreadCountImageView_: UIImageView?
    var groupNameLabel_: UILabel?
    var groupLastMessageLabel_: UILabel?
    var groupUnreadCountLabel_: UILabel?
    var userInGroupContainer_: [UserInGroupContainer] = [UserInGroupContainer]()

    var groupId_: Int?
    var groupUnreadCount: Int = 0
    static let kGroupIconSz_: CGFloat = 80.0
    
    class func getViewCellHeight() -> CGFloat{
        return kGroupIconSz_
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initViews() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.contentView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 0.4
        
        // グループアイコン
        self.groupImageView_ = UIImageView()
        self.groupImageView_?.translatesAutoresizingMaskIntoConstraints = false
        self.groupImageView_?.clipsToBounds = true
        self.groupImageView_?.layer.cornerRadius = (GroupViewCell.kGroupIconSz_ / 2)
        self.groupImageView_?.contentMode = UIViewContentMode.ScaleAspectFill

        self.contentView.addSubview(self.groupImageView_!)
        
        // グループメッセージ未読数
        self.groupUnreadCountImageView_ = UIImageView()
        self.groupUnreadCountImageView_?.translatesAutoresizingMaskIntoConstraints = false
        self.groupUnreadCountImageView_?.image = UIImage.init(named: "_bg_notify")
        self.contentView.addSubview(self.groupUnreadCountImageView_!)
        
        // グループメッセージ未読数ラベル
        self.groupUnreadCountLabel_ = UILabel()
        self.groupUnreadCountLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.groupUnreadCountLabel_?.font = UIFont.systemFontOfSize(12.0)
        self.groupUnreadCountLabel_?.textColor = MbUtils.UIColorFromRGB(0xffffff)
        self.groupUnreadCountLabel_?.text = "9"
        self.contentView.addSubview(self.groupUnreadCountLabel_!)
        // グループ名
        self.groupNameLabel_ = UILabel()
        self.groupNameLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.groupNameLabel_?.font = UIFont.systemFontOfSize(24.0)
        self.groupNameLabel_?.textColor = MbUtils.UIColorFromRGB(0x000000)
        self.groupNameLabel_?.textAlignment = NSTextAlignment.Left
        self.groupNameLabel_?.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.contentView.addSubview(self.groupNameLabel_!)
        // グループ最終メッセージ
        self.groupLastMessageLabel_ = UILabel()
        self.groupLastMessageLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.groupLastMessageLabel_?.font = UIFont.systemFontOfSize(14.0)
        self.groupLastMessageLabel_?.textColor = MbUtils.UIColorFromRGB(0x646464)
        self.groupLastMessageLabel_?.textAlignment = NSTextAlignment.Left
        self.groupLastMessageLabel_?.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.contentView.addSubview(self.groupLastMessageLabel_!)
        //
        self.applyConstraints()
    }
    
    private func applyConstraints() {
        // ユーザ数に応じた比率を算出
        let grouprate: CGFloat = 100.0 / (100.0 + (UserInGroupContainer.kUserIconSz_ * CGFloat(self.userInGroupContainer_.count)))
        
        // グループアイコン
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupImageView_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupImageView_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupImageView_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: GroupViewCell.kGroupIconSz_))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupImageView_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: GroupViewCell.kGroupIconSz_))
        // グループ名称
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupNameLabel_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.groupImageView_!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupNameLabel_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.groupImageView_!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupNameLabel_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupNameLabel_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Height, multiplier: (grouprate * 0.5), constant: 0))
        // グループ最終メッセージ
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupLastMessageLabel_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.groupNameLabel_, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupLastMessageLabel_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.groupImageView_!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupLastMessageLabel_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.groupLastMessageLabel_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Height, multiplier: (grouprate * 0.4), constant: 0))
        
        // 未読数表示のイメージ
        self.addConstraint(NSLayoutConstraint.init(item: self.groupUnreadCountImageView_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.groupUnreadCountImageView_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.groupUnreadCountImageView_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 22))
        self.addConstraint(NSLayoutConstraint.init(item: self.groupUnreadCountImageView_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 22))
        
        // 未読数ラベル
        self.addConstraint(NSLayoutConstraint.init(item: self.groupUnreadCountLabel_!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.groupUnreadCountImageView_!, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.groupUnreadCountLabel_!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.groupUnreadCountImageView_!, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    func setModel(model: GroupModel) {
        self.groupNameLabel_?.text = model.getName()
        self.groupId_ = model.getId()
        let lastmsg = model.get(GroupModel.LASTMSG) as! String
        
        if lastmsg.hasPrefix(MbUtils.META_SYSMSG_PREFIX){
            self.groupLastMessageLabel_?.text = model.get(GroupModel.LASTMSG).substringFromIndex(MbUtils.META_SYSMSG_00.characters.count)
        }else{
            self.groupLastMessageLabel_?.text = lastmsg.isEmpty ? "----" : lastmsg
        }
        
        groupUnreadCount = model.get(GroupModel.UNREADCNT) as! Int
        if groupUnreadCount > 9{
            self.groupUnreadCountLabel_?.text = "9+"
        }else{
            self.groupUnreadCountLabel_?.text = String(format: "%d", groupUnreadCount)
        }
        self.groupUnreadCountImageView_?.hidden = groupUnreadCount == 0 ? true : false
        self.groupUnreadCountLabel_?.hidden = groupUnreadCount == 0 ? true : false
        
        // 可変個数ユーザサマリビューを一旦削除
        for container in self.userInGroupContainer_{
            container.removeFromSuperView()
        }
        self.userInGroupContainer_.removeAll()
        
        let users = model.get(GroupModel.USER)
        if users is [UserModel]{
            let usermodels = users as! [UserModel]
            if usermodels.count > 0{
                for usermodel in usermodels{
                    self.userInGroupContainer_.append(UserInGroupContainer.create(usermodel, trgt: self.contentView))
                }
                //
                var baseview : UIView = self.groupLastMessageLabel_!
                for idx in 0..<self.userInGroupContainer_.count{
                    self.userInGroupContainer_[idx].applyConstraint(self , usercnt: self.userInGroupContainer_.count, bottom: baseview)
                    // その下に続ける
                    baseview = self.userInGroupContainer_[idx].userImageView_!
                }
            }
        }
        applyConstraints()
        if model.getImg().isEmpty{
            self.groupImageView_?.image = UIImage(named: "_guest.jpeg")
        }else{
            MbUtils.loadImage(model.getImg(), imageView: self.groupImageView_!, width: GroupViewCell.kGroupIconSz_, height: GroupViewCell.kGroupIconSz_)
        }
    }
}
