//
//  TrainingInput.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/29/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML

class DoubleFeatureProvider : MLFeatureProvider {
    /*
     MLFeatureProvider for Double data.
     */
    var dense_1_input_0: MLMultiArray
    var classLabel: String
    var featureNames: Set<String> {
        get {
            return ["dense_1_input:0", "classLabel"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        /*
         Return a MLFeatureValue based on whether the feature is the datapoint or label.
         */
        if (featureName == "dense_1_input:0") {
            return MLFeatureValue(multiArray: dense_1_input_0)
        }
        if (featureName == "classLabel") {
            return MLFeatureValue(string: classLabel)
        }
        return nil
    }
    
    init(dense_1_input_0: MLMultiArray, classLabel: String) {
        /*
         dense_1_input_0: The MLMultiArray encompassing the data.
         classLabel: The corresponding label.
         */
        self.dense_1_input_0 = dense_1_input_0
        self.classLabel = classLabel
    }
}

class ImagesFeatureProvider: MLFeatureProvider {
    /*
     MLFeatureProvider for images.
     */
    var image: CVPixelBuffer
    var label: String
    var featureNames: Set<String> {
        get {
            return ["image", "label"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        /*
        Return a MLFeatureValue based on whether the feature is the datapoint or label.
        */
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        if (featureName == "label") {
            return MLFeatureValue(string: label)
        }
        return nil
    }
    
    init(image: CVPixelBuffer, label: String) {
        /*
         image: The pixel buffer corresponding to the image.
         label: The label corresponding to this image.
         */
        self.image = image
        self.label = label
    }
    
    init(image: String, label: String, imageConstraint: MLImageConstraint) throws {
        /*
         image: The path to the image.
         label: The label corresponding to this image.
         imageConstraint: Constraints for the input image.
         */
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
