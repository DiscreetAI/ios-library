///
///  Orchestrator.swift
///  Discreet-DML
///
///  Created by Neelesh on 2/2/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import SystemConfiguration
import UIKit


/**
 Higher level class to set up the other components in the library. Directly called by users.
*/
public class Orchestrator {
    
    /// The repo ID corresponding to the dataset of this library.
    var repoID: String
    
    /// An instance of the Realm Client to store data to be trained on.
    var realmClient: RealmClient
    
    /// An instance of the Communication Manager to connect with the cloud node and allow the library to receive training requests.
    var communicationManager: CommunicationManager

    /**
     Initializes the Orchestrator, which initializes the other components of the library and sets them up. Since no data has been provided yet, the Communication Manager does not immediately connect to the cloud node.
     
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
     
     - Throws: `DMLError` if an error occurred during the setup of the library.
     */
    public init(repoID: String) throws {
        self.repoID = repoID
        self.realmClient = try RealmClient()
        var weightsProcessor: WeightsProcessor
        do {
            let mpsHandler = try MPSHandler()
            weightsProcessor = WeightsProcessor(mpsHandler: mpsHandler)
        } catch {
            weightsProcessor = WeightsProcessor()
        }
        let coreMLClient = CoreMLClient(modelLoader: ModelLoader(repoID: repoID), realmClient: self.realmClient, weightsProcessor: weightsProcessor)
        self.communicationManager = CommunicationManager(coreMLClient: coreMLClient, repoID: repoID)
        coreMLClient.configure(communicationManager: self.communicationManager)
    }
    
    /**
     Extension of constructor that initializes the Orchestrator and validates and then stores inital text data. Since data has been provided, the Communication Manager connects to the cloud node to prepare the library for training requests.
     
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
        - encodings: The encoded text data, which is an array of text datapoint, each of which consists of a 1D array of integer encodings.
        - labels: The labels for each of the text datapoints.
     
     - Throws: `DMLError` if an error occurred during the setup of the library or validation of the data.
     */
    public convenience init(repoID: String, encodings: [[Int]], labels: [Int]) throws {
        try self.init(repoID: repoID)
        try self.addEncodings(encodings: encodings, labels: labels)
        try self.connect()
    }
    
    /**
     Extension of constructor that initializes the Orchestrator and validates and then stores inital image data. Since data has been provided, the Communication Manager connects to the cloud node to prepare the library for training requests.
    
     - Parameters:
       - repoID: The repo ID corresponding to the dataset of this library.
       - images: The 1D array of image paths referring to images stored in the application.
       - labels: The labels for each of the images at the image paths.
    
     - Throws: `DMLError` if an error occurred during the setup of the library or validation of the data.
    */
    public convenience init(repoID: String, images: [String], labels: [String]) throws {
        try self.init(repoID: repoID)
        try self.addImages(images: images, labels: labels)
        try self.connect()
    }

    /**
     Validate and store more encodings for this repo ID.
     
     - Parameters:
        - encodings: The encoded text data, which is an array of text datapoint, each of which consists of a 1D array of integer encodings.
        - labels: The labels for each of the text datapoints.
     
     - Throws: `DMLError` if an error occurred during validation of the data
     */
    public func addEncodings(encodings: [[Int]], labels: [Int]) throws {
        try validateEncodings(encodings: encodings, labels: labels)
        try realmClient.addTextData(repoID: self.repoID, encodings: encodings, labels: labels)
    }

    /**
    Validate and store more image paths for this repo ID.
    
    - Parameters:
       - images: The 1D array of image paths referring to images stored in the application.
       - labels: The labels for each of the text datapoints.
    
    - Throws: `DMLError` if an error occurred during validation of the data.
    */
    public func addImages(images: [String], labels: [String]) throws {
        /*
         Store 1D array of image paths on device.
         */
        try self.validateImages(images: images, labels: labels)
        try realmClient.addImageData(repoID: self.repoID, images: images, labels: labels)
    }
    
    
    /**
    Validate the provided image paths. Then replace any imagedata already stored for the given repo ID with the provided image paths.
    
    - Parameters:
       - images: The 1D array of image paths referring to images stored in the application.
       - labels: The labels for each of the text datapoints.
    
    - Throws: `DMLError` if an error occurred during validation of the data.
    */
    public func setImages(images: [String], labels: [String]) throws {
        try self.validateImages(images: images, labels: labels)
        try self.clearData()
        try self.addImages(images: images, labels: labels)
    }
    
    /**
     Check to make sure the provided image path can be removed. Then remove it (and its corresponding label) from the data stored for this entry.
     
     - Parameters:
        - image: The image path to remove from the stored data.
     
     - Throws:
        - `DMLError` if the image path does not exist OR the library is connected to the cloud node and the image path is the last datapoint (the library cannot have 0 datapoints at any point the library is connected).
     */
    public func removeImage(image: String) throws {
        try validateImageRemove()
        try self.realmClient.removeImageDatapoint(repoID: self.repoID, image: image)
    }
    
    /**
     Check to make sure the image path at the provided index can be removed. Then remove it (and its corresponding label) from the data stored for this entry.
    
     - Parameters:
        - image: The image path to remove from the stored data.
    
     - Throws: `DMLError` if the provided index is invalid OR the library is connected to the cloud node and the image path is the last datapoint (the library cannot have 0 datapoints at any point the library is connected).
    */
    public func removeImage(index: Int) throws {
        /*
         Remove image at the given index.
         */
        try validateImageRemove()
        try self.realmClient.removeImageDatapoint(repoID: self.repoID, index: index)
    }
    
    /**
     Retrieve the image paths and labels that were previously stored.
     
     - Throws: `DMLError` if no image paths are currently stored.
     
     - Returns: A tuple (`images`, `labels`) where `images` refers to the stored image paths and `labels` refers to the corresponding labels.
     */
    public func getImages() throws -> ([String], [String]) {
        if let imageEntry = self.realmClient.getImageEntry(repoID: self.repoID) {
            return imageEntry.getData()
        } else {
            throw DMLError.userError(ErrorMessage.failedRealmRead)
        }
    }
    
    /**
     Connect to the cloud node via WebSocket by using the repo ID to form the URL.
     
     - Throws: `DMLError` if there is no internet connection or the repo ID is invalid or there are no datapoints.
    */
    public func connect() throws {
        try self.validateInternetConnection()
        try self.validateRepoID()
        if try self.realmClient.getDatapointCount(repoID: repoID) > 0 {
            self.communicationManager.connect()
        } else {
            throw DMLError.userError(ErrorMessage.noDatapoints)
        }
        
    }
    
    /**
     Connect to cloud node with the provided WebSocket URL. Used for testing.
     
     - Throws: `DMLError` if there are no datapoints.
    */
    func connect(webSocketURL: URL) throws {
        
        if try self.realmClient.getDatapointCount(repoID: repoID) > 0 {
            self.communicationManager.connect(webSocketURL: webSocketURL)
        } else {
            throw DMLError.userError(ErrorMessage.noDatapoints)
        }
    }
    
    /**
     Determine whether the library is connected to the cloud node.
     
     - Returns: A boolean representing whether the library is connected to the cloud node or not.
     */
    public func isConnected() -> Bool {
        return self.communicationManager.isConnected
    }
    
    /**
     Determine the state of the library.
     
     - Returns: A string representing the current state of the library.
     */
    public func getState() -> String {
        /*
         
         */
        return self.communicationManager.state.rawValue
    }
    
    /**
     Clear all of the data in Realm.
     
     - Throws: `DMLError` if an unexpected error with Realm occurred.
    */
    func clearAllData() throws {
        try self.realmClient.clear()
    }
    
    /**
     Clear all of the data corresponding to this specific repo ID in Realm.
     
     - Throws: `DMLError` if an unexpected error with Realm occurred.
    */
    public func clearData() throws {
        try self.realmClient.clear(repoID: self.repoID)
    }
    
    /**
     Get the default text encoder, which is formed from the provided vocabulary list.
     
     - Parameters:
        - vocabList: The vocab list of words that the encoder can expect to encode.
     
     - Returns: A basic encoder. Encodes `vocabList[0] -> 1`, `vocabList[1] -> 2`, etc. with unknown input encoded as `0`.
     */
    public func getBasicEncoder(vocabList: [String]) -> BasicEncoder {
        return BasicEncoder(vocabList: vocabList)
    }
    
    /**
     Validate whether the device has access to the internet.
     
     - Throws: `DMLError` if the device does not have access to the internet.
     */
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
    
    /**
     Validate whether the repo ID is valid by checkiing that the cloud node associated with this repo ID exists.
     
     - Throws: `DMLError` if the repo ID is invalid.
     */
    private func validateRepoID() throws {
        let url = makeCloudNodeURL(repoID: self.repoID)
        if !UIApplication.shared.canOpenURL(url) {
            throw DMLError.userError(ErrorMessage.invalidRepoID)
        }
    }
    
    /**
     Validate whether an image datapoint can be removed by checking that either the library is not connected or the number of current datapoints is greater than 1.
     
     - Throws: `DMLError` if an image datapoint cannot be removed.
     */
    private func validateImageRemove() throws {
        let datapointCount = try self.realmClient.getDatapointCount(repoID: self.repoID)
        if datapointCount == 1 && self.isConnected() {
            throw DMLError.userError(ErrorMessage.invalidImageRemove)
        }
    }
    
    /**
     Validate the data/labels by checking that the number of datapoints matches the number of labels and that both the number of datapoint and the number of labels is nonzero.
     
     - Throws: `DMLError` if the data/labels are invalid.
     */
    private func validateData(data: [Any], labels: [Any]) throws {
        if data.count != labels.count || data.count == 0 {
            throw DMLError.userError(ErrorMessage.invalidStore)
        }
    }
    
    /**
     Validate the image paths and labels as regular datapoints and then validate that the images corresponding to the image paths do in fact exist.
     
     - Throws: `DMLError` if the image paths and labels failed validation as regular datapoints or the image paths themselves are invalid.
     */
    private func validateImages(images: [String], labels: [String]) throws {
        try self.validateData(data: images, labels: labels)
                
        for imagePath in images {
            if !FileManager.default.fileExists(atPath: imagePath) {
                print("Failed to find image path:", imagePath)
                throw DMLError.userError(ErrorMessage.invalidImagePath)
            }
        }
    }
    
    /**
    Validate the encodings and labels as regular datapoints.
    
    - Throws: `DMLError` if the encodings and labels failed validation as regular datapoints.
     
     TODO: Validate that the integers are nonnegative and are less than the size of the vocab set.
    */
    private func validateEncodings(encodings: [[Int]], labels: [Int]) throws {
        try validateData(data: encodings, labels: labels)
    }
}
