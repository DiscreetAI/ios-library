//
//  DummyModelLoader.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/31/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import DiscreetAI

class DummyImageModelLoader: ModelLoader {
    /*
     Dummy model loader that simply compiles an already downloaded model and returns the URL.
     */
    convenience init() {
        self.init(downloadModelBaseURL: testImageModelURL)
    }
    
    override func downloadModel(downloadModelFullURL: URL) throws -> URL {
        let modelFolderURL = documentsDirectory.appendingPathComponent(testSession)
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
        return testImageModelURL
    }
}

class DummyTextModelLoader: ModelLoader {
    /*
     Dummy model loader that simply compiles an already downloaded model and returns the URL.
     */
    convenience init() {
        self.init(downloadModelBaseURL: testTextModelURL)
    }

    override func downloadModel(downloadModelFullURL: URL) throws -> URL {
        let modelFolderURL = documentsDirectory.appendingPathComponent(testSession)
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
        return testTextModelURL
    }
}
