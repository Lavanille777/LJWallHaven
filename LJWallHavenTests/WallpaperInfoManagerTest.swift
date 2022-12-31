//
//  WallpaperInfoManagerTest.swift
//  LJWallHavenTests
//
//  Created by 唐星宇 on 2021/2/4.
//

import XCTest
@testable import LJWallHaven

class WallpaperInfoManagerTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func test_getWallpaperInfoBy_starts_the_session(){
        
        let session = MockURLSession()
        let dataTask = MockURLSessionDataTask()
        
        session.sessionDataTask = dataTask
        
//        let manager = WallPaperInfoManager(baseURL: API.baseUrl, urlSession: session)
//
//        var decoded: WallpaperInfoModel? = nil
//
//        manager.getWallpaperBy(id: "yjed9d", isAuthentic: true) { (model, error) in
//            decoded = model
//        }
//
//        XCTAssert(session.sessionDataTask.isResumeCalled)
        
    }

}
