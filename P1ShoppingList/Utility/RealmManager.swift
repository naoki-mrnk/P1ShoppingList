//
//  RealmManager.swift
//  P1ShoppingList
//
//  Created by naoki-mrnk on 2021/07/09.
//  Copyright © 2021 naoki-mrnk. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    // MARK: - Properties
    /// 初回アクセスのタイミングでインスタンス生成
    static let shared = RealmManager()
    /// realmのインスタンス
    let realm = try! Realm()
    
    func writeDB(DB: Object) {
        do{
            try realm.write{
                realm.add(DB)
            }
        }catch {
            print("Error \(error)")
        }
    }
}
