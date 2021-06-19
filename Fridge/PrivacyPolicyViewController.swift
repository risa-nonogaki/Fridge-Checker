//
//  PrivacyPolicyViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/10/03.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func agree() {
        self.navigationController?.popViewController(animated: true)
    }

}
