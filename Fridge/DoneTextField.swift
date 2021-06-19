//
//  DoneTextField.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/17.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
// キーボードにDoneボタンをつける
class DoneTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let tools = UIToolbar()
        tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closeButtonTapped))
        doneButton.tintColor = .darkGray

        tools.items = [spacer, doneButton]
        tools.sizeToFit()
        self.inputAccessoryView = tools
        
    }
    
    @objc func closeButtonTapped() {
        self.endEditing(true)
        self.resignFirstResponder()
    }
    
}
