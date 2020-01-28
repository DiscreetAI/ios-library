//
//  RealmClientTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/27/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import XCTest
@testable import Discreet_DML

class RealmClientTests: XCTestCase {
    var realmClient: RealmClient = RealmClient()

    override func setUp() {
        realmClient.clear()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        //realmClient.clear()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRealmGetStore() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let data: [[Double]] = [[1.1, 2.2], [3.3, 4.4]]
        realmClient.storeStandardData(repoID: "test", data: data)
        let result: RealmDataDouble? = realmClient.getStandardData(repoID: "test")
        XCTAssertNotNil(result)
        if result != nil {
            func getData(datapoint: RealmDatapointDouble) -> [Double] {
                return Array(datapoint.datapoint)
            }
            let resultData = Array(result!.data).map(getData)
            XCTAssertEqual(data, resultData)
        }
        
    }
    
    func testBadGet() {
        var result = realmClient.getStandardData(repoID: "test")
        XCTAssertNil(result)
    }
}
