//
//  CommunicationManager.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/22/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import Starscream

enum State {
    /*
     State of the library.
     */
    case idle
    case waiting
    case training
}

class CommunicationManager: WebSocketDelegate {
    /*
     Manage communication with cloud node. Includes handling new connections, disconnections, and training messages.
     */
    var coreMLClient: CoreMLClient!
    var socket: WebSocket!
    var webSocketURL: URL!
    var reconnections: Int!

    var isConnected = false
    var state = State.idle


    init(coreMLClient: CoreMLClient, reconnections: Int = 3) {
        self.coreMLClient = coreMLClient
        self.reconnections = reconnections
    }

    public func connect(webSocketURL: URL) {
        /*
         Connect to the cloud node via WebSocket with the given URL. Save the URL in case future reconnections are needed.
         */
        self.webSocketURL = webSocketURL
        var request = URLRequest(url: webSocketURL)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket.delegate = self
        self.socket.connect()
    }

    private func reconnect() {
        /*
         Reconnect with the cloud node using the saved URL.
         */
        connect(webSocketURL: self.webSocketURL)
    }

    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        /*
         Higher level function for dealing with new event. If our handler deems that there is a message to be sent, then send it.
         */
        print("New event with client \(client)!")

        if let message = handleNewEvent(event: event) {
            socket.write(string: message)
        }
    }

    public func handleNewEvent(event: WebSocketEvent) -> String? {
        /*
         Inspect the provided event, and take the necessary actions. If there is a message to be sent to the cloud node, return it.
         */
        switch event {
        case .connected(let headers):
            print("websocket is connected: \(headers)")
            return handleNewConnection()
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
            handleDisconnection()
        case .text(let string):
            print("Received new message!")
            handleNewMessage(jsonString: string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viablityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            self.isConnected = false
        case .error(let error):
            self.isConnected = false
            handleError(error: error!)
        }
        return nil
    }

    private func handleNewConnection() -> String {
        /*
         Handler for new connections. Send a register message to the cloud node so that it registers this library.
         */
        self.isConnected = true
        self.reconnections = 3
        let registrationMessage = makeDictionaryString(keys: ["type", "node_type"], values: ["REGISTER", "library"])
        state = State.waiting
        return registrationMessage
    }

    private func handleDisconnection() {
        /*
         Handler for disconnections. As long as we have not had 3 straight disconnections, attempt to reconnect to the cloud node.
         */
        self.reconnections -= 1
        if self.reconnections > 0 {
            print("Reconnecting...")
            reconnect()
        } else {
            print("Failed to connect!")
            self.isConnected = false
            self.reset()
        }
    }

    private func handleNewMessage(jsonString: String) {
        /*
         Handler for new messages. Depending on the `action`, either begin training or set the state to `idle`.
         */
        let message: NSDictionary = parseJSON(jsonString: jsonString)
        switch message["action"] as! String {
        case "TRAIN":
            print("Received TRAIN message.")
            let job = DMLJob(sessionID: message["sessionID"] as! String, round: message["round"] as! Int)
            self.coreMLClient.train(job: job, callback: handleTrainingComplete)
            state = State.training
            break
        case "STOP":
            print("Received STOP message.")
            self.state = State.idle
            self.socket.disconnect()
            break
        default:
            print("Received unknown message.")
        }
    }

    private func handleError(error: Error) {
        /*
         Handler for errors with WebSocket. For now, just print the error.
         */
        print("Error occurred: \(error)")
    }

    public func handleTrainingComplete(job: DMLJob) -> String {
        /*
         Handler for Core ML when training has finished. Make the update message and send it.
         */
        let resultsMessage = makeDictionaryString(keys: ["gradients", "omega"], values: [job.gradients, job.omega])
        let updateMessage = makeDictionaryString(keys: ["type", "round", "session_id", "results"], values: ["NEW_UPDATE", job.round, job.sessionID, resultsMessage])
        if self.socket != nil {
            self.socket.write(string: updateMessage)
        }
        self.state = State.waiting
        return updateMessage
    }

    public func reset() {
        /*
         Reset the Communication Manager back to its default state. Primarily useful for debugging and tests.
         */
        self.state = State.idle
        self.isConnected = false
    }
}
