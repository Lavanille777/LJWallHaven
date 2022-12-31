//
//  UserDefaults.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/10.
//

import UIKit

extension UserDefaults {
    
    func setValue(_ value: Any?, forKey key: String, synchronizeToCloud: Bool = false) {
        self.setValue(value, forKey: key)
//        if synchronizeToCloud{
//            NSUbiquitousKeyValueStore.default.set(value, forKey: key)
//            NSUbiquitousKeyValueStore.default.synchronize()
//        }
    }

}
