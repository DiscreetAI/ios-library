//
//  Orchestrator.swift
//  Discreet-DML
//
//  Created by Neelesh on 2/2/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation
import SystemConfiguration
import UIKit

public class Orchestrator {
    /*
     Higher level class to set up the other components in the library.
     */
    var repoID: String
    var realmClient: RealmClient
    var coreMLClient: CoreMLClient
    var communicationManager: CommunicationManager

    public init(repoID: String) throws {
        /*
         repoID: repo ID corresponding to cloud node.
         */
        self.repoID = repoID
        self.realmClient = try RealmClient()
        let mpsHandler = try? MPSHandler()
        self.coreMLClient = CoreMLClient(modelLoader: ModelLoader(repoID: repoID), realmClient: self.realmClient, weightsProcessor: WeightsProcessor(mpsHandler: mpsHandler))
        self.communicationManager = CommunicationManager(coreMLClient: self.coreMLClient, repoID: repoID)
        self.coreMLClient.configure(communicationManager: self.communicationManager)
    }
    
    public convenience init(repoID: String, encodings: [[Int]], labels: [String]) throws {
        /*
         repoID: repo ID corresponding to cloud node.
         */
        try self.init(repoID: repoID)
        try self.addEncodings(encodings: encodings, labels: labels)
        try self.connect()
    }
    
    public convenience init(repoID: String, images: [String], labels: [String]) throws {
        /*
         repoID: repo ID corresponding to cloud node.
         */
        try self.init(repoID: repoID)
        try self.addImages(images: images, labels: labels)
        try self.connect()
    }

    public func addEncodings(encodings: [[Int]], labels: [String]) throws {
        /*
         Store 2D Int data.
         */
        try validateEncodings(encodings: encodings, labels: labels)
        try realmClient.addTextData(repoID: self.repoID, encodings: encodings, labels: labels)
    }

    public func addImages(images: [String], labels: [String]) throws {
        /*
         Store 1D array of image paths on device.
         */
        try self.validateImages(images: images, labels: labels)
        try realmClient.addImageData(repoID: self.repoID, images: images, labels: labels)
    }
    
    public func setImages(images: [String], labels: [String]) throws {
        try self.validateImages(images: images, labels: labels)
        try self.clearData()
        try self.addImages(images: images, labels: labels)
    }
    
    public func removeImage(image: String) throws {
        /*
         Remove image corresponding to the given path.
         */
        try validateImageRemove()
        try self.realmClient.removeImageDatapoint(repoID: self.repoID, image: image)
    }
    
    public func removeImage(index: Int) throws {
        /*
         Remove image at the given index.
         */
        try validateImageRemove()
        try self.realmClient.removeImageDatapoint(repoID: self.repoID, index: index)
    }
    
    public func getImages() throws -> ([String], [String]) {
        /*
         Retrieve the images and labels corresponding to the repo ID.
         */
        if let imageEntry = self.realmClient.getImageEntry(repoID: self.repoID) {
            return imageEntry.getData()
        } else {
            throw DMLError.userError(ErrorMessage.failedRealmRead)
        }
    }
    
    public func connect() throws {
        /*
        Connect to the cloud node via WebSocket by using the repo ID to form the URL.
        */
        try self.validateInternetConnection()
        try self.validateRepoID()
        if try self.realmClient.getDatapointCount(repoID: repoID) > 0 {
            self.communicationManager.connect()
        } else {
            throw DMLError.userError(ErrorMessage.noDatapoints)
        }
        
    }
    
    func connect(webSocketURL: URL) throws {
        /*
         Connect to cloud node with the provided WebSocket URL.
         */
        if try self.realmClient.getDatapointCount(repoID: repoID) > 0 {
            self.communicationManager.connect(webSocketURL: webSocketURL)
        } else {
            throw DMLError.userError(ErrorMessage.noDatapoints)
        }
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
    
    func clearAllData() throws {
        /*
         Clear the data in Realm.
         */
        try self.realmClient.clear()
    }
    
    public func clearData() throws {
        /*
         Clear the data for the provided repoID,
         */
        try self.realmClient.clear(repoID: self.repoID)
    }
    
    private func validateInternetConnection() throws {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            throw DMLError.userError(ErrorMessage.noInternet)
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            throw DMLError.userError(ErrorMessage.noInternet)
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        if !(isReachable && !needsConnection) {
            throw DMLError.userError(ErrorMessage.noInternet)
        }
    }
    
    private func validateRepoID() throws {
        let url = makeCloudNodeURL(repoID: self.repoID)
        if !UIApplication.shared.canOpenURL(url) {
            throw DMLError.userError(ErrorMessage.invalidRepoID)
        }
    }
    
    private func validateImageRemove() throws {
        let datapointCount = try self.realmClient.getDatapointCount(repoID: self.repoID)
        if datapointCount == 1 && self.isConnected() {
            throw DMLError.userError(ErrorMessage.invalidImageRemove)
        }
    }
    
    private func validateData(data: [Any], labels: [String]) throws {
        if data.count != labels.count || data.count == 0 {
            throw DMLError.userError(ErrorMessage.invalidStore)
        }
    }
    
    private func validateImages(images: [String], labels: [String]) throws {
        try self.validateData(data: images, labels: labels)
                
        for imagePath in images {
            if !FileManager.default.fileExists(atPath: imagePath) {
                print("Failed to find image path:", imagePath)
                throw DMLError.userError(ErrorMessage.invalidImagePath)
            }
        }
    }
    
    private func validateEncodings(encodings: [[Int]], labels: [String]) throws {
        try validateData(data: encodings, labels: labels)
    }
}
