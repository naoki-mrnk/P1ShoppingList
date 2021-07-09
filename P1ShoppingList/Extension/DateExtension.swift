//
//  DateExtension.swift
//  P1ShoppingList
//
//  Created by naoki-mrnk on 2021/07/09.
//  Copyright © 2021 naoki-mrnk. All rights reserved.
//

import Foundation

extension Date {
    func getDate() -> String? {
        let f = DateFormatter()
        f.dateStyle = .short
        f.locale = Locale(identifier: "ja_JP") as Locale
        let nowDate = f.string(from: self)
        return nowDate
    }
}
