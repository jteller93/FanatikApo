//
//  AppDelegate.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import AWSS3
import UserNotifications
import Pushwoosh

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NetworkConfiguration.share.setup()
        Styling.applyDefaultStyling()
        FirebaseConfig.configure()
        AWSConfiguration.setup()
        StripeConfig.setup()

        let _ = GeolocationService.shared // starting location update in background
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        MenuViewController.configure()
        setupPushWoosh()
        resetBadgeCount()
        
        let splashVC = SplashViewController()
        UIApplication.shared.appDelegate().makeRoot(viewController: splashVC)
                
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
        print(deviceToken.hexString)
        #endif
        FirebaseConfig.didRegisterWithDeviceToken(deviceToken: deviceToken)
        PushNotificationManager.push().handlePushRegistration(deviceToken as Data)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        if FirebaseConfig.canHandleNotification(notification: userInfo) {
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
        if #available(iOS 10.0, *) {
            completionHandler(UIBackgroundFetchResult.noData)
        } else {
            PushNotificationManager.push().handlePushReceived(userInfo)
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if FirebaseConfig.canHandle(url: url) {
            return true
        }
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        AWSS3TransferUtility.interceptApplication(application,
                                                  handleEventsForBackgroundURLSession: identifier,
                                                  completionHandler: completionHandler)
    }
    
    func makeRoot(viewController: UIViewController) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
    
    func setupPushWoosh() {
        
        PushNotificationManager.push().delegate = self
        
        UNUserNotificationCenter.current().delegate = PushNotificationManager.push().notificationCenterDelegate
        
        // track application open statistics
        PushNotificationManager.push().sendAppOpen()
        
        // register for push notifications!
        PushNotificationManager.push().registerForPushNotifications()
        //PushNotificationManager.push()?.getPushToken()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if FirebaseSession.shared.isSignIn {
            FirebaseSession.shared.getUserDetail()
        }
    }
}

extension UIApplication {
    func appDelegate() -> AppDelegate {
        return delegate as! AppDelegate
    }
}

extension AppDelegate: PushNotificationDelegate {
    
    //this event is fired when the push gets received
    func onPushReceived(_ pushManager: PushNotificationManager!, withNotification pushNotification: [AnyHashable : Any]!, onStart: Bool) {
        PushWooshObserver.shared.notificationReceiver.accept(true)
        // shows a push is received. Implement passive reaction to a push here, such as UI update or data download.
    }
    //this event is fired when user taps the notification
    func onPushAccepted(_ pushManager: PushNotificationManager!, withNotification pushNotification: [AnyHashable : Any]!, onStart: Bool) {
        print("Push notification accepted: \(String(describing: pushNotification))")
        // shows a user tapped the notification. Implement user interaction, such as showing push details
    }
    
    func resetBadgeCount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
