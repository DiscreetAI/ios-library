///
///  ModelLoader.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/28/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import CoreML


/**
 Utility class for preparing model to be trained with.
 */
class ModelLoader {
    
    /// The URL of the model to be downloaded.
    var downloadModelURL: URL?
    
    /**
     Initializes the Model Loader by forming the download URL from the repo ID.
     
     - Parameters:
        - repoID: The repo ID corresponding to the registered application.
     */
    init(repoID: String) {
        self.downloadModelURL = makeModelDownloadURL(repoID: repoID)
    }
    
    /**
     Initializes the Model Loader by taking in the download URL directly. Used for testing.
    
     - Parameters:
        - downloadModelURL: The URL of the model to be downloaded.
    */
    init(downloadModelURL: URL?) {
        /*
         downloadModelURL: The URL of the model to be directly downloaded from.
         */
        self.downloadModelURL = downloadModelURL
    }

    /**
     Download a .mlmodel file, compile it, and store it permanently.
     
     - Throws: `DMLError` if an error occurred during model loading.
     
     - Returns: URL of the compiled model on device.
     */
    func loadModel() throws -> URL {
        let localModelURL = try downloadModel()
        let compiledModelURL = try compileModel(localModelURL: localModelURL)
        return compiledModelURL
    }

    /**
     Download the model at the URL `downloadModelURL`.
     
     - Throws: `DMLError` if an error occurred during the model download.
     
     - Returns: URL of the `.mlmodel` file on device.
     */
    func downloadModel() throws -> URL {
        let destinationUrl = documentsDirectory.appendingPathComponent(self.downloadModelURL!.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists at [\(destinationUrl.path)], deleting...")
            do {
                try FileManager().removeItem(atPath: destinationUrl.path)
            } catch {
                print(error.localizedDescription)
                throw DMLError.modelLoaderError(ErrorMessage.error)
            }
        }
        
        if let dataFromURL = NSData(contentsOf: self.downloadModelURL!) {
            if dataFromURL.write(to: destinationUrl, atomically: true) {
                print("file saved [\(destinationUrl.path)]")
            } else {
                throw DMLError.modelLoaderError(ErrorMessage.failedModelSave)
            }
        } else {
            throw DMLError.modelLoaderError(ErrorMessage.failedDownload)
        }
        
        return destinationUrl
    }

    /**
     Compile the given local URL to the `.mlmodel` into `.mlmodelc` binary files.
     
     - Parameters:
        - localModelURL: Path to the `.mlmodel` file on device.
     
     - Throws: `DMLError` if an error occurred during model compilation.
    
     - Returns: URL of the compiled model on device.
     */
    func compileModel(localModelURL: URL) throws -> URL {
        /*
         
         */
        if let compiledUrl = try? MLModel.compileModel(at: localModelURL) {
            let permanentUrl = documentsDirectory.appendingPathComponent(compiledUrl.lastPathComponent)

            do {
                if fileManager.fileExists(atPath: permanentUrl.path) {
                    _ = try fileManager.replaceItemAt(permanentUrl, withItemAt: compiledUrl)
                } else {
                    try fileManager.copyItem(at: compiledUrl, to: permanentUrl)
                }
            } catch {
                print(error.localizedDescription)
                throw DMLError.modelLoaderError(ErrorMessage.failedCompiledModelSave)
            }
            return permanentUrl
        } else {
            throw DMLError.modelLoaderError(ErrorMessage.failedCompile)
        }
    }
}
