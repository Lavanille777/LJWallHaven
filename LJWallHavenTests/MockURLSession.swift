//
//  MockURLSession.swift
//  LJWallHavenTests
//
//  Created by 唐星宇 on 2021/2/4.
//

import XCTest
@testable import LJWallHaven

class MockURLSession: URLSessionProtocol {
    var sessionDataTask = MockURLSessionDataTask()
    
    func dataTask(with request: URLRequest, completionHandler: @escaping dataTaskHandler) -> URLSessionDataTaskProtocol {
        return sessionDataTask
    }
    
}
