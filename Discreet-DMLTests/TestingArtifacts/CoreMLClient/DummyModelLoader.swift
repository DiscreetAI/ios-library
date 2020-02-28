//
//  DummyModelLoader.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/31/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import Discreet_DML

class DummyImageModelLoader: ModelLoader {
    /*
     Dummy model loader that simply compiles an already downloaded model and returns the URL.
     */
    convenience init() {
        self.init(downloadModelURL: nil)
    }
    
    override func loadModel() throws -> URL {
        let modelPath = testingUtilsPath + "CoreMLClient/" + "my_model.mlmodel"
        return try compileModel(localModelURL: URL(fileURLWithPath: modelPath))
    }
}

class DummyTextModelLoader: ModelLoader {
    /*
     Dummy model loader that simply compiles an already downloaded model and returns the URL.
     */
    convenience init() {
        self.init(downloadModelURL: nil)
    }
    
    override func loadModel() throws -> URL {
        let modelPath = testingUtilsPath + "CoreMLClient/" + "neural_ngram_updatable.mlmodel"
        return try compileModel(localModelURL: URL(fileURLWithPath: modelPath))
    }
}
