//
//  LoadingViewManager.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/4.
//

import UIKit
import NVActivityIndicatorView

class LoadingViewManager: NSObject {
    
    private static var _sharedInstance: LoadingViewManager?
    
    var loadingView: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: WidthScale(100), height: WidthScale(100)), type: .ballRotateChase, color: .white, padding: WidthScale(20))
    
    /// 单例
    @discardableResult class func shared() -> LoadingViewManager {
        guard let instance = _sharedInstance else {
            _sharedInstance = LoadingViewManager()
            _sharedInstance?.loadingView.backgroundColor = .darkGray
            _sharedInstance?.loadingView.alpha = 0.9
            _sharedInstance?.loadingView.layer.masksToBounds = true
            _sharedInstance?.loadingView.layer.cornerRadius = WidthScale(10)
            return _sharedInstance!
        }
        return instance
    }

}
