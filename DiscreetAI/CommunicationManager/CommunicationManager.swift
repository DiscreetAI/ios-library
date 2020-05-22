///
///  CommunicationManager.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/22/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import UIKit
import Starscream


/**
 State of the library.
 */
enum State : String {
    
    /// The library is in the process of connecting to the cloud node via WebSocket.
    case notConnected = "Connecting to server..."
    
    /// The API key corresponding to the repo ID is invalid (error with registration).
    case authError = "Authentication error occurred! Check to make sure \nthe API key is correct!"
    
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
    
    /// An error occurred and the library is disconneccted.
    case libraryDisconnected = "Library is disconnected!"
    
}

/// TODO: Scale to multiple repo IDs per application.

/**
 Manage communication with cloud node. Includes handling new connections, disconnections, and training messages.
 */
class CommunicationManager: WebSocketDelegate {
    
    /// An instance of the Core ML Client to begin training when a request is received.
    var coreMLClient: CoreMLClient?
    
    /// The repo ID corresponding to the dataset of this library.
    var repoID: String
    
    /// The repo ID corresponding to the dataset of this library.
    var cloudDomain: String
    
    /// The API key for authentication.
    var apiKey: String
    
    /// The socket used for communication with the cloud node.
    var socket: WebSocket?
    
    /// The number of continuous reconnections with the cloud node that are allowed.
    var reconnections: Int
    
    /// The current training job for this library (if applicable).
    public var currentJobs = [DMLJob]()
        
    var registered: Bool?
    
    /// The job timer used for running jobs only when the library is in a valid training state.
    var jobTimer: Timer?
    
    /// Whether the library is currently connected to the cloud node or not.
    var isConnected = false
    
    /// The state of the library.
    var state = State.notConnected
    
    /**
     Initializes the Communication Manager, but does not immediately connect to the cloud node. Begin monitoring the device's battery (this will be necessary to decide when the library is in a valid training state).
     
     - Parameters:
         - coreMLClient: An instance of the Core ML Client to begin training when a request is received.
         - repoID: The repo ID corresponding to the dataset of this library.
         - apiKey: The API key for authentication.
     */
    init(coreMLClient: CoreMLClient?, repoID: String, apiKey: String, cloudDomain: String) {
        self.coreMLClient = coreMLClient
        self.repoID = repoID
        self.apiKey = apiKey
        self.cloudDomain = cloudDomain
        self.reconnections = 3
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    /**
     Connect to the cloud node via WebSocket by using the repo ID to form the URL.
     */
    func connect() -> Bool {
        let webSocketURL = makeWebSocketURL(cloudDomain: self.cloudDomain)
        return self.connect(webSocketURL: webSocketURL)
    }
    
    /**
     Connect to the cloud node via WebSocket with the given URL. Set up the socket to receive and send messages.
     
     - Parameters:
     - webSocketURL: Remote URL corresponding to the WebSocket on the cloud node.
     */
    func connect(webSocketURL: URL) -> Bool {
        var request = URLRequest(url: webSocketURL)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
        
        blockUntilRegistrationReponse(secondsToWait: 10)
        
        return (self.registered == nil) ? false : self.registered!
    }
    
    /**
     Disconnect from the cloud node.
     */
    func disconnect() {
        self.socket?.disconnect()
        self.socket = nil
        self.reset()
    }
    
    /**
     Block until a registration response has been received, or timeout.
     
     - Parameters:
        - secondsToWait: The number of seconds to wait until timeout.
     */
    func blockUntilRegistrationReponse(secondsToWait: Double) {
        let iterationTime: Double = 0.5
        let maxIterations = secondsToWait/iterationTime
        var numIterations = 0.0
        
            
        while self.registered == nil && numIterations < maxIterations {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: iterationTime))
            numIterations += 1
        }
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
            self.socket?.write(string: message)
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
        case .reconnectSuggested(_):
            break
        case .cancelled:
            self.isConnected = false
        case .error(let error):
            print("WebSocket is disconnected!")
            let errorMessage = error!
            print(errorMessage.localizedDescription)
            self.isConnected = false
        default:
            break
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
        return try makeRegistrationMessage()
    }
    
    /**
     Helper function to make registration message.
     
     - Throws: `DMLError` if the registration message could not be formed.
     
     - Returns: A string representing the registration message to be sent to the cloud node.
     */
    func makeRegistrationMessage() throws -> String {
        let keys = ["type", "node_type", "repo_id", "api_key"]
        let values = [MessageNames.RegistrationNames.registerName, MessageNames.RegistrationNames.libraryName, self.repoID, self.apiKey]
        return try makeDictionaryString(keys: keys, values: values)
    }
    
    /**
     Handler for disconnections. As long as we have not had `reconnections` consecutive reconnections, attempt to reconnect to the cloud node.
     
     - Throws: `DMLError` if `reconnections` consecutive reconnections occurred and the library is still unable to connect to the cloud node.
     */
    private func handleDisconnection() throws {
        self.state = State.libraryDisconnected
        self.reconnections -= 1
        if self.reconnections > 0 {
            print("Reconnecting...")
            _ = connect()
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
        
        if message["error"] as! Bool {
            if message["type"] as! String == "AUTHENTICATION" {
                self.state = State.authError
                self.registered = false
            } else {
                print(message["error_message"] as! String)
            }
            return
        }
        
        switch message["action"] as! String {
        case MessageNames.RegistrationNames.registrationSuccessName:
            print("Received \(MessageNames.RegistrationNames.registrationSuccessName) message.")
            self.state = State.idle
            self.registered = true
            break
        case MessageNames.TrainNames.trainName:
            let repoID = message["repo_id"] as! String
            print("Received \(MessageNames.TrainNames.trainName) message with repo ID: \(repoID).")
            let datasetID = message["dataset_id"] as! String
            let sessionID = message["session_id"] as! String
            let round = message["round"] as! Int
            let hyperparams = message["hyperparams"] as! NSDictionary
            let epochs = hyperparams["epochs"] as! Int
            let job = DMLJob(datasetID: datasetID, sessionID: sessionID, round: round)
            job.repoID = repoID
            job.epochs = epochs
            self.currentJobs.append(job)
            if (self.jobTimer == nil) {
                self.setUpJobTimer()
            }
            break
        case MessageNames.TrainNames.stopName:
            let repoID = message["repo_id"] as! String
            print("Received \(MessageNames.TrainNames.stopName) message with repo ID: \(repoID).")
            state = State.trainingComplete
            break
        default:
            print("Received unknown message.")
        }
    }
    
    /**
     Start up the job timer so that it checks for train jobs.
     */
    private func setUpJobTimer() {
        self.jobTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if !self.coreMLClient!.isTraining  {
                if self.isValidTrainingState() {
                    self.state = State.training
                    if self.currentJobs.count > 0 {
                        let job = self.currentJobs.remove(at: 0)
                        do {
                            if self.coreMLClient!.inProgressHandler {
                                try self.coreMLClient!.newJob(job: job)
                            } else {
                                try self.coreMLClient!.train(job: job)
                            }
                        } catch {
                            print(error.localizedDescription)
                            try! self.handleTrainingError(job: job)
                        }
                    }
                } else {
                    self.state = State.notCharging
                }
            }
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
        let updateMessage = try makeNewUpdateMessage(job: job)
        
        self.state = State.waiting
        
        if self.currentJobs.count == 0 {
            self.jobTimer?.invalidate()
            self.jobTimer = nil
        }
        
        if self.socket != nil {
            print("Sending \(MessageNames.TrainNames.newUpdateName) message with repo ID: \(job.repoID!).")
            self.socket?.write(string: updateMessage)
        }
        
        return updateMessage
    }
    
    /**
     Helper function to make new update message.
     
     - Parameters:
        - job: The DML Job associated with this training round. Holds the gradients and omega to be sent to the cloud node, along with other necessary training information.
     
     - Throws: `DMLError` if the update message could not be formed.
     
     - Returns: A string representing the update message.
     */
    func makeNewUpdateMessage(job: DMLJob) throws -> String {
        let resultsMessage = try makeDictionaryString(keys: ["gradients", "omega"], values: [job.gradients!, job.omega!])
        let keys = ["type", "round", "repo_id", "dataset_id", "session_id", "results"]
        let values: [Any] = [MessageNames.TrainNames.newUpdateName, job.round, job.repoID!, job.datasetID, job.sessionID, resultsMessage]
        return try makeDictionaryString(keys: keys, values: values)
    }
    
    /**
     Handler for the Core ML Client if no dataset/datapoints were found for the specified dataset. Make the no dataset message and send it.
     
     - Parameters:
        - job: The DML Job associated with this training round.
     
     - Throws: `DMLError` if the update message could not be formed.
     
     - Returns: A string representing the no dataset message. Primarily used for testing.
     */
    func handleNoDataset(job: DMLJob) throws -> String {
        let noDatasetMessage = try makeNoDatasetMessage(job: job)
        
        self.jobTimer?.invalidate()
        self.jobTimer = nil
        
        if self.socket != nil {
            print("Sending \(MessageNames.TrainNames.noDatasetName) message!")
            self.socket?.write(string: noDatasetMessage)
        }
        
        if let index = self.currentJobs.firstIndex(where: {$0.datasetID == job.datasetID}) {
            self.currentJobs.remove(at: index)
        }
        
        self.state = State.idle
        return noDatasetMessage
    }
    
    /**
     Helper function to make the no dataset message.
    
     - Parameters:
        - job: The DML Job associated with this training round.

     - Throws: `DMLError` if the no dataset message could not be formed.

     - Returns: A string representing the no dataset message.
    */
    func makeNoDatasetMessage(job: DMLJob) throws -> String {
        let keys = ["type", "round", "repo_id", "dataset_id", "session_id"]
        let values: [Any] = [MessageNames.TrainNames.noDatasetName, job.round, job.repoID!, job.datasetID, job.sessionID]
        return try makeDictionaryString(keys: keys, values: values)
    }
    
    
    /**
     Handler for the Core ML Client if an error occurred during training. Make the training error message and send it.
    
     - Parameters:
       - job: The DML Job associated with this training round.
    
     - Throws: `DMLError` if the training error message could not be formed.
    
     - Returns: A string representing the no dataset message. Primarily used for testing.
    */
    func handleTrainingError(job: DMLJob) throws -> String {
        let noDatasetMessage = try makeTrainingErrorMessage(job: job)
        
        self.jobTimer?.invalidate()
        self.jobTimer = nil
        
        if self.socket != nil {
            print("Sending \(MessageNames.TrainNames.trainingErrorName) message!")
            self.socket?.write(string: noDatasetMessage)
        }
        
        if let index = self.currentJobs.firstIndex(where: {$0.sessionID == job.sessionID}) {
            self.currentJobs.remove(at: index)
        }
        
        self.state = State.idle
        return noDatasetMessage
    }
    
    /**
     Helper functon to make the training error message.
    
     - Parameters:
       - job: The DML Job associated with this training round.
    
     - Throws: `DMLError` if the update message could not be formed.
    
     - Returns: A string representing the no dataset message.
    */
    func makeTrainingErrorMessage(job: DMLJob) throws -> String {
        let keys = ["type", "round", "repo_id", "dataset_id", "session_id"]
        let values: [Any] = [MessageNames.TrainNames.trainingErrorName, job.round, job.repoID!, job.datasetID, job.sessionID]
        return try makeDictionaryString(keys: keys, values: values)
    }
    
    /**
     Reset the Communication Manager back to its default state. Primarily useful for debugging and tests.
     */
    func reset() {
        self.state = State.idle
        self.isConnected = false
        self.jobTimer?.invalidate()
        self.jobTimer = nil
    }
}
