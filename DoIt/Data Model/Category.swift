//
//  Category.swift
//  DoIt
//
//  Created by Francisco Rosa on 14/03/2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var cellColor: String = ""
    let items = List<Item>()
}
