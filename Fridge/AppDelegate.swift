//
//  AppDelegate.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/01.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let applicationKey = "d6124751ca5b8e39007c27286c47be116761bff1cc30e629e5a0a3116f75f5f6"
        let clientKey = "093c62b35ca353f92d1237a0e2d9f89731d256d09bb3dee37350863991b2d99d"
        NCMB.setApplicationKey(applicationKey, clientKey: clientKey)
        
        
        UINavigationBar.appearance().tintColor = UIColor(red: 0.00, green: 0.91, blue: 0.80, alpha: 1.00)
        
        // ナビゲーションバーのタイトルの文字色
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.darkGray]

        // ナビゲーションバーの背景の半透明
        UINavigationBar.appearance().alpha = 0.5
        
        // ナビゲーションバーの下の影を無くす
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UITabBar.appearance().tintColor = UIColor(red: 0.00, green: 0.91, blue: 0.80, alpha: 1.00)
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.darkGray
        
//        UITabBarItem.appearance().imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: -6, right: -10)
        
        let ud = UserDefaults.standard
        if ud.object(forKey: "userName") == nil {
            //匿名ユーザの自動生成を有効化
            NCMBUser.enableAutomaticUser()
            NCMBUser.automaticCurrentUser { (user, error) in
                if error != nil {
                    print(error)
                } else {
                    ud.set(user?.objectId, forKey: "userName")
                    print(ud.object(forKey: "userName"))
                }
            }
        }
//        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

