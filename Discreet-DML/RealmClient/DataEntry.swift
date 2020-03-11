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
 General dataset object. Uniquely identified by `repoID`.
*/
class DataEntry: Object {
    
    /// The repo ID corresponding to the dataset of this library.
    @objc dynamic var repoID: String = ""

    /**
     Initializes the data entry object. Never initialized directly.
     
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
     */
    convenience init(repoID: String) {
        self.init()
        self.repoID = repoID
    }

    /**
     The primary key of the data entry object.
     
     - Returns: `repoID`, the name of the primary key.
     */
    override static func primaryKey() -> String? {
        return "repoID"
    }
}



