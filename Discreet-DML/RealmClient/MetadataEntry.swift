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
 Dataset object corresponding to the metadata of a dataset.
 
 TODO: Add more information here.
*/
class MetadataEntry: Object {
    
   /// The repo ID corresponding to the registered application.
    @objc dynamic var repoID: String = ""
    
    /// The list of data entries that exist for this repo ID.
    let dataEntries = List<DataEntry>()
    
    /**
     Initialize the metadata entry with the provided repo ID.
     
     - Parameters:
        - repoID: The repo ID corresponding to the registered application.
     */
    convenience init(repoID: String) {
        self.init()
        self.repoID = repoID
    }
    
    /**
     Add the newly formed data entry to the list of data entries. Convert it to be a regular data entry so it can be added to the list.
     
     NOTE: Even though this is done in a write transaction, the primary key of this data entry being the same as the data entry that was directly added does NOT create a conflict. Only objects directly added to Realm can be retrieved using the primary key.
     
     - Parameters:
        - dataEntry: The data entry to be added.
     */
    func addDataEntry(dataEntry: DataEntry) {
        self.dataEntries.append(dataEntry.toDataEntry())
    }
    
    /**
     Remove the data entry with the provided `datasetID` from the list of data entries, if it exists.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
     
     - Returns: Boolean determining whether the removal was successful or not.
     */
    func removeDataEntry(datasetID: String) -> Bool {
        let primaryKey = makePrimaryKey(repoID: self.repoID, datasetID: datasetID)
        
        if let index = self.dataEntries.firstIndex(where: {$0.primaryKey == primaryKey}) {
            self.dataEntries.remove(at: index)
            return true
        } else {
            return false
        }
    }
    
    /**
    Retrieve data entry using the `datasetID` to form the primary key.
    
    - Parameters:
       - datasetID: The dataset ID corresponding to the desired dataset.
    
    - Returns: An optional containing a `DataEntry` if retrieval succeeded and `nil` otherwise.
    */
    func getDataEntry(datasetID: String) -> DataEntry? {
        let primaryKey = makePrimaryKey(repoID: self.repoID, datasetID: datasetID)
        
        return self.dataEntries.filter{$0.primaryKey == primaryKey}.first
    }
    
    /**
     Retrieve the list of data entries.
     
     - Returns: The list of data entries.
     */
    func getDataEntries() -> [DataEntry] {
        return Array(self.dataEntries)
    }
    
    /**
    The primary key of the metadata entry object.
    
    - Returns: `repoID`,  the name of the primary key.
    */
    override static func primaryKey() -> String? {
        return "repoID"
    }
}
