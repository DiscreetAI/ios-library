//
//  DatasetLoader.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/28/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML

class TextBatchProvider: MLBatchProvider {
    /*
     MLBatchProvider subclass for encoded Text data.
     */
    var encodings: [[Int]]
    var labels: [Int]
    var count: Int
    
    init(encodings: [[Int]], labels: [Int]) {
        /*
         data: 2D array of Int encodings.
         labels: 1D array of labels for encodings.
         */
        self.encodings = encodings
        self.labels = labels
        self.count = encodings.count
    }
    
    init(realmClient: RealmClient, repoID: String) {
        /*
         realmClient: instance of RealmClient to get data from.
         repoID: repo ID to uniquely access data from RealmClient with.
         */
        let textEntry = realmClient.getTextEntry(repoID: repoID)!
        (self.encodings, self.labels) = textEntry.getData()
        self.count = self.encodings.count
    }
    
    func features(at index: Int) -> MLFeatureProvider {
        /*
         Get the corresponding MLFeatureProvider for the datapoint and label corresponding to this index.
         */
        let input = self.encodings[index]
        let label = self.labels[index]
        return TextFeatureProvider(input: input, label: label)
    }
}

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
