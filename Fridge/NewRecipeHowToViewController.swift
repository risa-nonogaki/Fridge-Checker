//
//  NewRecipeHowToViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/10/11.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD

class NewRecipeHowToViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HowToMakeTableViewCellDelegate {

    var selectedCell: Int = 0
    var howToMakeArray = [String]()
    var howToMakeImagesArray = [UIImage]()
    //画像のURLを配列で保存する
    var howToMakeUrlArray = [String]()
    
    @IBOutlet var howToMakeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        howToMakeTableView.delegate = self
        howToMakeTableView.dataSource = self
        
        howToMakeTableView.tableFooterView = UIView()
        howToMakeTableView.rowHeight = 70
        
        let nib = UINib(nibName: "HowToMakeTableViewCell", bundle: Bundle.main)
        howToMakeTableView.register(nib, forCellReuseIdentifier: "NewRecipeCell")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ud = UserDefaults.standard
        if ud.bool(forKey: "newRecipe") == true {

            if ud.bool(forKey: "makingRecipe3") == false {
                howToMakeArray.removeAll()
                    
                //作ってる最中って伝えるもの
                ud.set(true, forKey: "makingRecipe3")
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return howToMakeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewRecipeCell") as! HowToMakeTableViewCell
        cell.tag = indexPath.row
        cell.numberLabel.text = String(indexPath.row + 1)
        cell.descriptionTextField.text = howToMakeArray[indexPath.row]
        cell.howToMakeImageView.image = howToMakeImagesArray[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 選択した写真をURLにして配列に格納する

        howToMakeImagesArray[selectedCell] = (info[.originalImage] as! UIImage).scale(byFactor: 0.2)
        
        let imageData = howToMakeImagesArray[selectedCell].pngData()
        
        let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: imageData) as! NCMBFile
        file.saveInBackground { (error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error?.localizedDescription)
            } else {
                let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/W2F9rOIkiUvzkQMC/publicFiles/" + file.name
                //配列にURLで保存しておく
                self.howToMakeUrlArray.append(url)
                self.howToMakeTableView.reloadData()
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func didEditHowToMakeTextField(tableViewCell: UITableViewCell, textField: UITextField) {
        //cellのtextfieldを編集したら配列に代入し直す
        howToMakeArray[tableViewCell.tag] = textField.text!
        //print(howToMakeArray)
    }
    
    func choosePhoto(tableViewCell: UITableViewCell, button: UIButton) {

        selectedCell = tableViewCell.tag
        
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
    
    func deleteButton(tableViewCell: UITableViewCell, button: UIButton) {
        print("deleteButton is called!")
        
        howToMakeArray.remove(at: tableViewCell.tag)
        howToMakeUrlArray.remove(at: tableViewCell.tag)
        howToMakeImagesArray.remove(at: tableViewCell.tag)
        
        howToMakeTableView.reloadData()
    }
    
    @IBAction func tapScreen(_ sender: Any) {
            self.view.endEditing(true)
    }
    
    
    @IBAction func addRecipe() {
        howToMakeArray.append("")
        howToMakeImagesArray.append((defaultImage?.scale(byFactor: 0.2))!)
        //デフォルトの画像がアップロードされたらその番号目の配列は""だから、それで条件分岐して表示or保存の時にdefaultimageをURL化させたものを保存
        howToMakeUrlArray.append("")
        howToMakeTableView.reloadData()

    }
    
    @IBAction func upload() {
        //投稿のために全ての情報をNCMBにアップロードする
        let ud = UserDefaults.standard
        //1
        let recipeName = ud.string(forKey: "recipeName")
        let recipeImageUrl = ud.string(forKey: "recipeImageUrl")
        //2
        let numberOfPeople = ud.string(forKey: "numberOfPeople")
        let ingredientsArray = ud.array(forKey: "ingredientsArray")
        let quantityArray = ud.array(forKey: "quantityArray")
        let unitArray = ud.array(forKey: "unitArray")

        print(unitArray)
        print(recipeImageUrl)
        let recipe = NCMBObject(className: "Recipe")
        recipe?.setObject(recipeName, forKey: "recipeName")
        recipe?.setObject(recipeImageUrl, forKey: "imageUrl")
        recipe?.setObject(numberOfPeople, forKey: "numberOfPeople")
        recipe?.setObject(ingredientsArray, forKey: "ingredients")
        recipe?.setObject(quantityArray, forKey: "quantities")
        recipe?.setObject(unitArray, forKey: "units")
        recipe?.setObject(howToMakeArray, forKey: "howToMake")
        recipe?.setObject(howToMakeUrlArray, forKey: "howToMakeUrl")
        recipe?.setObject(NCMBUser.current()?.objectId, forKey: "user")
        
        recipe?.saveInBackground({ (error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error?.localizedDescription)
            } else {
                let alertController = UIAlertController(title: "👍", message: "投稿完了しました！", preferredStyle: .alert)
                
                self.present(alertController, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        //userDefaultsの内容を削除
                        ud.removeObject(forKey: "recipeName")
                        ud.removeObject(forKey: "recipeImageUrl")
                        ud.removeObject(forKey: "numberOfPeople")
                        ud.removeObject(forKey: "ingredientsArray")
                        ud.removeObject(forKey: "quantityArray")
                        ud.removeObject(forKey: "unitArray")
                        
                        //値を削除
                        self.howToMakeArray.removeAll()
                        self.howToMakeUrlArray.removeAll()
                        self.howToMakeImagesArray.removeAll()
                        
                        self.dismiss(animated: true, completion: nil)
                        self.navigationController?.popToRootViewController(animated: true)
                        self.tabBarController?.selectedIndex = 0
                        
                        ud.set(true, forKey: "newRecipe")
                    }
                }
            }
        })
    }

}
