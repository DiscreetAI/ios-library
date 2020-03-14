///
///  DatasetLoader.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/28/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import CoreML


/**
 MLBatchProvider subclass for encoded text data.
*/
class TextBatchProvider: MLBatchProvider {
    
    /// The encoded text data, which is an array of text datapoint, each of which consists of a 1D array of integer encodings.
    var encodings: [[Int]]
    
    /// The labels for each of the text datapoints.
    var labels: [Int]
    
    /// The number of datapoints.
    var count: Int
    
    /**
     Initialize the batch provider with the given instance of the Realm Client and the repo ID.
     
     - Parameters:
        - realmClient: instance of RealmClient to get data from.
        - datasetID: The dataset ID corresponding to the desired dataset.
     */
    init(realmClient: RealmClient, datasetID: String) {
        let textEntry = realmClient.getTextEntry(datasetID: datasetID)!
        (self.encodings, self.labels) = textEntry.getData()
        self.count = self.encodings.count
    }
    
    /**
     Retrieve the `TextFeatureProvider` formed from the text datapoint and label at the given index.
     
     - Parameters:
        - index: Index at which to get the text datapoint and label.
     
     - Returns: A `TextFeatureProvider` corresponding ot the text datapoint and label.
     */
    func features(at index: Int) -> MLFeatureProvider {
        let textDatapoint = self.encodings[index]
        let label = self.labels[index]
        return TextFeatureProvider(textDatapoint: textDatapoint, label: label)
    }
}
