//
//  ChangeInItemsTableViewCell.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/05.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit

// このプロトコル宣言をしているファイルではここで宣言されているfuncを使うことができる
protocol ChangeInItemsTableViewCellDelegate {
    func deleteButton(tableViewCell: UITableViewCell, button: UIButton)
    func didEditCategoryTextField(tableViewCell: UITableViewCell, textField: UITextField)
    func didEditQuantityTextField(tableViewCell: UITableViewCell, textField: UITextField)
    func didEditUnitTextField(tableViewCell: UITableViewCell, textField: UITextField)
    func doPickPhoto(tableViewCell: UITableViewCell, button: UIButton)
    
}

class ChangeInItemsTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var delegate: ChangeInItemsTableViewCellDelegate?
    
    var pickerView1 = UIPickerView()
    var pickerView2 = UIPickerView()

    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var categoryTextField: UITextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var unitTextField: UITextField!
    @IBOutlet var itemImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        quantityTextField.keyboardType = .decimalPad
        
        pickerView1.delegate = self
        pickerView1.dataSource = self
        pickerView1.showsSelectionIndicator = true
        
        pickerView2.delegate = self
        pickerView2.dataSource = self
        pickerView2.showsSelectionIndicator = true
        
        categoryTextField.delegate = self
        quantityTextField.delegate = self
        unitTextField.delegate = self
        
        let tools = UIToolbar()
        tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closeButtonTapped))
        doneButton.tintColor = .darkGray

        tools.items = [spacer, doneButton]
        tools.sizeToFit()

        self.unitTextField.inputView = pickerView1
        self.unitTextField.inputAccessoryView = tools
        
        self.categoryTextField.inputView = pickerView2
        self.categoryTextField.inputAccessoryView = tools
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerView1 {
            return units.count
        } else {
            return category.count
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerView1 {
            return units[row]
        } else {
            return category[row]
        }

    }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int, inComponent component: Int) {
        // 処理
        if pickerView == pickerView1 {
            unitTextField.text = units[row]
        } else {
            categoryTextField.text = category[row]
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == quantityTextField {
            self.delegate?.didEditQuantityTextField(tableViewCell: self, textField: textField)
        } else if textField == unitTextField {
            self.delegate?.didEditUnitTextField(tableViewCell: self, textField: textField)
            
        } else if textField == categoryTextField {
            self.delegate?.didEditCategoryTextField(tableViewCell: self, textField: textField)
        }
        
    }
    
    @objc func closeButtonTapped() {
        self.endEditing(true)
        self.resignFirstResponder()
        
    }
    
    @IBAction func pickePhoto(button: UIButton) {
        self.delegate?.doPickPhoto(tableViewCell: self, button: button)
    }
    
    @IBAction func deleteButton(button: UIButton) {
        
        self.delegate?.deleteButton(tableViewCell: self, button: button)
    }
    
}
