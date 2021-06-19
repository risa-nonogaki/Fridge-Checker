//
//  HomeViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/01.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD
import Kingfisher
import DZNEmptyDataSet

var units: [String] = ["個","mL","L","g","kg","本"]
let category = ["野菜","生鮮食品","調味料","飲み物","冷凍食品","その他"]
var defaultImage = UIImage(named: "cameraPlaceHolder.png")
var defaultProfileImage = UIImage(named: "placeholderHuman.jpg")

class HomeViewController: UIViewController, FridgeTableViewCellDelegate{

    var emptyArray = [String]()
    var veges = [Items]()
    var fresh = [Items]()
    var seasonings = [Items]()
    var drinks = [Items]()
    var frozens = [Items]()
    var others = [Items]()
    var selectedItems = [Items]()
    var allItemsName = [String]()
    var categoryNameIndex: Int?
    
    var tag: Int = 0
    
    @IBOutlet var fridgeTableView: UITableView!
    @IBOutlet var addItemButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setRefreshControl()
        
        let nib = UINib(nibName: "FridgeTableViewCell", bundle: Bundle.main)
        fridgeTableView.register(nib, forCellReuseIdentifier: "FridgeCell")
        
        fridgeTableView.delegate = self
        fridgeTableView.dataSource = self
        
        fridgeTableView.rowHeight = 170
        fridgeTableView.tableFooterView = UIView()
        
        fridgeTableView.emptyDataSetSource = self
        fridgeTableView.emptyDataSetDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        
        let user = NCMBUser.current()
        let ud = UserDefaults.standard
        print(ud.bool(forKey: "isLogin"))
        if ud.bool(forKey: "isLogin") == false && user?.mailAddress != nil {
            //ログアウトしていたら冷蔵庫は使えない！
            addItemButton.isEnabled = false
        } else {
            addItemButton.isEnabled = true
        }
    }
    
    func loadData() {
        //カテゴリーごとに呼び出して代入する
        let query = NCMBQuery(className: "Items")
        query?.whereKey("user", equalTo: NCMBUser.current())
        query?.includeKey("user")

        query?.findObjectsInBackground({ (results, error) in
            
            if error != nil {
                KRProgressHUD.showError(withMessage: error?.localizedDescription)
            } else {

                self.veges = []
                self.fresh = []
                self.seasonings = []
                self.drinks = []
                self.frozens = []
                self.others = []
                
                for result in results as! [NCMBObject] {
                    
                    let itemName = result.object(forKey: "itemName") as! String
                    let category = result.object(forKey: "category") as! String
                    let unit = result.object(forKey: "unit") as! String
                    let quantity = result.object(forKey: "quantity") as! Int
                    let itemImage = result.object(forKey: "itemImage") as! String
                    let objectId = result.objectId
                    
                    let user = result.object(forKey: "user") as! NCMBUser
                    
                    let userModel = User(objectId: user.userName, userName: user.objectId)
                    
                    let items = Items(objectId: objectId!, user: userModel, itemName: itemName, category: category, unit: unit, quantity: quantity, itemImage: itemImage)
                    
                    //食品で検索するためにItemの名前をカテゴリー関係なく配列にアペンド
                    self.allItemsName.append(itemName)
                    
                    if category == "野菜" {
                        self.veges.append(items)
                    } else if category == "生鮮食品" {
                        self.fresh.append(items)
                    } else if category == "調味料" {
                        self.seasonings.append(items)
                    } else if category == "飲み物" {
                        self.drinks.append(items)
                    } else if category == "冷凍食品" {
                        self.frozens.append(items)
                    } else if category == "その他" {
                        self.others.append(items)
                    }
                    
                }
            
            }
            self.fridgeTableView.reloadData()

        })

    }
    
    // 下に引っ張ってリリースすると更新されるUIの設定
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeLine(refreshControl:)), for: .valueChanged)
        fridgeTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeLine(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        loadData()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            refreshControl.endRefreshing()
        }
    }
    
    func didTapButtonToDetail(tableViewCell: UITableViewCell, button: UIButton) {
        
        categoryNameIndex = tableViewCell.tag
        
        if category[tableViewCell.tag] == "野菜" {
            selectedItems = veges
        } else if category[tableViewCell.tag] == "生鮮食品" {
            selectedItems = fresh
        } else if category[tableViewCell.tag] == "調味料"{
            selectedItems = seasonings
        } else if category[tableViewCell.tag] == "飲み物"{
            selectedItems = drinks
        } else if category[tableViewCell.tag] == "冷凍食品" {
            selectedItems = frozens
        } else {
            selectedItems = others
        }
        
        self.performSegue(withIdentifier: "toFridgeDetail", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toFridgeDetail" {
            let fridgeDetailViewController = segue.destination as! FridgeDetailViewController
            
            fridgeDetailViewController.selectedItems = selectedItems
            fridgeDetailViewController.fridgeCategoryIndex = categoryNameIndex
        } else if segue.identifier == "toSearchRecipe" {
            let fridgeSearchRecipeViewController = segue.destination as! FridgeSearchRecipeViewController
            
            fridgeSearchRecipeViewController.fridgeItemsName = allItemsName
        }

    }
    
    @IBAction func toSearchRecipe() {
        self.performSegue(withIdentifier: "toSearchRecipe", sender: nil)
    }
    

}

//TableViewの設定
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    //各indexPathのcellが表示される直前に呼ばれる
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FridgeTableViewCell else { return }
        
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if veges.count > 0 || fresh.count > 0 || seasonings.count > 0 || drinks.count > 0 || frozens.count > 0 || others.count > 0 {
            emptyArray = units
            
        }
        
        return emptyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FridgeCell") as! FridgeTableViewCell
        
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        cell.fridgeCollectionView.reloadData()
        
        //カテゴリ名の表示
        cell.detailButton.setTitle(category[indexPath.row], for: .normal)
        
        cell.delegate = self
        cell.tag = indexPath.row
        tag = indexPath.row
        
        //背景とセルの背景を透明/半透明にする
        tableView.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tag = indexPath.row
//    }
    
}

//CollectionViewの設定
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.tag = tag
        print(collectionView.tag)
        
        if collectionView.tag == 0 {
            return veges.count
        } else if collectionView.tag == 1 {
            return fresh.count
        } else if collectionView.tag == 2 {
            return seasonings.count
        } else if collectionView.tag == 3 {
            return drinks.count
        } else if collectionView.tag == 4 {
            return frozens.count
        } else {
            return others.count
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FridgeCell", for: indexPath) as! FridgeCollectionViewCell

        if collectionView.tag == 0 {
            //画像
            cell.itemNameLabel.text = veges[indexPath.row].itemName
            cell.quantityLabel.text = String(veges[indexPath.row].quantity) + veges[indexPath.row].unit
            cell.itemImageView.kf.setImage(with: URL(string: veges[indexPath.row].itemImage))
            
        } else if collectionView.tag == 1 {
            cell.itemNameLabel.text = fresh[indexPath.row].itemName
            cell.quantityLabel.text = String(fresh[indexPath.row].quantity) + fresh[indexPath.row].unit
            cell.itemImageView.kf.setImage(with: URL(string: fresh[indexPath.row].itemImage))
            
        } else if collectionView.tag == 2 {
            cell.itemNameLabel.text = seasonings[indexPath.row].itemName
            cell.quantityLabel.text = String(seasonings[indexPath.row].quantity) + seasonings[indexPath.row].unit
            cell.itemImageView.kf.setImage(with: URL(string: seasonings[indexPath.row].itemImage))
            
        } else if collectionView.tag == 3 {
            cell.itemNameLabel.text = drinks[indexPath.row].itemName
            cell.quantityLabel.text = String(drinks[indexPath.row].quantity) + drinks[indexPath.row].unit
            cell.itemImageView.kf.setImage(with: URL(string: drinks[indexPath.row].itemImage))
            
        } else if collectionView.tag == 4 {
            cell.itemNameLabel.text = frozens[indexPath.row].itemName
            cell.quantityLabel.text = String(frozens[indexPath.row].quantity) + frozens[indexPath.row].unit
            cell.itemImageView.kf.setImage(with: URL(string: frozens[indexPath.row].itemImage))
            
        } else {
            cell.itemNameLabel.text = others[indexPath.row].itemName
            cell.quantityLabel.text = String(others[indexPath.row].quantity) + others[indexPath.row].unit
            cell.itemImageView.kf.setImage(with: URL(string: others[indexPath.row].itemImage))
            
        }

        
        return cell
    }
    
}

extension HomeViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "foods.png")

        return image
    }
    
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        let color: UIColor = UIColor(red: 0.61, green: 1.00, blue: 0.88, alpha: 1.00)
        
        return color
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        let color: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
        
        return color
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -80
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "冷蔵庫にアイテムが入っていません。"

        return NSAttributedString(string: text)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let ud = UserDefaults.standard
        let user = NCMBUser.current()
        var text = ""
        if ud.bool(forKey: "isLogin") == false && user?.mailAddress != nil {
            text = "ログインするとこの機能が利用できます！"
        } else {
            text = "アイテムを追加してみましょう！"
        }
        
        return NSAttributedString(string: text)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        
        let ud = UserDefaults.standard
        let user = NCMBUser.current()
        var text = ""
        
        if (ud.bool(forKey: "isLogin") == false || ud.bool(forKey: "isLogin") == nil) && user?.mailAddress != nil {
            text = "ログイン画面へ"
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.font:UIFont.boldSystemFont(ofSize: 24),
                                                         .foregroundColor:UIColor.lightGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {

        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
        let RootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
        UIApplication.shared.keyWindow?.rootViewController = RootViewController

    }
}
