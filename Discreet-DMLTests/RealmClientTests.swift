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
    
    func testTextGetStore() {
        /*
         Test storing Double data and retrieving it.
         */
        do {
            try realmClient.addTextData(repoID: testRepo, encodings: testEncodings, labels: testEncodingLabels)
            let metaDataEntry = realmClient.getMetadataEntry(repoID: testRepo)
            XCTAssertNotNil(metaDataEntry)
            if metaDataEntry != nil {
                XCTAssertEqual(metaDataEntry!.dataType, DataType.TEXT.rawValue)
                let encodingEntry = realmClient.getTextEntry(repoID: testRepo)
                XCTAssertNotNil(encodingEntry)
                if encodingEntry != nil {
                    let (retrievedEncodings, retrievedLabels) = encodingEntry!.getData()
                    XCTAssertEqual(testEncodings, retrievedEncodings)
                    XCTAssertEqual(testEncodingLabels, retrievedLabels)
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
            try realmClient.addImageData(repoID: testRepo, images: testImages, labels: testLabels)
            let metaDataEntry = realmClient.getMetadataEntry(repoID: testRepo)
            XCTAssertNotNil(metaDataEntry)
            if metaDataEntry != nil {
                XCTAssertEqual(metaDataEntry!.dataType, DataType.IMAGE.rawValue)
                let imageEntry = realmClient.getImageEntry(repoID: testRepo)
                
                XCTAssertNotNil(imageEntry)
                if imageEntry != nil {
                    let (imageData, imageLabels) = imageEntry!.getData()
                    XCTAssertEqual(testImages, imageData)
                    XCTAssertEqual(testLabels, imageLabels)
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
            try realmClient.addImageData(repoID: testRepo, images: testImages, labels: testLabels)
            
            try realmClient.removeImageDatapoint(repoID: testRepo, index: 1)
            let data1 = realmClient.getImageEntry(repoID: testRepo)!.getData()
            XCTAssertEqual(data1.0, [testImages[0]])
            XCTAssertEqual(data1.1, [testLabels[0]])
            
            try realmClient.removeImageDatapoint(repoID: testRepo, image: "path1")
            let data2 = realmClient.getImageEntry(repoID: testRepo)!.getData()
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
        let result = realmClient.getDataEntry(repoID: "badRepo")
        XCTAssertNil(result)
    }
}
