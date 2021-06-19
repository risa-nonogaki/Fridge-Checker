//
//  SavedRecipeViewController.swift
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

class SavedRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var recipes = [NCMBObject]()
    var recipe: NCMBObject?
    
    @IBOutlet  var savedRecipeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard let currentUser = NCMBUser.current() else {
//
//            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
//            let RootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
//            UIApplication.shared.keyWindow?.rootViewController = RootViewController
//
//            let ud = UserDefaults.standard
//            ud.set(false, forKey: "isLogin")
//            ud.synchronize()
//
//            return
//        }
        
//        loadRecipes()
       
        savedRecipeTableView.delegate = self
        savedRecipeTableView.dataSource = self
        
        savedRecipeTableView.rowHeight = 90
        savedRecipeTableView.tableFooterView = UIView()
        
        setRefreshControl()
        
        savedRecipeTableView.emptyDataSetDelegate = self
        savedRecipeTableView.emptyDataSetSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ud = UserDefaults.standard
        let user = NCMBUser.current()
        //if_letでやらない理由は、アカウントからログアウトしていた場合、NCMBUser.current()はnilで飛ばされてしまうから！
        if user?.mailAddress == nil || ud.bool(forKey: "isLogin") == false {
            //匿名ユーザだったらマイページは存在しない！
            self.performSegue(withIdentifier: "toNoUser", sender: nil)
        } else {
            loadRecipes()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailFour" {
            let viewController = segue.destination as! DetailRecipeViewController
            
            viewController.recipe = recipe
        } else if segue.identifier == "toNoUser" {
            let viewController = segue.destination as! NoUserViewController
            
        }

    }
    
    // 下に引っ張ってリリースすると更新されるUIの設定
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeLine(refreshControl:)), for: .valueChanged)
        savedRecipeTableView.addSubview(refreshControl)
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
        
        recipes = []
        
        let query = NCMBQuery(className: "Recipe")
        query?.includeKey("user")
        
        query?.order(byDescending: "createDate")
        
        query?.findObjectsInBackground({ (recipe, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error?.localizedDescription)
            } else {
                
                for one in recipe! {
                    
                    var one = one as! NCMBObject
                    var savedUser = one.object(forKey: "savedUser") as? [String]
                    
                    if savedUser?.contains((NCMBUser.current()?.objectId)!) == true {
                        self.recipes.append(one)
                    }
                }
                print(self.recipes)
                self.savedRecipeTableView.reloadData()
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //選択されたcellの内容を代入
        recipe = recipes[indexPath.row]
        
        self.performSegue(withIdentifier: "toDetailFour", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedRecipeCell")!
        
        let recipeImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let recipeNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        cell.tag = indexPath.row

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

extension SavedRecipeViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "recipes.png")

        return image
    }
    
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        let color: UIColor = UIColor(red: 0.61, green: 1.00, blue: 0.88, alpha: 1.00)
        
        return color
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "保存されているレシピがありません。"
        
        return NSAttributedString(string: text)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "レシピを保存してみましょう！"
        
        return NSAttributedString(string: text)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        let color: UIColor = .white
        
        return color
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        let height: CGFloat = self.view.frame.height / 8
        
        return height

    }
}
