//
//  FridgeTableViewCell.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/27.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit

protocol FridgeTableViewCellDelegate {
    func didTapButtonToDetail(tableViewCell: UITableViewCell, button: UIButton)
}

class FridgeTableViewCell: UITableViewCell{

    var delegate: FridgeTableViewCellDelegate?
    
    @IBOutlet var fridgeCollectionView: UICollectionView!
    @IBOutlet var detailButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: "FridgeCollectionViewCell", bundle: Bundle.main)
        fridgeCollectionView.register(nib, forCellWithReuseIdentifier: "FridgeCell")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // これで、メインのviewControllerでcollectionViewの操作ができるようになる??
    
    func setCollectionViewDataSourceDelegate <D: UICollectionViewDataSource & UICollectionViewDelegate>(dataSourceDelegate: D, forRow row: Int) {
        
        fridgeCollectionView.delegate = dataSourceDelegate
        fridgeCollectionView.dataSource = dataSourceDelegate
        fridgeCollectionView.tag = row
//        fridgeCollectionView.reloadData()
        
    }
    
    @IBAction func didTapButtonToShowDetail(button: UIButton) {
        self.delegate?.didTapButtonToDetail(tableViewCell: self, button: button)
    }
    
    
}
