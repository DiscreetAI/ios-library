//
//  CoreMLClient.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/23/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation
import CoreML

class CoreMLClient {
    /*
     Handler for dealing with the Core ML API.
     
     TODO: Finish implementing this client.
     */
    var modelLoader: ModelLoader!
    var realmClient: RealmClient!
    
    init() {}
    
    init(modelLoader: ModelLoader, realmClient: RealmClient) {
        self.modelLoader = modelLoader
        self.realmClient = realmClient
    }

    func train(job: DMLJob, callback: (DMLJob) -> (String)) {
        let model = self.modelLoader.loadModel()
        
    }
}
