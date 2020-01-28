//
//  RealmClient.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/27/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation
import RealmSwift

public class RealmClient {
    /*
     Client to interact with Realm.
     */
    var realm: Realm!
    
    init() {
        self.realm = try! Realm()
    }
    
    public func storeStandardData(repoID: String, data: [[Double]]) {
        /*
         Store a 2D Double array under the given `repoID`.
         
         If data for this `repoID` already exists, simply append the given data.
         */
        
        try! self.realm.write {
            if let realmEntry = getStandardData(repoID: repoID) {
                realmEntry.addData(newData: data)
            } else {
                self.realm.add(RealmDataDouble(repoID: repoID, data: data))
            }
        }
        
    }
    
    public func getStandardData(repoID: String) -> RealmDataDouble? {
        /*
         Retrieve the standard data (2D Double array) object with the `repoID` as the primary key.
         */
        return self.realm.object(ofType: RealmDataDouble.self, forPrimaryKey: repoID)
    }
    
    public func clear() {
        /*
         Clear the Realm DB of all objects.
         */
        try! realm.write {
            self.realm.deleteAll()
        }
    }
}
