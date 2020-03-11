///
///  MetadataEntry.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/29/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import RealmSwift

/**
 Enum denoting type of data for this repo ID.
*/
enum DataType: String {
    
    /// Image data.
    case IMAGE = "IMAGE"
    
    /// Text data.
    case TEXT = "TEXT"
}

/**
 Dataset object corresponding to the metadata of a dataset.
 
 TODO: Add more information here, like number of datapoints.
*/
class MetadataEntry: DataEntry {
    
    /// The data type of the dataset corresponding to this repo ID.
    @objc dynamic var dataType: String = ""

    /**
     Initializes the metadata entry object with the provided `dataType`
     
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
        - dataType: Data type of this entry.
     */
    convenience init(repoID: String, dataType: DataType) {
        self.init(repoID: repoID)
        self.dataType = dataType.rawValue
    }
}
