//
//  AppDelegate.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/2/4.
//

import UIKit
import SDWebImage
import Alamofire
import Reachability
import YYKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var reachability: Reachability!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        do {
            try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Library/SplashBoard")
        } catch {
            print("Failed to delete launch screen cache: \(error)")
        }
        
        Thread.sleep(forTimeInterval: 0.5)
        
        self.window = UIWindow()
        self.window?.rootViewController = TabBarManager.shared().mainTabbarController
        self.window?.makeKeyAndVisible()
        
        DispatchQueue.global().async {
            if let notAutoLoad = UserDefaults.standard.value(forKey: Setting.autoLoadingOriginalSizeImage) as? Bool{
                Setting.notAutoLoad = notAutoLoad
            }
            
            if let autoDisplayToolView = UserDefaults.standard.value(forKey: Setting.autoDisplayToolViewKey) as? Bool{
                Setting.autoDisplayToolView = autoDisplayToolView
            }
            
            if let scrollAnimationEnable = UserDefaults.standard.value(forKey: Setting.scrollAnimationSwitchKey) as? Bool{
                Setting.scrollAnimationEnable = scrollAnimationEnable
            }
            
            if let maxDiskSize = UserDefaults.standard.value(forKey: Setting.diskSize) as? UInt{
                YYImageCache.shared().diskCache.costLimit = maxDiskSize
            }
            if YYImageCache.shared().diskCache.costLimit == 0{
                YYImageCache.shared().diskCache.costLimit = 1024 * 1024 * 1024
            }
            
            SDImageCache.shared.deleteOldFiles(completionBlock: nil)
            
            SQLManager.shared()
        }
        
        reachability = try! Reachability()
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                netWordState = .ethernetOrWiFi
            } else {
                netWordState = .cellular
            }
        }
        reachability.whenUnreachable = { _ in
            netWordState = .notReachable
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
                
        // 获取当前模式
        let currentMode = UITraitCollection.current.userInterfaceStyle
        if (currentMode == .dark) {
            print("深色模式")
        } else if (currentMode == .light) {
            print("浅色模式")
        } else {
            print("未知模式")
        }
        
        SDImageCache.shared.clearDisk {
            
        }
        
        return true
    }

}

