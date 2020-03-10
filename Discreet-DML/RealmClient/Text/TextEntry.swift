//
//  TextEntry.swift
//  Discreet-DML
//
//  Created by Neelesh on 3/3/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import RealmSwift

class TextEntry: DataEntry {
    /*
     Dataset object representing a 2D array of integer encodings.
     */
    let encodings: List<TextDatapoint> = List<TextDatapoint>()
    let labels: List<Int> = List<Int>()

    convenience init(repoID: String, encodings: [[Int]], labels: [Int]) {
        /*
         repoID: repo ID associated with this entry.
         encodings: 2D array of encodings.
         labels: 1D array of labels for data.
         */
        self.init(repoID: repoID)
        self.addEncodings(encodings: encodings, labels: labels)
    }

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
    
    func getData() -> ([[Int]], [Int]) {
        /*
        Unwrap this entry as tuple of encodings and labels.
        */
        let unwrappedData = Array(self.encodings).map({
            (encoding: TextDatapoint) -> [Int] in
            return encoding.getData()
        })
        let unwrappedLabels = Array(self.labels)
        return (unwrappedData, unwrappedLabels)
    }
    
    func getDatapointCount() -> Int {
        /*
         Return the number of datapoints.
         */
        return self.labels.count
    }
}

class TextDatapoint: Object {
    /*
     Encoding object representing a 1D array of Ints.
     */
    let textDatapoint: List<Int> = List<Int>()

    convenience init(textDatapoint: [Int]) {
        /*
         Encoding: 1D array of Int data
         */
        self.init()
        self.textDatapoint.append(objectsIn: textDatapoint)
    }
    
    func getData() -> [Int] {
        /*
         Unwrap entry as 1D array of Int array.
         */
        return Array(self.textDatapoint)
    }
}
