//
//  ModelLoaderTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/29/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import XCTest
import CoreML
@testable import Discreet_DML

class ModelLoaderTests: XCTestCase {
    let modelLoader = ModelLoader(downloadModelURL: testModelURL)
    
    func testLoad() {
        /*
        Download the model from S3, and compile it. Load it to ensure that the previous actions succeeded.
        */
        let modelURL = modelLoader.loadModel()
        let model = try? MLModel(contentsOf: modelURL)
        XCTAssertNotNil(model)
    }
}
