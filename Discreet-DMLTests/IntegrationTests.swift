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

class IntegrationTests: XCTestCase {
    let orchestrator = try! DummyOrchestrator(repoID: testRepo)

    override func setUp() {
        try! orchestrator.realmClient.clear()
    }

    func testIntegration() {
        /*
         Test general integration of library components.

         Here is a list of things that are not tested here:
         - Communication Manager communication (we shouldn't rely on cloud node for testing, and yet there isn't a simple way of setting up a local test server)
         - MPS (Cocoapods does not support all dependencies for Mac Catalyst, so we must only test on iOS, and we don't have a physical iOS device yet).
         - Downloading the converted model from a cloud node instead of just S3 (Again shouldn't rely on cloud node for testing)
         
         WARNING: This test takes a long time to run (about 2 minutes).
         */
        let iterationTime: Double = 0.5
        let maxTime: Double = 125
        let maxIterations = maxTime/iterationTime
        var numIterations = 0.0

        orchestrator.storeImages(images: testImages, labels: testLabels)
        do {
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
    
    func testCloud() {
        /*
         MUST READ: Steps for testing.
         
         1. Launch the local cloud server (`python server.py`)
         2. Run this test
         3. Run the mock Explora (`python start_new_session.py ios`)
         
         WARNING: This test takes an even longer amount of time to run (about 10 minutes max).
         */
        let orchestrator2 = try! Orchestrator(repoID: testRepo, connect: false)
        orchestrator2.coreMLClient.modelLoader = ModelLoader(downloadModelURL: URL(string: "http://127.0.0.1:8999/my_model.mlmodel")!)
        orchestrator2.storeImages(images: testImages, labels: testLabels)
        orchestrator2.connect(webSocketURL: testWebSocketURL)
        let iterationTime: Double = 0.5
        let maxTime: Double = 600
        let maxIterations = maxTime/iterationTime
        var numIterations = 0.0
        while numIterations < maxIterations {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: iterationTime))
            numIterations += 1
        }
    }
    
    func testEndToEnd() {
        /*
         MUST READ: Steps for testing.
         
         1. Run this test
         2. Run Explora cells with the appropriate repo ID
         
         WARNING: This test takes an even longer amount of time to run (about 10 minutes max).
         */
        let repoID = "f93bb383416a5140c328ee1bd177eb6c"
        let orchestrator2 = try! Orchestrator(repoID: repoID)
        orchestrator2.storeImages(images: testImages, labels: testLabels)
        let iterationTime: Double = 0.5
        let maxTime: Double = 600
        let maxIterations = maxTime/iterationTime
        var numIterations = 0.0
        while numIterations < maxIterations {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: iterationTime))
            numIterations += 1
        }
    }
}
