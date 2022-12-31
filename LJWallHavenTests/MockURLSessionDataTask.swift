//
//  MockURLSessionDataTask.swift
//  LJWallHavenTests
//
//  Created by 唐星宇 on 2021/2/4.
//

import XCTest
@testable import LJWallHaven

class MockURLSessionDataTask: URLSessionDataTaskProtocol {

    private (set) var isResumeCalled = false
    
    func resume() {
        self.isResumeCalled = true
    }
    
}
