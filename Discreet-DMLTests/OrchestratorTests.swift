//
//  OrchestratorTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 2/3/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import XCTest
import Starscream
@testable import Discreet_DML

class OrchestratorTests: XCTestCase {
    let orchestrator = try! DummyOrchestrator(repoID: testRepo)

    override func setUp() {
        try! orchestrator.realmClient.clear()
    }
    
    func testInvalidRepoID() {
        XCTAssertThrowsError(try Orchestrator(repoID: testRepo, encodings: testEncodings, labels: testEncodingLabels)) { error in
            XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidRepoID))
        }
    }
    
    func testInvalidData() {
        do {
            let orchestrator = try Orchestrator(repoID: testRepo)
            
            XCTAssertThrowsError(try orchestrator.addImages(images: testImages, labels: testLabels)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidImagePath))
            }
            
            XCTAssertThrowsError(try orchestrator.addImages(images: [], labels: [])) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidStore))
            }
            
            XCTAssertThrowsError(try orchestrator.addImages(images: realImages, labels: testLabels)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidStore))
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testInvalidImageRemove() {
        do {
            let orchestrator = try Orchestrator(repoID: testRepo)
            try! orchestrator.addImages(images: Array(realImages[0...1]), labels: Array(realLabels[0...1]))
            
            XCTAssertThrowsError(try orchestrator.removeImage(image: "badPath")) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidImagePath))
            }
            
            XCTAssertThrowsError(try orchestrator.removeImage(index: 10)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidDatapointIndex))
            }
            
            XCTAssertThrowsError(try orchestrator.removeImage(index: -1)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidDatapointIndex))
            }
            
            try orchestrator.removeImage(index: 0)
            orchestrator.communicationManager.isConnected = true
            
            XCTAssertThrowsError(try orchestrator.removeImage(index: 0)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.invalidImageRemove))
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testConnectWithoutDatapoints() {
        do {
            let orchestrator = try Orchestrator(repoID: testRepo)
            
            XCTAssertThrowsError(try orchestrator.connect(webSocketURL: testWebSocketURL)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.failedRealmRead))
            }
            
            try orchestrator.addImages(images: Array(realImages[0..<1]), labels: Array(realLabels[0..<1]))
            try orchestrator.removeImage(index: 0)
            
            XCTAssertThrowsError(try orchestrator.connect(webSocketURL: testWebSocketURL)) { error in
                XCTAssertEqual(error as! DMLError, DMLError.userError(ErrorMessage.noDatapoints))
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
        let maxTime: Double = 300
        let maxIterations = maxTime/iterationTime
        var numIterations = 0.0

        do {
            try orchestrator.addImages(images: realImages, labels: realLabels)
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
