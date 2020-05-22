///
///  Utils.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/18/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import CoreML


/// Names of messages received and sent by library.
struct MessageNames {
    
    /// Names of messages associated with registration.
    struct RegistrationNames {
        
        /// Name for a register messsage.
        static var registerName = "REGISTER"

        /// Name for a message from the library.
        static var libraryName = "LIBRARY"
        
        /// Name of successful registration message.
        static var registrationSuccessName = "REGISTRATION_SUCCESS"
    }
    
    /// Names of messages associated with training.
    struct TrainNames {
        
        /// Name of a train message.
        static var trainName = "TRAIN"

        /// Name of an update message.
        static var newUpdateName = "NEW_UPDATE"
        
        /// Name of a no dataset message.
        static var noDatasetName = "NO_DATASET"
        
        /// Name of a training error message.
        static var trainingErrorName = "TRAINING_ERROR"

        /// Name of a stop message.
        static var stopName = "STOP"
    }
}

/// Paths to dataset folders.
struct Artifacts {
    static var bundle = Bundle(identifier: "com.discreetai.library")!
    
    static var datasetsFolder = bundle.url(forResource: "Datasets", withExtension: nil)!

    static var imageDatasetsFolder = datasetsFolder.appendingPathComponent("ImageDatasets")

    static var textDatasetsFolder = datasetsFolder.appendingPathComponent("TextDatasets")
    
    static var demoCredsPath = bundle.url(forResource: "demo_details", withExtension: "json")!
}

/// Max number epochs total on device.
var unlimitedEpochs = 100000

/**
 Helper function to demo repo credentials.
 
 - Returns: Dictionary holding the credentials.
 */
func getDemoCreds() throws -> NSDictionary? {
    if fileManager.fileExists(atPath: Artifacts.demoCredsPath.path) {
         return try parseJSON(stringOrFile: Artifacts.demoCredsPath.path, isString: false) as! NSDictionary
    }
    
    return nil
}

/**
 Turn an arbitrary object (Dictionary, Int, etc.) into a String
 
 - Parameters:
    - object: The object to be jsonified.
 
 - Throws: `DMLError` if the object could not be jsonified.
 
 - Returns: The jsonified object (as a String)
 */
func jsonify(object: Any) throws -> String {
    var data: Data
    do {
        data = try JSONSerialization.data(withJSONObject: object, options: [])
    } catch {
        print(error.localizedDescription)
        throw DMLError.communicationManagerError(ErrorMessage.failedJsonify)
    }
    return String(data: data, encoding: String.Encoding.utf8)!
}

/**
 Turn a String into a JSON object.
 
 - Parameters:
    - stringOrFile: The string to be parsed as a JSON object, or the path to the file to be parsed as a JSON object.
    - isString: Boolean determining whether the previous argument refers to a string or a file.
 
 - Throws: `DMLError` if an error occurred during parsing.
 
 - Returns: The parsed JSON object.
 */
func parseJSON(stringOrFile: String, isString: Bool) throws -> Any {
    var data: Data
    do {
        data = isString ? Data(stringOrFile.utf8) : try Data(contentsOf: URL(fileURLWithPath: stringOrFile), options: .mappedIfSafe)
        return try JSONSerialization.jsonObject(with: data)
    } catch {
        print(error.localizedDescription)
        throw DMLError.communicationManagerError(ErrorMessage.failedParse)
    }
}

/**
 Make a dictionary with the given keys and values, and then jsonify the dictionary.
 
 - Parameters:
    - keys: The keys to the dictionary.
    - values: The values to the dictionary.
 
 - Throws: `DMLError` if the dictionary could not be jsonified.
 
 - Returns: The jsonified dictionary formed from the provided keys and values.
 */
func makeDictionaryString(keys: [String], values: [Any]) throws -> String {
    var dict: [String: Any] = [:]
    for (key, value) in zip(keys, values) {
        dict[key] = value
    }
    return try jsonify(object: dict)
}

/**
 Make the WebSocket URL for the Communication Manager.
 
 - Parameters:
    - cloudDomain: The domain of the cloud node.
 
 - Returns: The WebSocket URL.
 */
func makeWebSocketURL(cloudDomain: String) -> URL {
    return URL(string: "ws://\(cloudDomain).cloud.discreetai.com")!
}

/**
 Make the model download URL for the Model Loader.

 - Parameters:
    - cloudDomain: The domain of the cloud node.

 - Returns:The base cloud node URL.
*/
func makeCloudNodeURL(cloudDomain: String) -> URL {
    return URL(string: "http://\(cloudDomain).cloud.discreetai.com")!
}

/**
 Make the model download URL for the Model Loader.

 - Parameters:
    - cloudDomain: The domain of the cloud node.

 - Returns: The model download URL.
*/
func makeDownloadModelBaseURL(cloudDomain: String) -> URL {
    return makeCloudNodeURL(cloudDomain: cloudDomain).appendingPathComponent("/mlmodel/")
}

/**
 Get the domain for the cloud node.
 
 - Parameters:
    - repoID: The repo ID corresponding to the registered application.
    - apiKey: The API key for authentication

 - Returns: The domain of the cloud node.
 
 */
func getCloudDomain(repoID: String, apiKey: String) throws -> String {
    if let demoCreds = try getDemoCreds() {
        let demoRepoID = demoCreds["demo_repo_id"] as! String
        let demoApiKey = demoCreds["demo_api_key"] as! String
        return apiKey == demoApiKey && repoID == demoRepoID ? demoRepoID : repoID
    }
    
    return repoID
}

/**
 Make the weights path given the URL of the compiled model on devicfe.
 
 - Parameters:
    - modelURL: The URL of the compiled model on device.
 
 - Returns: The path to the weights of the model.
 */
func makeWeightsPath(modelURL: URL) -> String {
    return modelURL.path + "/model.espresso.weights"
}

/**
 Make the primary key to retrieve a data entry from Realm.
 
 - Parameters:
    - repoID: The repo ID corresponding to the registered application.
    - datasetID: The dataset ID corresponding to the desired dataset.
 
 - Returns: The primary key of the desired data entry.
 */
func makePrimaryKey(repoID: String, datasetID: String) -> String {
    return repoID + "/" + datasetID
}

/**
 Make the primary key corresponding to the metadata of a data entry from Realm.

 - Parameters:
    - repoID: The repo ID corresponding to the registered application.
    - datasetID: The dataset ID corresponding to the desired dataset.

 - Returns: The primary key of the desired data entry.
*/
func makeMetadataKey(repoID: String, datasetID: String) -> String {
    return "metadata/" + makePrimaryKey(repoID: repoID, datasetID: datasetID)
}

/**
 Make the primary key corresponding to the metadata of a data entry from Realm.

 - Parameters:
    - repoID: The repo ID corresponding to the registered application.
    - datasetID: The dataset ID corresponding to the desired dataset.

 - Returns: The primary key of the desired data entry.
*/
func makeMetadataKey(primaryKey: String) -> String {
    return "metadata/" + primaryKey
}

/// The File Manager for this library.
var fileManager = FileManager.default

/// The documents directory.
var documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

/**
 Make the image URL within the documents directory.
 
 - Parameters:
    - image: The path to the image stored in the application's documents directory.
 
 - Returns: The URL referring to the absolute path of the image.
 */
func makeImageURL(image: String) -> URL {
    return documentsDirectory.appendingPathComponent(image)
}

