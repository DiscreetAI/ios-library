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
    var downloadModelBaseURL: URL?
    
    
    /**
     Initializes the Model Loader by forming the download URL from the repo ID.
     
     - Parameters:
        - cloudDomain: The domain of the cloud node.
     */
    init(cloudDomain: String) {
        self.downloadModelBaseURL = makeDownloadModelBaseURL(cloudDomain: cloudDomain)
    }
    
    /**
     Initializes the Model Loader by taking in the download URL directly. Used for testing.
    
     - Parameters:
        - downloadModelURL: The URL of the model to be downloaded.
    */
    init(downloadModelBaseURL: URL?) {
        /*
         downloadModelURL: The URL of the model to be directly downloaded from.
         */
        self.downloadModelBaseURL = downloadModelBaseURL
    }

    /**
     Download a .mlmodel file, compile it, and store it permanently.
     
     - Throws: `DMLError` if an error occurred during model loading.
     
     - Returns: URL of the compiled model on device.
     */
    func loadModel(sessionID: String) throws -> URL {
        let downloadModelFullURL = self.downloadModelBaseURL!.appendingPathComponent(sessionID)
        return try loadModel(downloadModelFullURL: downloadModelFullURL)
    }
    
    func loadModel(downloadModelFullURL: URL) throws -> URL {
        let localModelURL = try downloadModel(downloadModelFullURL: downloadModelFullURL)
        let sessionID = downloadModelFullURL.lastPathComponent
        let compiledModelURL = try compileModel(localModelURL: localModelURL, sessionID: sessionID)
        return compiledModelURL
    }

    /**
     Download the model at the URL `downloadModelURL`.
     
     - Throws: `DMLError` if an error occurred during the model download.
     
     - Returns: URL of the `.mlmodel` file on device.
     */
    func downloadModel(downloadModelFullURL: URL) throws -> URL {
        let modelFolderURL = documentsDirectory.appendingPathComponent("temp")
        
        if fileManager.fileExists(atPath: modelFolderURL.path) {
            print("Folder already exists [\(modelFolderURL.path)], deleting...")
            do {
                try FileManager().removeItem(atPath: modelFolderURL.path)
            } catch {
                print(error.localizedDescription)
                throw DMLError.modelLoaderError(ErrorMessage.error)
            }
        }
        
        try fileManager.createDirectory(at: modelFolderURL, withIntermediateDirectories: true, attributes: nil)
        let destinationUrl = modelFolderURL.appendingPathComponent("my_model.mlmodel")
        
        
        if let dataFromURL = NSData(contentsOf: downloadModelFullURL) {
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
    func compileModel(localModelURL: URL, sessionID: String) throws -> URL {
        print("Compiling now...")
        if let compiledUrl = try? MLModel.compileModel(at: localModelURL) {
            print("Compilation successful")
            let permanentUrl = documentsDirectory.appendingPathComponent("temp").appendingPathComponent(compiledUrl.lastPathComponent)
            
            do {
                try fileManager.copyItem(at: compiledUrl, to: permanentUrl)
                #if targetEnvironment(simulator)
                #else
                try fileManager.removeItem(atPath: localModelURL.path)
                #endif
                try fileManager.removeItem(at: compiledUrl)
            } catch {
                print(error.localizedDescription)
                throw DMLError.modelLoaderError(ErrorMessage.failedCompiledModelSave)
            }
            print("Model successfully compiled and saved.")
            return permanentUrl
        } else {
            throw DMLError.modelLoaderError(ErrorMessage.failedCompile)
        }
    }
    
    func deleteModelFolder(sessionID: String) throws {
        let modelFolderURL = documentsDirectory.appendingPathComponent("temp")
        
        if fileManager.fileExists(atPath: modelFolderURL.path) {
            print("Deleting model folder...")
            do {
                try FileManager().removeItem(atPath: modelFolderURL.path)
            } catch {
                print(error.localizedDescription)
                throw DMLError.modelLoaderError(ErrorMessage.error)
            }
        }
    }
}
