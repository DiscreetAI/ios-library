//
//  DummyWeightsProcessor.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/31/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import Discreet_DML

public class DummyWeightsProcessor: WeightsProcessor {
    /*
     Dummy class to simulate gradients calculation.
     */
    convenience init() {
        self.init(mpsHandler: nil)
    }
    
    override public func calculateGradients(oldWeightsPath: String, newWeightsPath: String, learningRate: Float32, useGPU: Bool = true) -> [[Float32]] {
        return []
    }
}
