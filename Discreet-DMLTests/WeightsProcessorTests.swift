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

    // Folder to testing artifacts
    let artifactsPath: String = testingUtilsPath + "WeightsProcessor/"
    
    var expectedSimpleGradients: [[Float32]] = [[-13.81011, -133.04008, -150.22589, -13.192558]]
    var expectedComplexGradients: [[Float32]] = [[95.57994842529297, -98.76066589355469, 148.50088500976562, -126.80604553222656], [31.69979476928711, 89.48539733886719, -114.56241607666016, 167.16433715820312], [157.56167602539062, -85.74986267089844, 213.60821533203125, -7.016921043395996], [167.75433349609375, 154.42352294921875, 16.086214065551758, -79.71075439453125], [79.56541442871094, -84.7736587524414, 48.14379119873047, 28.75021743774414]]
    
    func testSimpleGradients() {
        /*
         Test gradient calculation for a model with one layer
         */
        #if targetEnvironment(simulator)
        #else
        let oldSimpleWeightsPath: String = artifactsPath + "old_simple_weights"
        let newSimpleWeightsPath: String = artifactsPath + "new_simple_weights"
        let calculatedGradients: [[Float32]] = weightsProcessor.calculateGradients(oldModelPath: oldSimpleWeightsPath, newModelPath: newSimpleWeightsPath, learningRate: 0.01)
        let roundedCalculatedGradients: [Float32] = roundArr(arr: calculatedGradients[0], places: 3)
        let roundedExpectedGradients: [Float32] = roundArr(arr: expectedSimpleGradients[0], places: 3)
        XCTAssertEqual(roundedExpectedGradients, roundedCalculatedGradients)
        #endif
    }

    func testComplexGradients() {
        /*
         Test gradient calculation for a model with multiple layers.
         */
        #if targetEnvironment(simulator)
        #else
        let oldComplexWeightsPath: String = artifactsPath + "old_complex_weights"
        let newComplexWeightsPath: String = artifactsPath + "new_complex_weights"
        let calculatedGradients: [[Float32]] = weightsProcessor.calculateGradients(oldModelPath: oldComplexWeightsPath, newModelPath: newComplexWeightsPath, learningRate: 0.01)
        for (calculatedGradient, expectedGradient) in zip(calculatedGradients, expectedComplexGradients) {
            let roundedCalculatedGradient: [Float32] = roundArr(arr: calculatedGradient, places: 3)
            let roundedExpectedGradient: [Float32] = roundArr(arr: expectedGradient, places: 3)
            XCTAssertEqual(roundedExpectedGradient, roundedCalculatedGradient)
        }
        #endif
    }
}
