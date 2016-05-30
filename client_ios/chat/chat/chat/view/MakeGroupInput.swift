import UIKit

protocol MakeGroupInputViewDelegate {
    func clickMakeButton(group: String)
    func clickGroupFileAttachButton()
}

class MakeGroupInputView: UIView {
    let kGroupFontSize: CGFloat = 14.0
    let kGroupMakeButtonFontSize: CGFloat = 11.0
    
    var topLineView: UIView?
    var groupTextField: UITextField?
    var makeButton: UIButton?
    var fileAttachButton: UIButton?
    
    var makeGroupInputViewDelegate: MakeGroupInputViewDelegate?
    var textFieldDelegate: UITextFieldDelegate?
    
    private var inputEnabled: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.inputEnabled = true
        
        self.backgroundColor = MbUtils.UIColorFromRGB(0xffffff)
        
        self.topLineView = UIView()
        self.topLineView?.translatesAutoresizingMaskIntoConstraints = false
        self.topLineView?.backgroundColor = MbUtils.UIColorFromRGB(0xbfbfbf)
        
        self.groupTextField = UITextField()
        self.groupTextField?.translatesAutoresizingMaskIntoConstraints = false
        self.groupTextField?.returnKeyType = UIReturnKeyType.Done
        self.groupTextField?.placeholder = "グループを追加できます"
        self.groupTextField?.textColor = MbUtils.UIColorFromRGB(0x37434f)
        self.groupTextField?.attributedPlaceholder = NSAttributedString.init(string: "グループを追加できます", attributes: [NSForegroundColorAttributeName : MbUtils.UIColorFromRGB(0xbbc3c9)])
        self.groupTextField?.font = UIFont.systemFontOfSize(kGroupFontSize)
        let paddingLeftView: UIView = UIView.init(frame: CGRectMake(0, 0, 8, 8))
        let paddingRightView: UIView = UIView.init(frame: CGRectMake(0, 0, 48, 8))
        self.groupTextField?.leftView = paddingLeftView
        self.groupTextField?.rightView = paddingRightView
        self.groupTextField?.leftViewMode = UITextFieldViewMode.Always
        self.groupTextField?.rightViewMode = UITextFieldViewMode.Always
        self.groupTextField?.layer.borderWidth = 1.0
        self.groupTextField?.layer.borderColor = MbUtils.UIColorFromRGB(0xbbc3c9).CGColor
        self.groupTextField?.addTarget(self, action: #selector(MakeGroupInputView.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        self.makeButton = UIButton()
        self.makeButton?.translatesAutoresizingMaskIntoConstraints = false
        self.makeButton?.setTitle("MAKE", forState: UIControlState.Normal)
        self.makeButton?.titleLabel?.font = UIFont.boldSystemFontOfSize(kGroupMakeButtonFontSize)
        self.makeButton?.setBackgroundImage(UIImage.init(named: "_btn_green"), forState: UIControlState.Normal)
        self.makeButton?.setBackgroundImage(UIImage.init(named: "_btn_green"), forState: UIControlState.Highlighted)
        self.makeButton?.setBackgroundImage(UIImage.init(named: "_btn_green"), forState: UIControlState.Selected)
        self.makeButton?.setBackgroundImage(UIImage.init(named: "_btn_white_line"), forState: UIControlState.Disabled)
        self.makeButton?.addTarget(self, action: #selector(MakeGroupInputView.clickMakeButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.makeButton?.alpha = 0
        self.makeButton?.enabled = false
        
        self.fileAttachButton = UIButton()
        self.fileAttachButton?.backgroundColor = UIColor.clearColor()
        self.fileAttachButton?.translatesAutoresizingMaskIntoConstraints = false
        self.fileAttachButton?.setImage(UIImage.init(named: "_btn_upload_off"), forState: UIControlState.Normal)
        self.fileAttachButton?.setImage(UIImage.init(named: "_btn_upload_on"), forState: UIControlState.Highlighted)
        self.fileAttachButton?.setImage(UIImage.init(named: "_btn_upload_on"), forState: UIControlState.Selected)
        self.fileAttachButton?.addTarget(nil, action: #selector(MakeGroupInputView.clickFileAttachButton), forControlEvents: UIControlEvents.TouchUpInside)
        self.fileAttachButton?.layer.borderWidth = 1.0
        self.fileAttachButton?.layer.borderColor = MbUtils.UIColorFromRGB(0xbbc3c9).CGColor

        self.addSubview(self.fileAttachButton!)
        self.addSubview(self.groupTextField!)
        self.addSubview(self.makeButton!)
        self.addSubview(self.topLineView!)
        
        self.applyConstraints()
    }
    
    private func applyConstraints() {
        // Top Line View
        self.addConstraint(NSLayoutConstraint.init(item: self.topLineView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.topLineView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.topLineView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.topLineView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 1))
        
        // File Attach Button
        self.addConstraint(NSLayoutConstraint.init(item: self.fileAttachButton!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.fileAttachButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 28))
        self.addConstraint(NSLayoutConstraint.init(item: self.fileAttachButton!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30))
        self.addConstraint(NSLayoutConstraint.init(item: self.groupTextField!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.fileAttachButton!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -1))
        // group TextField
        self.addConstraint(NSLayoutConstraint.init(item: self.groupTextField!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.groupTextField!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30))
        self.addConstraint(NSLayoutConstraint.init(item: self.groupTextField!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -10))
        
        // make Button
        self.addConstraint(NSLayoutConstraint.init(item: self.makeButton!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.makeButton!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -10))
        self.addConstraint(NSLayoutConstraint.init(item: self.makeButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        self.addConstraint(NSLayoutConstraint.init(item: self.makeButton!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30))
    }
    
    func clickMakeButton(sender: AnyObject) {
        if self.groupTextField?.text?.characters.count == 0 {
            return
        }
        self.makeGroupInputViewDelegate?.clickMakeButton((self.groupTextField?.text)!)
        // 初期化
        self.hideMakeButton()
        self.groupTextField?.text = ""
    }
    func clickFileAttachButton() {
        self.makeGroupInputViewDelegate?.clickGroupFileAttachButton()
    }
    
    func hideMakeButton() {
        UILabel.beginAnimations(nil, context: nil)
        UILabel.setAnimationDuration(0.3)
        self.makeButton?.alpha = 0
        UILabel.commitAnimations()
        self.makeButton?.enabled = false
    }
    
    func showMakeButton() {
        self.makeButton?.alpha = 1
        self.makeButton?.enabled = true
    }
    func hideKeyboard() {
        self.groupTextField?.endEditing(true)
    }
    
    func setDelegate(delegate: UITextFieldDelegate) {
        self.textFieldDelegate = delegate
        self.groupTextField?.delegate = delegate
    }
    
    func textFieldDidChange(textView: UITextView) {
        if textView.text.characters.count > 0 {
            if self.makeButton?.alpha == 0 {
                UILabel.beginAnimations(nil, context: nil)
                UILabel.setAnimationDuration(0.3)
                self.makeButton?.alpha = 1
                UILabel.commitAnimations()
                self.makeButton?.enabled = true
            }
        }
        else {
            UILabel.beginAnimations(nil, context: nil)
            UILabel.setAnimationDuration(0.3)
            self.makeButton?.alpha = 0
            UILabel.commitAnimations()
            self.makeButton?.enabled = false
        }
    }
    
    func setInputEnable(enable: Bool) {
        self.groupTextField?.enabled = enable
        self.makeButton?.enabled = enable
    }
    
    func isInputEnable() -> Bool {
        return self.inputEnabled
    }
}
