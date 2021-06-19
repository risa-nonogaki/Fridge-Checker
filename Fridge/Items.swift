//
//  Items.swift
//  Fridge
//
//  Created by Lisa Nonogaki on 2020/09/05.
//  Copyright © 2020 Lisa Nonogaki. All rights reserved.
//

import UIKit

class Items {
    var objectId: String
    var user: User
    var itemName: String
    var category: String
    var unit: String
    var quantity: Int
    var itemImage: String

    init(objectId: String, user: User, itemName: String, category: String, unit: String, quantity: Int, itemImage: String) {
        self.objectId = objectId
        self.user = user
        self.itemName = itemName
        self.category = category
        self.unit = unit
        self.quantity = quantity
        self.itemImage = itemImage
    }
}
