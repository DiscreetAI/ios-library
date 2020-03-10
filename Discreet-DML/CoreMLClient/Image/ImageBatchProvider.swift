//
//  ImageBatchProvider.swift
//  Discreet-DML
//
//  Created by Neelesh on 3/3/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML

class ImagesBatchProvider: MLBatchProvider {
    /*
     MLBatchProvider class for images.
     */
    
    var images: [String]
    var labels: [String]
    var imageConstraint: MLImageConstraint
    var count: Int

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


    func features(at index: Int) -> MLFeatureProvider {
        /*
        Get the corresponding MLFeatureProvider for the datapoint and label corresponding to this index.
        */
        return try! ImagesFeatureProvider(image: self.images[index], label: self.labels[index], imageConstraint: self.imageConstraint)
    }
}
