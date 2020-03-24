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
    
    /// The repo ID corresponding to the registered application.
    var repoID: String
    
    /// An instance of the Realm Client to store data to be trained on.
    var realmClient: RealmClient
    
    /// An instance of the Communication Manager to connect with the cloud node and allow the library to receive training requests.
    var communicationManager: CommunicationManager
    
    /**
     Initializes the Orchestrator, which initializes the other components of the library and sets them up. Since no data has been provided yet, the Communication Manager does not immediately connect to the cloud node.
     
     - Parameters:
        - repoID: The repo ID corresponding to the registered application.
     
     - Throws: `DMLError` if an error occurred during the setup of the library.
     */
    public init(repoID: String, connectImmediately: Bool = true) throws {
        self.repoID = repoID
        self.realmClient = try RealmClient(repoID: self.repoID)
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
        
        if connectImmediately {
            try self.connect()
        }
    }
    
    /**
     Validate and store more encodings and labels for this repo ID.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
        - encodings: The encoded text data, which is an array of text datapoint, each of which consists of a 1D array of integer encodings.
        - labels: The labels for each of the text datapoints.
     
     - Throws: `DMLError` if an error occurred during validation of the data
     */
    public func addEncodings(datasetID: String, encodings: [[Int]], labels: [Int]) throws {
        try validateDatasetID(datasetID: datasetID, expectedType: DataType.TEXT)
        try validateEncodings(encodings: encodings, labels: labels)
        try realmClient.addTextData(datasetID: datasetID, encodings: encodings, labels: labels)
    }
    
    /**
     Validate and store more image paths and labels for this repo ID.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
        - images: The 1D array of image paths referring to images stored in the application's documents directory.
        - labels: The labels for each of the text datapoints.
     
     - Throws: `DMLError` if an error occurred during validation of the data.
     */
    public func addImages(datasetID: String, images: [String], labels: [String]) throws {
        try validateDatasetID(datasetID: datasetID, expectedType: DataType.IMAGE)
        try self.validateImages(images: images, labels: labels)
        try realmClient.addImageData(datasetID: datasetID, images: images, labels: labels)
    }
    
    
    /**
     Validate the provided image paths. Then replace any imagedata already stored for the given repo ID with the provided image paths and labels.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
        - images: The 1D array of image paths referring to images stored in the application's documents directory.
        - labels: The labels for each of the text datapoints.
     
     - Throws: `DMLError` if an error occurred during validation of the data.
     */
    public func setImages(datasetID: String, images: [String], labels: [String]) throws {
        try validateDatasetID(datasetID: datasetID, expectedType: DataType.IMAGE)
        try self.validateImages(images: images, labels: labels)
        try self.clearData(datasetID: datasetID)
        try self.addImages(datasetID: datasetID, images: images, labels: labels)
    }
    
    /**
     Check to make sure the provided image path can be removed. Then remove it (and its corresponding label) from the data stored for this entry.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
        - image: The image path to remove from the stored data.
     
     - Throws: `DMLError` if the image path does not exist .
     */
    public func removeImage(datasetID: String, image: String) throws {
        try validateDatasetID(datasetID: datasetID, expectedType: DataType.IMAGE)
        try self.realmClient.removeImageDatapoint(datasetID: datasetID, image: image)
    }
    
    /**
     Check to make sure the image path at the provided index can be removed. Then remove it (and its corresponding label) from the data stored for this entry.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
        - image: The image path to remove from the stored data.
     
     - Throws: `DMLError` if the provided index is invalid .
     */
    public func removeImage(datasetID: String, index: Int) throws {
        try validateDatasetID(datasetID: datasetID, expectedType: DataType.IMAGE)
        try self.realmClient.removeImageDatapoint(datasetID: datasetID, index: index)
    }
    
    /**
     Retrieve the image paths and labels that were previously stored.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
     
     - Throws: `DMLError` if no image paths are currently stored.
     
     - Returns: A tuple (`images`, `labels`) where `images` refers to the stored image paths and `labels` refers to the corresponding labels.
     */
    public func getImages(datasetID: String) throws -> ([String], [String]) {
        try validateDatasetID(datasetID: datasetID, expectedType: DataType.IMAGE)
        if let imageEntry = self.realmClient.getImageEntry(datasetID: datasetID) {
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
        self.communicationManager.connect()
    }
    
    /**
     Connect to cloud node with the provided WebSocket URL. Used for testing.
     
     - Throws: `DMLError` if there are no datapoints.
     */
    func connect(webSocketURL: URL) throws {
        self.communicationManager.connect(webSocketURL: webSocketURL)
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
    public func clearData(datasetID: String) throws {
        try self.realmClient.clear(datasetID: datasetID)
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
        if NSData(contentsOf: url) == nil {
            throw DMLError.userError(ErrorMessage.invalidRepoID)
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
     Validate the data type of data being modified to make sure it is the expected type. Used to ensure that an image dataset doesn't end up with text data, and vice-versa.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
        - expectedType: The expected data type of this dataset.
     
     - Throws: `DMLError` if the data type of the dataset does not match the expected dataset type.
     */
    private func validateDataType(datasetID: String, expectedType: DataType) throws {
        if let actualType = self.realmClient.getDataEntryType(datasetID: datasetID) {
            if actualType != expectedType {
                print("Expected data type is \(expectedType.rawValue), but the actual data type for this dataset ID is \(actualType.rawValue).")
                throw DMLError.userError(ErrorMessage.invalidDataType)
            }
        }
    }
    
    private func validateDefaultDataset(datasetID: String) throws {
        if self.realmClient.isDefaultDataset(datasetID: datasetID) {
            throw DMLError.userError(ErrorMessage.defaultDataset)
        }
    }
    
    private func validateDatasetID(datasetID: String, expectedType: DataType) throws {
        try validateDefaultDataset(datasetID: datasetID)
        try validateDataType(datasetID: datasetID, expectedType: expectedType)
    }
    /**
     Validate the image paths and labels as regular datapoints and then validate that the images corresponding to the image paths do in fact exist.
     
     - Throws: `DMLError` if the image paths and labels failed validation as regular datapoints or the image paths themselves are invalid.
     */
    private func validateImages(images: [String], labels: [String]) throws {
        try self.validateData(data: images, labels: labels)
        
        for imagePath in images {
            let fullPath = makeImageURL(image: imagePath).path
            if !fileManager.fileExists(atPath: fullPath) {
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
