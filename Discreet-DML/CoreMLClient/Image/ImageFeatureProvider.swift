///
///  ImageFeatureProvider.swift
///  Discreet-DML
///
///  Created by Neelesh on 3/3/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import CoreML

/**
 MLFeatureProvider subclass for an image path and label.
*/
class ImagesFeatureProvider: MLFeatureProvider {
    
    /// The input image as a pixel buffer.
    var image: CVPixelBuffer
    
    /// The corresponding label for this image.
    var label: String
    
    /// The possible feature names. Currently just the input image and label.
    var featureNames: Set<String> {
        get {
            return ["image", "label"]
        }
    }
    
    /**
     Determine the correct feature based on the feature name.
    
     - Parameters:
        - featureName: The name of the desired feature.
    
     - Returns: An optional consisting of the desired feature or `nil`.
    */
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        if (featureName == "label") {
            return MLFeatureValue(string: label)
        }
        return nil
    }
    
    /**
     Initialize the `TextFeatureValue` by turning the input text datapoint and label into MLMultiArrays.
    
     - Parameters:
        - image: The path to the image.
        - label: The corresponding label for this datapoint
        - imageConstraint: The constraints of the input image.
     
     - Throws: `DMLError` if the image could not be loaded from the provided path.
    */
    init(image: String, label: String, imageConstraint: MLImageConstraint) throws {
        let imageURL = URL(fileURLWithPath: image)
        let imageOptions: [MLFeatureValue.ImageOption: Any] = [:]
        var featureValue: MLFeatureValue
        do {
            featureValue = try MLFeatureValue(imageAt: imageURL, constraint: imageConstraint, options: imageOptions)
        } catch {
            print(error.localizedDescription)
            print("Failed to load the image at \(image)!")
            throw DMLError.dataError(ErrorMessage.failedImagePath)
        }
        self.image = featureValue.imageBufferValue!
        self.label = label
    }
}
