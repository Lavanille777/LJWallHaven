//
//  Configuration.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/2/4.
//

import Foundation

struct API {
    
    static let baseUrl: URL = URL(string: "https://wallhaven.cc/api/v1")!
    
}

struct NotificationName {
    static let HistoryRecordDeleted: String = "HistoryRecordDeleted"
    static let CollectionStateChaged: String = "CollectionStateChaged"
    static let TraitCollectionDidChange: Notification.Name = Notification.Name(rawValue: "traitCollectionDidChange")
}

struct Setting {
    static var skin: String = "skin"
    static var autoDisplayToolView: Bool = true
    static var notAutoLoad: Bool = false
    static var scrollAnimationEnable: Bool = true
    static let diskSize: String = "diskSize"
    static let autoDisplayToolViewKey: String = "autoDisplayToolViewKey"
    static let autoLoadingOriginalSizeImage: String = "autoLoadingOriginalSizeImage"
    static let appKey: String = "appKey"
    static let app_version: String = "1.3"
    static let storeReviewPopDateKey: String = "storeReviewPopDate"
    static let scrollAnimationSwitchKey: String = "scrollAnimationSwitchKey"
}

struct SearchFilterSetting {
    static var categoriesKey: String = "filter_categories"
    static var sortingKey: String = "filter_sorting"
    static var orderKey: String = "filter_order"
    static var purityKey: String = "filter_purity"
    static var color: String = ""
}

var pageSize: Int = 1

let AppID: String = "1557161729"

let iCloudKey = "iCloudKey"

struct Colors {
    
    static var mainBackGroundColor: UIColor = UIColor { (collection) -> UIColor in
        switch collection.userInterfaceStyle{
        case .dark:
            return HEXCOLOR(h: 0x171717, alpha: 1.0)
        case .unspecified:
            return HEXCOLOR(h: 0xffffff, alpha: 1.0)
        case .light:
            return HEXCOLOR(h: 0xffffff, alpha: 1.0)
        @unknown default:
            return HEXCOLOR(h: 0xffffff, alpha: 1.0)
        }
    }
    
    static var imageCellColor: UIColor = UIColor { (collection) -> UIColor in
        switch collection.userInterfaceStyle{
        case .dark:
            return HEXCOLOR(h: 0x242424, alpha: 1.0)
        case .unspecified:
            return HEXCOLOR(h: 0xFFFAFA, alpha: 1.0)
        case .light:
            return HEXCOLOR(h: 0xFFFAFA, alpha: 1.0)
        @unknown default:
            return HEXCOLOR(h: 0xFFFAFA, alpha: 1.0)
        }
    }
    
    static var imageCellShadowColor: UIColor = UIColor { (collection) -> UIColor in
        switch collection.userInterfaceStyle{
        case .dark:
            return HEXCOLOR(h: 0x000000, alpha: 0.8)
        case .unspecified:
            return HEXCOLOR(h: 0x8B0000, alpha: 0.3)
        case .light:
            return HEXCOLOR(h: 0x8B0000, alpha: 0.3)
        @unknown default:
            return HEXCOLOR(h: 0x8B0000, alpha: 0.3)
        }
    }
    
    static var toastShadowColor: CGColor{
        get{
            switch UITraitCollection.current.userInterfaceStyle{
            case .dark:
                return HEXCOLOR(h: 0x000000, alpha: 0.8).cgColor
            case .unspecified:
                return HEXCOLOR(h: 0x000000, alpha: 0.2).cgColor
            case .light:
                return HEXCOLOR(h: 0x000000, alpha: 0.2).cgColor
            @unknown default:
                return HEXCOLOR(h: 0x000000, alpha: 0.2).cgColor
            }
        }
    }
    
    static var alertBackGroundColor: UIColor = UIColor { (collection) -> UIColor in
        switch collection.userInterfaceStyle{
        case .dark:
            return HEXCOLOR(h: 0x281f1d, alpha: 1.0)
        case .unspecified:
            return HEXCOLOR(h: 0xFFFAF0, alpha: 1.0)
        case .light:
            return HEXCOLOR(h: 0xFFFAF0, alpha: 1.0)
        @unknown default:
            return HEXCOLOR(h: 0xFFFAF0, alpha: 1.0)
        }
    }
    
    static var whiteTextColor: UIColor = UIColor { (collection) -> UIColor in
        switch collection.userInterfaceStyle{
        case .dark:
            return .white
        case .unspecified:
            return HEXCOLOR(h: 0x303030, alpha: 1.0)
        case .light:
            return HEXCOLOR(h: 0x303030, alpha: 1.0)
        @unknown default:
            return HEXCOLOR(h: 0x303030, alpha: 1.0)
        }
    }
    
    static var toastTextColor: UIColor = UIColor { (collection) -> UIColor in
        switch collection.userInterfaceStyle{
        case .dark:
            return HEXCOLOR(h: 0xf9d574, alpha: 0.8)
        case .unspecified:
            return HEXCOLOR(h: 0x303030, alpha: 1.0)
        case .light:
            return HEXCOLOR(h: 0x303030, alpha: 1.0)
        @unknown default:
            return HEXCOLOR(h: 0x303030, alpha: 1.0)
        }
    }
    
    static var toastBackGroundColor: UIColor = UIColor { (collection) -> UIColor in
        switch collection.userInterfaceStyle{
        case .dark:
            return HEXCOLOR(h: 0x282828, alpha: 0.8)
        case .unspecified:
            return HEXCOLOR(h: 0xFAFAD2, alpha: 1.0)
        case .light:
            return HEXCOLOR(h: 0xFAFAD2, alpha: 1.0)
        @unknown default:
            return HEXCOLOR(h: 0xFAFAD2, alpha: 1.0)
        }
    }
    
    static var detailTextColor: UIColor = UIColor { (collection) -> UIColor in
        switch collection.userInterfaceStyle{
        case .dark:
            return .gray
        case .unspecified:
            return .darkGray
        case .light:
            return .darkGray
        @unknown default:
            return .darkGray
        }
    }
    
    static var grayColor: UIColor = UIColor { (collection) -> UIColor in
        switch collection.userInterfaceStyle{
        case .dark:
            return HEXCOLOR(h: 0x696969, alpha: 1.0)
        case .unspecified:
            return HEXCOLOR(h: 0xBEBEBE, alpha: 1.0)
        case .light:
            return HEXCOLOR(h: 0xBEBEBE, alpha: 1.0)
        @unknown default:
            return HEXCOLOR(h: 0xBEBEBE, alpha: 1.0)
        }
    }
    
    static var navLineColor: UIColor = UIColor { (collection) -> UIColor in
        switch collection.userInterfaceStyle{
        case .dark:
            return .clear
        case .unspecified:
            return HEXCOLOR(h: 0xBEBEBE, alpha: 1.0)
        case .light:
            return HEXCOLOR(h: 0xBEBEBE, alpha: 1.0)
        @unknown default:
            return HEXCOLOR(h: 0xBEBEBE, alpha: 1.0)
        }
    }
    
}

var userInterfaceStyle: UIUserInterfaceStyle = .unspecified

let collectionPageSize: Int = 100

class TabBarManager: NSObject {
    
    private static var _sharedInstance: TabBarManager?
    
    var mainTabbarController: MainPageTabBarController = MainPageTabBarController()
    
    @discardableResult class func shared() -> TabBarManager {
        guard let instance = _sharedInstance else {
            _sharedInstance = TabBarManager()
            return _sharedInstance!
        }
        return instance
    }

}


