//
//  RealmClient.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/27/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation
import RealmSwift

class RealmClient {
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
    
    

    func addTextData(repoID: String, encodings: [[Int]], labels: [Int]) throws {
        /*
         Store a 2D Int array and labels under the given `repoID`.

         If data for this `repoID` already exists, simply append the given data.
         */
        do {
            try self.realm.write {
                if let EncodingEntry = getTextEntry(repoID: repoID) {
                    EncodingEntry.addEncodings(encodings: encodings, labels: labels)
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

    func addImageData(repoID: String, images: [String], labels: [String]) throws {
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
    
    func removeImageDatapoint(repoID: String, image: String) throws {
        /*
         Remove image datapoint with provided image path.
         */
        if let imageEntry = getImageEntry(repoID: repoID) {
            var (images, labels) = imageEntry.getData()
            for i in 0..<images.count {
                if images[i] == image {
                    images.remove(at: i)
                    labels.remove(at: i)
                    do {
                        try self.realm.write {
                            imageEntry.setData(images: images, labels: labels)
                        }
                    } catch {
                        print(error.localizedDescription)
                        throw DMLError.realmError(ErrorMessage.failedRealmWrite)
                    }
                    return
                }
            }
            print("Failed to find image path:", image)
            throw DMLError.userError(ErrorMessage.invalidImagePath)
        } else {
            throw DMLError.userError(ErrorMessage.failedRealmRead)
        }
        
    }
    
    func removeImageDatapoint(repoID: String, index: Int) throws {
        /*
         Remove image datapoint at provided index.
         */
        if let imageEntry = getImageEntry(repoID: repoID) {
            var (images, labels) = imageEntry.getData()
            if index < 0  || index > images.count {
                throw DMLError.userError(ErrorMessage.invalidDatapointIndex)
            }
            images.remove(at: index)
            labels.remove(at: index)
            do {
                try self.realm.write {
                    imageEntry.setData(images: images, labels: labels)
                }
            } catch {
                print(error.localizedDescription)
                throw DMLError.realmError(ErrorMessage.failedRealmWrite)
            }
        } else {
            throw DMLError.realmError(ErrorMessage.failedRealmRead)
        }
        
    }

    func getDataEntry(repoID: String) -> DataEntry? {
        /*
         Retrieve data entry with the `repoID` as the primary key.
         */
        return self.realm.object(ofType: DataEntry.self, forPrimaryKey: repoID)
    }

    func getTextEntry(repoID: String) -> EncodingEntry? {
        /*
         Retrieve TextEntry with the `repoID` as the primary key.
         */
        return self.realm.object(ofType: EncodingEntry.self, forPrimaryKey: repoID)
    }

    func getImageEntry(repoID: String) -> ImageEntry? {
        /*
         Retrieve ImageEntry with the `repoID` as the primary key.
         */
        return self.realm.object(ofType: ImageEntry.self, forPrimaryKey: repoID)
    }
    
    func getMetadataEntry(repoID: String) -> MetadataEntry? {
        /*
         Retrieve MetadataEntry with the `repoID` as the primary key.
         */
        return self.realm.object(ofType: MetadataEntry.self, forPrimaryKey: repoID)
    }
    
    func getDatapointCount(repoID: String) throws -> Int {
        /*
         Get the datapoint count for the DataEntry corresponding to the given repo ID.
         */
        if let metaDataEntry = self.getMetadataEntry(repoID: repoID) {
            let type = DataType(rawValue: metaDataEntry.dataType)
            switch type {
            case .TEXT:
                return self.getTextEntry(repoID: repoID)!.getDatapointCount()
            case .IMAGE:
                return self.getImageEntry(repoID: repoID)!.getDatapointCount()
            default:
                throw DMLError.realmError(ErrorMessage.error)
            }
        } else {
            throw DMLError.userError(ErrorMessage.failedRealmRead)
        }
    }

    func clear() throws {
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
    
    func clear(repoID: String) throws {
        /*
         Clear the entries corresponding to the given repo ID, if they exist.
         */
        if let metaDataEntry = self.getMetadataEntry(repoID: repoID) {
            let type = DataType(rawValue: metaDataEntry.dataType)
            var entry: DataEntry
            switch type {
            case .TEXT:
                entry = self.getTextEntry(repoID: repoID)!
                break
            case .IMAGE:
                entry = self.getImageEntry(repoID: repoID)!
            default:
                throw DMLError.realmError(ErrorMessage.error)
            }
            do {
                try self.realm.write {
                    realm.delete(entry)
                    realm.delete(metaDataEntry)
                }
            } catch {
                throw DMLError.realmError(ErrorMessage.failedRealmWrite)
            }
        } else {
            print("No entries found with the provided repo ID!")
        }
    }
}
