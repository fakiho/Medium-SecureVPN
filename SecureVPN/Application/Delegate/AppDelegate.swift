//
//  AppDelegate.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import SwiftyStoreKit
import AdSupport
import BugShaker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let appDIContainer = AppDIContainer()
    var window: UIWindow?
    lazy var notificationUseCase = appDIContainer.makeVPNSceneDIContainer().makeNotificationUseCase()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BugShaker.configure(to: [""], subject: "Bug Report")
        AppAppearance.setupAppearance()
        //MARK: - YOU need a firbase config file
        // FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        setupFirebaseNotification(application: application)
        application.registerForRemoteNotifications()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let vpnLauncherViewController = appDIContainer.makeVPNSceneDIContainer().makeSplashViewController()
        window?.rootViewController = vpnLauncherViewController
        window?.makeKeyAndVisible()
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
               switch purchase.transaction.transactionState {
               case .purchased, .restored:
                   if purchase.needsFinishTransaction {
                       // Deliver content from server, then:
                       SwiftyStoreKit.finishTransaction(purchase.transaction)
                   }
                   // Unlock content
               case .failed, .purchasing, .deferred:
                   break
               @unknown default:
                   fatalError()
                }
            }
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack
    @available(iOS 13, *)
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "VPN_Guard")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    @available(iOS 13, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        let notificationObject: NotificationObject = NotificationObject(timelaps: Int(Date().timeIntervalSince1970), title: "background", subtitle: "data")
        _ = notificationUseCase.saveNotification(notification: notificationObject) { _ in }
        completionHandler(UIBackgroundFetchResult.newData)

    }
}

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    func setupFirebaseNotification(application: UIApplication) {
        registerForPushNotifications(application: application)
        Messaging.messaging().delegate = self        
    }
    
    func registerForPushNotifications(application: UIApplication) {
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(_ application: UIApplication, 
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any], 
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let notificationObject: NotificationObject = NotificationObject(timelaps: Int(Date().timeIntervalSince1970), 
                                                                        title: userInfo["title"] as? String ?? "UNK", 
                                                                        subtitle: userInfo["body"] as? String ?? "UK")
        _ = notificationUseCase.saveNotification(notification: notificationObject) { _ in }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let title = notification.request.content.title
        let body = notification.request.content.body
        let notificationObject: NotificationObject = NotificationObject(timelaps: Int(Date().timeIntervalSince1970), title: title, subtitle: body)
        _ = notificationUseCase.saveNotification(notification: notificationObject) { _ in }
        completionHandler([.alert, .sound])
    }
    
    fileprivate func showLocalNotification() {

        //creating the notification content
        let content = UNMutableNotificationContent()

        //adding title, subtitle, body and badge
        content.title = "App Update"
        //content.subtitle = "local notification"
        content.body = "New version of app update is available."
        //content.badge = 1
        content.sound = UNNotificationSound.default
        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        //getting the notification request
        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)

        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request)
    }
}

private extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
