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

let orchestrator = DummyOrchestrator(repoID: testRepo)
class IntegrationTests: XCTestCase {
    
    override func setUp() {
        orchestrator.realmClient.clear()
    }

    func testIntegration() {
        /*
         Test general integration of library components.
         
         Here is a list of things that are not tested here:
         - Communication Manager communication (we shouldn't rely on cloud node for testing, and yet there isn't a simple way of setting up a local test server)
         - MPS (Cocoapods does not support all dependencies for Mac Catalyst, so we must only test on iOS, and we don't have a physical iOS device yet).
         - Downloading the converted model from a cloud node instead of just S3 (Again shouldn't rely on cloud node for testing)
         */
        orchestrator.storeImages(images: testImages, labels: testLabels)
        _ = orchestrator.communicationManager.handleNewEvent(event: WebSocketEvent.text(trainMessage))
        
        let iterationTime: Double = 0.5
        let maxTime: Double = 50
        let maxIterations = maxTime/iterationTime
        var numIterations = 0.0
        
        let dummyCommunicationManager: DummyCommunicationManager = orchestrator.communicationManager as! DummyCommunicationManager
        while !dummyCommunicationManager.success && numIterations < maxIterations {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: iterationTime))
            numIterations += 1
        }
        
        XCTAssertTrue(dummyCommunicationManager.success)
    }
}
