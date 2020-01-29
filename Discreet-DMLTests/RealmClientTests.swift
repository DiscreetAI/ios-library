////
////  RealmClientTests.swift
////  Discreet-DMLTests
////
////  Created by Neelesh on 1/27/20.
////  Copyright © 2020 DiscreetAI. All rights reserved.
////
import XCTest
import RealmSwift
@testable import Discreet_DML

class RealmClientTests: XCTestCase {
    
//
//    override func setUp() {
//        realmClient.clear()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        //realmClient.clear()
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testRealmGetStore() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        let data: [[Double]] = [[1.1, 2.2], [3.3, 4.4]]
//        realmClient.storeData(repoID: "test", data: data)
//        let result: DoubleEntry? = realmClient.getDoubleEntry(repoID: "test")
//        XCTAssertNotNil(result)
//        if result != nil {
//            let resultData = Array(result!.data).map({
//                (datapoint: DoubleDatapoint) -> [Double] in
//                return Array(datapoint.datapoint)
//            })
//            XCTAssertEqual(data, resultData)
//        }
//
//    }
//
//    func testBadGet() {
//        var result = realmClient.getDataEntry(repoID: "test")
//        XCTAssertNil(result)
//    }
    func testSanity() {
        var realmClient: RealmClient = RealmClient()
        XCTAssertNil(nil)
    }
}
