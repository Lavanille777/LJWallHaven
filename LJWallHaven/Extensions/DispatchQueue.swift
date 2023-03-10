//
//  DispatchQueue.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/3.
//

import UIKit

extension DispatchQueue {
    
    typealias Task = (_ cancel: Bool) -> Void
    
    /// 设置可取消的延时任务
    /// - Parameters:
    ///   - time: 延时
    ///   - task: 任务
    /// - Returns: 延时任务
    func delay(_ time: TimeInterval, task: @escaping ()->()) -> Task? {
        
        func dispatch_later(_ block: @escaping ()->()) {
            let t = DispatchTime.now() + time
            self.asyncAfter(deadline: t, execute: block)
        }
        
        var closure: (()->Void)? = task
        var result: Task?
        
        let delayedClosure: Task = { cancel in
            if let internalClosure = closure {
                if cancel == false {
                    self.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        
        return result
    }
    
    func cancel(_ task: Task?) {
        task?(true)
    }
}

