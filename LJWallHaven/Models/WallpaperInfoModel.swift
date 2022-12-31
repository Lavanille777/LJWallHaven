//
//  WallpaperModel.swift
//  LJWallHaven
//  壁纸信息
//  Created by 唐星宇 on 2021/2/4.
//

import UIKit
import SwiftyJSON
import SQLite
/*
 
 Wallpaper info can be accessed via URL
 https://wallhaven.cc/api/v1/w/<ID here>
 NSFW wallpapers are blocked to guests. Users can access them by providing their API key:
 https://wallhaven.cc/api/v1/w/<ID>?apikey=<API KEY>

 GET https://wallhaven.cc/api/v1/w/94x38z
{
  "data": {
    "id": "94x38z",
    "url": "https://wallhaven.cc/w/94x38z",
    "short_url": "http://whvn.cc/94x38z",
    "uploader": {
      "username": "test-user",
      "group": "User",
      "avatar": {
        "200px": "https://wallhaven.cc/images/user/avatar/200/11_3339efb2a813.png",
        "128px": "https://wallhaven.cc/images/user/avatar/128/11_3339efb2a813.png",
        "32px": "https://wallhaven.cc/images/user/avatar/32/11_3339efb2a813.png",
        "20px": "https://wallhaven.cc/images/user/avatar/20/11_3339efb2a813.png"
      }
    },
    "views": 12,
    "favorites": 0,
    "source": "",
    "purity": "sfw",
    "category": "anime",
    "dimension_x": 6742,
    "dimension_y": 3534,
    "resolution": "6742x3534",
    "ratio": "1.91",
    "file_size": 5070446,
    "file_type": "image/jpeg",
    "created_at": "2018-10-31 01:23:10",
    "colors": [
      "#000000",
      "#abbcda",
      "#424153",
      "#66cccc",
      "#333399"
    ],
    "path": "https://w.wallhaven.cc/full/94/wallhaven-94x38z.jpg",
    "thumbs": {
      "large": "https://th.wallhaven.cc/lg/94/94x38z.jpg",
      "original": "https://th.wallhaven.cc/orig/94/94x38z.jpg",
      "small": "https://th.wallhaven.cc/small/94/94x38z.jpg"
    },
    "tags": [
      {
        "id": 1,
        "name": "anime",
        "alias": "Chinese cartoons",
        "category_id": 1,
        "category": "Anime & Manga",
        "purity": "sfw",
        "created_at": "2015-01-16 02:06:45"
      }
    ]
  }
}
*/

///缩略图类型
enum ThumbType : String{
    case small = "small"
    case original = "original"
    case large = "large"
}

class WallpaperInfoModel: NSObject{
    
    ///id
    var id: String = ""
    
    ///浏览数
    var views: Int = 0

    ///收藏数
    var favorites: Int = 0
    
    ///来源
    var source: String = ""
    
    ///分级
    var purity: String = ""

    ///分类
    var category: String = ""

    ///分辨率
    var dimension: CGPoint = .zero

    ///分辨率（字符串）
    var resolution: String = ""

    ///信噪比
    var ratio: String = ""

    ///文件大小(字节)
    var file_size: Int = 0

    ///文件类型
    var file_type: String = ""

    ///创建时间 "yyyy-MM-dd hh:mm:ss"
    var created_at: String = ""

    ///包含颜色 #000000
    var colors: [String] = []

    ///原图地址
    var path: String = ""

    ///缩略图
    var thumbs: [ThumbType:String] = [:]

    ///标签
    var tags: [WallpaperTagModel] = []
    
    ///收藏
    var isCollected: Bool = false
    
    class func getModelFrom(json: JSON) -> WallpaperInfoModel{
        
        let model: WallpaperInfoModel = WallpaperInfoModel()
        model.id = json["id"].stringValue
        model.views = json["views"].intValue
        model.favorites = json["favorites"].intValue
        model.source = json["source"].stringValue
        model.purity = json["purity"].stringValue
        model.category = json["category"].stringValue
        model.dimension.x = CGFloat(json["dimension_x"].floatValue)
        model.dimension.y = CGFloat(json["dimension_y"].floatValue)
        model.resolution = json["resolution"].stringValue
        model.ratio = json["ratio"].stringValue
        model.file_size = json["file_size"].intValue
        model.file_type = json["file_type"].stringValue
        model.created_at = json["created_at"].stringValue
        for colorJson in json["colors"].arrayValue{
            model.colors.append(colorJson.stringValue)
        }
        model.path = json["path"].stringValue
        for thumbJson in json["thumbs"].dictionaryValue {
            var key: ThumbType = .original
            switch thumbJson.key {
            case "small":
                key = .small
            case "original":
                key = .original
            case "large":
                key = .large
            default:
                break
            }
            model.thumbs.updateValue(thumbJson.value.stringValue, forKey: key)
        }
        
        for tagJson in json["tags"].arrayValue{
            
            model.tags.append(WallpaperTagModel.getModelFrom(json: tagJson))
            
        }
        
        model.isCollected = SQLManager.queryCollection(byModel: model) > 0
        return model
    }
    
    static let id = Expression<String>("imgID")
    static let path = Expression<String>("path")
    static let file_size = Expression<Int>("file_size")
    static let resolution = Expression<String>("resolution")
    static let thumb = Expression<String>("thumb")
    static let dimension_x = Expression<Double>("dimension_x")
    static let dimension_y = Expression<Double>("dimension_y")
    static let category = Expression<String>("category")
    
    class func getData(fromDB row: Row) -> WallpaperInfoModel{
        let model = WallpaperInfoModel()
        model.id = row[id]
        model.path = row[path]
        model.thumbs.updateValue(row[thumb], forKey: ThumbType.original)
        model.file_size = row[file_size]
        model.resolution = row[resolution]
        model.dimension = CGPoint(x: CGFloat(row[dimension_x]), y: CGFloat(row[dimension_y]))
        model.category = row[category]
        
        model.isCollected = SQLManager.queryCollection(byModel: model) > 0
        return model
    }
    
}

