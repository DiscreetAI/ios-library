//
//  DataEntry.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/27/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation
import RealmSwift

class DataEntry: Object {
    /*
     General dataset object. Uniquely identified by `repoID`.
     */
    @objc dynamic var repoID: String = ""

    convenience init(repoID: String) {
        /*
         repoID: repo ID associated with this entry.
         */
        self.init()
        self.repoID = repoID
    }

    override static func primaryKey() -> String? {
        /*
         The identifying attribute of this entry.
         */
        return "repoID"
    }
}

class ImageEntry: DataEntry {
    /*
     Dataset object representing a list of paths to images on device.
     */
    let images: List<String> = List<String>()
    let labels: List<String> = List<String>()

    convenience init(repoID: String, images: [String], labels: [String]) {
        /*
         repoID: repo ID associated with this entry.
         images: 1D array of image paths.
         labels: 1D array of labels for data.
         */
        self.init(repoID: repoID)
        self.addImages(images: images, labels: labels)
    }

    func addImages(images: [String], labels: [String]) {
        /*
         Add more images and labels to this entry.
         */
        self.images.append(objectsIn: images)
        self.labels.append(objectsIn: labels)
    }
    
    func getData() -> ([String], [String]) {
        /*
         Unwrap this entry as tuple of data and labels.
         */
        let unwrappedImages = Array(self.images)
        let unwrappedLabels = Array(self.labels)
        return (unwrappedImages, unwrappedLabels)
    }
    
    func setData(images: [String], labels: [String]) {
        /*
         Set the data for this entry with the given image paths and labels.
         */
        self.images.removeAll()
        self.labels.removeAll()
        self.addImages(images: images, labels: labels)
    }
    
    func getDatapointCount() -> Int {
        /*
         Return the number of datapoints.
         */
        return self.labels.count
    }
}

class EncodingEntry: DataEntry {
    /*
     Dataset object representing a 2D array of Ints.
     */
    let encodings: List<EncodingDatapoint> = List<EncodingDatapoint>()
    let labels: List<Int> = List<Int>()

    convenience init(repoID: String, encodings: [[Int]], labels: [Int]) {
        /*
         repoID: repo ID associated with this entry.
         encodings: 2D array of Int data.
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
            (encodingDatapoint: [Int]) -> EncodingDatapoint in
            return EncodingDatapoint(encodingDatapoint: encodingDatapoint)
        })
        self.encodings.append(objectsIn: encodings)
        self.labels.append(objectsIn: labels)
    }
    
    func getData() -> ([[Int]], [Int]) {
        /*
        Unwrap this entry as tuple of encodings and labels.
        */
        let unwrappedData = Array(self.encodings).map({
            (encoding: EncodingDatapoint) -> [Int] in
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

class EncodingDatapoint: Object {
    /*
     Encoding object representing a 1D array of Ints.
     */
    let encodingDatapoint: List<Int> = List<Int>()

    convenience init(encodingDatapoint: [Int]) {
        /*
         Encoding: 1D array of Int data
         */
        self.init()
        self.encodingDatapoint.append(objectsIn: encodingDatapoint)
    }
    
    func getData() -> [Int] {
        /*
         Unwrap entry as 1D array of Int array.
         */
        return Array(self.encodingDatapoint)
    }
}
