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



