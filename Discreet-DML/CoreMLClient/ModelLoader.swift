//
//  ModelLoader.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/28/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation
import CoreML

public class ModelLoader {
    /*
     Utility class for preparing model to be trained with.
     */
    var downloadModelURL: URL?
    
    init(repoID: String) {
        /*
         repoID: The repo ID of the corresponding cloud node.
         */
        self.downloadModelURL = makeModelDownloadURL(repoID: repoID)
    }
    
    init(downloadModelURL: URL?) {
        /*
         downloadModelURL: The URL of the model to be directly downloaded from.
         */
        self.downloadModelURL = downloadModelURL
    }

    public func loadModel() throws -> URL {
        /*
         Util method to download a .mlmodel file, compile it, and store it permanently.
         */
        let localModelURL = try downloadModel()
        let compiledModelURL = try compileModel(localModelURL: localModelURL)
        return compiledModelURL
    }

    func downloadModel() throws -> URL {
        /*
         Download the model at the URL `downloadModelURL`.
         */
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(downloadModelURL!.path)
    

        let destinationUrl = documentsUrl.appendingPathComponent(self.downloadModelURL!.lastPathComponent)
        print(destinationUrl.path)

        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)], deleting...")
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

    func compileModel(localModelURL: URL) throws -> URL {
        /*
         Compile the given local URL to the `.mlmodel` into `.mlmodelc`.
         */
        if let compiledUrl = try? MLModel.compileModel(at: localModelURL) {
            let fileManager = FileManager.default
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            let permanentUrl = documentsUrl.appendingPathComponent(compiledUrl.lastPathComponent)

            do {
                // if the file exists, replace it. Otherwise, copy the file to the destination.
                if fileManager.fileExists(atPath: permanentUrl.path) {
                    print("File exists: \(permanentUrl.path)")
                    _ = try fileManager.replaceItemAt(permanentUrl, withItemAt: compiledUrl)
                } else {
                    print("File doesn't exist")
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
