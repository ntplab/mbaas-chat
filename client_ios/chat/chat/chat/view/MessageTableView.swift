import UIKit
import MobileCoreServices

class MessageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageInputViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, JobDelegate {
    // クラスコンスタント
    private let kMessageCellIdentifier_: String = "MessageCellIdentifier"
    private let kMyMessageCellIdentifier_: String = "MyMessageCellIdentifier"
    private let kSystemMessageCellIdentifier_: String = "SystemMessageCellIdentifier"
    

    // インスタンス変数
    private var userToken_ : String = ""
    private var userNickname_: String = ""
    private var userId_ : String = ""
    private var userImg_ : String = ""
    private var groupId_: Int = 0
    private var messageId_: Int = 0
    private var messageImg_: String = ""
    
    // メッセージ一覧表示
    private var messageTableView_: UITableView?
    private var messageRecord_: [MessageModel] = []
    private var tableViewBottomMargin: NSLayoutConstraint?
    private var bottomMargin: NSLayoutConstraint?
    private var notifyObserver_: NotifyJob?
    // メッセージ入力
    var messageInputView_: MessageInputView?

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        // イベント受信オブザーバ開始
        self.notifyObserver_ = NotifyJob.start([:], delegate: self)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationButton()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        self.messageRecord_ = []
        self.initViews()
        self.startChatting()
    }
    func setUserValue(userToken: String, userNickname: String, groupId: Int, userImage: String){
        self.userToken_ = userToken
        self.userNickname_ = userNickname
        self.groupId_ = groupId
        self.userImg_ = userImage
        // カレントグループidを設定します
        MbUtils.groupid(groupId)
        
        self.title = ""
        self.userId_ = ""
    }
    func setNavigationButton() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = MbUtils.UIColorFromRGB(0x533a9c)
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationItem.rightBarButtonItems = Array()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_setting"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_close"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MessageTableViewController.dismissModal(_:)))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
    }
    func dismissModal(sender: AnyObject) {
        // イベント受信オブザーバ開始
        self.notifyObserver_?.pause()
        self.notifyObserver_ = nil
        
        self.navigationController?.popViewControllerAnimated(false)
    }
    // チャット開始メイン
    func startChatting() {
        NSLog("startChatting")

        self.messageRecord_.removeAll()
        self.messageTableView_?.reloadData()
        self.messageInputView_?.setInputEnable(true)
        
        // ユーザ識別子から、ユーザidを取得ジョブ開始
        RestApiJob.start([:], delegate: self, callback: {(req: NSDictionary!, job: RestApiJob!)->Void in
            RestApiJob.findUserId(job, userToken: self.userToken_, userNickname: self.userNickname_, userImage: self.userImg_)
        })
    }
    // +++++++++++++++++++++++++++++++
    // MARK: RestApiJobDelegate
    func notifyJobEvent(eventtype: JobDelegateType, argtype: Int, opt: Int, value: AnyObject? ){
        switch(eventtype){
        case JobDelegateType.FoundUserId:
            // グループ内メッセージ取得
            RestApiJob.start(["gid": self.groupId_], delegate: self, callback: {(req: NSDictionary!, job: RestApiJob!)->Void in
                RestApiJob.findMessage(job, gid: self.groupId_, mid: self.messageId_ )
            })
            break
        case JobDelegateType.FoundMessage:
            let msgmdl = value as! MessageModel
            self.messageId_ = max(self.messageId_, msgmdl.getId())
            self.messageRecord_.insert(msgmdl, atIndex: 0)
            break
        case JobDelegateType.FoundMessageCompleted:
            self.messageTableView_?.reloadData()
            self.notifyObserver_?.resume()
            break
        case JobDelegateType.CreatedMessageCompleted:
            NSLog("created msg(%d)", opt)
            break
        case JobDelegateType.EventNotify:
            // カレントグループの場合自動読み込み
            if opt == self.groupId_{
                RestApiJob.start(["gid": opt], delegate: self, callback: {(req: NSDictionary!, job: RestApiJob!)->Void in
                    let gid = req.objectForKey("gid") as! Int
                    RestApiJob.findMessage(job, gid: gid, mid: self.messageId_)
                })
            }
            break
        default:break
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p: CGPoint = gestureRecognizer.locationInView(self.messageTableView_!)
        let indexPath: NSIndexPath? = self.messageTableView_!.indexPathForRowAtPoint(p)
        if indexPath == nil {
            NSLog("long press on table view but not on a row")
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let jmc: MessageModel = self.messageRecord_[indexPath!.row]
            NSLog("long press on table view at row %ld(%d)", indexPath!.row, jmc.getId());
        }
        else {
            NSLog("gestureRecognizer.state = %ld", gestureRecognizer.state.rawValue)
        }
    }
    // +++++++++++++++++++++++++++++++
    // MARK: 画面構築
    func initViews() {
        self.view.backgroundColor = UIColor.clearColor()
        self.view.opaque = false
        
        // 入力テキスト
        self.messageInputView_ = MessageInputView()
        self.messageInputView_?.translatesAutoresizingMaskIntoConstraints = false
        self.messageInputView_?.setDelegate(self)
        self.messageInputView_?.messageInputViewDelegate = self
        self.view.addSubview(self.messageInputView_!)
        
        // メッセージ一覧
        self.messageTableView_ = UITableView()
        self.messageTableView_?.translatesAutoresizingMaskIntoConstraints = false
        self.messageTableView_?.delegate = self
        self.messageTableView_?.dataSource = self
        self.messageTableView_?.hidden = false
        self.messageTableView_?.separatorColor = UIColor.clearColor()
        self.messageTableView_?.backgroundColor = MbUtils.UIColorFromRGB(0xfcfcfc)
        self.messageTableView_?.contentInset = UIEdgeInsetsMake(6, 0, 6, 0)
        //
        self.messageTableView_?.registerClass(MessageViewCell.self, forCellReuseIdentifier: kMessageCellIdentifier_)
        self.messageTableView_?.registerClass(MyMessageViewCell.self, forCellReuseIdentifier: kMyMessageCellIdentifier_)
        self.view.addSubview(self.messageTableView_!)
        
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(MessageTableViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 1.2
        lpgr.delegate = self
        self.messageTableView_?.addGestureRecognizer(lpgr)
        //
        self.applyConstraints()
    }
    
    func applyConstraints() {
        // 発言テキスト
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageInputView_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageInputView_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.bottomMargin = NSLayoutConstraint.init(item: self.messageInputView_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(self.bottomMargin!)
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageInputView_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 44))
        
        // 発言一覧
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageTableView_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageTableView_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageTableView_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.tableViewBottomMargin = NSLayoutConstraint.init(item: self.messageTableView_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageInputView_!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        self.view.addConstraint(self.tableViewBottomMargin!)
    }

    // +++++++++++++++++++++++++++++++
    // MARK: MessageInputViewDelegate
    func clickSendButton(message: String) {
        NSLog("clickSendButton(%@)", message)
        RestApiJob.start(["gid": self.groupId_,"msg": message], delegate: self, callback: {(req: NSDictionary!, job: RestApiJob!)->Void in
            let gid = req.objectForKey("gid") as! Int
            let msg = req.objectForKey("msg") as! String
            RestApiJob.createMessage(job, gid: gid, msg: msg)
        })
    }
    func clickFileAttachButton() {
        NSLog("clickFileAttachButton")
        let mediaUI: UIImagePickerController = UIImagePickerController()
        mediaUI.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        let mediaTypes: NSMutableArray = NSMutableArray.init(array: [kUTTypeImage])
        mediaUI.mediaTypes = mediaTypes as NSArray as! [String]
        mediaUI.delegate = self
        self.presentViewController(mediaUI, animated: true, completion: nil)
    }

    func clickChannelListButton() {
        NSLog("clickChannelListButton")
    }
    
    // +++++++++++++++++++++++++++++++
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.messageRecord_.count)
    }
    // +++++++++++++++++++++++++++++++
    // MARK: UITableViewDelegate
    // セルの描画
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let model = self.messageRecord_[indexPath.row]
        let uid = model.get(MessageModel.UID) as! Int
        let msg = model.get(MessageModel.MSG) as! String
        
        // システムメッセージ：タイプ00
        if msg.hasPrefix(MbUtils.META_SYSMSG_00){
            cell = tableView.dequeueReusableCellWithIdentifier(kSystemMessageCellIdentifier_)
            if cell == nil {
                cell = SystemMessageViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kSystemMessageCellIdentifier_)
            }
            if (cell != nil){
                (cell as! SystemMessageViewCell).setModel(model)
            }
        }else if uid == MbUtils.userid(){   // 自分のメッセージ
            cell = tableView.dequeueReusableCellWithIdentifier(kMyMessageCellIdentifier_)
            if cell == nil {
                cell = MyMessageViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kMyMessageCellIdentifier_)
            }
            if (cell != nil){
                (cell as! MyMessageViewCell).setModel(model)
            }
        }else{                             // 他人のメッセージ
            cell = tableView.dequeueReusableCellWithIdentifier(kMessageCellIdentifier_)
            if cell == nil {
                cell = MessageViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kMessageCellIdentifier_)
            }
            if (cell != nil){
                (cell as! MessageViewCell).setModel(model)
            }
        }
        return cell!
    }
    // セルの高さ
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var calculatedHeight: CGFloat = 0
        calculatedHeight = CGFloat(self.messageRecord_[indexPath.row].getHeight())
        // 高さが設定されていない場合は
        // デフォルトの高さで動作させる
        if calculatedHeight == 0.0 {
            calculatedHeight = self.messageRecord_[indexPath.row].getViewCellHeight()
        }
        // 計算済みの高さ
        return calculatedHeight
    }
    // +++++++++++++++++++++++++++++++
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        self.dismissViewControllerAnimated(true, completion: nil)
        self.messageInputView_?.setInputEnable(false)
        //
        var pathimg = NSHomeDirectory()
        pathimg = pathimg.stringByAppendingString("/Documents/tmpimg_msg.png");
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
            MbUtils.uploadToS3(NSURL(fileURLWithPath: pathimg), imgdata: dataimg!,  onEnd: {(s3path: String!, error: NSError!)->Void in
                if error == nil{
                    self.messageImg_ = s3path
                }
                self.messageInputView_?.setInputEnable(true)
            })
        }else{
            self.messageInputView_?.setInputEnable(true)
        }
    }
}
