///
///  CoreMLUtils.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/31/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import CoreML

/**
 Rename the model at `modelURL` to `old_model.modelc`.
 
 - Parameters:
    - modelURL: The URL of the compiled model on device
 
 - Throws: `DMLError` if an error occurred during the renaming of the model.
 
 - Returns: The URL of the renamed model.
 */
func renameModel(modelURL: URL) throws -> URL {
    let newName = "old_model.mlmodelc"
    let newURL = modelURL.deletingLastPathComponent().appendingPathComponent(newName)
    do {
        try fileManager.createDirectory(at: newURL, withIntermediateDirectories: true, attributes: nil)
        if fileManager.fileExists(atPath: newURL.path) {
            print("File already exists [\(newURL.path)], deleting...")
            try fileManager.removeItem(atPath: newURL.path)
        }
        try fileManager.moveItem(atPath: modelURL.path, toPath: newURL.path)
    } catch {
        print(error.localizedDescription)
        throw DMLError.coreMLError(ErrorMessage.failedRename)
    }
    
    return newURL
}

/**
 Save the provided model at the given URL.
 
 - Parameters:
    - model: The model to be saved.
    - url: The URL to save the model at.
 
 - Throws: `DMLError` if an error occurred during saving the model.
 */
func saveUpdatedModel(_ model: MLModel & MLWritable, to url: URL) throws {
    do {
        if fileManager.fileExists(atPath: url.path) {
            print("File already exists [\(url.path)], deleting...")
            try fileManager.removeItem(atPath: url.path)
        }
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        try model.write(to: url)
    } catch {
        print(error.localizedDescription)
        throw DMLError.coreMLError(ErrorMessage.failedModelUpdate)
    }
}

/**
 Get the input and predicted feature name from the model.
 
 - Parameters:
    - model: The model to train with.
 
 - Returns: A length-2 tuple consisting of the input name and the predicted feature name.
 */
func getModelNames(model: MLModel) -> (String, String) {
    let trainingInputs =  Array(model.modelDescription.trainingInputDescriptionsByName.keys)
    let inputName = model.modelDescription.inputDescriptionsByName.keys.first!
    return inputName == trainingInputs[0] ? (trainingInputs[0], trainingInputs[1]) : (trainingInputs[1], trainingInputs[0])
}
