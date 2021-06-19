//
//  NewRecipeIngredientsViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/10/11.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import NCMB


class NewRecipeIngredientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ingredientsDelegate {

    var ingredientsArray = [String]()
    var quantityArray = [String]()
    var unitArray = [String]()
    
    @IBOutlet var ingredientsTableView: UITableView!
    @IBOutlet var numberOfPeopleTextField: UITextField!
    @IBOutlet var nextPageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientsTableView.dataSource = self
        ingredientsTableView.delegate = self
        numberOfPeopleTextField.delegate = self
        
        ingredientsTableView.tableFooterView = UIView()
        ingredientsTableView.rowHeight = 50
        
        numberOfPeopleTextField.keyboardType = .decimalPad
        
        // カスタムセルの宣言
        let nib = UINib(nibName: "IngredientsTableViewCell", bundle: Bundle.main)
        ingredientsTableView.register(nib, forCellReuseIdentifier: "IngredientsCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ud = UserDefaults.standard
        
        if ud.bool(forKey: "newRecipe") == true {

            if ud.bool(forKey: "makingRecipe2") == false {
                
                ingredientsArray.removeAll()
                
                //作ってる最中って伝えるもの
                ud.set(true, forKey: "makingRecipe2")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientsArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsCell") as! IngredientsTableViewCell
        cell.ingredientsTextField.text = ingredientsArray[indexPath.row]
        cell.quantityTextField.text = quantityArray[indexPath.row]
        cell.unitTextField.text = unitArray[indexPath.row]
        cell.delegate = self
        cell.tag = indexPath.row

        return cell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        confirmContent()
    }
    
    func didEditIngredientsTextField(tableViewCell: UITableViewCell, textField: UITextField){
        
        ingredientsArray[tableViewCell.tag] = textField.text!
        //print(ingredientsArray)
    }
    
    func didEditQuantityTextField(tableViewCell: UITableViewCell, textField: UITextField) {
        
        quantityArray[tableViewCell.tag] = textField.text!
        //print(quantityArray)
    }
    
    func didEditUnitTextField(tableViewCell: UITableViewCell, textField: UITextField) {
        
        unitArray[tableViewCell.tag] = textField.text!
        //print(unitArray)
    }
    
    func deleteIngredientsCellButton(tableViewCell: UITableViewCell, button: UIButton) {
        ingredientsArray.remove(at: tableViewCell.tag)
        unitArray.remove(at: tableViewCell.tag)
        quantityArray.remove(at: tableViewCell.tag)
        
        print(unitArray)
        print(quantityArray)
        
        ingredientsTableView.reloadData()
    }
    
    func confirmContent() {
        
        if ingredientsArray.count > 0 || numberOfPeopleTextField.text != nil {
            nextPageButton.isHidden = false
        } else {
            nextPageButton.isHidden = true
        }
        
    }
    
    @IBAction func tapScreen(_ sender: Any) {
            self.view.endEditing(true)
    }
    
    //材料cellの追加
    @IBAction func addIngredients() {
        
        let alertController = UIAlertController(title: "材料追加", message: "材料名を入力してください", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "追加", style: .default) { (action) in
            
            // newItemsの配列(辞書型)に追加する
            self.ingredientsArray.append((alertController.textFields?.first?.text)!)
            // 配列をcellの数に揃える
            self.quantityArray.append("")
            self.unitArray.append("")
//            print(self.ingredientsArray)
            
            print(self.quantityArray)
            print(self.unitArray)
            
            self.ingredientsTableView.reloadData()
            self.confirmContent()
            
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        // textFieldをalertControllerに追加する
        alertController.addTextField { (textField) in
            textField.placeholder = "材料名"
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func nextPage() {
        // userdefaultsに今ある情報を全て保存して画面遷移する
        //材料の配列・単位の配列・量の配列・何人分か
        let ud = UserDefaults.standard
        
        ud.set(numberOfPeopleTextField.text, forKey: "numberOfPeople")
        ud.set(ingredientsArray, forKey: "ingredientsArray")
        ud.set(quantityArray, forKey: "quantityArray")
        ud.set(unitArray, forKey: "unitArray")
        
        self.performSegue(withIdentifier: "toHowTo", sender: nil)
        
    }

}
