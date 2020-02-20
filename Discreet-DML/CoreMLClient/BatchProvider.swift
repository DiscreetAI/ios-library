//
//  DatasetLoader.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/28/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML
import UIKit

public class DoubleBatchProvider: MLBatchProvider {
    /*
     MLBatchProvider subclass for Double data.
     */
    var data: [[Double]]
    var labels: [String]
    public var count: Int
    
    init(data: [[Double]], labels: [String]) {
        /*
         data: 2D array of Double data.
         labels: 1D array of labels for data.
         */
        self.data = data
        self.labels = labels
        self.count = data.count
    }
    
    init(realmClient: RealmClient, repoID: String) {
        /*
         realmClient: instance of RealmClient to get data from.
         repoID: repo ID to uniquely access data from RealmClient with.
         */
        let doubleEntry = realmClient.getDoubleEntry(repoID: repoID)!
        (self.data, self.labels) = doubleEntry.getData()
        self.count = self.data.count
    }
    
    public func features(at index: Int) -> MLFeatureProvider {
        /*
         Get the corresponding MLFeatureProvider for the datapoint and label corresponding to this index.
         */
        let input = try! MLMultiArray.from(self.data[index])
        let label = self.labels[index]
        return DoubleFeatureProvider(dense_1_input_0: input, classLabel: label)
    }
}

public class ImagesBatchProvider: MLBatchProvider {
    /*
     MLBatchProvider class for images.
     */
    
    var images: [String]
    var labels: [String]
    var imageConstraint: MLImageConstraint
    public var count: Int

    init(images: [String], labels: [String], imageConstraint: MLImageConstraint) {
        /*
        images: 1D array of image paths.
        labels: 1D array of labels for data.
        imageConstraint: Constraints for the input image.
        */
        self.images = images
        self.labels = labels
        self.count = images.count
        self.imageConstraint = imageConstraint
    }

    init(realmClient: RealmClient, repoID: String, imageConstraint: MLImageConstraint) {
        /*
        realmClient: instance of RealmClient to get data from.
        repoID: repo ID to uniquely access data from RealmClient with.
        imageConstraint: Constraints for the input image.
        */
        let imageEntry = realmClient.getImageEntry(repoID: repoID)!
        (self.images, self.labels) = imageEntry.getData()
        self.count = self.images.count
        self.imageConstraint = imageConstraint
    }
    
    init(imageConstraint: MLImageConstraint) {
        self.images = []
        self.labels = []
        self.count = 0
        self.imageConstraint = imageConstraint
    }


    public func features(at index: Int) -> MLFeatureProvider {
        /*
        Get the corresponding MLFeatureProvider for the datapoint and label corresponding to this index.
        */
        return try! ImagesFeatureProvider(image: self.images[index], label: self.labels[index], imageConstraint: self.imageConstraint)
    }
}
