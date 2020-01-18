//
//  WeightsProcessorTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/15/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import XCTest
import CoreML
@testable import Discreet_DML

class WeightsProcessorTests: XCTestCase {
    var weightsProcessor = WeightsProcessor()

    // Paths to models on device
    var oldSimpleURL: String? = nil
    var newSimpleURL: String? = nil
    var oldComplexURL: String? = nil
    var newComplexURL: String? = nil
    
    // URLs to download models from
    var oldSimpleModelURL: URL = URL(string:"https://ios-discreetai.s3-us-west-1.amazonaws.com/old_model.mlmodel")!
    var newSimpleModelURL:URL = URL(string:"https://ios-discreetai.s3-us-west-1.amazonaws.com/new_model.mlmodel")!
    var oldComplexModelURL: URL = URL(string:"https://ios-discreetai.s3-us-west-1.amazonaws.com/old.mlmodel")!
    var newComplexModelURL:URL = URL(string:"https://ios-discreetai.s3-us-west-1.amazonaws.com/new.mlmodel")!
    
    var expectedSimpleGradients = [[-13.81011, -133.04008, -150.22589, -13.192558]]
    var expectedComplexGradients = [[95.57994842529297, -98.76066589355469, 148.50088500976562, -126.80604553222656], [31.69979476928711, 89.48539733886719, -114.56241607666016, 167.16433715820312], [157.56167602539062, -85.74986267089844, 213.60821533203125, -7.016921043395996], [167.75433349609375, 154.42352294921875, 16.086214065551758, -79.71075439453125], [79.56541442871094, -84.7736587524414, 48.14379119873047, 28.75021743774414]]
    
    override func setUp() {
        /*
         Download the weights needed for the tests.
         */
        oldSimpleURL = getWeights(url: oldSimpleModelURL)
        newSimpleURL = getWeights(url: newSimpleModelURL)
        oldComplexURL = getWeights(url: oldComplexModelURL)
        newComplexURL = getWeights(url: newComplexModelURL)
    }
    
    func testSimpleGradients() {
        /*
         Test gradient calculation for a model with one layer
         */
        let calculatedGradients: [[Double]] = weightsProcessor.calculateGradients(oldModelPath: oldSimpleURL!, newModelPath: newSimpleURL!, learningRate: 0.01)
        let roundedCalculatedGradients: [Double] = roundArr(arr: calculatedGradients[0], places: 3)
        let roundedExpectedGradients: [Double] = roundArr(arr: expectedSimpleGradients[0], places: 3)
        XCTAssertEqual(roundedExpectedGradients, roundedCalculatedGradients)
    }

    func testComplexGradients() {
        /*
         Test gradient calculation for a model with multiple layers.
         */
        let calculatedGradients: [[Double]] = weightsProcessor.calculateGradients(oldModelPath: oldComplexURL!, newModelPath: newComplexURL!, learningRate: 0.01)
        for (calculatedGradient, expectedGradient) in zip(calculatedGradients, expectedComplexGradients) {
            let roundedCalculatedGradient: [Double] = roundArr(arr: calculatedGradient, places: 3)
            let roundedExpectedGradient: [Double] = roundArr(arr: expectedGradient, places: 3)
            XCTAssertEqual(roundedExpectedGradient, roundedCalculatedGradient)
        }
    }
}
