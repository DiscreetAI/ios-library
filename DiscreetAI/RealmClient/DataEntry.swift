///
///  DataEntry.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/27/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import RealmSwift


/**
 Enum denoting type of data for a specific dataset ID.
*/
enum DataType: String {
    
    /// Image data.
    case IMAGE = "IMAGE"
    
    /// Text data.
    case TEXT = "TEXT"
}

/**
 General dataset object. Uniquely identified by `repoID/datasetID`.
*/
class DataEntry: Object {
    
    /// The data type of this entry.
    @objc dynamic var dataType: String = ""
    
    /// The primary key of this entry.
    @objc dynamic var primaryKey: String = ""

    /**
     Initializes the data entry object. Never initialized directly.
     
     - Parameters:
        - repoID: The repo ID corresponding to the registered application.
        - datasetID: The dataset ID corresponding to the desired dataset.
     */
    convenience init(repoID: String, datasetID: String) {
        self.init()
        self.primaryKey = makePrimaryKey(repoID: repoID, datasetID: datasetID)
    }

    convenience init(primaryKey: String, dataType: String) {
        self.init()
        self.primaryKey = primaryKey
        self.dataType = dataType
    }
    /**
     The primary key of the data entry object.
     
     - Returns: `primaryKey`,  the name of the primary key.
     */
    override static func primaryKey() -> String? {
        return "primaryKey"
    }
    
    /**
     Convert this data entry into a `DataEntry` object.
     
     - Returns: The `DataEntry` object formed from this data entry's primary key
     */
    func toDataEntry() -> DataEntry {
        return DataEntry(primaryKey: self.primaryKey, dataType: self.dataType)
    }
}



