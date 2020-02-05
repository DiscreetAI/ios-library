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

    init() throws {
        do {
            self.realm = try Realm()
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmSetup)
        }
    }

    public func storeData(repoID: String, data: [[Double]], labels: [String]) throws {
        /*
         Store a 2D Double array and labels under the given `repoID`.

         If data for this `repoID` already exists, simply append the given data.
         */
        do {
            try self.realm.write {
                if let doubleEntry = getDoubleEntry(repoID: repoID) {
                    doubleEntry.addData(datapoints: data, labels: labels)
                } else {
                    self.realm.add(MetadataEntry(repoID: repoID, dataType: DataType.DOUBLE))
                    self.realm.add(DoubleEntry(repoID: repoID, datapoints: data, labels: labels))
                }
            }
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmWrite)
        }
    }

    public func storeData(repoID: String, data: [String], labels: [String]) throws {
        /*
         Store a 1D String array of image paths under the given `repoID`.

         If data for this `repoID` already exists, simply append the given data.
         */
        do {
            try self.realm.write {
                if let imageEntry = getImageEntry(repoID: repoID) {
                    imageEntry.addImages(images: data, labels: labels)
                } else {
                    self.realm.add(MetadataEntry(repoID: repoID, dataType: DataType.IMAGE))
                    self.realm.add(ImageEntry(repoID: repoID, images: data, labels: labels))
                }
            }
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmWrite)
        }
    }

    public func getDataEntry(repoID: String) -> DataEntry? {
        /*
         Retrieve data entry with the `repoID` as the primary key.
         */
        return self.realm.object(ofType: DataEntry.self, forPrimaryKey: repoID)
    }

    public func getDoubleEntry(repoID: String) -> DoubleEntry? {
        /*
         Retrieve DoubleEntry with the `repoID` as the primary key.
         */
        return self.realm.object(ofType: DoubleEntry.self, forPrimaryKey: repoID)
    }

    public func getImageEntry(repoID: String) -> ImageEntry? {
        /*
         Retrieve ImageEntry with the `repoID` as the primary key.
         */
        return self.realm.object(ofType: ImageEntry.self, forPrimaryKey: repoID)
    }
    
    public func getMetadataEntry(repoID: String) -> MetadataEntry? {
        return self.realm.object(ofType: MetadataEntry.self, forPrimaryKey: repoID)
    }

    public func clear() throws {
        /*
         Clear the Realm DB of all objects.
         */
        do {
            try realm.write {
                self.realm.deleteAll()
            }
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmClear)
        }
        
    }
}
