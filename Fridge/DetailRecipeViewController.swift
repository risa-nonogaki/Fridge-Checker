//
//  DetailRecipeViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/26.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import KRProgressHUD

class DetailRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var recipe: NCMBObject?
    var tag: Int = 0
    var isSaved: Bool = true
    var cellIdentifier: String = ""
    var ingredientsArray = [String]()
    var howToMakeArray = [String]()
    var tagFilledImage = UIImage(named: "tabbar-icon-tagFilled@2x.png")
    var tagImage = UIImage(named: "tabbar-icon-tag@2x.png")
    var savedCounter: Int = 0
    var recipeObjectId: String = ""
    
    @IBOutlet var ingredientsTableView: UITableView!
    @IBOutlet var howToMakeTableView: UITableView!
    @IBOutlet var recipeImageView: UIImageView!
    @IBOutlet var recipeNameLabel: UILabel!
    @IBOutlet var numberOfPeopleLabel: UILabel!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var deleteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDetail()
        
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        howToMakeTableView.delegate = self
        howToMakeTableView.dataSource = self
        
        ingredientsTableView.rowHeight = 43.5
        howToMakeTableView.rowHeight = 90
        
        ingredientsTableView.tableFooterView = UIView()
        howToMakeTableView.tableFooterView = UIView()
        
        recipeNameLabel.text = recipe?.object(forKey: "recipeName") as! String
        numberOfPeopleLabel.text = recipe?.object(forKey: "numberOfPeople") as! String + "人前"
        
        let imageUrl = recipe?.object(forKey: "imageUrl") as! String
        recipeImageView.kf.setImage(with: URL(string: imageUrl))
        recipeImageView.layer.cornerRadius = recipeImageView.bounds.width / 8.0
        recipeImageView.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ud = UserDefaults.standard
        let user = NCMBUser.current()
        if user?.mailAddress == nil || ud.bool(forKey: "isLogin") == false {
            //匿名ユーザ,ログアウトしていたら
            saveButton.isEnabled = false
            saveButton.isHidden = true
        } else {
            saveButton.isEnabled = true
            saveButton.isHidden = false
        }
    }

    // 複数あるTableViewを条件分岐
    func checkTableView(_ tableView: UITableView) -> Void {
        
        if tableView.tag == 0 {
            tag = 0
            cellIdentifier = "IngredientCell"
            
        } else {
            tag = 1
            cellIdentifier = "HowToMakeCell"
        }
    }
    
    func loadDetail() {
        let creator = recipe?.object(forKey: "user") as! String
        //はじめに配列の個数を確認することで、cellの個数を明らかにする
        ingredientsArray = recipe?.object(forKey: "ingredients") as! [String]
        howToMakeArray = recipe?.object(forKey: "howToMake") as! [String]
        recipeObjectId = (recipe?.objectId)!
        
        let user = NCMBUser.current()
        
        var savedUser = recipe?.object(forKey: "savedUser") as? [String]
        
        if user != nil {
            
            if savedUser!.contains((user?.objectId)!){
                isSaved = true
                print(isSaved)
                saveButton.setBackgroundImage(tagFilledImage, for: .normal)
            } else {
                isSaved = false
                print(isSaved)
                saveButton.setBackgroundImage(tagImage, for: .normal)
            }
        }
        
        if creator == user?.objectId {
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
        }
        
//        print(savedCounter,"7777")
 
        ingredientsTableView.reloadData()
        howToMakeTableView.reloadData()
        
    }
    
    func reloadDetail(){
        // 画面遷移前に情報を取得しているからboolかたのobjectが変わらないのでは？
        let query = NCMBQuery(className: "Recipe")
        
        query?.whereKey("objectId", equalTo: recipeObjectId)
        query?.findObjectsInBackground({ (recipeResult, error) in
            
            var recipe = recipeResult as! [NCMBObject]
            var savedUser = recipe.first?.object(forKey: "savedUser") as? [String]
            if savedUser!.contains((NCMBUser.current()?.objectId)!) == true {
                self.isSaved = true
                print(self.isSaved)
                self.saveButton.setBackgroundImage(self.tagFilledImage, for: .normal)
            } else {
                self.isSaved = false
                print(self.isSaved)
                self.saveButton.setBackgroundImage(self.tagImage, for: .normal)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        checkTableView(tableView)
        
        if tableView.tag == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!

            let ingredientNameLabel = cell.contentView.viewWithTag(1) as! UILabel
            let amountLabel = cell.contentView.viewWithTag(2) as! UILabel
            
            let amounts = recipe?.object(forKey: "quantities") as! [String]
            let units = recipe?.object(forKey: "units") as! [String]
            
            ingredientNameLabel.text = ingredientsArray[indexPath.row]
            amountLabel.text = amounts[indexPath.row] + units[indexPath.row]
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
            
            let howToMakeTextView = cell.contentView.viewWithTag(1) as! UITextView
            let indexLabel = cell.contentView.viewWithTag(2) as! UILabel
            let howToMakeImageView = cell.contentView.viewWithTag(3) as! UIImageView

            let howToMakeImageArray = recipe?.object(forKey: "howToMakeUrl") as! [String]
            
            for i in 0...(howToMakeImageArray.count-1) {
                if howToMakeImageArray[i] == nil || howToMakeImageArray[i] == "" {
                    howToMakeImageView.image = defaultImage
                } else {
                    howToMakeImageView.kf.setImage(with: URL(string: howToMakeImageArray[indexPath.row]))
                    
                }
            }
            
            howToMakeTextView.text = howToMakeArray[indexPath.row]
            indexLabel.text = String(indexPath.row + 1)
            
            return cell
            
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        checkTableView(tableView)
        
        if tableView.tag == 0 {

            return ingredientsArray.count
            
        } else {
            
            return howToMakeArray.count
            
        }
        
    }
    
    //保存
    @IBAction func saveRecipe() {
        
        guard let currentUser = NCMBUser.current() else {
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let RootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = RootViewController
//            let ud = UserDefaults.standard
//            ud.set(false, forKey: "isLogin")
//            ud.synchronize()
//            
            return
        }
        
        //ボタンが押されるたびに回数を数えて奇数偶数で条件分岐
//        savedCounter += 1
//        print(savedCounter)
        if isSaved == false || isSaved == nil {
            
            let query = NCMBQuery(className: "Recipe")
            print(recipeObjectId)

            query?.getObjectInBackground(withId: recipeObjectId, block: { (recipes, error) in
                if error != nil {
                    print(error)
                } else {
                    recipes?.addUniqueObject(NCMBUser.current()?.objectId!, forKey: "savedUser")
                    recipes?.saveEventually({ (error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error?.localizedDescription)
                        } else {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                self.reloadDetail()
//                            }
                            self.reloadDetail()

                        }
                    })
                }
            })
        } else {
            // 保存する
            let query = NCMBQuery(className: "Recipe")
            print(recipeObjectId)
            print(NCMBUser.current()?.objectId)
            query?.getObjectInBackground(withId: recipeObjectId, block: { (recipes, error) in
                if error != nil {
                    print(error)
                } else {
                    recipes?.removeObjects(in: [NCMBUser.current()?.objectId!], forKey: "savedUser")
                    recipes?.saveEventually({ (error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error?.localizedDescription)
                        } else {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                self.reloadDetail()
//                            }
                            self.reloadDetail()
                        }
                    })
                }
            })
        }
        
    }
    
    //自分のレシピに対してのみ削除ボタンが表示される
    @IBAction func deleteRecipe() {
        let alertController = UIAlertController(title: "削除", message: "レシピを削除してもよろしいですか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "削除", style: .default) { (action) in
            self.recipe?.deleteInBackground({ (error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error?.localizedDescription)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        KRProgressHUD.showSuccess(withMessage: "削除が完了しました。ホーム画面に戻ります！")
                        self.tabBarController?.selectedIndex = 0
                    }
                    
                }
            })
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
