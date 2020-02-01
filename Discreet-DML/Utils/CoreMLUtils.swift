//
//  CoreMLUtils.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/31/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML

public func renameModel(modelURL: URL) -> URL {
    /*
     Rename the model at `modelURL` to `old_model.modelc`.
     */
    let newName = "old_model.mlmodelc"
    let newURL = modelURL.deletingLastPathComponent().appendingPathComponent(newName)
    let fileManager = FileManager.default
    try! fileManager.createDirectory(at: newURL,
    withIntermediateDirectories: true,
    attributes: nil)
    print(newURL.path)
    print(modelURL.path)
    if FileManager().fileExists(atPath: newURL.path) {
        print("File already exists [\(newURL.path)], deleting...")
        try! FileManager().removeItem(atPath: newURL.path)
    }
    try! FileManager.default.moveItem(atPath: modelURL.path, toPath: newURL.path)
    return newURL
}

public func saveUpdatedModel(_ model: MLModel & MLWritable, to url: URL) {
    /*
     Save `model` at the given URL.
     */
    do {
        if FileManager().fileExists(atPath: url.path) {
            print("File already exists [\(url.path)], deleting...")
            try! FileManager().removeItem(atPath: url.path)
        }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        try model.write(to: url)
    } catch {
        print("Error saving neural network model to \(url):", error)
    }
}
