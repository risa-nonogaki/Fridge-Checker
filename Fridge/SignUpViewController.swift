//
//  SignUpViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/01.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        emailLabel.isHidden = true
        
        print(defaultProfileImage!.pngData())

    }
    
    @IBAction func signUp() {
        let user = NCMBUser.current()
        if emailTextField.text!.count > 0 {
            // 入力事項が全て記入されていたら登録して画面遷移をする
            
            KRProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                KRProgressHUD.dismiss()
            }
            
            // 撮影した画像をデータ化した時に右に90度回転してしまう問題の解消
            UIGraphicsBeginImageContext(defaultProfileImage!.size)
            let rect = CGRect(x: 0, y: 0, width: defaultProfileImage!.size.width, height: defaultProfileImage!.size.height)
            defaultProfileImage!.draw(in: rect)
            // returns image from the bit-map based content
            defaultProfileImage = UIGraphicsGetImageFromCurrentImageContext()
            // to clean up the drawing environment
            UIGraphicsEndImageContext()

            let data = defaultProfileImage!.pngData()
            let file = NCMBFile.file(with: data) as! NCMBFile
            
            file.saveInBackground { (error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error?.localizedDescription)
                } else {
                    let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/W2F9rOIkiUvzkQMC/publicFiles/" + file.name
                    
                    //プロフィール画像をデフォルトに設定
                    user?.setObject(url, forKey: "imageUrl")
                    user?.setObject(self.emailTextField.text, forKey: "mailAddress")

                    user?.saveInBackground { (error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error?.localizedDescription)
                        } else {
                            //処理成功
                            user?.mailAddress = self.emailTextField.text
                            let alertController = UIAlertController(title: "ステップ①", message: "送信されたメールからユーザ登録を完了させてください！", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "メールからユーザ登録完了", style: .default) { (action) in
                                alertController.dismiss(animated: true, completion: nil)
                                
                                if user?.mailAddress == self.emailTextField.text {
                                    NCMBUser.requestPasswordResetForEmail(inBackground: user?.mailAddress) { (error) in
                                        if error != nil {
                                            print(error)
                                        } else {
                                            print("パスワード設定")
                                            let alertController2 = UIAlertController(title: "ステップ②", message: "ユーザ登録が確認できました。次に送られたメールからパスワードを設定してください！", preferredStyle: .alert)

                                            let okAction2 = UIAlertAction(title: "パスワード設定完了、ログイン画面に戻る", style: .default) { (action) in
                                                alertController2.dismiss(animated: true, completion: nil)
                                                self.navigationController?.popViewController(animated: true)
                                            }

                                            alertController2.addAction(okAction2)
                                            self.present(alertController2, animated: true, completion: nil)

                                        }
                                    }
                                }
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
    
        } else {
            // 必要事項が全部書かれていなかったらアラートが出てそれを伝える。
            let alertController = UIAlertController(title: "エラー", message: "入力に不足があります！", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // returnキーで完了
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        if textField == emailTextField {
            if emailTextField.text!.count == 0 {
                emailLabel.isHidden = false
            } else if emailTextField.text?.contains("@") == false {
                emailLabel.text = "正しいメールアドレスを入力してください"
                emailLabel.isHidden = false
            }
        } else {
            emailLabel.isHidden = true
        }
    }

}
