//
//  CommunicationManagerTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/23/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import Starscream
import XCTest
@testable import DiscreetAI

class CommunicationManagerTests: XCTestCase {
    var communicationManager = CommunicationManager(coreMLClient: DummyCoreMLClient(), repoID: testRepo, apiKey: testApiKey, cloudDomain: testRepo)

    override func tearDown() {
        communicationManager.reset()
    }

    func testNewConnection() {
        /*
         Test that the protocol for a new connection is correct.
         */
        do {
            let actual = try communicationManager.handleNewEvent(event: WebSocketEvent.connected(["header": "headerValue"]))
            XCTAssertNotNil(actual)
            let expectedJSON = try parseJSON(stringOrFile: registrationMessage, isString: true) as! NSDictionary
            let actualJSON = try parseJSON(stringOrFile: actual!, isString: true) as! NSDictionary
            XCTAssertEqual(expectedJSON["type"] as! String, actualJSON["type"] as! String)
            XCTAssertEqual(expectedJSON["node_type"] as! String, actualJSON["node_type"] as! String)
            XCTAssertTrue(communicationManager.isConnected)
            XCTAssertEqual(communicationManager.state, State.awaitingRegistration)
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
        
        
    }

    func testDisconnection() {
        /*
         Test that the protocol for a disconnection is correct.
         */
        communicationManager.isConnected = true
        communicationManager.state = State.waiting
        communicationManager.reconnections = 1
        XCTAssertThrowsError(try communicationManager.handleNewEvent(event: WebSocketEvent.disconnected("Reason", 1000))) { error in
            XCTAssertEqual(error as! DMLError, DMLError.communicationManagerError(ErrorMessage.failedConnection)
        )}
    }

    func testNewTrainMessage() {
        /*
         Test that the protocol for a new train message is correct.
         */
        do {
            let job = DMLJob(datasetID: testDataset, sessionID: testSession, round: testRound)
            job.repoID = testRepo
            communicationManager.currentJobs = [job]
            let result = try communicationManager.handleNewEvent(event: WebSocketEvent.text(trainMessage))
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
            XCTAssertNil(result)
            XCTAssertEqual(communicationManager.state, State.training)
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }

    func testTrainingComplete() {
        /*
         Test that the message to be sent after training is correct.
         */
        do {
            let job = DummyDMLJob(datasetID: testDataset, sessionID: testSession, round: testRound)
            job.repoID = testRepo
            let actual = try communicationManager.handleTrainingComplete(job: job)

            let expectedJSON = try parseJSON(stringOrFile: updateMessage, isString: true) as! NSDictionary
            let actualJSON = try parseJSON(stringOrFile: actual, isString: true) as! NSDictionary

            XCTAssertEqual(expectedJSON["type"] as! String, actualJSON["type"] as! String)
            XCTAssertEqual(expectedJSON["round"] as! Int, actualJSON["round"] as! Int)
            XCTAssertEqual(expectedJSON["session_id"] as! String, actualJSON["session_id"] as! String)

            let expectedResults = try parseJSON(stringOrFile: expectedJSON["results"] as! String, isString: true ) as! NSDictionary
            let actualResults = try parseJSON(stringOrFile: actualJSON["results"] as! String, isString: true) as! NSDictionary
            XCTAssertEqual(expectedResults["gradients"] as! [[Float32]], actualResults["gradients"] as! [[Float32]])
            XCTAssertEqual(expectedResults["omega"] as! Int, actualResults["omega"] as! Int)

            XCTAssertEqual(communicationManager.state, State.waiting)
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
        
    }

}
