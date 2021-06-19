//
//  IngredientsTableViewCell.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/18.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
protocol ingredientsDelegate {
    func didEditIngredientsTextField(tableViewCell: UITableViewCell, textField: UITextField)
    func didEditQuantityTextField(tableViewCell: UITableViewCell, textField: UITextField)
    func didEditUnitTextField(tableViewCell: UITableViewCell, textField: UITextField)
    func deleteIngredientsCellButton(tableViewCell: UITableViewCell, button: UIButton)
}

class IngredientsTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {

    var delegate: ingredientsDelegate?
    
    var pickerView = UIPickerView()
    var ingredientsArray = [String]()
    var quantityArray = [String]()
    var unitArray = [String]()
    
    @IBOutlet var ingredientsTextField: UITextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var unitTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        quantityTextField.keyboardType = .decimalPad
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        ingredientsTextField.delegate = self
        quantityTextField.delegate = self
        unitTextField.delegate = self

        let tools = UIToolbar()
        tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closeButtonTapped))
        doneButton.tintColor = .darkGray

        tools.items = [spacer, doneButton]
        tools.sizeToFit()

        self.unitTextField.inputView = pickerView
        self.unitTextField.inputAccessoryView = tools
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return units[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return units.count
    }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int, inComponent component: Int) {
        // 処理
        unitTextField.text = units[row]
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == ingredientsTextField {
            self.delegate?.didEditIngredientsTextField(tableViewCell: self, textField: textField)
        } else if textField == quantityTextField {
            self.delegate?.didEditQuantityTextField(tableViewCell: self, textField: textField)
        } else {
            self.delegate?.didEditUnitTextField(tableViewCell: self, textField: textField)
        }
        
        
    }
    
    @objc func closeButtonTapped() {
        self.endEditing(true)
        self.resignFirstResponder()
        
    }
    
    @IBAction func deleteCell(button: UIButton) {
        self.delegate?.deleteIngredientsCellButton(tableViewCell: self, button: button)
    }
    
}
