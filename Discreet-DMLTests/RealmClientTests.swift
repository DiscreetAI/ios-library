//
//  RealmClientTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/27/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import XCTest
import RealmSwift
import Foundation
@testable import Discreet_DML

class RealmClientTests: XCTestCase {
    var realmClient = try! RealmClient()
    
    override func setUp() {
        try! realmClient.clear()
    }
    
    func testDoubleGetStore() {
        /*
         Test storing Double data and retrieving it.
         */
        let data = [[1.1, 2.2], [3.3, 4.4]]
        let labels = ["small", "large"]
        
        do {
            try realmClient.storeData(repoID: "test", data: data, labels: labels)
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
        
        
        let metaDataEntry = realmClient.getMetadataEntry(repoID: "test")
        XCTAssertNotNil(metaDataEntry)
        if metaDataEntry != nil {
            XCTAssertEqual(metaDataEntry!.dataType, DataType.DOUBLE.rawValue)
        }
        
        let doubleEntry = realmClient.getDoubleEntry(repoID: "test")
        XCTAssertNotNil(doubleEntry)
        if doubleEntry != nil {
            let (doubleData, doubleLabels) = doubleEntry!.getData()
            XCTAssertEqual(data, doubleData)
            XCTAssertEqual(labels, doubleLabels)
        }
    }
    
    func testImageGetStore() {
        /*
         Test storing image data and retrieving it.
         */
        let data = ["path1", "path2"]
        let labels = ["small", "large"]
        
        do {
            try realmClient.storeData(repoID: "test", data: data, labels: labels)
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
        
        
        let metaDataEntry = realmClient.getMetadataEntry(repoID: "test")
        XCTAssertNotNil(metaDataEntry)
        if metaDataEntry != nil {
            XCTAssertEqual(metaDataEntry!.dataType, DataType.IMAGE.rawValue)
        }
        
        let imageEntry = realmClient.getImageEntry(repoID: "test")
        
        XCTAssertNotNil(imageEntry)
        if imageEntry != nil {
            let (imageData, imageLabels) = imageEntry!.getData()
            XCTAssertEqual(data, imageData)
            XCTAssertEqual(labels, imageLabels)
        }
    }

    func testBadGet() {
        /*
         Test getting with an invalid `repoID`.
         */
        let result = realmClient.getDataEntry(repoID: "test")
        XCTAssertNil(result)
    }
}
