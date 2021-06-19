//
//  FridgeCollectionViewCell.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/27.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit

class FridgeCollectionViewCell: UICollectionViewCell {

    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemImageView.layer.cornerRadius = itemImageView.bounds.width / 8.0
        itemImageView.layer.masksToBounds = true
        
    }

}
