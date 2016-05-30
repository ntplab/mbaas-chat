import UIKit
import MobileCoreServices


class ViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    static let kUserImageSz_: CGFloat = 64.0
    var logoImageView_: UIImageView?
    var versionLabel_: UILabel?
    var backgroundImageView_: UIImageView?
    var startMessaging_: UIButton?
    var userNicknameTextField_: UITextField?
    var userTokenLabel_: UILabel?
    var userTokenTextField_: UITextField?
    var userImageView_: UIImageView?
    //
    var userImagePath_: String = ""
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initView() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // 背景イメージ
        self.backgroundImageView_ = UIImageView(image: UIImage(named: "_startup_background.jpg"))
        self.backgroundImageView_?.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView_?.contentMode = UIViewContentMode.ScaleAspectFill
        self.backgroundImageView_?.clipsToBounds = true
        self.view.addSubview(self.backgroundImageView_!)
        
        // ロゴ
        self.logoImageView_ = UIImageView(image: UIImage(named: "_logo"))
        self.logoImageView_?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.logoImageView_!)
        
        NSLog("Version: %@", MbUtils.version())
        self.versionLabel_ = UILabel()
        self.versionLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.versionLabel_?.text = String(format: "ver: %@", MbUtils.version())
        self.versionLabel_?.textColor = UIColor.blackColor()
        self.versionLabel_?.font = UIFont.init(name: "AmericanTypewriter-Bold", size: 28.0)
        self.versionLabel_?.hidden = false
        self.view.addSubview(self.versionLabel_!)
        
        // ユーザトークンラベル
        self.userTokenLabel_ = UILabel()
        self.userTokenLabel_?.translatesAutoresizingMaskIntoConstraints = false
        self.userTokenLabel_?.text = "トークン/ニックネームを入力してください"
        self.userTokenLabel_?.textColor = UIColor.blackColor()
        self.userTokenLabel_?.font = UIFont.boldSystemFontOfSize(8.0)
        self.userTokenLabel_?.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.userTokenLabel_!)
        
        // ユーザトークン入力
        self.userTokenTextField_ = UITextField()
        self.userTokenTextField_?.translatesAutoresizingMaskIntoConstraints = false
        self.userTokenTextField_?.background = MbUtils.imageFromColor(MbUtils.UIColorFromRGB(0xE8EAF6))
        self.userTokenTextField_?.clipsToBounds = true
        self.userTokenTextField_?.layer.cornerRadius = 4.0
        var leftPaddingView: UIView?
        var rightPaddingView: UIView?
        leftPaddingView = UIView.init(frame: CGRectMake(0, 0, 12, 0))
        rightPaddingView = UIView.init(frame: CGRectMake(0, 0, 12, 0))
        self.userTokenTextField_?.leftView = leftPaddingView
        self.userTokenTextField_?.leftViewMode = UITextFieldViewMode.Always
        self.userTokenTextField_?.rightView = rightPaddingView
        self.userTokenTextField_?.rightViewMode = UITextFieldViewMode.Always
        self.userTokenTextField_?.placeholder = "トークン"
        self.userTokenTextField_?.font = UIFont.systemFontOfSize(16.0)
        self.userTokenTextField_?.returnKeyType = UIReturnKeyType.Done
        self.userTokenTextField_?.delegate = self
        self.userTokenTextField_?.keyboardType = .NumberPad
        self.view.addSubview(self.userTokenTextField_!)
        
        
        // ユーザニックネーム入力
        self.userNicknameTextField_ = UITextField()
        self.userNicknameTextField_?.translatesAutoresizingMaskIntoConstraints = false
        self.userNicknameTextField_?.background = MbUtils.imageFromColor(MbUtils.UIColorFromRGB(0xE8EAF6))
        self.userNicknameTextField_?.clipsToBounds = true
        self.userNicknameTextField_?.layer.cornerRadius = 4.0
        let nleftPaddingView = UIView.init(frame: CGRectMake(0, 0, 12, 0))
        let nrightPaddingView = UIView.init(frame: CGRectMake(0, 0, 12, 0))
        self.userNicknameTextField_?.leftView = nleftPaddingView
        self.userNicknameTextField_?.leftViewMode = UITextFieldViewMode.Always
        self.userNicknameTextField_?.rightView = nrightPaddingView
        self.userNicknameTextField_?.rightViewMode = UITextFieldViewMode.Always
        self.userNicknameTextField_?.placeholder = "ニックネーム"
        self.userNicknameTextField_?.font = UIFont.systemFontOfSize(16.0)
        self.userNicknameTextField_?.returnKeyType = UIReturnKeyType.Done
        self.userNicknameTextField_?.delegate = self
        self.view.addSubview(self.userNicknameTextField_!)
        
        // アイコン
        self.userImageView_ = UIImageView(image: UIImage(named: "_guest.jpeg"))
        self.userImageView_?.translatesAutoresizingMaskIntoConstraints = false
        self.userImageView_?.clipsToBounds = true
        self.userImageView_?.layer.cornerRadius = (ViewController.kUserImageSz_ / 2)
        self.userImageView_?.contentMode = UIViewContentMode.ScaleAspectFill
        self.userImageView_?.userInteractionEnabled = true
        let tapg:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapGesture(_:)))
        self.userImageView_?.addGestureRecognizer(tapg)
        
        self.view.addSubview(self.userImageView_!)
        
        // 開始ボタン
        self.startMessaging_ = UIButton()
        self.startMessaging_?.translatesAutoresizingMaskIntoConstraints = false
        self.startMessaging_?.setBackgroundImage(MbUtils.imageFromColor(MbUtils.UIColorFromRGB(0xAB47BC)), forState: UIControlState.Normal)
        self.startMessaging_?.clipsToBounds = true
        self.startMessaging_?.layer.cornerRadius = 4.0
        self.startMessaging_?.addTarget(self, action:#selector(ViewController.startButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.startMessaging_?.setTitle("開始する", forState: UIControlState.Normal)
        self.startMessaging_?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.startMessaging_?.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        self.view.addSubview(self.startMessaging_!)
        
        self.setConstraints()
    }
    
    func setConstraints() {
        // 背景画像
        self.view.addConstraint(NSLayoutConstraint.init(item: self.backgroundImageView_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.backgroundImageView_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.backgroundImageView_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.backgroundImageView_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        
        // ロゴ
        self.view.addConstraint(NSLayoutConstraint.init(item: self.logoImageView_!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.logoImageView_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 48))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.logoImageView_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 80))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.logoImageView_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 76.4))
        
        // バージョンラベル
        self.view.addConstraint(NSLayoutConstraint.init(item: self.versionLabel_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.logoImageView_, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 8))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.versionLabel_!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.logoImageView_, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        
        // ユーザトークン
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userTokenLabel_!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userTokenLabel_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.versionLabel_, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userTokenLabel_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userTokenLabel_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))
        
        // ユーザトークン入力テキスト
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userTokenTextField_!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userTokenTextField_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.userTokenLabel_, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 4))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userTokenTextField_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userTokenTextField_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))
        
        // ユーザニックネーム入力テキスト
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userNicknameTextField_!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userNicknameTextField_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.userTokenTextField_, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 4))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userNicknameTextField_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userNicknameTextField_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))
        
        // ユーザアバター
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userImageView_!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userImageView_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.userNicknameTextField_, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 4))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userImageView_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: ViewController.kUserImageSz_))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.userImageView_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: ViewController.kUserImageSz_))
        
        // 開始ボタン
        self.view.addConstraint(NSLayoutConstraint.init(item: self.startMessaging_!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.startMessaging_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.userImageView_, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 12))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.startMessaging_!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.startMessaging_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    func tapGesture(sender:UITapGestureRecognizer){
        let mediaUI: UIImagePickerController = UIImagePickerController()
        mediaUI.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        let mediaTypes: NSMutableArray = NSMutableArray.init(array: [kUTTypeImage])
        mediaUI.mediaTypes = mediaTypes as NSArray as! [String]
        mediaUI.delegate = self
        self.presentViewController(mediaUI, animated: true, completion: nil)
    }
    func startButton(sender: AnyObject) {
        NSLog("startButton")
        if self.userNicknameTextField_?.text?.characters.count > 0 && self.userTokenTextField_?.text?.characters.count > 0{
            self.startMessageBoard((self.userNicknameTextField_?.text)!,usertoken: (self.userTokenTextField_?.text)!)
        }
    }
    private func startMessageBoard(username: String, usertoken: String) {
        let vc: GroupTableViewController = GroupTableViewController()
        vc.setUserValue(username, userToken: usertoken, userImage: self.userImagePath_)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField==self.userTokenTextField_{
            if string != ""{
                if (Int(string) != nil){
                    return true
                }
                return false
            }
        }
        return true
    }
    // +++++++++++++++++++++++++++++++
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        self.dismissViewControllerAnimated(true, completion: nil)
        //
        var pathimg = NSHomeDirectory()
        pathimg = pathimg.stringByAppendingString("/Documents/tmpimg_user.png");
        let tookimg = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageW = tookimg.size.width;
        let imageH = tookimg.size.height;
        let scale = imageW > imageH ? 96.0/imageH : 96.0/imageW
        let resized = CGSizeMake(imageW*scale,imageH*scale)
        UIGraphicsBeginImageContext(resized)
        tookimg.drawInRect(CGRectMake(0.0, 0.0, resized.width, resized.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        let dataimg = UIImagePNGRepresentation(resizedImage)
        let retmkimg = dataimg?.writeToFile(pathimg, atomically: false)
        UIGraphicsEndImageContext()
        if (retmkimg == true){
            MbUtils.uploadToS3(NSURL(fileURLWithPath: pathimg), imgdata: dataimg!, onEnd: {(s3path: String!, error: NSError!)->Void in
                if error == nil{
                    self.userImagePath_ = s3path
                    MbUtils.loadImage(s3path, imageView: self.userImageView_!, width: ViewController.kUserImageSz_, height: ViewController.kUserImageSz_)
                }
            })
        }
    }
}

