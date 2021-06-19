//
//  LogInViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/01.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD

class LogInViewController: UIViewController {
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func logIn() {
        if userNameTextField.text!.count > 0 && passwordTextField.text!.count > 0 {
            // 入力情報を元にログインする

            if userNameTextField.text?.contains("@") == true {
                NCMBUser.logInWithMailAddress(inBackground: userNameTextField.text, password: passwordTextField.text) { (user, error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: "ログイン情報が間違っています！")
                    } else {
                        self.userNameTextField.text = user?.userName
                        KRProgressHUD.showSuccess()
                        //画面遷移
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")

                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                                            
                        let ud = UserDefaults.standard
                        ud.set(true, forKey: "isLogin")
                        ud.synchronize()
                    }
                }
            } else {
                
                NCMBUser.logInWithUsername(inBackground: userNameTextField.text, password: passwordTextField.text) { (user, error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: "ログイン情報が間違っています！")
                    } else {
                        KRProgressHUD.showSuccess()
                        // 成功したら画面遷移
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
                        
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                        
                        let ud = UserDefaults.standard
                        ud.set(true, forKey: "isLogin")
                        ud.synchronize()
                        
                    }
                }
            }
            
        } else {
            let alertController = UIAlertController(title: "エラー", message: "入力が完了していません", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
