//
//  WallpaperTagsModel.swift
//  LJWallHaven
//  壁纸标签
//  Created by 唐星宇 on 2021/2/4.
//

import UIKit
import SwiftyJSON

/*
 "id": 1,
 "name": "anime",
 "alias": "Chinese cartoons",
 "category_id": 1,
 "category": "Anime & Manga",
 "purity": "sfw",
 "created_at": "2015-01-16 02:06:45"
 */

class WallpaperTagModel: Encodable {

    var id: Int = 0
    
    var name: String = ""
    
    var alias: String = ""
    
    var category_id: Int = 0
    
    var category: String = ""
    
    var purity: String = ""
    
    var created_at: String = ""
    
    class func getModelFrom(json: JSON) -> WallpaperTagModel{
        let model: WallpaperTagModel = WallpaperTagModel()
        model.id = json["id"].intValue
        model.name = json["name"].stringValue
        model.alias = json["alias"].stringValue
        model.category_id = json["category_id"].intValue
        model.purity = json["purity"].stringValue
        model.category = json["category"].stringValue
        model.created_at = json["created_at"].stringValue
        return model
    }
}
