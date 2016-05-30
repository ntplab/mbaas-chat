import Foundation
import UIKit
import AWSS3
import AWSCore

public class MbUtils {
    public static let AWSCOGNIT_PID_: String = "us-eastxx:xxyyzzyy"
    static let AWSS3_URL_: String = "https://d3-ap-xxxx.amazonaws.com/xxxx/"
    static let AWSS3_BUCKET_: String = "your-bucket-name"
    static var MAIN_QUEUE_: dispatch_queue_t  = dispatch_get_main_queue();
    static var API_QUEUE_: dispatch_queue_t  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    static let REST_URL_: String = "http://localhost:8080/v1/mb/"
    static let VERSION_: String = "0.0.0.1"
    static var APPID_: String = ""
    static var USERID_: Int = 0
    static var USERTOKEN_: Int = 0
    static var GROUPID_: Int = 0
    static let META_SYSMSG_PREFIX = "<#$"
    static let META_SYSMSG_00 = "<#$00$#>"
    //
    static var deviceId_ = ""
    static func deviceUniqueID() -> String {
        return deviceId_
    }
    static func deviceUniqueID(deviceId: String){
        deviceId_ = deviceId
    }
    static func version() -> String {
        return VERSION_
    }
    static func appid() -> String {
        return APPID_
    }
    static func appid(appId: String){
        APPID_ = appId
    }
    static func userid() -> Int{
        return USERID_
    }
    static func userid(userId: Int){
        USERID_ = userId
    }
    static func usertoken() -> Int{
        return USERTOKEN_
    }
    static func usertoken(userToken: Int){
        USERTOKEN_ = userToken
    }
    static func groupid(groupid: Int){
        GROUPID_ = groupid
    }
    static func groupid() -> Int{
        return GROUPID_
    }
    
    // /v1/mb/group/
    static func getGroupsAtMainThread(job: AnyObject, onEnd: ((job: AnyObject, response: NSDictionary!, error: NSError!) -> Void)!){
        callApiAtMainThread(job, method: "GET", uri: "group/0", body: nil, onEnd: onEnd )
    }
    // /v1/mb/group/
    static func createGroupsAtMainThread(job: AnyObject,token: Int, name: String, image: String, uname: String, uimage: String, onEnd: ((job: AnyObject, response: NSDictionary!, error: NSError!) -> Void)!){
        callApiAtMainThread(job, method: "POST", uri: "group", body: ["creator": token, "name": name, "image": image, "uname": uname, "uimage": uimage], onEnd: onEnd )
    }
    
    // /v1/mb/info/<gid>/<uid>/<mid>
    static func getGroupSummaryAtMainThread(job: AnyObject, gid: Int, uid: Int, mid: Int, onEnd: ((job: AnyObject,response: NSDictionary!, error: NSError!) -> Void)!){
        callApiAtMainThread(job, method: "GET", uri: String(format: "info/%d/%d/%d", gid, uid, mid), body: nil, onEnd: onEnd )
    }
    // /v1/mb/user/<gid>/<token>
    static func getUserIdAtMainThread(job: AnyObject, token: String, nickname: String, image: String, onEnd: ((job: AnyObject, response: NSDictionary!, error: NSError!) -> Void)!){
        let gid : Int = MbUtils.groupid()
        
        callApiAtMainThread(job, method: "POST", uri: String(format: "user/%d/%d", gid, Int(token)!), body:["name": nickname, "image": image], onEnd: onEnd )
    }
    // /v1/mb/chat/<gid>/<mid>
    static func getMessagesAtMainThread(job: AnyObject, gid: Int, mid: Int, onEnd: ((job: AnyObject, response: NSDictionary!, error: NSError!) -> Void)!){
        callApiAtMainThread(job, method: "GET", uri: String(format: "chat/%d/%d", gid, mid),body: nil, onEnd: onEnd )
    }
    // /v1/mb/chat/<gid>/<uid>
    static func createMessagesAtMainThread(job: AnyObject, gid: Int, uid: Int, msg: String, onEnd: ((job: AnyObject, response: NSDictionary!, error: NSError!) -> Void)!){
        callApiAtMainThread(job, method: "POST", uri: String(format: "chat/%d/%d", gid, uid),body: ["message": msg], onEnd: onEnd )
    }
    
    // /v1/mb/chat/<id>/read
    static func markAsReadForChannel(job: AnyObject, chanid: String, onEnd: ((job: AnyObject, response: NSDictionary!, error: NSError!) -> Void)!){
        callApiAtMainThread(job, method: "GET", uri: "chat/" + chanid + "/read",body: nil, onEnd: onEnd )
    }
    // /v1/mb/notify
    static func observeEvent(job: AnyObject, onEnd: ((job: AnyObject, response: NSDictionary!, error: NSError!) -> Void)!){
        callApiAtMainThread(job, method: "GET", uri: "notify", body: nil, onEnd: onEnd )
    }
    

    static private func callApiAtMainThread(job: AnyObject, method: String, uri: String, body: NSDictionary?, onEnd: ((job: AnyObject, response: NSDictionary!, error: NSError!) -> Void)!) {
        let url:NSURL = NSURL(string: REST_URL_ + uri)!
        var request: NSMutableURLRequest
        var json:NSDictionary! = [:]
        request = NSMutableURLRequest()
        request.HTTPMethod = method
        request.setValue(String.init(format: "MB/%@", VERSION_), forHTTPHeaderField: "User-Agent")
        request.setValue(String.init(format: "%@", APPID_), forHTTPHeaderField: "appid")
        //
        request.URL = url
        
        if (body != nil){
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body!, options: NSJSONWritingOptions.PrettyPrinted)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                NSLog("failed. json body:(%@)", uri)
            }
        }
        //
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if data == nil || response == nil || error != nil{
                dispatch_async(MAIN_QUEUE_,{ onEnd(job: job, response: json, error: error)})
            }else{
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                } catch  {
                    NSLog("failed. json(%@)", uri)
                }
                if json.count == 0{
                    dispatch_async(MAIN_QUEUE_,{ onEnd(job: job, response: json, error: NSError(domain: "http failed.",code: 0, userInfo: [:]))})
                }else{
                    dispatch_async(MAIN_QUEUE_,{ onEnd(job: job, response: json, error: error)})
                }
            }
        }
        task.resume()
    }
    static func imageDownload(url: NSURL, onEnd: ((response: NSData!, error: NSError!) -> Void)!) {
        var request: NSMutableURLRequest
        
        request = NSMutableURLRequest()
        request.HTTPMethod = "GET"
        request.setValue(String.init(format: "MB/%@", VERSION_), forHTTPHeaderField: "User-Agent")
        request.URL = url
        
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            onEnd(response: data, error: error)
        }
    }
    static func scaledImage(image: UIImage, width: CGFloat) -> UIImage {
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if image.size.width > image.size.height {
            newWidth = width * image.size.width / image.size.height
            newHeight = width
        }
        else {
            newHeight = width * image.size.width / image.size.height
            newWidth = width
        }
        
        let newSize = CGSizeMake(newWidth, newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, true, UIScreen.mainScreen().scale)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    static func imageFromColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    static func UIColorFromRGB(rgbValue: Int32) -> UIColor {
        return UIColor.init(colorLiteralRed: ((Float)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((Float)((rgbValue & 0x00FF00) >>  8))/255.0, blue: ((Float)((rgbValue & 0x0000FF) >>  0))/255.0, alpha: 1.0)
    }
    static func loadImage(imageUrl: String, imageView: UIImageView, width: CGFloat, height: CGFloat) {
        let iv: UIImageView = imageView
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.HTTPMethod = "GET"
        request.setValue(String.init(format: "MB/%@", MbUtils.version()), forHTTPHeaderField: "User-Agent")
        request.URL = NSURL.init(string: imageUrl)
        
        iv.setImageWithUrlRequest(request, placeHolderImage: nil,
                                  success: { (request: NSURLRequest?, response: NSURLResponse?, image: UIImage, fromCache:Bool) -> Void in
                                    
            var newSize: CGSize = CGSizeMake(height * 2, width * 2)
            let widthRatio: CGFloat = newSize.width / image.size.width
            let heightRatio: CGFloat = newSize.height / image.size.height
            
            if widthRatio > heightRatio {
                newSize = CGSizeMake(image.size.width * heightRatio, image.size.height * heightRatio)
            }
            else {
                newSize = CGSizeMake(image.size.width * widthRatio, image.size.height * widthRatio)
            }
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            iv.image = newImage
            
            }, failure: nil)
    }
    static func getUrlFromstring(bulk: String) -> String {
        var arrString: Array<String>?
        var url: String? = ""
        
        arrString = bulk.componentsSeparatedByString(" ")
        for i in 0 ..< arrString!.count {
            if (arrString![i].rangeOfString("http://", options: NSStringCompareOptions.CaseInsensitiveSearch)) != nil {
                url = arrString![i]
                break;
            }
            
            if (arrString![i].rangeOfString("https://", options: NSStringCompareOptions.CaseInsensitiveSearch)) != nil {
                url = arrString![i]
                break;
            }
        }
        
        return url!;
    }
    static func uploadToS3(fileUrl: NSURL, imgdata: NSData, onEnd: ((s3path: String!, error: NSError!) -> Void)!) {
        //make a timestamp variable to use in the key of the video I'm about to upload
        let date:NSDate = NSDate()
        let unixTimeStamp:NSTimeInterval = date.timeIntervalSince1970
        let unixTimeStampString:String = String(format:"%f", unixTimeStamp)
        print("this is my unix timestamp as a string:",unixTimeStampString)
        // set upload settings
        let myTransferManagerRequest:AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        myTransferManagerRequest.bucket = AWSS3_BUCKET_
        let uploadedFileName = "upload_\(unixTimeStampString).jpg"
        myTransferManagerRequest.key = uploadedFileName
        myTransferManagerRequest.body = fileUrl
        myTransferManagerRequest.contentLength = imgdata.length
        myTransferManagerRequest.ACL = AWSS3ObjectCannedACL.PublicRead
        
        let myMainThreadBFExecutor:AWSExecutor = AWSExecutor.mainThreadExecutor()
        let myTransferManager:AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
        myTransferManager.upload(myTransferManagerRequest).continueWithExecutor(myMainThreadBFExecutor, withBlock: { (myBFTask) -> AnyObject! in
            if((myBFTask.result) != nil){
                print("Success!!")
                // send api?
                let s3Path = AWSS3_URL_ + uploadedFileName
                print("uploaded s3 path is \(s3Path)")
                onEnd(s3path: s3Path, error: nil)
            } else {
                print("upload didn't seem to go through..")
                let myError = myBFTask.error
                print("error: \(myError)")
                onEnd(s3path: "", error: myError)
            }
            return nil
        })
    }

}

