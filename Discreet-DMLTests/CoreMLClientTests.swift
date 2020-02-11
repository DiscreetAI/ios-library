//
//  CoreMLClientTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/30/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import XCTest
@testable import Discreet_DML

let artifactsPath: String = testingUtilsPath + "CoreMLClient/"

class CoreMLClientTests: XCTestCase {
    func testTraining() {
        /*
         Verify the training of a simple image classifier. Test that training finishes within a reasonable amount of time. 
         */
        let iterationTime: Double = 0.5
        let maxTime: Double = 10
        let maxIterations = maxTime/iterationTime
        var numIterations = 0.0
        
        do {
            let coreMLClient = CoreMLClient(modelLoader: DummyModelLoader(), realmClient: try DummyRealmClient(), weightsProcessor: DummyWeightsProcessor())
            let communicationManager = DummyCommunicationManager(coreMLClient: coreMLClient)
            coreMLClient.configure(communicationManager: communicationManager)
            let job = DMLJob(repoID: testRepo, sessionID: testSession, round: testRound)
            try coreMLClient.train(job: job)
            
            while !communicationManager.success && numIterations < maxIterations {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: iterationTime))
                numIterations += 1
            }
            
            XCTAssertTrue(communicationManager.success)
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }
}