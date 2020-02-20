//
//  CommunicationManager.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/22/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import Starscream

enum State : String {
    /*
     State of the library.
     */
    case notConnected = "Connecting to server..."
    case idle = "Waiting for training requests..."
    case waiting = "Waiting for the next round..."
    case notCharging = "Received training request! Device must \nbe charged before continuing with training."
    case training = "Your device is now training..."
    case trainingComplete = "Training complete!"
}

class CommunicationManager: WebSocketDelegate {
    /*
     Manage communication with cloud node. Includes handling new connections, disconnections, and training messages.
     */
    var coreMLClient: CoreMLClient?
    var repoID: String!
    var socket: WebSocket!
    var reconnections: Int!
    var currentJob: DMLJob?

    var isConnected = false
    var state = State.notConnected


    init(coreMLClient: CoreMLClient?, repoID: String, reconnections: Int = 3) {
        self.coreMLClient = coreMLClient
        self.repoID = repoID
        self.reconnections = reconnections
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.currentJob != nil && self.state != State.training {
                  if UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full {
                    try! self.coreMLClient!.train(job: self.currentJob!)
                    self.state = State.training
                } else {
                    self.state = State.notCharging
                }
            }
        }
    }

    public func connect() {
        /*
         Connect to the cloud node via WebSocket by using the repo ID to form the URL.
         */
        let webSocketURL = makeWebSocketURL(repoID: self.repoID)
        self.connect(webSocketURL: webSocketURL)
    }
    
    public func connect(webSocketURL: URL) {
        /*
         Connect to the cloud node via WebSocket with the given URL.
         */
        var request = URLRequest(url: webSocketURL)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket.delegate = self
        self.socket.connect()
    }

    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        /*
         Higher level function for dealing with new event. If our handler deems that there is a message to be sent, then send it.
         */
        if let message = try! handleNewEvent(event: event) {
            print("Sending new message...")
            socket.write(string: message)
        }
    }

    public func handleNewEvent(event: WebSocketEvent) throws -> String? {
        /*
         Inspect the provided event, and take the necessary actions. If there is a message to be sent to the cloud node, return it.
         */
        switch event {
        case .connected(_):
            print("WebSocket is connected, sending registration message.")
            return try handleNewConnection()
        case .disconnected(let reason, let code):
            print("WebSocket is disconnected: \(reason) with code: \(code)")
            try handleDisconnection()
        case .text(let string):
            print("Received new message!")
            try handleNewMessage(jsonString: string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            self.socket.write(ping: Data())
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
            print("WebSocket is disconnected!")
            let errorMessage = error!
            print(errorMessage.localizedDescription)
            self.isConnected = false
        }
        return nil
    }

    private func handleNewConnection() throws -> String {
        /*
         Handler for new connections. Send a register message to the cloud node so that it registers this library.
         */
        self.isConnected = true
        self.reconnections = 3
        let registrationMessage = try makeDictionaryString(keys: ["type", "node_type"], values: [registerName, libraryName])
        state = State.idle
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            self.socket.write(ping: Data())
        }
        
        return registrationMessage
    }

    private func handleDisconnection() throws {
        /*
         Handler for disconnections. As long as we have not had 3 straight disconnections, attempt to reconnect to the cloud node.
         */
        self.reconnections -= 1
        if self.reconnections > 0 {
            print("Reconnecting...")
            connect()
        } else {
            throw DMLError.communicationManagerError(ErrorMessage.failedConnection)
        }
    }

    private func handleNewMessage(jsonString: String) throws {
        /*
         Handler for new messages. Depending on the `action`, either begin training or set the state to `idle`.
         */
        let message: NSDictionary = try parseJSON(stringOrFile: jsonString, isString: true) as! NSDictionary
        switch message["action"] as! String {
        case trainName:
            print("Received TRAIN message.")
            let sessionID = message["session_id"] as! String
            let round = message["round"] as! Int
            let job = DMLJob(repoID: self.repoID, sessionID: sessionID, round: round)
            self.currentJob = job
            break
        case stopName:
            print("Received STOP message.")
            state = State.trainingComplete
            break
        default:
            print("Received unknown message.")
        }
    }

    public func handleTrainingComplete(job: DMLJob) throws -> String {
        /*
         Handler for Core ML when training has finished. Make the update message and send it.
         */
        let resultsMessage = try makeDictionaryString(keys: ["gradients", "omega"], values: [job.gradients!, job.omega!])
        let updateMessage = try makeDictionaryString(keys: ["type", "round", "session_id", "results"], values: ["NEW_UPDATE", job.round, job.sessionID, resultsMessage])
                
        if self.socket != nil {
            self.socket.write(string: updateMessage)
        }
        self.currentJob = nil
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
