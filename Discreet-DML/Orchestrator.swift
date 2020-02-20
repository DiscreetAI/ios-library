//
//  Orchestrator.swift
//  Discreet-DML
//
//  Created by Neelesh on 2/2/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation

public class Orchestrator {
    /*
     Higher level class to set up the other components in the library.
     */
    var repoID: String
    var realmClient: RealmClient
    var coreMLClient: CoreMLClient
    var communicationManager: CommunicationManager

    public init(repoID: String, connect: Bool = true) throws {
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
    
    public func removeImage(image: String) {
        /*
         Remove image corresponding to the given path.
         */
        try! self.realmClient.removeImageDatapoint(repoID: self.repoID, image: image)
    }
    
    public func removeImage(index: Int) {
        /*
         Remove image at the given index.
         */
        try! self.realmClient.removeImageDatapoint(repoID: self.repoID, index: index)
    }
    
    public func getImages() -> ([String], [String]) {
        /*
         Retrieve the images and labels corresponding to the repo ID.
         */
        let imageEntry = self.realmClient.getImageEntry(repoID: self.repoID)!
        return imageEntry.getData()
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
    
    public func isConnected() -> Bool {
        /*
         Return whether the library is connected to the cloud node.
         */
        return self.communicationManager.isConnected
    }
    
    public func getState() -> String {
        /*
         Return the state of the library.
         */
        return self.communicationManager.state.rawValue
    }
    
    public func clearData() {
        /*
         Clear the data in Realm.
         */
        try! self.realmClient.clear()
    }
}
