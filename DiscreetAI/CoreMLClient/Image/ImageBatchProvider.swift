///
///  ImageBatchProvider.swift
///  Discreet-DML
///
///  Created by Neelesh on 3/3/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import CoreML

/**
 MLBatchProvider subclass for image paths and labels.
 */
class ImagesBatchProvider: MLBatchProvider {

    /// The 1D array of image paths referring to images stored in the application's documents directory.
    var images: [String]
    
    /// The labels for each of the images at the image paths.
    var labels: [String]
    
    /// The constraints of the input image.
    var imageConstraint: MLImageConstraint
    
    /// The name of the input .
    var inputName: String
    
    /// The name of the predicted feature.
    var predictedFeatureName: String
    
    /// The number of datapoints.
    var count: Int

    /**
     Initialize the batch provider with the given instance of the Realm Client and the repo ID and the image contraints.
    
     - Parameters:
        - realmClient: instance of RealmClient to get data from.
        - datasetID: The dataset ID corresponding to the desired dataset.
        - imageConstraint: The constraints of the input image.
        - inputName: The name of the input .
        - predictedFeatureName: The name of the predicted feature.
    */
    init(realmClient: RealmClient, datasetID: String, imageConstraint: MLImageConstraint, inputName: String, predictedFeatureName: String) {
        let imageEntry = realmClient.getImageEntry(datasetID: datasetID)!
        (self.images, self.labels) = imageEntry.getData()
        self.count = self.images.count
        self.imageConstraint = imageConstraint
        self.inputName = inputName
        self.predictedFeatureName = predictedFeatureName
    }

    /**
     Retrieve the `ImageFeatureProvider` formed from the image path and label at the given index.
    
     - Parameters:
        - index: Index at which to get the image path and label.
    
     - Returns: A `ImageFeatureProvider` corresponding ot the image path and label.
    */
    func features(at index: Int) -> MLFeatureProvider {
        return try! ImagesFeatureProvider(image: self.images[index], label: self.labels[index], imageConstraint: self.imageConstraint, inputName: inputName, predictedFeatureName: predictedFeatureName)
    }
}
