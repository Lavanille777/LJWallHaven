//
//  SearchMacroModel.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/3.
//

import UIKit
import SQLite

class SearchMacroModel: NSObject {
    ///id
    var id: Int = 0
    
    var key: String = ""

    var value: String = ""
    
    static let id = Expression<Int>("id")
    static let key = Expression<String>("key")
    static let value = Expression<String>("value")
    
    class func getData(fromDB row: Row) -> SearchMacroModel{
        let model = SearchMacroModel()
        model.id = row[id]
        model.key = row[key]
        model.value = row[value]
        return model
    }
    
}
