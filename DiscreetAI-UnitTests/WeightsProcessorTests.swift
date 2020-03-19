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
@testable import DiscreetAI

class WeightsProcessorTests: XCTestCase {
    let artifactsPath: String = testingUtilsPath + "WeightsProcessor/"
    
    private func compareGradients(expectedGradients: [[Float32]], calculatedGradients: [[Float32]]) {
        for (calculatedGradient, expectedGradient) in zip(calculatedGradients, expectedGradients) {
            let roundedCalculatedGradient: [Float32] = roundArr(arr: calculatedGradient, places: 3)
            let roundedExpectedGradient: [Float32] = roundArr(arr: expectedGradient, places: 3)
            XCTAssertEqual(roundedExpectedGradient, roundedCalculatedGradient)
        }
    }

    func testSimpleGradients() {
        /*
         Test gradient calculation for a model with one layer.
         */
        let weightsProcessor = WeightsProcessor()
        let oldSimpleWeightsPath: String = artifactsPath + "old_simple_weights"
        let newSimpleWeightsPath: String = artifactsPath + "new_simple_weights"
        var calculatedGradients: [[Float32]]
        do {
            calculatedGradients = try weightsProcessor.calculateGradients(oldWeightsPath: oldSimpleWeightsPath, newWeightsPath: newSimpleWeightsPath, learningRate: 0.01)
            compareGradients(expectedGradients: simpleGradients, calculatedGradients: calculatedGradients)
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
        let weightsProcessor = WeightsProcessor()
        let oldComplexWeightsPath: String = self.artifactsPath + "old_complex_weights"
        let newComplexWeightsPath: String = self.artifactsPath + "new_complex_weights"
        var calculatedGradients: [[Float32]]
        do {
            calculatedGradients = try weightsProcessor.calculateGradients(oldWeightsPath: oldComplexWeightsPath, newWeightsPath: newComplexWeightsPath, learningRate: 0.01)
            compareGradients(expectedGradients: complexGradients, calculatedGradients: calculatedGradients)
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
        let weightsProcessor = WeightsProcessor()
        let oldSimpleWeightsPath: String = artifactsPath + "missing_old_weights"
        let newSimpleWeightsPath: String = artifactsPath + "missing_new_weights"
        XCTAssertThrowsError(try weightsProcessor.calculateGradients(oldWeightsPath: oldSimpleWeightsPath, newWeightsPath: newSimpleWeightsPath, learningRate: 0.01)) { error in
            XCTAssertEqual(error as! DMLError, DMLError.weightsProcessorError(ErrorMessage.failedFileHandle))
        }
    }
}
