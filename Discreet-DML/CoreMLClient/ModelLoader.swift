//
//  ModelLoader.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/28/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation
import CoreML

class ModelLoader {
    var modelURL: URL

    init(urlString: String) {
        self.modelURL = URL(string: urlString)!
    }

    public func loadModel() -> MLModel {
        /*
         Util method to download a .mlmodel file, compile it, and load it into memory.
         */
        let modelURL = compileModel(destinationURL: downloadModel())
        let model = try! MLModel(contentsOf: modelURL)

        return model
    }

    private func downloadModel() -> URL {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(self.modelURL.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)], deleting...")
            try! FileManager().removeItem(atPath: destinationUrl.path)
        }
        else if let dataFromURL = NSData(contentsOf: self.modelURL) {
            if dataFromURL.write(to: destinationUrl, atomically: true) {
                print("file saved [\(destinationUrl.path)]")
            } else {
                print("error saving file")
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
        }

        return destinationUrl
    }

    private func compileModel(destinationURL: URL) -> URL {
        let compiledUrl = try! MLModel.compileModel(at: destinationURL)

        let fileManager = FileManager.default
        let appSupportDirectory = try! fileManager.url(for: .applicationSupportDirectory,
                in: .userDomainMask, appropriateFor: compiledUrl, create: true)
        // create a permanent URL in the app support directory
        let permanentUrl = appSupportDirectory.appendingPathComponent(compiledUrl.lastPathComponent)
        do {
            // if the file exists, replace it. Otherwise, copy the file to the destination.
            if fileManager.fileExists(atPath: permanentUrl.absoluteString) {
                _ = try fileManager.replaceItemAt(permanentUrl, withItemAt: compiledUrl)
            } else {
                try fileManager.copyItem(at: compiledUrl, to: permanentUrl)
            }
        } catch {
            print("Error during copy: \(error.localizedDescription)")
        }

        return permanentUrl
    }
}
