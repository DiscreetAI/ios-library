//
//  TextFeatureProvider.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/29/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML

class TextFeatureProvider : MLFeatureProvider {
    /*
     MLFeatureProvider for Double data.
     */
    var input: MLMultiArray
    var label: MLMultiArray
    
    var featureNames: Set<String> {
        get {
            return ["input.1", "14_true"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        /*
        Return a MLFeatureValue based on whether the feature is the datapoint or label.
        */
        if (featureName == "input.1") {
            return MLFeatureValue(multiArray: input)
        }
        if (featureName == "14_true") {
            return MLFeatureValue(multiArray: label)
        }
        return nil
    }
    
    init(input: MLMultiArray, label: MLMultiArray) {
        /*
         image: The pixel buffer corresponding to the image.
         label: The label corresponding to this image.
         */
        self.input = input
        self.label = label
    }
    
    init(input: [Int], label: Int) {
        /*
         image: The pixel buffer corresponding to the image.
         label: The label corresponding to this image.
         */
        self.input = MLMultiArray.from(input, dims: 2)
        self.label = MLMultiArray.from([label])
    }
}


