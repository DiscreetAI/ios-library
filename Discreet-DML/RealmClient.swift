////
////  RealmClient.swift
////  Discreet-DML
////
////  Created by Neelesh on 1/27/20.
////  Copyright © 2020 DiscreetAI. All rights reserved.
////
//import Foundation
//import RealmSwift
//
//public class RealmClient {
//    /*
//     Client to interact with Realm.
//     */
//    var realm: Realm!
//
//    init() {
//        self.realm = try! Realm()
//    }
//
//    public func storeData(repoID: String, data: [[Double]]) {
//        /*
//         Store a 2D Double array under the given `repoID`.
//
//         If data for this `repoID` already exists, simply append the given data.
//         */
//
//        try! self.realm.write {
//            if let doubleEntry = getDoubleEntry(repoID: repoID) {
//                doubleEntry.addData(datapoints: data)
//            } else {
//                self.realm.add(DoubleEntry(repoID: repoID, datapoints: data))
//            }
//        }
//    }
//
//    public func storeData(repoID: String, data: [String]) {
//        /*
//         Store a 1D String array of image paths under the given `repoID`.
//
//         If data for this `repoID` already exists, simply append the given data.
//         */
//
//        try! self.realm.write {
//            if let imageEntry = getImageEntry(repoID: repoID) {
//                imageEntry.addImages(images: data)
//            } else {
//                self.realm.add(ImageEntry(repoID: repoID, images: data))
//            }
//        }
//    }
//
//    public func getDataEntry(repoID: String) -> DataEntry? {
//        /*
//         Retrieve data entry with the `repoID` as the primary key.
//         */
//        return self.realm.object(ofType: DataEntry.self, forPrimaryKey: repoID)
//    }
//
//    public func getDoubleEntry(repoID: String) -> DoubleEntry? {
//        /*
//         Retrieve DoubleEntry with the `repoID` as the primary key.
//         */
//        return self.realm.object(ofType: DoubleEntry.self, forPrimaryKey: repoID)
//    }
//
//    public func getImageEntry(repoID: String) -> ImageEntry? {
//        /*
//         Retrieve ImageEntry with the `repoID` as the primary key.
//         */
//        return self.realm.object(ofType: ImageEntry.self, forPrimaryKey: repoID)
//    }
//
//    public func clear() {
//        /*
//         Clear the Realm DB of all objects.
//         */
//        try! realm.write {
//            self.realm.deleteAll()
//        }
//    }
//}
