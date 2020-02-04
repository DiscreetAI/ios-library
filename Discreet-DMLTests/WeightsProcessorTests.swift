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

    // Folder to testing artifacts
    let artifactsPath: String = testingUtilsPath + "WeightsProcessor/"

    var expectedSimpleGradients: [[Float32]] = [[-13.81011, -133.04008, -150.22589, -13.192558]]
    var expectedComplexGradients: [[Float32]] = [[95.57994842529297, -98.76066589355469, 148.50088500976562, -126.80604553222656], [31.69979476928711, 89.48539733886719, -114.56241607666016, 167.16433715820312], [157.56167602539062, -85.74986267089844, 213.60821533203125, -7.016921043395996], [167.75433349609375, 154.42352294921875, 16.086214065551758, -79.71075439453125], [79.56541442871094, -84.7736587524414, 48.14379119873047, 28.75021743774414]]

    func testSimpleGradients() {
        /*
         Test gradient calculation for a model with one layer.
         */
        let weightsProcessor = WeightsProcessor(mpsHandler: nil)
        let oldSimpleWeightsPath: String = artifactsPath + "old_simple_weights"
        let newSimpleWeightsPath: String = artifactsPath + "new_simple_weights"
        var calculatedGradients: [[Float32]]
        do {
            calculatedGradients = try weightsProcessor.calculateGradients(oldWeightsPath: oldSimpleWeightsPath, newWeightsPath: newSimpleWeightsPath, learningRate: 0.01)
            let roundedCalculatedGradients: [Float32] = roundArr(arr: calculatedGradients[0], places: 3)
            let roundedExpectedGradients: [Float32] = roundArr(arr: expectedSimpleGradients[0], places: 3)
            XCTAssertEqual(roundedExpectedGradients, roundedCalculatedGradients)
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }

    func testComplexGradients() {
        /*
         Test gradient calculation for a model with multiple layers.
         */
        let weightsProcessor = WeightsProcessor(mpsHandler: nil)
        let oldComplexWeightsPath: String = artifactsPath + "old_complex_weights"
        let newComplexWeightsPath: String = artifactsPath + "new_complex_weights"
        var calculatedGradients: [[Float32]]
        do {
            calculatedGradients = try weightsProcessor.calculateGradients(oldWeightsPath: oldComplexWeightsPath, newWeightsPath: newComplexWeightsPath, learningRate: 0.01)
            for (calculatedGradient, expectedGradient) in zip(calculatedGradients, expectedComplexGradients) {
                let roundedCalculatedGradient: [Float32] = roundArr(arr: calculatedGradient, places: 3)
                let roundedExpectedGradient: [Float32] = roundArr(arr: expectedGradient, places: 3)
                XCTAssertEqual(roundedExpectedGradient, roundedCalculatedGradient)
            }
        } catch {
            print("An unexpected error occurred during the test.")
            print(error.localizedDescription)
            XCTFail()
        }
    }

    func testSimpleGradientsGPU() {
        /*
         Test gradient calculation using GPU for a model with one layer.

         Trivially passes on simulators, since they do not use a GPU.
         */
        #if targetEnvironment(simulator)
        #else
        var weightsProcessor = WeightsProcessor(mpsHandler: MPSHandler())
        let oldSimpleWeightsPath: String = artifactsPath + "old_simple_weights"
        let newSimpleWeightsPath: String = artifactsPath + "new_simple_weights"
        let calculatedGradients: [[Float32]] = weightsProcessor.calculateGradients(oldWeightsPath: oldSimpleWeightsPath, newWeightsPath: newSimpleWeightsPath, learningRate: 0.01)
        let roundedCalculatedGradients: [Float32] = roundArr(arr: calculatedGradients[0], places: 3)
        let roundedExpectedGradients: [Float32] = roundArr(arr: expectedSimpleGradients[0], places: 3)
        XCTAssertEqual(roundedExpectedGradients, roundedCalculatedGradients)
        #endif
    }

    func testComplexGradientsGPU() {
        /*
         Test gradient calculation using GPU for a model with multiple layers.

         Trivially passes on simulators, since they do not use a GPU.
         */
        #if targetEnvironment(simulator)
        #else
        var weightsProcessor = WeightsProcessor(mpsHandler: MPSHandler())
        let oldComplexWeightsPath: String = artifactsPath + "old_complex_weights"
        let newComplexWeightsPath: String = artifactsPath + "new_complex_weights"
        let calculatedGradients: [[Float32]] = weightsProcessor.calculateGradients(oldWeightsPath: oldComplexWeightsPath, newWeightsPath: newComplexWeightsPath, learningRate: 0.01)
        for (calculatedGradient, expectedGradient) in zip(calculatedGradients, expectedComplexGradients) {
            let roundedCalculatedGradient: [Float32] = roundArr(arr: calculatedGradient, places: 3)
            let roundedExpectedGradient: [Float32] = roundArr(arr: expectedGradient, places: 3)
            XCTAssertEqual(roundedExpectedGradient, roundedCalculatedGradient)
        }
        #endif
    }

    func testBadDevice() {
        #if targetEnvironment(simulator)
        XCTAssertThrowsError(try MPSHandler()) { error in
                XCTAssertEqual(error as! DMLError, DMLError.mpsError(ErrorMessage.badDevice))
        }
        #else
        #endif
    }
    
    func testMissingWeightsFile() {
        let weightsProcessor = WeightsProcessor(mpsHandler: nil)
        let oldSimpleWeightsPath: String = artifactsPath + "missing_old_weights"
        let newSimpleWeightsPath: String = artifactsPath + "missing_new_weights"
        XCTAssertThrowsError(try weightsProcessor.calculateGradients(oldWeightsPath: oldSimpleWeightsPath, newWeightsPath: newSimpleWeightsPath, learningRate: 0.01)) { error in
            XCTAssertEqual(error as! DMLError, DMLError.weightsProcessorError(ErrorMessage.failedFileHandle))
        }
    }
}
