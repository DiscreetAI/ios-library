//
//  Data.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/27/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation
import RealmSwift

public class RealmDatapointDouble: Object {
    var datapoint: List<Double> = List<Double>()
    
    convenience init(arr: [Double]) {
        self.init()
        self.datapoint.append(objectsIn: arr)
    }
}

public class RealmDataDouble: Object {
    @objc dynamic var repoID: String = ""
    var data: List<RealmDatapointDouble> = List<RealmDatapointDouble>()
    @objc dynamic var rows: Int = 0
    @objc dynamic var cols: Int = 0
    
    convenience init(repoID: String, data: [[Double]]) {
        self.init()
        self.data.append(objectsIn: data.map(makeRealmDatapointDouble))
        self.repoID = repoID
        self.rows = data.count
        self.cols = data[0].count
    }
    
    func makeRealmDatapointDouble(arr: [Double]) -> RealmDatapointDouble {
        return RealmDatapointDouble(arr: arr)
    }
    
    public override static func primaryKey() -> String? {
        return "repoID"
    }
    
    public func addData(newData: [[Double]]) {
        self.data.append(objectsIn: newData.map(makeRealmDatapointDouble))
    }
}
