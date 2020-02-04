//
//  Errors.swift
//  Discreet-DML
//
//  Created by Neelesh on 2/3/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation

public enum ErrorMessage: String {
    case error = "An unknown error occurred."
    case failedJsonify = "Failed to jsonify update message for cloud node!"
    case failedParse = "Failed to parse JSON message from cloud node!"
    case failedConnection = "Failed to connect to cloud node!"
    case failedRealmSetup = "Failed to setup Realm database!"
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
}

public enum DMLError: Error, Equatable {
    case mpsError(ErrorMessage)
    case modelLoaderError(ErrorMessage)
    case weightsProcessorError(ErrorMessage)
    case dataError(ErrorMessage)
    case coreMLError(ErrorMessage)
    case realmError(ErrorMessage)
    case communicationManagerError(ErrorMessage)
}
