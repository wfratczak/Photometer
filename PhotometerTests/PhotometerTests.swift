//
//  PhotometerTests.swift
//  PhotometerTests
//
//  Created by Wojtek Frątczak on 02.11.2016.
//  Copyright © 2016 Wojtek. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Photometer

class PhotometerTests: XCTestCase {
    
    var realm: Realm!
    var meters: [Meter] = []
    
    override func setUp() {
        super.setUp()
        realm = try! Realm()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
