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

var realmClient = try! RealmClient(repoID: testRepo)

class RealmClientTests: XCTestCase {
    override func tearDown() {
        try! realmClient.clear(datasetID: testDataset)
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
            try realmClient.addImageData(datasetID: testDataset, images: testImages, labels: testImageLabels)
            XCTAssert(realmClient.containsDataEntry(datasetID: testDataset))
            if realmClient.containsDataEntry(datasetID: testDataset) {
                if let imageEntry = realmClient.getImageEntry(datasetID: testDataset) {
                    XCTAssertEqual(imageEntry.dataType, DataType.IMAGE.rawValue)
                    let (retrievedImages, retrievedLabels) = imageEntry.getData()
                    XCTAssertEqual(testImages, retrievedImages)
                    XCTAssertEqual(testImageLabels, retrievedLabels)
                    
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
            try realmClient.addImageData(datasetID: testDataset, images: testImages, labels: testImageLabels)
            
            try realmClient.removeImageDatapoint(datasetID: testDataset, index: 1)
            let data1 = realmClient.getImageEntry(datasetID: testDataset)!.getData()
            XCTAssertEqual(data1.0, [testImages[0]])
            XCTAssertEqual(data1.1, [testImageLabels[0]])
            
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
    
    func testDefaultDatasets() {
        do {
            let mnist = ImageDatasets.MNIST.rawValue
            XCTAssert(realmClient.containsDataEntry(datasetID: mnist))
            if realmClient.containsDataEntry(datasetID: mnist) {
                let (expectedImages, expectedLabels) = getMNISTData()
                let (actualImages, actualLabels) = realmClient.getImageEntry(datasetID: ImageDatasets.MNIST.rawValue)!.getData()
                XCTAssertEqual(expectedImages, actualImages)
                XCTAssertEqual(expectedLabels, actualLabels)
            }
            
            let shakespeare = TextDatasets.SHAKESPEARE.rawValue
            XCTAssert(realmClient.containsDataEntry(datasetID: shakespeare))
            if realmClient.containsDataEntry(datasetID: shakespeare) {
                let (expectedEncodings, expectedLabels) = try getShakespeareData()
                let (actualEncodings, actualLabels) = realmClient.getTextEntry(datasetID: shakespeare)!.getData()
                XCTAssertEqual(expectedEncodings, actualEncodings)
                XCTAssertEqual(expectedLabels, actualLabels)
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testDefaultDatasetsPersistence() {
        do {
            try realmClient.clear()
            testDefaultDatasets()
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
}
