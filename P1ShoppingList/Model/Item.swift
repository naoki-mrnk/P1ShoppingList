//
//  Item.swift
//  P1ShoppingList
//
//  Created by naoki-mrnk on 2021/07/09.
//  Copyright © 2021 naoki-mrnk. All rights reserved.
//

import Foundation
import RealmSwift

/// 追加したItemを保存しておくDB
class Item:Object {
    @objc dynamic var itemID = NSUUID().uuidString
    @objc dynamic var itemName: String = ""
    
    override static func primaryKey() -> String? {
        return "itemID"
    }
}
