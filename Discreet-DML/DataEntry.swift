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

    convenience init(repoID: String) {
        self.init()
        self.repoID = repoID
    }

    public override static func primaryKey() -> String? {
        return "repoID"
    }
}

public class ImageEntry: DataEntry {
    /*
     Dataset object representing a list of paths to images on device.
     */
    var images: List<String> = List<String>()

    convenience init(repoID: String, images: [String]) {
        self.init(repoID: repoID)
        addImages(images: images)
    }

    func addImages(images: [String]) {
        self.images.append(objectsIn: images)
    }
}

public class DoubleEntry: DataEntry {
    /*
     Dataset object representing a 2D array of Doubles.
     */
    var data: List<DoubleDatapoint> = List<DoubleDatapoint>()

    convenience init(repoID: String, datapoints: [[Double]]) {
        self.init(repoID: repoID)
        addData(datapoints: datapoints)
    }

    func addData(datapoints: [[Double]]) {
        let doubleDatapoints = datapoints.map({
            (datapoint: [Double]) -> DoubleDatapoint in
            return DoubleDatapoint(datapoint: datapoint)
        })
        self.data.append(objectsIn: doubleDatapoints)
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
