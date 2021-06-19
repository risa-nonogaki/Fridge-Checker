//
//  SelfRecipeViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/02.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD
import Kingfisher
import DZNEmptyDataSet

class SelfRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var recipes = [NCMBObject]()
    var recipe: NCMBObject?
    
    @IBOutlet var myRecipeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        loadRecipes()
        
        myRecipeTableView.delegate = self
        myRecipeTableView.dataSource = self
        
        myRecipeTableView.tableFooterView = UIView()
        myRecipeTableView.rowHeight = 90
        
        setRefreshControl()
        
        myRecipeTableView.emptyDataSetDelegate = self
        myRecipeTableView.emptyDataSetSource = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        loadRecipes()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let viewController = segue.destination as! DetailRecipeViewController
        
        viewController.recipe = recipe
    }
    
    // 下に引っ張ってリリースすると更新されるUIの設定
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeLine(refreshControl:)), for: .valueChanged)
        myRecipeTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeLine(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        loadRecipes()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            refreshControl.endRefreshing()
        }
    }
    
    func loadRecipes() {
        
        let query = NCMBQuery(className: "Recipe")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: NCMBUser.current()?.objectId)
        
        query?.order(byDescending: "createDate")
        
        query?.findObjectsInBackground({ (recipe, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error?.localizedDescription)
            } else {
                
                self.recipes = recipe as! [NCMBObject]
                
                self.myRecipeTableView.reloadData()
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //選択されたcellの内容を代入
        recipe = recipes[indexPath.row]
        
        self.performSegue(withIdentifier: "toDetailThree", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelfRecipeCell")!
        
        let recipeImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let recipeNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        cell.tag = indexPath.row
        
//        print(recipes)
        
        let recipeImageUrl = recipes[indexPath.row].object(forKey: "imageUrl") as! String
        recipeImageView.kf.setImage(with: URL(string: recipeImageUrl))
        recipeNameLabel.text = recipes[indexPath.row].object(forKey: "recipeName") as! String
        
        recipeImageView.layer.cornerRadius = recipeImageView.bounds.width / 8.0
        recipeImageView.layer.masksToBounds = true
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recipes.count
    }

}

extension SelfRecipeViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "recipes.png")

        return image
    }
    
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        let color: UIColor = UIColor(red: 0.61, green: 1.00, blue: 0.88, alpha: 1.00)
        
        return color
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "レシピの投稿がありません。"
        
        return NSAttributedString(string: text)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "自分のレシピを投稿してみましょう！"
        
        return NSAttributedString(string: text)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        let color: UIColor = .white
        
        return color
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        let height: CGFloat = self.view.frame.height / 9
        
        return height

    }
}
