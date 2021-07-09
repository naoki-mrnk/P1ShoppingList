//
//  ShoppingList.swift
//  P1ShoppingList
//
//  Created by naoki-mrnk on 2021/07/09.
//  Copyright © 2021 naoki-mrnk. All rights reserved.
//

import Foundation
import RealmSwift

/// 購入履歴を管理
class ShoppingItem:Object {
    @objc dynamic var shoppingItemID: String = NSUUID().uuidString
    @objc dynamic var itemID: String = ""
    @objc dynamic var createAt = Date()
    @objc dynamic var boughtAt: Date? = nil
    
    override static func primaryKey() -> String? {
        return "shoppingItemID"
    }
}
