//
//  HowToMakeTableViewCell.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/18.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit

protocol HowToMakeTableViewCellDelegate {
    func deleteButton(tableViewCell: UITableViewCell, button: UIButton)
    func didEditHowToMakeTextField(tableViewCell: UITableViewCell, textField: UITextField)
    func choosePhoto(tableViewCell: UITableViewCell, button: UIButton)
}
class HowToMakeTableViewCell: UITableViewCell, UITextFieldDelegate {

    var delegate: HowToMakeTableViewCellDelegate?
    var descriptionArray = [String]()
    
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var howToMakeImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        descriptionTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.didEditHowToMakeTextField(tableViewCell: self, textField: textField)
    }
    
    
    @IBAction func deleteCell(button: UIButton) {
        self.delegate?.deleteButton(tableViewCell: self, button: button)
    }
    
    @IBAction func choosePhoto(button: UIButton) {
        self.delegate?.choosePhoto(tableViewCell: self, button: button)
    }
    
}
