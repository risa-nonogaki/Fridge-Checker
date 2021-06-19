//
//  UserPageViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/16.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD
import Kingfisher

class UserPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var recipes = [NCMBObject]()
    var recipe: NCMBObject?
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var myRecipeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadRecipes()
        
        myRecipeTableView.delegate = self
        myRecipeTableView.dataSource = self
        
        myRecipeTableView.tableFooterView = UIView()
        myRecipeTableView.rowHeight = 90
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 8.0
        profileImageView.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let user = NCMBUser.current() {
            
            self.navigationItem.title = user.userName
            let imageUrl = user.object(forKey: "imageUrl") as! String
            
            profileImageView.kf.setImage(with: URL(string: imageUrl))
        }
            
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailTwo" {
            let viewController = segue.destination as! DetailRecipeViewController
            
            viewController.recipe = recipe
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
        
        self.performSegue(withIdentifier: "toDetailTwo", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell")!
        
        let recipeImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let recipeNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        cell.tag = indexPath.row
        
//        print(recipes)
        
        let recipeImageUrl = recipes[indexPath.row].object(forKey: "imageUrl") as! String
        recipeImageView.kf.setImage(with: URL(string: recipeImageUrl))
        
        recipeImageView.layer.cornerRadius = recipeImageView.bounds.width / 8.0
        recipeImageView.layer.masksToBounds = true
        
        recipeNameLabel.text = recipes[indexPath.row].object(forKey: "recipeName") as! String
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recipes.count
    }
    
}
