///
///  Errors.swift
///  Discreet-DML
///
///  Created by Neelesh on 2/3/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation


/**
 Enum for various error messages encountered in the library.
 */
enum ErrorMessage: String {
    
    /// General error with an unknown cause.
    case error = "An unknown error occurred."
    
    /// An arbitrary object could not be jsonified.
    case failedJsonify = "Failed to jsonify update message for cloud node!"
    
    /// A string could not be parsed as a JSON object.
    case failedParse = "Failed to parse JSON message from cloud node!"
    
    /// The library failed to connect to the cloud node after consecutive failed attemps at connection.
    case failedConnection = "Failed to connect to cloud node!"
    
    /// The library could not set up an instance of Realm.
    case failedRealmSetup = "Failed to setup Realm database!"
    
    /// A data entry with the provided repo ID could not be found in Realm.
    case failedRealmRead = "Failed to find entry with provided dataset ID!"
    
    /// Realm failed to add or update the entry from its DB.
    case failedRealmWrite = "Failed to add entry to Realm database!"
    
    /// Realm failed to clear objects from its DB.
    case failedRealmClear = "Failed to clear Realm database!"
    
    /// The Model Loader failed to download the model.
    case failedDownload = "Model could not be downloaded!"
    
    /// The Model Loader failed to save the downloaded model.
    case failedModelSave = "Downloaded model could not be saved!"
    
    /// The Model Loader failed to compile the model.
    case failedCompile = "Model could not be compiled!"
    
    /// The Model Loader failed to save the compiled model in permanent storage.
    case failedCompiledModelSave = "Failed to move the compiled model to permanent storage!"
    
    /// The ImageFeatureProvider failed to load an image from an image path.
    case failedImagePath = "The provided image path is invalid! Check to make sure the image exists, or remove the path from the data entry!"
    
    /// An encoded  text datapoint or label could not be turned into an MLMultiArray.
    case failedTextData = "The provided input data is invalid!"
    
    /// The Core ML Client failed to load a (image) MLModel into memory.
    case failedMLModel = "Failed to load the compiled memory into memory! Check to make sure the model is valid!"
    
    /// The Core ML Client failed to rename the old model after training.
    case failedRename = "Failed to rename old model after training!"
    
    /// The Core ML Client failed to save the new model after training.
    case failedModelUpdate = "Failed to save new model after training!"
    
    /// The Weights Processor failed to parse some part of the weights file.
    case failedUnpack = "Error while reading weights data!"
    
    /// The Weights Processor failed to creater a file handler with a weights file path.
    case failedFileHandle = "Failed to create handler for weights files!"
    
    /// An attempt at creating an MPS Handler was made while the device is currently a simulator.
    case badDevice = "This device does not support MPS!"
        
    /// User error for provided an invalid image path.
    case invalidImagePath = "Provided image path is invalid! Image could not be found!"
    
    /// User error for calling the wrong method with a particular dataset type.
    case invalidDataType = "Invalid data type! Image methods can only be called for an image dataset, and text methods can only be called for a text dataset!"
    
    /// User error for trying to remove an image path and label with an invalid index.
    case invalidDatapointIndex = "Invalid index for entry!"
    
    /// User error for generally trying to store invalid data
    case invalidStore = "Number of datapoints and labels are 0 or do not match!"
    
    /// User error for trying to connect to the cloud ndoe with an invalid repo ID.
    case invalidRepoID = "Invalid repo ID! Cloud node with this repo ID does not exist!"
    
    /// User error for trying to connect to the cloud node while the device does not have internet.
    case noInternet = "Device is not connected to Internet!"
}

/**
 Enum for various types of error messages in the library.
 */
enum DMLError: Error, Equatable {
    
    /// Type of error associated with the MPS Handler.
    case mpsError(ErrorMessage)
    
    /// Type of error associated with the Model Loader.
    case modelLoaderError(ErrorMessage)
    
    /// Type of error associated with the Weights Processor.
    case weightsProcessorError(ErrorMessage)
    
    /// Type of error associated with a Feature/Batch Provider.
    case dataError(ErrorMessage)
    
    /// Type of error associated with the Core ML Client.
    case coreMLError(ErrorMessage)
    
    /// Type of error associated with the Realm Client.
    case realmError(ErrorMessage)
    
    /// Type of error associated with the Communication Manager.
    case communicationManagerError(ErrorMessage)
    
    /// Type of error associated with faulty user input or function calls.
    case userError(ErrorMessage)
}
