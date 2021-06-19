//
//  ChangeInItemsViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/05.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import KRProgressHUD
import NCMB
import Kingfisher

class ChangeInItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChangeInItemsTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var newItemsArray = [String]()
    var quantitiesArray = [Int]()
    var unitsArray = [String]()
    var categoriesArray = [String]()
    var itemImagesArray = [UIImage]()
    //画像ファイルにしたものを保存する配列
    var fileArray = [NCMBFile]()
    var pickedImage: UIImage!
    var pickerImageUrlArray = [String]()
    var selectedIndex: Int = 0
    var selectedImage: UIImage!

    @IBOutlet var itemsTableView: UITableView!
    
    @IBOutlet var usedOrBought: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        
        itemsTableView.tableFooterView = UIView()
        itemsTableView.rowHeight = 60
        
        // カスタムセルの設定
        let nib = UINib(nibName: "ChangeInItemsTableViewCell", bundle: Bundle.main)
        itemsTableView.register(nib, forCellReuseIdentifier: "NewItemsCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return newItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewItemsCell") as! ChangeInItemsTableViewCell

        cell.delegate = self
        cell.tag = indexPath.row

        //配列に、格納されている情報を一つ一つ代入する
        cell.itemNameLabel.text = newItemsArray[indexPath.row]
        cell.quantityTextField.text = String(quantitiesArray[indexPath.row])
        cell.unitTextField.text = unitsArray[indexPath.row]
        cell.categoryTextField.text = categoriesArray[indexPath.row]
        cell.itemImageView.image = itemImagesArray[indexPath.row]

        return cell
    }

    func deleteButton(tableViewCell: UITableViewCell, button: UIButton) {
        print("deleteButton is called!")
        
        //　選択したcellの内容を配列から削除する
        
        newItemsArray.remove(at: tableViewCell.tag)
        quantitiesArray.remove(at: tableViewCell.tag)
        unitsArray.remove(at: tableViewCell.tag)
        categoriesArray.remove(at: tableViewCell.tag)
        itemImagesArray.remove(at: tableViewCell.tag)
        
        itemsTableView.reloadData()
    }
    
    func didEditQuantityTextField(tableViewCell: UITableViewCell, textField: UITextField) {
        
        quantitiesArray[tableViewCell.tag] = Int(textField.text!)!
    }
    
    func didEditUnitTextField(tableViewCell: UITableViewCell, textField: UITextField) {
        
        unitsArray[tableViewCell.tag] = textField.text!
    }
    
    func didEditCategoryTextField(tableViewCell: UITableViewCell, textField: UITextField) {
        
        categoriesArray[tableViewCell.tag] = textField.text!
    }
    
    func doPickPhoto(tableViewCell: UITableViewCell, button: UIButton) {
        //選択されたcellのindexを保管しておく
        selectedIndex = tableViewCell.tag
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        selectedImage = info[.originalImage] as! UIImage
        
        itemImagesArray[selectedIndex] = selectedImage.scale(byFactor: 0.2)
        // 選択した写真を表示
        itemsTableView.reloadData()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addItems() {
        let alertController = UIAlertController(title: "商品を追加", message: "商品名入力してください", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "追加", style: .default) { (action) in
            //冷蔵庫に既にその食べ物がある場合は、unitとcategoryを先に表示してしまう！
            let query = NCMBQuery(className: "Items")

            query?.whereKey("itemName", equalTo: (alertController.textFields?.first?.text)!)
            //自分が以前追加したことあるもののみ
            query?.whereKey("user", equalTo: NCMBUser.current())
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error?.localizedDescription)
                } else {
                    //もしもその食べ物があったら
                    if result?.isEmpty == false {
                        let items = result as! [NCMBObject]
                        print(items.count)
                        let item = items.first
                        let itemUnit = item?.object(forKey: "unit") as! String
                        let itemCategory = item?.object(forKey: "category") as! String
                        let itemImage = item?.object(forKey: "itemImage") as! String
                        let data = try? Data(contentsOf: URL(string: itemImage)!) //URLは存在するかと確認して下さい。もし存在しない可能があれば
                        
    //                    print(itemUnit)
    //                    print(itemCategory)
                        
                        self.newItemsArray.append((alertController.textFields?.first?.text)!)
                        self.quantitiesArray.append(0)
                        self.unitsArray.append(itemUnit)
                        self.categoriesArray.append(itemCategory)
                        self.itemImagesArray.append(UIImage(data: data!)!)

                    } else {
                        
                        self.newItemsArray.append((alertController.textFields?.first?.text)!)
                        self.quantitiesArray.append(0)
                        self.unitsArray.append("")
                        self.categoriesArray.append("")
                        self.itemImagesArray.append(defaultImage!)

                    }
                }
                
                self.itemsTableView.reloadData()
            })

        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        // textFieldをalertControllerに追加する
        alertController.addTextField { (textField) in
            textField.placeholder = "商品名"
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func update() {

        for image in itemImagesArray {
            UIGraphicsBeginImageContext(image.size)
            var image = image
            let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            image.draw(in: rect)
            // returns image from the bit-map based content
            image = UIGraphicsGetImageFromCurrentImageContext()!
            // to clean up the drawing environment
            UIGraphicsEndImageContext()
            
            let data = image.pngData()
            let file = NCMBFile.file(with: data) as! NCMBFile
            
            fileArray.append(file)

        }
        // cellそれぞれに値が入っていなかったらだめ
        if (newItemsArray.count == quantitiesArray.count) && (quantitiesArray.count == unitsArray.count) {
            
            // newitemsクラスに読み込んだものを一つ一つitemクラスにアペンド
            // 0 - newItemsの個数
            for i in 0...(newItemsArray.count  - 1){
                
                let query = NCMBQuery(className: "Items")
                query?.whereKey("itemName", equalTo: newItemsArray[i])
                query?.includeKey("quantity")
                query?.findObjectsInBackground({ (items, error) in

                    if error != nil {
                        KRProgressHUD.showError(withMessage: error?.localizedDescription)
                    } else {
                        if items?.isEmpty == true {                            // 値がないのに「使った」は間違い
                            if self.usedOrBought.selectedSegmentIndex == 1 {
                                let alertController = UIAlertController(title: "⚠︎", message: "冷蔵庫にない項目を使ったことになっています。", preferredStyle: .alert)
                                let fixAction = UIAlertAction(title: "修正する", style: .default) { (action) in
                                    alertController.dismiss(animated: true, completion: nil)
                                }
                                
                                alertController.addAction(fixAction)
                                self.present(alertController, animated: true, completion: nil)
                                
                            } else {
                                // 同じ商品名が入っていなかった場合新しくNCMBに追加したい
                                    
                                self.fileArray[i].saveInBackground { (error) in
                                    if error != nil {
                                        KRProgressHUD.showError(withMessage: error?.localizedDescription)
                                    } else {
                                        
                                        let itemObject = NCMBObject(className: "Items")

                                        itemObject?.setObject(NCMBUser.current(), forKey: "user")
                                        itemObject?.setObject(self.newItemsArray[i], forKey: "itemName")
                                        itemObject?.setObject(self.quantitiesArray[i], forKey: "quantity")
                                        itemObject?.setObject(self.unitsArray[i], forKey: "unit")
                                        itemObject?.setObject(self.categoriesArray[i], forKey: "category")
                                        let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/W2F9rOIkiUvzkQMC/publicFiles/" + self.fileArray[i].name
                                        itemObject?.setObject(url, forKey: "itemImage")
                                    
                                        // 0なら買った1なら使った
    //                                    itemObject?.setObject(String(self.usedOrBought.selectedSegmentIndex), forKey: "usedOrBought")
                                        
                                        itemObject?.saveInBackground({ (error) in
                                            if error != nil {
                                                KRProgressHUD.showError(withMessage: error?.localizedDescription)
                                            } else {
                                                
                                                self.navigationController?.popViewController(animated: true)
                                            }
                                        })
                                    }
                                }
                            }

                        } else {
                            // すでに同じ名前があったら個数を変更
                            for item in items as! [NCMBObject] {
                                
                                var itemQuantity: Int = 0
                                
                                itemQuantity = item.object(forKey: "quantity") as! Int
                                // 新しく追加されたものの個数を反映する
                                // 0なら買った1なら使った
                                if self.usedOrBought.selectedSegmentIndex == 0 {
                                    itemQuantity = itemQuantity + self.quantitiesArray[i]
                                } else if self.usedOrBought.selectedSegmentIndex == 1 {
                                    itemQuantity = itemQuantity - self.quantitiesArray[i]
                                }
                                
                                // そのアイテムの個数をNCMBに設定しなおす
                                item.setObject(itemQuantity, forKey: "quantity")
                                item.saveInBackground { (error) in
                                    if error != nil {
                                        KRProgressHUD.showError(withMessage: error?.localizedDescription)
                                    } else {
                                        // 保存に成功したら戻る
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                }
                            }
                        }
                        
                    }
                })
            }
        } else {
            let alertController = UIAlertController(title: "⚠︎", message: "入力内容に不足があります。", preferredStyle: .alert)
            self.present(alertController, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
       
    }
    
    @IBAction func cancel() {
        let alertController = UIAlertController(title: "キャンセル", message: "編集内容を破棄しますがよろしいですか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // cancelしたらcellにかかれていた内容を消去して、画面を前の画面に遷移する
            self.newItemsArray.removeAll()
            self.quantitiesArray.removeAll()
            self.unitsArray.removeAll()
            self.categoriesArray.removeAll()
            self.itemImagesArray.removeAll()
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
