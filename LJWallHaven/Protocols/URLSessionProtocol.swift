//
//  URLSessionProtocol.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/2/4.
//
import Foundation

protocol URLSessionProtocol {
    typealias dataTaskHandler = (Data?, URLResponse?, Error?) -> Void
    
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping dataTaskHandler)
    -> URLSessionDataTaskProtocol
}

