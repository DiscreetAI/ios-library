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
@testable import Discreet_DML

class CommunicationManagerTests: XCTestCase {
    var communicationManager = CommunicationManager(coreMLClient: DummyCoreMLClient(), repoID: "testRepo")

    override func tearDown() {
        communicationManager.reset()
    }

    func testNewConnection() {
        /*
         Test that the protocol for a new connection is correct.
         */
        let registrationMessage = makeDictionaryString(keys: ["node_type", "type"], values: ["library", "REGISTER"])
        let actual = communicationManager.handleNewEvent(event: WebSocketEvent.connected(["header": "headerValue"]))
        XCTAssertNotNil(actual)
        let expectedJSON = parseJSON(stringOrFile: registrationMessage, isString: true) as! NSDictionary
        let actualJSON = parseJSON(stringOrFile: actual!, isString: true) as! NSDictionary
        XCTAssertEqual(expectedJSON["type"] as! String, actualJSON["type"] as! String)
        XCTAssertEqual(expectedJSON["node_type"] as! String, actualJSON["node_type"] as! String)
        XCTAssertTrue(communicationManager.isConnected)
        XCTAssertEqual(communicationManager.state, State.waiting)
    }

    func testDisconnection() {
        /*
         Test that the protocol for a disconnection is correct.
         */
        communicationManager.isConnected = true
        communicationManager.state = State.waiting
        communicationManager.reconnections = 1
        let result = communicationManager.handleNewEvent(event: WebSocketEvent.disconnected("Reason", 1000))
        XCTAssertNil(result)
        XCTAssertFalse(communicationManager.isConnected)
        XCTAssertEqual(communicationManager.state, State.idle)
    }

    func testNewTrainMessage() {
        /*
         Test that the protocol for a new train message is correct.
         */
        let result = communicationManager.handleNewEvent(event: WebSocketEvent.text(trainMessage))
        XCTAssertNil(result)
        XCTAssertEqual(communicationManager.state, State.training)
    }

    func testTrainingComplete() {
        /*
         Test that the message to be sent after training is correct.
         */
        let resultsMessage = makeDictionaryString(keys: ["gradients", "omega"], values: [[[1]], 1])
        let updateMessage = makeDictionaryString(keys: ["type", "round", "session_id", "results"], values: ["NEW_UPDATE", 1, "test", resultsMessage])

        let job = DMLJob(repoID: "testRepo", sessionID: "test", round: 1, gradients: [[1]], omega: 1)
        let actual = communicationManager.handleTrainingComplete(job: job)

        let expectedJSON = parseJSON(stringOrFile: updateMessage, isString: true) as! NSDictionary
        let actualJSON = parseJSON(stringOrFile: actual, isString: true) as! NSDictionary

        XCTAssertEqual(expectedJSON["type"] as! String, actualJSON["type"] as! String)
        XCTAssertEqual(expectedJSON["round"] as! Int, actualJSON["round"] as! Int)
        XCTAssertEqual(expectedJSON["session_id"] as! String, actualJSON["session_id"] as! String)

        let expectedResults = parseJSON(stringOrFile: expectedJSON["results"] as! String, isString: true ) as! NSDictionary
        let actualResults = parseJSON(stringOrFile: actualJSON["results"] as! String, isString: true) as! NSDictionary
        XCTAssertEqual(expectedResults["gradients"] as! [[Float32]], actualResults["gradients"] as! [[Float32]])
        XCTAssertEqual(expectedResults["omega"] as! Int, actualResults["omega"] as! Int)

        XCTAssertEqual(communicationManager.state, State.waiting)
    }

}
