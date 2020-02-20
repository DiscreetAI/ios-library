//
//  DataEntry.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/27/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation
import RealmSwift

public class DataEntry: Object {
    /*
     General dataset object. Uniquely identified by `repoID`.
     */
    @objc dynamic var repoID: String = ""
    let labels: List<String> = List<String>()

    convenience init(repoID: String) {
        /*
         repoID: repo ID associated with this entry.
         */
        self.init()
        self.repoID = repoID
    }

    public override static func primaryKey() -> String? {
        /*
         The identifying attribute of this entry.
         */
        return "repoID"
    }
    
    public func addLabels(labels: [String]) {
        /*
         Add labels to this entry (usually in conjunction with data).
         */
        self.labels.append(objectsIn: labels)
    }
}

public class ImageEntry: DataEntry {
    /*
     Dataset object representing a list of paths to images on device.
     */
    let images: List<String> = List<String>()

    convenience init(repoID: String, images: [String], labels: [String]) {
        /*
         repoID: repo ID associated with this entry.
         images: 1D array of image paths.
         labels: 1D array of labels for data.
         */
        self.init(repoID: repoID)
        addImages(images: images, labels: labels)
    }

    public func addImages(images: [String], labels: [String]) {
        /*
         Add more images and labels to this entry.
         */
        self.images.append(objectsIn: images)
        addLabels(labels: labels)
    }
    
    public func getData() -> ([String], [String]) {
        /*
         Unwrap this entry as tuple of data and labels.
         */
        let unwrappedImages = Array(self.images)
        let unwrappedLabels = Array(self.labels)
        return (unwrappedImages, unwrappedLabels)
    }
    
    public func setData(images: [String], labels: [String]) {
        self.images.removeAll()
        self.labels.removeAll()
        self.addImages(images: images, labels: labels)
    }
}

public class DoubleEntry: DataEntry {
    /*
     Dataset object representing a 2D array of Doubles.
     */
    let data: List<DoubleDatapoint> = List<DoubleDatapoint>()

    convenience init(repoID: String, datapoints: [[Double]], labels: [String]) {
        /*
         repoID: repo ID associated with this entry.
         datapoints: 2D array of Double data.
         labels: 1D array of labels for data.
         */
        self.init(repoID: repoID)
        addData(datapoints: datapoints, labels: labels)
    }

    public func addData(datapoints: [[Double]], labels: [String]) {
        /*
        Add more datapoints and labels to this entry.
        */
        let doubleDatapoints = datapoints.map({
            (datapoint: [Double]) -> DoubleDatapoint in
            return DoubleDatapoint(datapoint: datapoint)
        })
        self.data.append(objectsIn: doubleDatapoints)
        addLabels(labels: labels)
    }
    
    public func getData() -> ([[Double]], [String]) {
        /*
        Unwrap this entry as tuple of data and labels.
        */
        let unwrappedData = Array(self.data).map({
            (datapoint: DoubleDatapoint) -> [Double] in
            return datapoint.getData()
        })
        let unwrappedLabels = Array(self.labels)
        return (unwrappedData, unwrappedLabels)
    }
}

public class DoubleDatapoint: Object {
    /*
     Datapoint object representing a 1D array of Doubles.
     */
    let datapoint: List<Double> = List<Double>()

    convenience init(datapoint: [Double]) {
        /*
         datapoint: 1D array of Double data
         */
        self.init()
        self.datapoint.append(objectsIn: datapoint)
    }
    
    func getData() -> [Double] {
        /*
         Unwrap entry as 1D array of Double array.
         */
        return Array(self.datapoint)
    }
}
