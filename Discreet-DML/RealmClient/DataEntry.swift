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
        self.init()
        self.repoID = repoID
    }

    public override static func primaryKey() -> String? {
        return "repoID"
    }
    
    public func addLabels(labels: [String]) {
        self.labels.append(objectsIn: labels)
    }
}

public class ImageEntry: DataEntry {
    /*
     Dataset object representing a list of paths to images on device.
     */
    let images: List<String> = List<String>()

    convenience init(repoID: String, images: [String], labels: [String]) {
        self.init(repoID: repoID)
        addImages(images: images, labels: labels)
    }

    func addImages(images: [String], labels: [String]) {
        self.images.append(objectsIn: images)
        addLabels(labels: labels)
    }
}

public class DoubleEntry: DataEntry {
    /*
     Dataset object representing a 2D array of Doubles.
     */
    let data: List<DoubleDatapoint> = List<DoubleDatapoint>()

    convenience init(repoID: String, datapoints: [[Double]], labels: [String]) {
        self.init(repoID: repoID)
        addData(datapoints: datapoints, labels: labels)
    }

    func addData(datapoints: [[Double]], labels: [String]) {
        let doubleDatapoints = datapoints.map({
            (datapoint: [Double]) -> DoubleDatapoint in
            return DoubleDatapoint(datapoint: datapoint)
        })
        self.data.append(objectsIn: doubleDatapoints)
        addLabels(labels: labels)
    }
}

public class DoubleDatapoint: Object {
    /*
     Datapoint object representing a 1D array of Doubles.
     */
    let datapoint: List<Double> = List<Double>()

    convenience init(datapoint: [Double]) {
        self.init()
        self.datapoint.append(objectsIn: datapoint)
    }
}
