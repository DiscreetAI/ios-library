///
///  TextEntry.swift
///  Discreet-DML
///
///  Created by Neelesh on 3/3/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import RealmSwift

/**
 Dataset object representing a list text datapoints and labels.
*/
class TextEntry: DataEntry {
    
    /// The encoded text data, which is a list of text datapoints.
    let encodings: List<TextDatapoint> = List<TextDatapoint>()
    
    /// The labels for each of the text datapoints.
    let labels: List<Int> = List<Int>()

    /**
     Initializes the `TextEntry` object with the starting encodings and labels.
    
     - Parameters:
        - repoID: The repo ID corresponding to the registered application.
        - datasetID: The dataset ID corresponding to the desired dataset.
        - encodings: The encoded text data, which is an array of text datapoint, each of which consists of a 1D array of integer encodings.
        - labels: The labels for each of the text datapoints.
    */
    convenience init(repoID: String, datasetID: String, encodings: [[Int]], labels: [Int]) {
        self.init(repoID: repoID, datasetID: datasetID)
        self.dataType = DataType.TEXT.rawValue
        self.addEncodings(encodings: encodings, labels: labels)
    }

    /**
     Add more encodings and labels for this repo ID.
    
     - Parameters:
        - encodings: The encoded text data, which is an array of text datapoint, each of which consists of a 1D array of integer encodings.
        - labels: The labels for each of the text datapoints.
    */
    func addEncodings(encodings: [[Int]], labels: [Int]) {
        /*
        Add more encodings and labels to this entry.
        */
        let encodings = encodings.map({
            (textDatapoint: [Int]) -> TextDatapoint in
            return TextDatapoint(textDatapoint: textDatapoint)
        })
        self.encodings.append(objectsIn: encodings)
        self.labels.append(objectsIn: labels)
    }
    
    /**
     Retrieve the encodings and labels that were previously stored.
    
     - Returns: A tuple (`encodings`, `labels`) where `encodings` refers to the stored encodings and `labels` refers to the corresponding labels.
    */
    func getData() -> ([[Int]], [Int]) {
        let unwrappedData = Array(self.encodings).map({
            (encoding: TextDatapoint) -> [Int] in
            return encoding.getData()
        })
        let unwrappedLabels = Array(self.labels)
        return (unwrappedData, unwrappedLabels)
    }
    
    /**
     Get the datapoint count for this entry.
    
     - Returns: The datapoint count.
    */
    func getDatapointCount() -> Int {
        return self.labels.count
    }
}

/**
 Dataset object representing a 1D array of integer encodings.
*/
class TextDatapoint: Object {
    
    /// Text datapoint consisting of a list of integer encodings.
    let textDatapoint: List<Int> = List<Int>()

    /**
     Initializes the text datapoint with a list of encodings.
     
     - Parameters:
        - textDatapoint: 1D array consisting of integer encodings.
     */
    convenience init(textDatapoint: [Int]) {
        self.init()
        self.textDatapoint.append(objectsIn: textDatapoint)
    }
    
    /**
     Retrieve the datapoint's encodings.
     
     - Returns: A 1D array of integer encodings.
     */
    func getData() -> [Int] {
        return Array(self.textDatapoint)
    }
}
