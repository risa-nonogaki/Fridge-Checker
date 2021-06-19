//
//  FridgeSearchRecipeViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/10/21.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD
import Kingfisher
import DZNEmptyDataSet

class FridgeSearchRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //Itemの名前だけ前の画面から画面遷移された
    var fridgeItemsName = [String]()
    //filterがかけられた後のレシピの表示のための配列
    var showRecipes = [NCMBObject]()
    
    var selectedRecipe: NCMBObject?

    
    @IBOutlet var fridgeRecipeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        fridgeRecipeTableView.delegate = self
        fridgeRecipeTableView.dataSource = self
        
        fridgeRecipeTableView.tableFooterView = UIView()
        fridgeRecipeTableView.rowHeight = 100
        
        //dznEmptyDataSet用のデリゲート
        fridgeRecipeTableView.emptyDataSetSource = self
        fridgeRecipeTableView.emptyDataSetDelegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {

        searchRecipe()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            //値渡し
            let viewController = segue.destination as! DetailRecipeViewController
            print(self.selectedRecipe)
            viewController.recipe = self.selectedRecipe
        }

    }
    
    func searchRecipe() {

        showRecipes.removeAll()
        print(showRecipes.count)
        
        let ud = UserDefaults.standard
        
        let query = NCMBQuery(className: "Recipe")

        query?.findObjectsInBackground({ (recipes, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error?.localizedDescription)
            } else {

                for recipe in recipes as! [NCMBObject] {
                    
                    let recipeName = recipe.object(forKey: "recipeName") as! String
                    ud.set(false, forKey: recipeName)
                    print(ud.bool(forKey: recipeName))

                    //レシピに含まれている材料を配列で取得する
                    
                    let item: [String] = recipe.object(forKey: "ingredients") as! [String]
                    
                    //resultに全てのRecipeが入っている
                    //それをitemNameで絞る
                    for itemName in self.fridgeItemsName {
                        
                        //食品の名前でフィルタをかけたものを宣言
                        let itemFiltered = item.filter{$0 == itemName}
//                        print(itemFiltered)
                        //フィルタで引っかかるものがあったら
                        if itemFiltered.count > 0 {
                            //すでに配列に入っていたらtrue
                            if ud.bool(forKey: recipeName) == false {
                                
                                self.showRecipes.append(recipe)
                                ud.set(true, forKey: recipeName)
                            }

                            continue
                        }
                       
//                        self.fridgeRecipeTableView.reloadData()
                        print(self.showRecipes.count)
                        
//                        self.showRecipes.removeAll()
                    }
                    self.fridgeRecipeTableView.reloadData()
                }

            }
        })


    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchRecipeCell")!
        
        let recipeImageview = cell.viewWithTag(1) as! UIImageView
        let recipeNameLabel = cell.viewWithTag(2) as! UILabel
        
        let recipeImageUrl = showRecipes[indexPath.row].object(forKey: "imageUrl") as! String
        
        recipeImageview.kf.setImage(with: URL(string: recipeImageUrl))
        recipeImageview.layer.cornerRadius = recipeImageview.bounds.width / 8.0
        recipeImageview.layer.masksToBounds = true
        
        recipeNameLabel.text = showRecipes[indexPath.row].object(forKey: "recipeName") as! String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(showRecipes.count)
        return showRecipes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedRecipe = showRecipes[indexPath.row]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.performSegue(withIdentifier: "toDetail", sender: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension FridgeSearchRecipeViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "recipes.png")

        return image
    }
    
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        let color: UIColor = UIColor(red: 0.61, green: 1.00, blue: 0.88, alpha: 1.00)
        
        return color
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "当てはまるレシピがありません。"
        
        return NSAttributedString(string: text)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = " "
        
        return NSAttributedString(string: text)
    }

}


