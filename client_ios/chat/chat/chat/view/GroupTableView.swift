import UIKit
import MobileCoreServices

class GroupTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, JobDelegate , MakeGroupInputViewDelegate{

    // クラスコンスタント
    private let kGroupCellIdentifier_: String = "GroupCellIdentifier"

    // インスタンス変数
    private var userToken_ : String = ""
    private var userNicName_ : String = ""
    private var userImage_ : String = ""
    private var groupImg_ : String = ""
    
    // グループ一覧表示
    private var groupTableView_: UITableView?
    private var groupRecord_: [GroupModel] = []
    private var tableViewBottomMargin_: NSLayoutConstraint?
    private var bottomMargin_: NSLayoutConstraint?
    private var notifyObserver_: NotifyJob?
    // グループ入力
    var groupInputView_: MakeGroupInputView?
    //
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
        self.groupRecord_ = []
        self.initViews()
        self.startChatting()
    }
    func setUserValue(userNickname: String, userToken: String, userImage: String){
        self.userNicName_ = userNickname
        self.userToken_ = userToken
        self.userImage_ = userImage
        self.title = userNickname
    }
    func setNavigationButton() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = MbUtils.UIColorFromRGB(0x533a9c)
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationItem.rightBarButtonItems = Array()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_setting"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GroupTableViewController.openMenuActionSheet(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_close"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GroupTableViewController.dismissModal(_:)))
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

        self.groupRecord_.removeAll()
        self.groupTableView_?.reloadData()
        self.groupInputView_?.setInputEnable(true)
        
        RestApiJob.start([:], delegate: self, callback: {(req: NSDictionary!, job: RestApiJob!)->Void in
            // ユーザトークン（ユーザ識別子と同意）を設定します
            MbUtils.usertoken(Int(self.userToken_)!)
            // 全体グループidを設定します
            MbUtils.groupid(1)
            
            RestApiJob.findUserId(job, userToken: self.userToken_, userNickname: self.userNicName_, userImage: self.userImage_)
        })
    }
    // +++++++++++++++++++++++++++++++
    // MARK: JobDelegate
    func notifyJobEvent(eventtype: JobDelegateType, argtype: Int, opt: Int, value: AnyObject? ){
        switch(eventtype){
        case JobDelegateType.FoundUserId,JobDelegateType.CreateGroupCompleted:
            // ユーザid取得完了通知 -> グループ一覧取得ジョブ開始
            // グループ登録完了 -> グループ一覧取得ジョブ開始
            self.groupRecord_.removeAll()
            //
            RestApiJob.start([:], delegate: self, callback: {(req: NSDictionary!, job: RestApiJob!)->Void in
                RestApiJob.findGroups(job)
            })
            break
        case JobDelegateType.FoundGroupModel:           // グループ一覧取得通知 -> グループ毎サマリ取得ジョブ開始
            self.groupRecord_.append(value as! GroupModel)
            RestApiJob.start(["gid": (value as! GroupModel).getId()], delegate: self, callback: {(req: NSDictionary!, job: RestApiJob!)->Void in
                let gid = req.objectForKey("gid") as! Int
                RestApiJob.findGroupSummary(job, gid: gid)
            })
            break
        case JobDelegateType.FoundGroupModelCompleted:  // グループ一覧取得完了通知
            self.groupTableView_?.reloadData()
            break
        case JobDelegateType.FoundGroupSummary:         // グループ毎サマリ取得通知
            for i in 0..<self.groupRecord_.count{
                if self.groupRecord_[i].getId() == opt{
                    self.groupRecord_[i].set(argtype, value: value!)
                    break
                }
            }
            break
        case JobDelegateType.FoundGroupSummryCompleted: // グループ毎サマリ取得完了通知
            self.groupTableView_?.reloadData()
            self.notifyObserver_?.resume()
            break
        case JobDelegateType.EventNotify:
            RestApiJob.start(["gid": opt], delegate: self, callback: {(req: NSDictionary!, job: RestApiJob!)->Void in
                let gid = req.objectForKey("gid") as! Int
                RestApiJob.findGroupSummary(job, gid: gid)
            })
            break
        default:
            NSLog("default::")
            break
        }
    }
    
    func openMenuActionSheet(sender: AnyObject) {
        let closeButtonText: String = "Close"
        let alert: UIAlertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let mkgrpAction: UIAlertAction = UIAlertAction.init(title: "make group", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            NSLog("make group")
        }
        let closeAction: UIAlertAction = UIAlertAction.init(title: closeButtonText, style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(mkgrpAction)
        alert.addAction(closeAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func aboutMessageBoard(sender: AnyObject) {
        let title: String = "MessageBoard"
        let message: String = MbUtils.version()
        let closeButtonText: String = "Close"
        
        let alert: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let closeAction: UIAlertAction = UIAlertAction.init(title: closeButtonText, style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(closeAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p: CGPoint = gestureRecognizer.locationInView(self.groupTableView_!)
        let indexPath: NSIndexPath? = self.groupTableView_!.indexPathForRowAtPoint(p)
        if indexPath == nil {
            NSLog("long press on table view but not on a row")
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let jmc: GroupModel = self.groupRecord_[indexPath!.row]
            NSLog("long press on table view at row %ld(%d)", indexPath!.row, jmc.getId());
            
            let vc: MessageTableViewController = MessageTableViewController()
            vc.setUserValue(self.userToken_, userNickname: self.userNicName_, groupId: jmc.getId(), userImage: self.userImage_)
            self.navigationController?.pushViewController(vc, animated: false)
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
        // 入力グループ
        self.groupInputView_ = MakeGroupInputView()
        self.groupInputView_?.translatesAutoresizingMaskIntoConstraints = false
        self.groupInputView_?.setDelegate(self)
        self.groupInputView_?.makeGroupInputViewDelegate = self
        self.view.addSubview(self.groupInputView_!)
        
        // グループ一覧
        self.groupTableView_ = UITableView()
        self.groupTableView_?.translatesAutoresizingMaskIntoConstraints = false
        self.groupTableView_?.delegate = self
        self.groupTableView_?.dataSource = self
        self.groupTableView_?.hidden = false
        self.groupTableView_?.separatorColor = UIColor.clearColor()
        self.groupTableView_?.backgroundColor = MbUtils.UIColorFromRGB(0xfcfcfc)
        self.groupTableView_?.contentInset = UIEdgeInsetsMake(6, 0, 6, 0)
        //
        self.groupTableView_?.registerClass(GroupViewCell.self, forCellReuseIdentifier: kGroupCellIdentifier_)
        self.view.addSubview(self.groupTableView_!)
        
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(GroupTableViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 1.2
        lpgr.delegate = self
        self.groupTableView_?.addGestureRecognizer(lpgr)
        //
        self.applyConstraints()
    }
    
    func applyConstraints() {
        // 発言テキスト
        self.view.addConstraint(NSLayoutConstraint.init(item: self.groupInputView_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.groupInputView_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.bottomMargin_ = NSLayoutConstraint.init(item: self.groupInputView_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(self.bottomMargin_!)
        self.view.addConstraint(NSLayoutConstraint.init(item: self.groupInputView_!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 44))

        // グループ一覧
        self.view.addConstraint(NSLayoutConstraint.init(item: self.groupTableView_!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.groupTableView_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint.init(item: self.groupTableView_!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.groupTableView_!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.tableViewBottomMargin_ = NSLayoutConstraint.init(item: self.groupTableView_!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.groupInputView_!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        self.view.addConstraint(self.tableViewBottomMargin_!)
    }
    // +++++++++++++++++++++++++++++++
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.groupRecord_.count)
    }
    // +++++++++++++++++++++++++++++++
    // MARK: UITableViewDelegate
    // セルの描画
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kGroupCellIdentifier_)
        if cell == nil {
            cell = GroupViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kGroupCellIdentifier_)
        }
        if (cell != nil){
            let model = self.groupRecord_[indexPath.row]
            (cell as! GroupViewCell).setModel(model)
        }
        return cell!
    }
    // セルの高さ
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var calculatedHeight: CGFloat = 0
        calculatedHeight = CGFloat(self.groupRecord_[indexPath.row].getHeight())
        // 高さが設定されていない場合は
        // デフォルトの高さで動作させる
        if calculatedHeight == 0.0 {
            calculatedHeight = GroupViewCell.getViewCellHeight()
            self.groupRecord_[indexPath.row].setHeight(Float(calculatedHeight))
        }
        // 計算済みの高さ
        return calculatedHeight
    }
    // +++++++++++++++++++++++++++++++
    // MARK: MakeGroupInputViewDelegate
    func clickMakeButton(group: String){
        NSLog("clickMakeButton(%@)", group)
        let image = self.groupImg_
        RestApiJob.start(["name": group, "image": image, "uname": self.userNicName_, "uimage": self.userImage_], delegate: self, callback: {(req: NSDictionary!, job: RestApiJob!)->Void in
            let image = req.objectForKey("image") as! String
            let name = req.objectForKey("name") as! String
            let mname = req.objectForKey("uname") as! String
            let uimg = req.objectForKey("uimage") as! String
            RestApiJob.createGroup(job, name: name, image: image, uname: mname, uimage: uimg)
        })
    }
    func clickGroupFileAttachButton(){
        NSLog("clickGroupFileAttachButton")
        let mediaUI: UIImagePickerController = UIImagePickerController()
        mediaUI.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        let mediaTypes: NSMutableArray = NSMutableArray.init(array: [kUTTypeImage])
        mediaUI.mediaTypes = mediaTypes as NSArray as! [String]
        mediaUI.delegate = self
        self.presentViewController(mediaUI, animated: true, completion: nil)

    }
    // +++++++++++++++++++++++++++++++
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        self.dismissViewControllerAnimated(true, completion: nil)
        self.groupInputView_?.setInputEnable(false)
        // 
        var pathimg = NSHomeDirectory()
        pathimg = pathimg.stringByAppendingString("/Documents/tmpimg_grp.png");
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
                    self.groupImg_ = s3path
                }
                self.groupInputView_?.setInputEnable(true)
            })
        }else{
            self.groupInputView_?.setInputEnable(true)
        }
    }
}
