//
//  NewRecipeViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/13.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit
import KRProgressHUD

class NewRecipeViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var resizedImage: UIImage!
    var selectedImage = defaultImage
    var window: UIWindow!

    @IBOutlet var recipeImageView: UIImageView!
    @IBOutlet var recipeTextField: UITextField!
    @IBOutlet var nextPageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeTextField.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ud = UserDefaults.standard
        let user = NCMBUser.current()
        if user?.mailAddress == nil || ud.bool(forKey: "isLogin") == false {
            print("匿名です")
            //匿名ユーザだったらマイページは存在しない！
            self.performSegue(withIdentifier: "toNoUser", sender: nil)
        }

        if ud.bool(forKey: "newRecipe") == true {

            if ud.bool(forKey: "makingRecipe1") == false {
                recipeImageView.image = defaultImage
                recipeTextField.text = ""
                nextPageButton.isHidden = true
                
                //作ってる最中って伝えるもの
                ud.set(true, forKey: "makingRecipe1")
            }
        }

        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        selectedImage = info[.originalImage] as! UIImage
        resizedImage = selectedImage!.scale(byFactor: 0.2)
        // 選択した写真を表示
        recipeImageView.image = resizedImage
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードのreturnキーで完了
        self.view.endEditing(true)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // レシピ名が書き込まれていたら次へのボタンが表示
        if recipeTextField.text != nil {
            nextPageButton.isHidden = false
        } else {
            nextPageButton.isHidden = true
        }
    }
    
    func clearEverything() {
        
        // 編集内容を全て消去する
        self.recipeTextField.text = ""
        self.recipeImageView.image = UIImage(named: "cameraPlaceHolder.png")
        
    }
    
    //次のペーじに進む前にuserdefaultsに情報を保存しておく
    func saveRecipe() {
        
        // 撮影した画像をデータ化した時に右に90度回転してしまう問題の解消
        UIGraphicsBeginImageContext(resizedImage.size)
        let rect = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
        resizedImage.draw(in: rect)
        // returns image from the bit-map based content
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        // to clean up the drawing environment
        UIGraphicsEndImageContext()

        let data = resizedImage.pngData()
        let file = NCMBFile.file(with: data) as! NCMBFile

        file.saveInBackground { [self] (error) in

            if error != nil {

                KRProgressHUD.showError(withMessage: error?.localizedDescription)

            } else {
                
                let ud = UserDefaults.standard
                
                let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/W2F9rOIkiUvzkQMC/publicFiles/" + file.name
                
                ud.set(self.recipeTextField.text, forKey: "recipeName")
                ud.set(url, forKey: "recipeImageUrl")
  
                print(ud.string(forKey: "recipeImageUrl"))
                
                self.performSegue(withIdentifier: "toIngredients", sender: nil)

            }

        } progressBlock: { (progress) in

            print(progress)

        }
 
    }
    
    @IBAction func tapScreen(_ sender: Any) {
            self.view.endEditing(true)
    }
    
    //1ページ目
    @IBAction func selectImage() {
        //tagの値でどちらの写真か識別

        let alertController = UIAlertController(title: "写真を選択", message: "写真の選択方法を選んでください", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let image = UIImagePickerController()
                image.sourceType = .camera
                image.delegate = self
                self.present(image, animated: true, completion: nil)
                
            } else {
                let alertController = UIAlertController(title: "エラー", message: "この機種ではカメラは利用できません。", preferredStyle: .alert)
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
                let alertController = UIAlertController(title: "エラー", message: "この機種では写真アルバムは利用できません。", preferredStyle: .alert)
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
    
    @IBAction func nextPage() {
        
        if self.resizedImage == nil {

            let alertController = UIAlertController(title: "⚠︎", message: "レシピ画像の登録をしていないですが、よろしいですか。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { [self] (action) in

                alertController.dismiss(animated: true, completion: nil)
                
                self.selectedImage = defaultImage
                self.resizedImage = self.selectedImage!.scale(byFactor: 0.2)
                
                self.saveRecipe()

            }

            let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }

            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)

        } else {
            
            self.saveRecipe()

        }
        
        
    }
    
    @IBAction func cancel() {
        let alertController = UIAlertController(title: "⚠︎", message: "編集内容を消去しても良いですか", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "消去", style: .default) { (action) in
            
            self.clearEverything()
            let ud = UserDefaults.standard
            ud.set(true, forKey: "newRecipe")
            
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

