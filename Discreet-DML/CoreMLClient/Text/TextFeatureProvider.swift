///
///  TextFeatureProvider.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/29/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import CoreML

/**
 MLFeatureProvider subclass for an encoded text datapoint and label.
*/
class TextFeatureProvider : MLFeatureProvider {
    
    /// The input text datapoint as an MLMultiArray of textDatapoint.
    var textDatapoint: MLMultiArray
    
    /// The corresponding label as an MLMultiArray.
    var label: MLMultiArray
    
    /// The possible feature names. Currently just the input text datapoint and label.
    var featureNames: Set<String> {
        get {
            return ["input.1", "14_true"]
        }
    }
    
    /**
     Determine the correct feature based on the feature name.
     
     - Parameters:
        - featureName: The name of the desired feature.
     
     - Returns: An optional consisting of the desired feature or `nil`.
     */
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "input.1") {
            return MLFeatureValue(multiArray: self.textDatapoint)
        }
        if (featureName == "14_true") {
            return MLFeatureValue(multiArray: self.label)
        }
        return nil
    }
    
    /**
     Initialize the `TextFeatureValue` by turning the input text datapoint and label into MLMultiArrays.
     
     - Parameters:
        - textDatapoint: The 1D array of encoded text data.
        - label: The corresponding label for this datapoint
     */
    init(textDatapoint: [Int], label: Int) {
        self.textDatapoint = MLMultiArray.from(textDatapoint, dims: 2)
        self.label = MLMultiArray.from([label])
    }
}
