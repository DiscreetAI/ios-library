//
//  RealmClientTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/27/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import XCTest
import RealmSwift
@testable import Discreet_DML

class RealmClientTests: XCTestCase {
    var realmClient = RealmClient()
    
    override func setUp() {
        realmClient.clear()
    }
    
    func testRealmGetStore() {
        /*
         Test storing data and retrieving it.
         */
        let data: [[Double]] = [[1.1, 2.2], [3.3, 4.4]]
        realmClient.storeData(repoID: "test", data: data)
        let result: DoubleEntry? = realmClient.getDoubleEntry(repoID: "test")
        XCTAssertNotNil(result)
        if result != nil {
            let resultData = Array(result!.data).map({
                (datapoint: DoubleDatapoint) -> [Double] in
                return Array(datapoint.datapoint)
            })
            XCTAssertEqual(data, resultData)
        }
    }

    func testBadGet() {
        /*
         Test getting with an invalid `repoID`.
         */
        var result = realmClient.getDataEntry(repoID: "test")
        XCTAssertNil(result)
    }
}
