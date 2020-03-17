//
//  ModelLoaderTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/29/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import XCTest
import CoreML
@testable import DiscreetAI

class ModelLoaderTests: XCTestCase {
    func testLoad() {
        /*
        Download the model from S3, and compile it. Load it to ensure that the previous actions succeeded.
        */
        do {
            let modelLoader = ModelLoader(downloadModelURL: testModelURL)
            let modelURL = try modelLoader.loadModel()
            let model = try? MLModel(contentsOf: modelURL)
            XCTAssertNotNil(model)
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
        
    }
    
    func testBadDownload() {
        let modelLoader = ModelLoader(downloadModelURL: URL(string: "http://badserver.com/model.mlmodel")!)
        XCTAssertThrowsError(try modelLoader.loadModel()) { error in
            XCTAssertEqual(error as! DMLError, DMLError.modelLoaderError(ErrorMessage.failedDownload))
        }
    }
}
