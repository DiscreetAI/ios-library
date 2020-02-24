//
//  MetadataEntry.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/29/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import RealmSwift

public enum DataType: String {
    /*
     Enum denoting type of data for this repo ID.
     */
    case IMAGE = "Image"
    case TEXT = "Text"
}

public class MetadataEntry: Object {
    /*
     General dataset object. Uniquely identified by `repoID`.
     */
    @objc dynamic var repoID: String = ""
    @objc dynamic var dataType: String = ""

    convenience init(repoID: String, dataType: DataType) {
        /*
         repoID: repo ID associated with this entry.
         dataType: Data type of this entry.
         */
        self.init()
        self.repoID = repoID
        self.dataType = dataType.rawValue
    }

    public override static func primaryKey() -> String? {
        /*
        The identifying attribute of this entry.
        */
        return "repoID"
    }
}
