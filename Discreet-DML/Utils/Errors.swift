//
//  Errors.swift
//  Discreet-DML
//
//  Created by Neelesh on 2/3/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation

enum ErrorMessage: String {
    case error = "An unknown error occurred."
    case failedJsonify = "Failed to jsonify update message for cloud node!"
    case failedParse = "Failed to parse JSON message from cloud node!"
    case failedConnection = "Failed to connect to cloud node!"
    case failedRealmSetup = "Failed to setup Realm database!"
    case failedRealmRead = "Failed to find entry with provided repo ID!"
    case failedRealmWrite = "Failed to add entry to Realm database!"
    case failedRealmClear = "Failed to clear Realm database!"
    case failedDownload = "Model could not be downloaded!"
    case failedModelSave = "Downloaded model could not be saved!"
    case failedCompile = "Model could not be compiled!"
    case failedCompiledModelSave = "Failed to move the compiled model to permanent storage!"
    case failedModelLoad = "An unknown error occurred during model loading."
    case failedImagePath = "The provided image path is invalid! Check to make sure the image exists, or remove the path from the data entry!"
    case failedDoubleData = "The provided input data is invalid!"
    case failedMLModel = "Failed to load the compiled memory into memory! Check to make sure the model is valid!"
    case failedRename = "Failed to rename old model after training!"
    case failedModelUpdate = "Failed to save new model after training!"
    case failedUnpack = "Error while reading weights data!"
    case failedFileHandle = "Failed to create handler for weights files!"
    case badDevice = "This device does not support MPS!"
    case noDatapoints = "No datapoints exist for this Realm entry! Call one of the store functions to store data first!"
    case invalidImagePath = "Provided image path does not exist!"
    case invalidImageRemove = "Number of datapoints must be greater than 0 while device is connected to cloud node!"
    case invalidDatapointIndex = "Invalid index for entry!"
    case invalidStore = "Number of datapoints and labels are 0 or do not match!"
    case invalidRepoID = "Invalid repo ID! Cloud node with this repo ID does not exist!"
    case noInternet = "Device is not connected to Internet!"
}

enum DMLError: Error, Equatable {
    case mpsError(ErrorMessage)
    case modelLoaderError(ErrorMessage)
    case weightsProcessorError(ErrorMessage)
    case dataError(ErrorMessage)
    case coreMLError(ErrorMessage)
    case realmError(ErrorMessage)
    case communicationManagerError(ErrorMessage)
    case userError(ErrorMessage)
}
