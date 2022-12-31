//
//  SQLManager.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/2.
//

import UIKit
import SQLite
import StoreKit

class SQLManager: NSObject {
    private static var _sharedInstance: SQLManager?
    var db: Connection?
    
    ///搜索历史表
    let searchHistoryTable: Table = Table("searchHistory")
    ///历史浏览表
    let browseHistoryTable: Table = Table("browseHistory")
    ///收藏夹表
    let collectionTable: Table = Table("collection")
    ///搜索宏表
    let searchMacroTable: Table = Table("searchMacro")
    
    static let primaryId = Expression<Int>("id")

    
    //MARK: - 覆盖更新表
    
    /// 单例
    @discardableResult class func shared() -> SQLManager {
        guard let instance = _sharedInstance else {
            _sharedInstance = SQLManager()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return _sharedInstance!
        }
        return instance
    }
    
    private override init() {
        guard let docPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last, let bundleSqlPath = Bundle.main.path(forResource: "db", ofType: ".sqlite") else {
            db = nil
            return
        }
        
        print("The DB Path:", docPath)
        let dir = docPath + "/db.sqlite"
        
        ///如果Doc下没有数据库则从Bundle拷贝一份
        if !FileManager.default.fileExists(atPath: dir){
            try? FileManager.default.copyItem(atPath: bundleSqlPath, toPath: dir)
        }
        
        do {
            db = try Connection.init(dir)
            db?.busyTimeout = 5
            db?.busyHandler({ tries in
                if tries >= 3 {
                    return false
                }
                return true
            })
        }catch let error {
            print("数据库连接或创建失败====\(error)")
            db = nil
        }
    } // 私有化init方法
    
    // MARK: 表操作
    
    // MARK: 历史浏览表相关操作
    
    ///查询所有的历史浏览
    static func queryAllBrowseHistory() -> [WallpaperInfoModel]? {
        var imgArray: [WallpaperInfoModel] = []
        do {
            let db = SQLManager.shared().db
            let query = SQLManager.shared().browseHistoryTable.order(primaryId.desc).limit(300, offset: 0)
            if let items = try db?.prepare(query){
                for item in items {
                    let model: WallpaperInfoModel = WallpaperInfoModel.getData(fromDB: item)
                    imgArray.append(model)
                }
            }
        } catch _ {
            Dprint("数据库查询失败")
        }
        return imgArray
    }
    
    ///插入历史浏览(最多300条)
    static func insertBrowseHistory(_ model: WallpaperInfoModel) -> Int64 {
        do {
            let db = SQLManager.shared().db
            
            let thumb = model.thumbs[.original] ?? ""
            var rowId: Int64 = -1
            
            deleteFromHistoryTable(model)
            
            var tableLength = 0
            if let items = try db?.prepare(SQLManager.shared().browseHistoryTable){
                for _ in items{
                    tableLength += 1
                }
            }
            
            if tableLength >= 300{
                let item = SQLManager.shared().browseHistoryTable.order(primaryId.asc).limit(1, offset: 0)
                try db?.run(item.delete())
            }
            
            let insert = SQLManager.shared().browseHistoryTable.insert(WallpaperInfoModel.id <- model.id, WallpaperInfoModel.path <- model.path, WallpaperInfoModel.file_size <- model.file_size, WallpaperInfoModel.resolution <- model.resolution, WallpaperInfoModel.thumb <- thumb, WallpaperInfoModel.dimension_x <- Double(model.dimension.x), WallpaperInfoModel.dimension_y <- Double(model.dimension.y), WallpaperInfoModel.category <- model.category)
            rowId = try db?.run(insert) ?? -1 as Int64
            
            return rowId
        } catch _ {
            Dprint("数据库插入失败")
        }
        return -1
    }
    
    ///从历史浏览删除
    static func deleteFromHistoryTable(_ model: WallpaperInfoModel) -> Int64 {
        let item = SQLManager.shared().browseHistoryTable.filter(WallpaperInfoModel.id == model.id)
        do {
            let db = SQLManager.shared().db
            
            try db?.run(item.delete())
            
            return 1
        } catch _ {
            Dprint("数据库查询失败")
        }
        return -1
    }

    // MARK: 收藏夹表相关操作
    
    ///查询所有的收藏夹
    static func queryAllCollection(page: Int = 0) -> [WallpaperInfoModel]? {
        var imgArray: [WallpaperInfoModel] = []
        do {
            let db = SQLManager.shared().db
            if let items = try db?.prepare(SQLManager.shared().collectionTable.order(primaryId.desc).limit(collectionPageSize, offset: page * collectionPageSize)){
                for item in items {
                    let model: WallpaperInfoModel = WallpaperInfoModel.getData(fromDB: item)
                    imgArray.append(model)
                }
            }
        } catch _ {
            Dprint("数据库查询失败")
        }
        return imgArray
    }
    
    ///根据id查询收藏夹
    static func queryCollection(byModel model: WallpaperInfoModel) -> Int {
        do {
            let db = SQLManager.shared().db
            
            let query = SQLManager.shared().collectionTable.filter(WallpaperInfoModel.id == model.id)
            
            var count = 0
            
            if let items =  try db?.prepare(query){
                for item in items{
                    count += 1
                }
            }

            return count
        } catch _ {
            Dprint("数据库插入失败")
        }
        return -1
    }
    
    ///插入收藏夹
    static func insertCollection(_ model: WallpaperInfoModel) -> Int64 {
        do {
            let db = SQLManager.shared().db
            
            let thumb = model.thumbs[.original] ?? ""
            
            var rowId: Int64 = -1
            
            if SQLManager.queryCollection(byModel: model) == 0{
                let insert = SQLManager.shared().collectionTable.insert(WallpaperInfoModel.id <- model.id, WallpaperInfoModel.path <- model.path, WallpaperInfoModel.file_size <- model.file_size, WallpaperInfoModel.resolution <- model.resolution, WallpaperInfoModel.thumb <- thumb, WallpaperInfoModel.dimension_x <- Double(model.dimension.x), WallpaperInfoModel.dimension_y <- Double(model.dimension.y), WallpaperInfoModel.category <- model.category)
                rowId = try db?.run(insert) ?? -1 as Int64
            }
            
            var lasePopDate: Date = Date(timeIntervalSince1970: 0)
            if let date = UserDefaults.standard.value(forKey: Setting.storeReviewPopDateKey) as? Date{
                lasePopDate = date
            }
            let now = Date()
            let duration = now.timeIntervalSince1970 - lasePopDate.timeIntervalSince1970
            if duration / 3600 / 24 > 3{
                DispatchQueue.global().async {
                    let arr = queryAllCollection()
                    if arr?.count ?? 0 > 10{
                        UserDefaults.standard.setValue(Date(), forKey: Setting.storeReviewPopDateKey)
                        DispatchQueue.main.async {
                            SKStoreReviewController.requestReview()
                        }
                    }
                }
            }

            
            return rowId
        } catch _ {
            Dprint("数据库插入失败")
        }
        return -1
    }
    
    ///从收藏夹删除
    static func deleteFromCollection(_ model: WallpaperInfoModel) -> Int64 {
        let item = SQLManager.shared().collectionTable.filter(WallpaperInfoModel.id == model.id)
        do {
            let db = SQLManager.shared().db
            
            try db?.run(item.delete())
            
            return 1
        } catch _ {
            Dprint("数据库查询失败")
        }
        return -1
    }
    
    ///查询所有的宏
    static func queryAllSearchMacro() -> [SearchMacroModel]? {
        var imgArray: [SearchMacroModel] = []
        do {
            let db = SQLManager.shared().db
            if let items = try db?.prepare(SQLManager.shared().searchMacroTable){
                for item in items {
                    let model: SearchMacroModel = SearchMacroModel.getData(fromDB: item)
                    imgArray.append(model)
                }
            }
        } catch _ {
            Dprint("数据库查询失败")
        }
        return imgArray
    }
    
    ///根据key查询宏
    static func querySearchMacro(byKey key: String) -> [SearchMacroModel] {
        var arr: [SearchMacroModel] = []
        do {
            let db = SQLManager.shared().db
            
            let query = SQLManager.shared().searchMacroTable.filter(SearchMacroModel.key.like("%\(key)%"))
            
            var count = 0
            
            if let items =  try db?.prepare(query){
                for item in items{
                    count += 1
                    arr.append(SearchMacroModel.getData(fromDB: item))
                }
            }

            return arr
        } catch _ {
            Dprint("数据库插入失败")
        }
        return arr
    }
    
    ///从宏中删除
    static func deleteFromMacro(_ model: SearchMacroModel) -> Int64 {
        let item = SQLManager.shared().searchMacroTable.filter(SearchMacroModel.id == model.id)
        do {
            let db = SQLManager.shared().db
            
            try db?.run(item.delete())
            
            return 1
        } catch _ {
            Dprint("数据库删除失败")
        }
        return -1
    }
    
    ///插入宏
    static func insertSearchMacro(_ model: SearchMacroModel) -> Int64 {
        do {
            let db = SQLManager.shared().db
            
            var rowId: Int64 = -1
            
            if SQLManager.querySearchMacro(byKey: model.key).count == 0{
                let insert = SQLManager.shared().searchMacroTable.insert(SearchMacroModel.key <- model.key, SearchMacroModel.value <- model.value)
                rowId = try db?.run(insert) ?? -1 as Int64
            }else{
                UIView.makeToast("已经有同样的宏名称了")
            }

            return rowId
        } catch _ {
            Dprint("数据库插入失败")
        }
        return -1
    }
    
    static func updateSearchMacro(_ model: SearchMacroModel) {
        do {
            let db = SQLManager.shared().db
            
            let update = SQLManager.shared().searchMacroTable.filter(SearchMacroModel.id == model.id).update(SearchMacroModel.key <- model.key, SearchMacroModel.value <- model.value)
            try db?.run(update)
            
            UIView.makeToast("搜索宏更新成功")
        } catch _ {
            Dprint("搜索宏更新失败")
        }
    }
    

}
