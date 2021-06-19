//
//  ExploreViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/01.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD
import Kingfisher

class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var searchBar: UISearchBar!
    var recipes = [NCMBObject]()
    //レシピの名前だけかえる
    var recipesName = [String]()
    var recipe: NCMBObject?
    
    @IBOutlet var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        searchTableView.tableFooterView = UIView()
        searchTableView.rowHeight = 100
        
        let nib = UINib(nibName: "ExploreTableViewCell", bundle: Bundle.main)
        searchTableView.register(nib, forCellReuseIdentifier: "ExploreCell")
        
        setSearchBar()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreCell") as! ExploreTableViewCell
        let recipeImageUrl = recipes[indexPath.row].object(forKey: "imageUrl") as! String
        cell.recipeImageView.kf.setImage(with: URL(string: recipeImageUrl))
        cell.recipeImageView.layer.cornerRadius = cell.recipeImageView.bounds.width / 8.0
        cell.recipeImageView.layer.masksToBounds = true
        cell.recipeNameLabel.text = recipes[indexPath.row].object(forKey: "recipeName") as! String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        recipe = recipes[indexPath.row]
        self.performSegue(withIdentifier: "toDetail", sender: nil)
        // 選択されてるcellを画面遷移するときに解除する
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //値渡し
        let viewController = segue.destination as! DetailRecipeViewController
        
        viewController.recipe = recipe
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        loadRecipes(searchText: searchBar.text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        loadRecipes(searchText: searchBar.text)
    }
    

    
    func setSearchBar() {
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "レシピ名で検索"
            searchBar.autocapitalizationType = .none

            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    
    func loadRecipes(searchText: String?) {
        // レシピをNCMBから取得する
        let query = NCMBQuery(className: "Recipe")
        
        // 検索ワードあり
        if let text = searchText {
            query!.whereKey("recipeName", equalTo: text)
        }
        
        query?.order(byDescending: "createDate")
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error?.localizedDescription)
            } else {
                
                self.recipes = result as! [NCMBObject]
                
                self.searchTableView.reloadData()
                
            }
        })
        
    }

}
