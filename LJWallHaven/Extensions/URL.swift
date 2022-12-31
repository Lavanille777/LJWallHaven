//
//  URL.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/2.
//

import UIKit

extension URL {
    /// URL中文编码处理
    /// - Parameter string: 带中文的url
    /// - Returns: 编码后的url
    static func initPercent(string:String) -> URL
    {
        let urlwithPercentEscapes = string.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let url = URL.init(string: urlwithPercentEscapes!)
        return url!
    }
}
