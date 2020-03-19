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
@testable import DiscreetAI

class RealmClientTests: XCTestCase {
    var realmClient = try! RealmClient(repoID: testRepo)
    
    override func setUp() {
        try! realmClient.clear()
    }
    
    func testTextGetStore() {
        /*
         Test storing Double data and retrieving it.
         */
        do {
            try realmClient.addTextData(datasetID: testDataset, encodings: testEncodings, labels: testEncodingLabels)
            XCTAssert(realmClient.containsDataEntry(datasetID: testDataset))
            if realmClient.containsDataEntry(datasetID: testDataset) {
            
                if let encodingEntry = realmClient.getTextEntry(datasetID: testDataset) {
                    XCTAssertEqual(encodingEntry.dataType, DataType.TEXT.rawValue)
                    let (retrievedEncodings, retrievedLabels) = encodingEntry.getData()
                    XCTAssertEqual(testEncodings, retrievedEncodings)
                    XCTAssertEqual(testEncodingLabels, retrievedLabels)
                } else {
                    XCTFail()
                }
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testImageGetStore() {
        /*
         Test storing image data and retrieving it.
         */
        do {
            try realmClient.addImageData(datasetID: testDataset, images: testImages, labels: testLabels)
            XCTAssert(realmClient.containsDataEntry(datasetID: testDataset))
            if realmClient.containsDataEntry(datasetID: testDataset) {
            
                if let imageEntry = realmClient.getImageEntry(datasetID: testDataset) {
                    XCTAssertEqual(imageEntry.dataType, DataType.IMAGE.rawValue)
                    let (retrievedImages, retrievedLabels) = imageEntry.getData()
                    XCTAssertEqual(testImages, retrievedImages)
                    XCTAssertEqual(testLabels, retrievedLabels)
                    
                } else {
                    XCTFail()
                }
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testRemoveImageDatapoint() {
        do {
            try realmClient.addImageData(datasetID: testDataset, images: testImages, labels: testLabels)
            
            try realmClient.removeImageDatapoint(datasetID: testDataset, index: 1)
            let data1 = realmClient.getImageEntry(datasetID: testDataset)!.getData()
            XCTAssertEqual(data1.0, [testImages[0]])
            XCTAssertEqual(data1.1, [testLabels[0]])
            
            try realmClient.removeImageDatapoint(datasetID: testDataset, image: "path1")
            let data2 = realmClient.getImageEntry(datasetID: testDataset)!.getData()
            XCTAssertEqual(data2.0, [])
            XCTAssertEqual(data2.1, [])
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }

    func testBadGet() {
        /*
         Test getting with an invalid `repoID`.
         */
        let result = realmClient.getDataEntry(datasetID: "badRepo")
        XCTAssertNil(result)
    }
}
