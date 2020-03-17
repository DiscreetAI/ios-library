//
//  DummyWeightsProcessor.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/31/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import DiscreetAI

class DummyWeightsProcessor: WeightsProcessor {
    /*
     Dummy class to simulate gradients calculation.
     */
    override func calculateGradients(oldWeightsPath: String, newWeightsPath: String, learningRate: Float32) throws -> [[Float32]] {
        return []
    }
}
