//
//  URLSession.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/2/4.
//

import Foundation

extension URLSession: URLSessionProtocol {
    
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping dataTaskHandler)
    -> URLSessionDataTaskProtocol {
        
        return (dataTask(
                    with: request,
                    completionHandler: completionHandler)
                    as URLSessionDataTask)
            as URLSessionDataTaskProtocol
        
    }
    

}
