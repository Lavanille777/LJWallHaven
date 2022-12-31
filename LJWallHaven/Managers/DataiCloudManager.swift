//
//  DataiCloudManager.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/10.
//

import UIKit

class DataiCloudManager: NSObject {
    
    private static var _sharedInstance: DataiCloudManager?
    
    var keyValueStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
    
    private override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("初始化失败")
    }
    
    /// 单例
    ///
    /// - Returns: 单例对象
    class func shared() -> DataiCloudManager {
        guard let instance = _sharedInstance else {
            let manager = DataiCloudManager()
            _sharedInstance = manager
            return _sharedInstance!
        }
        return instance
    }
    
    func iCloudDocumentURL() -> URL? {
        let fileManager = FileManager.default
        if let url = fileManager.url(forUbiquityContainerIdentifier: nil) {
          return url.appendingPathComponent("Documents")
        }
        return nil
    }
    
    private var query : NSMetadataQuery = NSMetadataQuery()
    
    func loadDocuments()->Bool{
        let baseURL = self.iCloudDocumentURL()
        guard baseURL != nil else {
            return false
        }
        let center = NotificationCenter.default
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(value: true)
        center.addObserver(self, selector: #selector(metadataQueryDidFinishGathering), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        self.query.enableUpdates()
        query.start()
        return true
    }
    
    @objc func metadataQueryDidFinishGathering() {
           query.disableUpdates()
           query.stop()
           let center = NotificationCenter.default
           center.removeObserver(self)

           if (query.resultCount == 1) {
               let item = query.results.first as! NSMetadataItem
               let fileURL = item.value(forAttribute: NSMetadataItemURLKey) as! URL
               let document = SQLiteDocument(fileURL: fileURL )
               document.open(completionHandler: { (success) in
                   document.close(completionHandler: nil)
               })

           }else{
//               self.delegate?.queryDocumentsComplete(results: diaryList)
           }
       }

}

let kArchiveKey  = "Diary"
class SQLiteDocument: UIDocument {
    
    var data:NSData?
    var sqlData:NSData?

    override func contents(forType typeName: String) throws -> Any {
        if typeName == "db.sqlite" {
            return sqlData ?? NSData()
        } else {
            return Data()
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let userContent = contents as? NSData {
            data = userContent
        }
    }
}
