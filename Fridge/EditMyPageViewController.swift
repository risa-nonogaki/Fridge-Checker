//
//  EditMyPageViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/04.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD
import NYXImagesKit
import Kingfisher

class EditMyPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var resizedImage: UIImage!
    var placeholder = UIImage(named: "placeholderHuman.jpg")
    var oldPassword: String!
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameTextField.delegate = self
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 8.0
        profileImageView.layer.masksToBounds = true
        
        if let user = NCMBUser.current() {
            
            userNameTextField.text = user.userName
            let imageUrl = user.object(forKey: "imageUrl") as! String
            
            profileImageView.kf.setImage(with: URL(string: imageUrl))
            
//            let data = try? Data(contentsOf: URL(string: imageUrl)!)
//            print(imageUrl)
//            print(data)
            //URLは存在するかと確認して下さい。もし存在しない可能があれば if let / try-catch でアンラップして下さい。
//            DispatchQueue.main.async {
//                self.resizedImage = UIImage(data: data!)
//            }

        } else {
            
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            
            return
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[.originalImage] as! UIImage
        
        resizedImage = selectedImage.scale(byFactor: 0.2)
        
        profileImageView.image = resizedImage

        picker.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func changeProfile() {
        let alertController = UIAlertController(title: nil, message: "画像取得方法を選択", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let camera = UIImagePickerController()
                camera.sourceType = .camera
                camera.delegate = self
                self.present(camera, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "エラー", message: "この機種ではカメラを利用できません", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        let photoAlbumAction = UIAlertAction(title: "写真アルバム", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let photoAlbum = UIImagePickerController()
                photoAlbum.sourceType = .photoLibrary
                photoAlbum.delegate = self
                self.present(photoAlbum, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "エラー", message: "この機種では写真アルバムを利用できません", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        alertController.addAction(photoAlbumAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func saveChanges() {
        //KRProgressHUD.show()
        //撮影した画像をデータ化した時に右に90度回転してしまう問題の解消
        if resizedImage != nil {
            UIGraphicsBeginImageContext(resizedImage!.size)
            let rect = CGRect(x: 0, y: 0, width: resizedImage!.size.width, height: resizedImage!.size.height)
            resizedImage!.draw(in: rect)
            // returns image from the bit-map based content
            resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            // to clean up the drawing environment
            UIGraphicsEndImageContext()
            
            //PNGにファイルを変換して保存する
            let data = resizedImage!.pngData()
            let file = NCMBFile.file(with: data) as! NCMBFile
            // 画像をNCMBFileに保存している
            
            file.saveInBackground({ (error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error?.localizedDescription)
    
                } else {
            
                    let user = NCMBUser.current()
                    user?.setObject(self.userNameTextField.text, forKey: "userName")
                    let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/W2F9rOIkiUvzkQMC/publicFiles/" + file.name
                    user?.setObject(url, forKey: "imageUrl")
                    
                    user?.saveInBackground({(error)in
                        if error != nil{
                        }else{
                            self.dismiss(animated: true, completion: nil)
                            self.navigationController?.popViewController(animated: true)//元の画面に戻る
                        }
                    })

                }
            }) { (progress) in
                print(progress)
            }
        } else {
            let user = NCMBUser.current()
            user?.setObject(self.userNameTextField.text, forKey: "userName")
            
            user?.saveInBackground({ (error) in
                if error != nil {
                    //エラー
                } else {
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)//元の画面に戻る
                }
            })
        }
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

}
