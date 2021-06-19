//
//  MenuViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/03.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD

class MenuViewController: UIViewController {

    @IBOutlet var menuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // メニューの位置を取得する
        let menuPos = self.menuView.layer.position
        
        // メニューが見えない状態から始めるために、右端が一番端に位置する様にする
        self.menuView.layer.position.x = -self.menuView.frame.width
        
        // メニューが表示される時のアニメーション
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
            self.menuView.layer.position.x = menuPos.x
            }
        ) { (bool) in
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        for touch in touches {
            // メニュー以外の画面がタップされたらメニューが消える
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                }) { (bool) in
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func toMyPage() {
        let ud = UserDefaults.standard
        let user = NCMBUser.current()
        //if_letでやらない理由は、アカウントからログアウトしていた場合、NCMBUser.current()はnilで飛ばされてしまうから！
        if user?.mailAddress == nil || ud.bool(forKey: "isLogin") == false {
            //匿名ユーザだったらマイページは存在しない！
            let alertController = UIAlertController(title: "⚠︎", message: "マイページ閲覧するには、会員登録が必要です！", preferredStyle: .alert)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alertController.dismiss(animated: true, completion: nil)
            }
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            //会員登録を行っていたらマイページは表示できる！
            self.performSegue(withIdentifier: "toMyPage", sender: nil)
        }
    }
    
    @IBAction func logOut() {
        let ud = UserDefaults.standard
        let user = NCMBUser.current()
        //if_letでやらない理由は、アカウントからログアウトしていた場合、NCMBUser.current()はnilで飛ばされてしまうから！
        if user?.mailAddress == nil || ud.bool(forKey: "isLogin") == false {
            //匿名ユーザだったらマイページは存在しない！
            let alertController = UIAlertController(title: "⚠︎", message: "ログアウトには、会員登録が必要です！", preferredStyle: .alert)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alertController.dismiss(animated: true, completion: nil)
            }
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            //会員登録を行っていたらログアウトできる！
            let alertController = UIAlertController(title: "ログアウト", message: "本当にログアウトしていいですか？", preferredStyle: .actionSheet)
            let logOutAction = UIAlertAction(title: "ログアウト", style: .destructive) { (action) in
                NCMBUser.logOutInBackground { (error) in
                    KRProgressHUD.show()
                    if error != nil {
                        KRProgressHUD.showError(withMessage: error?.localizedDescription)
                    } else {
                        KRProgressHUD.showSuccess(withMessage: "ログアウトに成功しました。")
                        
                        // 画面遷移をしてログイン画面に戻る
                        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
                        
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                        
                        let ud = UserDefaults.standard
                        ud.set(false, forKey: "isLogin")
                        ud.synchronize()
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(logOutAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
