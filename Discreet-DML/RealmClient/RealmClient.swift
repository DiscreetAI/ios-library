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

    public func storeTextData(repoID: String, encodings: [[Int]], labels: [String]) throws {
        /*
         Store a 2D Int array and labels under the given `repoID`.

         If data for this `repoID` already exists, simply append the given data.
         */
        do {
            try self.realm.write {
                if let EncodingEntry = getTextEntry(repoID: repoID) {
                    EncodingEntry.addData(encodings: encodings, labels: labels)
                } else {
                    self.realm.add(MetadataEntry(repoID: repoID, dataType: DataType.TEXT))
                    self.realm.add(EncodingEntry(repoID: repoID, encodings: encodings, labels: labels))
                }
            }
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmWrite)
        }
    }

    public func storeImageData(repoID: String, images: [String], labels: [String]) throws {
        /*
         Store a 1D String array of image paths under the given `repoID`.

         If data for this `repoID` already exists, simply append the given data.
         */
        do {
            try self.realm.write {
                if let imageEntry = getImageEntry(repoID: repoID) {
                    imageEntry.addImages(images: images, labels: labels)
                } else {
                    self.realm.add(MetadataEntry(repoID: repoID, dataType: DataType.IMAGE))
                    self.realm.add(ImageEntry(repoID: repoID, images: images, labels: labels))
                }
            }
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmWrite)
        }
    }
    
    public func removeImageDatapoint(repoID: String, image: String) throws {
        /*
         Remove image datapoint with provided image path.
         */
        do {
            try self.realm.write {
                if let imageEntry = getImageEntry(repoID: repoID) {
                    var (images, labels) = imageEntry.getData()
                    
                    for i in 0...images.count {
                        if images[i] == image {
                            images.remove(at: i)
                            labels.remove(at: i)
                            imageEntry.setData(images: images, labels: labels)
                            return
                        }
                    }
                } else {
                    throw DMLError.realmError(ErrorMessage.failedRealmRead)
                }
                
                
            }
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmWrite)
        }
    }
    
    public func removeImageDatapoint(repoID: String, index: Int) throws {
        /*
         Remove image datapoint at provided index.
         */
        do {
            try self.realm.write {
                if let imageEntry = getImageEntry(repoID: repoID) {
                    var (images, labels) = imageEntry.getData()
                    print("Images", images)
                    print("Labels", labels)
                    print("Index", index)
                    images.remove(at: index)
                    labels.remove(at: index)
                    imageEntry.setData(images: images, labels: labels)
                } else {
                    throw DMLError.realmError(ErrorMessage.failedRealmRead)
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

    public func getTextEntry(repoID: String) -> EncodingEntry? {
        /*
         Retrieve TextEntry with the `repoID` as the primary key.
         */
        return self.realm.object(ofType: EncodingEntry.self, forPrimaryKey: repoID)
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
