//
//  IntegrationTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 2/3/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import XCTest
import Starscream
@testable import Discreet_DML

class IntegrationTests: XCTestCase {
    func testCloudIntegration() {
        /*
         MUST READ: Steps for testing.
         
         1. Launch the local cloud server (`python server.py`)
         2. Run this test
         3. Run the mock Explora (`python start_new_session.py ios`)
         
         WARNING: This test takes an even longer amount of time to run (about 10 minutes max).
         */
        let orchestrator2 = try! Orchestrator(repoID: testRepo)
        try! orchestrator2.realmClient.clear()
        orchestrator2.coreMLClient.modelLoader = ModelLoader(downloadModelURL: URL(string: "http://127.0.0.1:8999/my_model.mlmodel")!)
        try! orchestrator2.addImages(images: realImages, labels: realLabels)
        try! orchestrator2.connect(webSocketURL: testWebSocketURL)
        let iterationTime: Double = 0.5
        let maxTime: Double = 600
        let maxIterations = maxTime/iterationTime
        var numIterations = 0.0
        while numIterations < maxIterations {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: iterationTime))
            numIterations += 1
        }
    }
    
    func testCloudExploraIntegration() {
        /*
         MUST READ: Steps for testing.
         
         1. Run this test
         2. Run Explora cells with the appropriate repo ID
         
         WARNING: This test takes an even longer amount of time to run (about 10 minutes max).
         */
        
        let orchestrator2 = try! Orchestrator(repoID: testRemoteRepo)
        try! orchestrator2.addImages(images: realImages, labels: realLabels)
        try! orchestrator2.connect()
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
