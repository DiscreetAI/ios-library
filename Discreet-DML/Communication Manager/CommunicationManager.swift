///
///  CommunicationManager.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/22/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import Starscream


/**
 State of the library.
 */
enum State : String {
    
    /// The library is in the process of connecting to the cloud node via WebSocket.
    case notConnected = "Connecting to server..."
    
    /// The library is connected to the cloud node and waiting for a training request to begin its first training session.
    case idle = "Waiting for training requests..."
    
    /// The library has finished training and sending the update to the cloud node, and currently waits for the request for the next round of training.
    case waiting = "Waiting for the next round..."
    
    /// The library has received a training request, but has not started training since the device is not charged.
    case notCharging = "Received training request! Device must \nbe charged before continuing with training."
    
    /// The library has received a training request and is now training.
    case training = "Your device is now training..."
    
    /// The library has finished training for the current session and currently waits a training request to begin its next training session.
    case trainingComplete = "Training complete!"
}

/// TODO: Scale to multiple repo IDs per application.

/**
 Manage communication with cloud node. Includes handling new connections, disconnections, and training messages.
*/
class CommunicationManager: WebSocketDelegate {
    
    /// An instance of the Core ML Client to begin training when a request is received.
    var coreMLClient: CoreMLClient?
    
    /// The repo ID corresponding to the dataset of this library.
    var repoID: String!
    
    /// The socket used for communication with the cloud node.
    var socket: WebSocket?
    
    /// The number of continuous reconnections with the cloud node that are allowed.
    var reconnections: Int
    
    /// The current training job for this library (if applicable).
    var currentJob: DMLJob?
    
    /// The job timer used for running jobs only when the library is in a valid training state.
    var jobTimer: Timer?
    
    /// The ping timer used to detect when the library is disconnected from the cloud node.
    var pingTimer: Timer?

    /// Whether the library is currently connected to the cloud node or not.
    var isConnected = false
    
    /// The state of the library.
    var state = State.notConnected

    /**
     Initializes the Communication Manager, but does not immediately connect to the cloud node. Begin monitoring the device's battery (this will be necessary to decide when the library is in a valid training state).
     
     - Parameters:
        - coreMLClient: An instance of the Core ML Client to begin training when a request is received.
        - repoID: The repo ID corresponding to the dataset of this library.
        - reconnections: The number of continuous reconnections with the cloud node that are allowed. The default number is 3.
     */
    init(coreMLClient: CoreMLClient?, repoID: String, reconnections: Int = 3) {
        self.coreMLClient = coreMLClient
        self.repoID = repoID
        self.reconnections = reconnections
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    /**
     Connect to the cloud node via WebSocket by using the repo ID to form the URL.
    */
    func connect() {
        
        let webSocketURL = makeWebSocketURL(repoID: self.repoID)
        self.connect(webSocketURL: webSocketURL)
    }
    
    /**
     Connect to the cloud node via WebSocket with the given URL. Set up the socket to receive and send messages.
     
     - Parameters:
        - webSocketURL: Remote URL corresponding to the WebSocket on the cloud node.
    */
    func connect(webSocketURL: URL) {
        var request = URLRequest(url: webSocketURL)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
    }

    /**
     Higher level function for dealing with new event. If our handler deems that there is a message to be sent, then send it.
     
     - Parameters:
        - event: An WebSocket associated event, such as a new connection, disconnection, etc.
        - client: The client WebSocket on the cloud node that the event is associated with.
    */
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        
        if let message = try! handleNewEvent(event: event) {
            print("Sending new message...")
            socket?.write(string: message)
        }
    }

    /**
     Inspect the provided event, and take the necessary actions. If there is a message to be sent to the cloud node, return it.
     
    
     - Parameters:
        - event: An WebSocket associated event, such as a new connection, disconnection, etc.
     
     - Throws: `DMLError`, if something went wrong processing the event.
    
     - Returns: A string representing the message to be sent to the cloud node, if applicable.
    */
    func handleNewEvent(event: WebSocketEvent) throws -> String? {
        
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
            self.socket?.write(ping: Data())
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
            self.pingTimer?.invalidate()
            self.pingTimer = nil
        }
        return nil
    }

    /**
     Handler for new connections. Send a register message to the cloud node so that it registers this library.
     
     - Throws: `DMLError` if the registration message could not be formed.
     
     - Returns: A string representing the registration message to be sent to the cloud node.
    */
    private func handleNewConnection() throws -> String {
        
        self.isConnected = true
        self.reconnections = 3
        state = State.idle
        
        if self.socket != nil {
            self.setUpPingTimer()
        }
        
        return try makeDictionaryString(keys: ["type", "node_type"], values: [registerName, libraryName])
    }

    /**
     Handler for disconnections. As long as we have not had `reconnections` consecutive reconnections, attempt to reconnect to the cloud node.
     
     - Throws: `DMLError` if `reconnections` consecutive reconnections occurred and the library is still unable to connect to the cloud node.
    */
    private func handleDisconnection() throws {
        
        self.reconnections -= 1
        if self.reconnections > 0 {
            print("Reconnecting...")
            connect()
        } else {
            throw DMLError.communicationManagerError(ErrorMessage.failedConnection)
        }
    }

    /**
     Handler for new messages. Depending on the action, either begin training or set the state to `State.trainingComplete`.
     
     - Parameters:
        - jsonString: The string representing the message received from the cloud node.
     
     - Throws: `DMLError` if an error occurred during training.
    */
    private func handleNewMessage(jsonString: String) throws {
        
        let message: NSDictionary = try parseJSON(stringOrFile: jsonString, isString: true) as! NSDictionary
        switch message["action"] as! String {
        case trainName:
            print("Received TRAIN message.")
            let sessionID = message["session_id"] as! String
            let round = message["round"] as! Int
            let job = DMLJob(repoID: self.repoID, sessionID: sessionID, round: round)
            self.currentJob = job
            self.setUpJobTimer()
            break
        case stopName:
            print("Received STOP message.")
            state = State.trainingComplete
            break
        default:
            print("Received unknown message.")
        }
    }
    
    /**
     Start up the job  timer so that it checks for train jobs.
    */
    private func setUpJobTimer() {
        self.jobTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if self.state != State.training {
                if self.isValidTrainingState() {
                    self.state = State.training
                    try! self.coreMLClient!.train(job: self.currentJob!)
                } else {
                    self.state = State.notCharging
                }
            }
        }
    }
    
    /**
     Start up the ping timer so that it begins pinging the cloud node every 5 seconds.
     */
    private func setUpPingTimer() {
        self.pingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            self.socket?.write(ping: Data())
        }
    }
    
    /**
     Determine whether the device is in a valid training state. Currently, the device is in a valid training state if the device is a simulator or a physical phone that is charging.
     
     - Returns: Boolean representing whether the device is in a valid training state.
    */
    func isValidTrainingState() -> Bool {
        
        #if targetEnvironment(simulator)
        return true
        #else
        return UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
        #endif
    }

    /**
     Handler for the Core ML Client when training has finished. Make the update message and send it.
     
     - Parameters:
        - job: The DML Job associated with this training round. Holds the gradients and omega to be sent to the cloud node, along with other necessary training information.
     
     - Throws: `DMLError` if the update message could not be formed.
     
     - Returns: A string representing the update message. Primarily used for testing.
    */
    func handleTrainingComplete(job: DMLJob) throws -> String {
        let resultsMessage = try makeDictionaryString(keys: ["gradients", "omega"], values: [job.gradients!, job.omega!])
        let updateMessage = try makeDictionaryString(keys: ["type", "round", "session_id", "results"], values: ["NEW_UPDATE", job.round, job.sessionID, resultsMessage])
        
        self.jobTimer?.invalidate()
        self.jobTimer = nil
        
        if self.socket != nil {
            self.socket?.write(string: updateMessage)
        }
        
        self.currentJob = nil
        self.state = State.waiting
        return updateMessage
    }

    /**
     Reset the Communication Manager back to its default state. Primarily useful for debugging and tests.
    */
    func reset() {
        self.state = State.idle
        self.isConnected = false
        self.jobTimer?.invalidate()
        self.jobTimer = nil
        self.pingTimer?.invalidate()
        self.pingTimer = nil
    }
}
