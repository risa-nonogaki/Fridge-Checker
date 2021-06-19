//
//  FridgeDetailViewController.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/29.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit
import Kingfisher

class FridgeDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedItems = [Items]()
    var fridgeCategoryIndex: Int?
    
    @IBOutlet var fridgeDetailCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fridgeDetailCollectionView.delegate = self
        fridgeDetailCollectionView.dataSource = self
        
        self.navigationItem.title = category[fridgeCategoryIndex!]
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FridgeDetailCell", for: indexPath)
        
        let itemImageView = cell.viewWithTag(1) as! UIImageView
        let itemNameLabel = cell.viewWithTag(2) as! UILabel
        let quantityLabel = cell.viewWithTag(3) as! UILabel
        
        itemImageView.layer.cornerRadius = itemImageView.bounds.width / 8.0
        itemImageView.layer.masksToBounds = true
        
        itemNameLabel.text = selectedItems[indexPath.row].itemName
        quantityLabel.text = String(selectedItems[indexPath.row].quantity) + selectedItems[indexPath.row].unit
        itemImageView.kf.setImage(with: URL(string: selectedItems[indexPath.row].itemImage))

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (self.view.frame.size.width / 3) - 8
        let height: CGFloat = width * 1.5
        
        return CGSize(width: width, height: height)
    }

}
