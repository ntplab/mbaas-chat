import UIKit
import AWSS3
import AWSDynamoDB
import AWSSQS
import AWSSNS
import AWSCognito

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var viewController: ViewController?
    var navController: UINavigationController?
    var taskQueue: NSOperationQueue?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        viewController = ViewController()
        navController = UINavigationController(rootViewController: viewController!)
        navController?.navigationBar.hidden = true
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        // アプリケーションidを設定します
        MbUtils.appid("appid-dummy")
        //
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        else {
            application.registerForRemoteNotificationTypes([.Alert, .Sound, .Badge])
        }
        // S3に画像を保存するのに利用します
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: MbUtils.AWSCOGNIT_PID_)
        let configuration = AWSServiceConfiguration(region: .APNortheast1, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration;
        
        return true
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData){
        NSLog("%@", deviceToken)
        let devtoken = NSString(data:deviceToken, encoding: NSUTF8StringEncoding) as String?
        MbUtils.deviceUniqueID(devtoken!)
    }
    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
}
