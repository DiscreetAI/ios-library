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
    
    init(repoID: String) {
        self.repoID = repoID
        self.realmClient = RealmClient()
        self.coreMLClient = CoreMLClient(modelLoader: ModelLoader(repoID: repoID), realmClient: self.realmClient, weightsProcessor: WeightsProcessor(mpsHandler: MPSHandler()))
        self.communicationManager = CommunicationManager(coreMLClient: self.coreMLClient, repoID: repoID)
        self.coreMLClient.configure(communicationManager: self.communicationManager)
        self.communicationManager.connect()
        print("Connected to cloud node!")
    }
    
    public func storeData(data: [[Double]], labels: [String]) {
        realmClient.storeData(repoID: self.repoID, data: data, labels: labels)
    }
    
    public func storeImages(images: [String], labels: [String]) {
        realmClient.storeData(repoID: self.repoID, data: images, labels: labels)
    }
}
