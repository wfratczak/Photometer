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
        meters = Array(realm.objects(Meter.self))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMeterImageRecognize() {
        var recognizedIndex = 999
        var max = 0.0
        if let sourceImageFromFirstAvailableMeter = meters.first?.image {
            for (index, meter) in meters.enumerated() {
                let result = OpenCV.compare(sourceImageFromFirstAvailableMeter, with: meter.image)
                print("Reult for meter name: \(meter.name) \(result)")
                if (result?.first?.doubleValue)! > max {
                    recognizedIndex = index
                    max = (result?.first?.doubleValue)!
                }
            }
            XCTAssert(recognizedIndex == 0)
        } else {
            print("No meters available!")
        }
    }
    
}
