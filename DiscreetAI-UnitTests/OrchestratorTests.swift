//
//  OrchestratorTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 2/3/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import XCTest
import Starscream
@testable import DiscreetAI

class OrchestratorTests: XCTestCase {
    let orchestrator = try! DummyOrchestrator(repoID: testRepo, connectImmediately: false)
    
    override func tearDown() {
        try! orchestrator.clearData(datasetID: testDataset)
    }
    
    func testInvalidRepoID() {
        /*
         Test validation of the repo ID.
         */
        do {
            let badOrchestrator = try Orchestrator(repoID: testRepo, connectImmediately: false)
            XCTAssertThrowsError(try badOrchestrator.connect()) { error in
            XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidRepoID))
            
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testInvalidData() {
        /*
         Test validation with the addition of new data.
         */
        do {
            let orchestrator = try Orchestrator(repoID: testRepo, connectImmediately: false)
            
            XCTAssertThrowsError(try orchestrator.addImages(datasetID: testDataset, images: testImages, labels: testImageLabels)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidImagePath))
            }
            
            XCTAssertThrowsError(try orchestrator.addImages(datasetID: testDataset, images: [], labels: [])) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidStore))
            }
            
            XCTAssertThrowsError(try orchestrator.addImages(datasetID: testDataset, images: realImages, labels: testImageLabels)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidStore))
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testInvalidImageRemove() {
        /*
         Test validation with removing an image.
         */
        do {
            let orchestrator = try Orchestrator(repoID: testRepo, connectImmediately: false)
            try orchestrator.addImages(datasetID: testDataset, images: Array(realImages[0...1]), labels: Array(realLabels[0...1]))
            
            XCTAssertThrowsError(try orchestrator.removeImage(datasetID: testDataset, image: "badPath")) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidImagePath))
            }
            
            XCTAssertThrowsError(try orchestrator.removeImage(datasetID: testDataset, index: 10)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidDatapointIndex))
            }
            
            XCTAssertThrowsError(try orchestrator.removeImage(datasetID: testDataset, index: -1)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidDatapointIndex))
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testInvalidDataType() {
        do {
            let orchestrator = try Orchestrator(repoID: testRepo, connectImmediately: false)
            try orchestrator.addImages(datasetID: testDataset, images: realImages, labels: realLabels)
            
            XCTAssertThrowsError(try orchestrator.addEncodings(datasetID: testDataset, encodings: testEncodings, labels: testEncodingLabels)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidDataType))
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testInvalidDefaultDatasetStore() {
        do {
            let orchestrator = try Orchestrator(repoID: testRepo, connectImmediately: false)
            
            let mnist = ImageDatasets.MNIST.rawValue
            XCTAssertThrowsError(try orchestrator.addImages(datasetID: mnist, images: testImages, labels: testImageLabels)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.defaultDataset))
            }
            
            let shakespeare = TextDatasets.SHAKESPEARE.rawValue
            XCTAssertThrowsError(try orchestrator.addEncodings(datasetID: shakespeare, encodings: testEncodings, labels: testEncodingLabels)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.defaultDataset))
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }

    func testOrchestratorEndtoEnd() {
        /*
         Test general integration of library components.

         Here is a list of things that are not tested here:
         - Communication Manager communication (we shouldn't rely on cloud node for testing, and yet there isn't a simple way of setting up a local test server)
         - MPS (Cocoapods does not support all dependencies for Mac Catalyst, so we must only test on iOS, and we don't have a physical iOS device yet).
         - Downloading the converted model from a cloud node instead of just S3 (Again shouldn't rely on cloud node for testing)
         
         WARNING: This test takes a long time to run (about 2 minutes).
         */
        let iterationTime: Double = 0.5
        let maxTime: Double = 200
        let maxIterations = maxTime/iterationTime
        var numIterations = 0.0

        do {
            try orchestrator.addImages(datasetID: testDataset, images: realImages, labels: realLabels)
            let result = try orchestrator.communicationManager.handleNewEvent(event: WebSocketEvent.text(trainMessage))
            XCTAssertNil(result)
            let dummyCommunicationManager: DummyCommunicationManager = orchestrator.communicationManager as! DummyCommunicationManager
            while !dummyCommunicationManager.success && numIterations < maxIterations {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: iterationTime))
                numIterations += 1
            }
            XCTAssertTrue(dummyCommunicationManager.success)
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
}
