//
//  NoUserViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/10/27.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit

class NoUserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func toSignUp() {
        //signIn画面に移動！
        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
        let RootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
        UIApplication.shared.keyWindow?.rootViewController = RootViewController
        
//        let ud = UserDefaults.standard
//        ud.set(false, forKey: "isLogin")
//        ud.synchronize()

    }
    
    @IBAction func cancel() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
        UIApplication.shared.keyWindow?.rootViewController = rootViewController

//        let ud = UserDefaults.standard
//        ud.setValue(false, forKey: "isLogin")
//        ud.synchronize()
    }
}
