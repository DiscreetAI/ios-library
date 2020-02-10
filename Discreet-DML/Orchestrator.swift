//
//  Orchestrator.swift
//  Discreet-DML
//
//  Created by Neelesh on 2/2/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation

class Orchestrator {
    /*
     Higher level class to set up the other components in the library.
     */
    var repoID: String
    var realmClient: RealmClient
    var coreMLClient: CoreMLClient
    var communicationManager: CommunicationManager

    init(repoID: String, connect: Bool = true) throws {
        /*
         repoID: repo ID corresponding to cloud node.
         connect: Boolean indicating whether we should immediately try connecting to the cloud node.
         */
        self.repoID = repoID
        self.realmClient = try! RealmClient()
        let mpsHandler = try? MPSHandler()
        self.coreMLClient = CoreMLClient(modelLoader: ModelLoader(repoID: repoID), realmClient: self.realmClient, weightsProcessor: WeightsProcessor(mpsHandler: mpsHandler))
        self.communicationManager = CommunicationManager(coreMLClient: self.coreMLClient, repoID: repoID)
        self.coreMLClient.configure(communicationManager: self.communicationManager)
        if connect {
            self.communicationManager.connect()
            print("Connected to cloud node!")
        } else {
            print("Call orchestrator.connect() to manually connect!")
        }
    }

    public func storeData(data: [[Double]], labels: [String]) {
        /*
         Store 2D Double data.
         */
        try! realmClient.storeData(repoID: self.repoID, data: data, labels: labels)
    }

    public func storeImages(images: [String], labels: [String]) {
        /*
         Store 1D array of image paths on device.
         */
        try! realmClient.storeData(repoID: self.repoID, data: images, labels: labels)
    }
    
    public func connect() {
        /*
        Connect to the cloud node via WebSocket by using the repo ID to form the URL.
        */
        self.communicationManager.connect()
    }
    
    public func connect(webSocketURL: URL) {
        /*
         Connect to cloud node with the provided WebSocket URL.
         */
        self.communicationManager.connect(webSocketURL: webSocketURL)
    }
}
