///
///  RealmClient.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/27/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import RealmSwift


/**
 Client to interact with Realm.
*/
class RealmClient {
    
    /// An instance of Realm for storing/retrieving objects.
    var realm: Realm!

    /**
     Initialize the Realm Client.
     
     - Throws: `DMLError` if an error occurred during Realm setup.
     */
    init() throws {
        do {
            self.realm = try Realm()
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmSetup)
        }
    }
    
    /**
     Add the encodings and labels under the given `repoID`. Create a `MetadataEntry` and `TextEntry` if they don't exist and set the encodings/labels to the `TextEntry`
     
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
        - encodings: The encoded text data, which is an array of text datapoint, each of which consists of a 1D array of integer encodings.
        - labels: The labels for each of the text datapoints.
     
     - Throws: `DMLError` if an error occurred while writing to Realm.
     */
    func addTextData(repoID: String, encodings: [[Int]], labels: [Int]) throws {
        do {
            try self.realm.write {
                if let TextEntry = getTextEntry(repoID: repoID) {
                    TextEntry.addEncodings(encodings: encodings, labels: labels)
                } else {
                    self.realm.add(MetadataEntry(repoID: repoID, dataType: DataType.TEXT))
                    self.realm.add(TextEntry(repoID: repoID, encodings: encodings, labels: labels))
                }
            }
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmWrite)
        }
    }

    /**
     Add the images and labels under the given `repoID`. Create a `MetadataEntry` and `ImageEntry` if they don't exist and set the images/labels to the `ImageEntry`
    
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
        - images: The 1D array of image paths referring to images stored in the application.
        - labels: The labels for each of the images at the image paths.
    
     - Throws: `DMLError` if an error occurred while writing to Realm.
    */
    func addImageData(repoID: String, images: [String], labels: [String]) throws {
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
    
    /**
     Remove an image path (and its corresponding label) from the data stored for the entry corresponding to the given repo ID.
    
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
        - image: The image path to remove from the stored data.
    
     - Throws: `DMLError` if the image path does not exist.
    */
    func removeImageDatapoint(repoID: String, image: String) throws {
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
    
    /**
     Remove the image path at the given index (and its corresponding label) from the data stored for the entry corresponding to the given repo ID.
    
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
        - image: The image path to remove from the stored data.
     
     - Throws: `DMLError` if the provided index is invalid..
    */
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

    /**
     Retrieve data entry with the `repoID` as the primary key.
     
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
     
     - Returns: An optional containing a `DataEntry` if retrieval succeeded and `nil` otherwise.
     */
    func getDataEntry(repoID: String) -> DataEntry? {
        return self.realm.object(ofType: DataEntry.self, forPrimaryKey: repoID)
    }

    /**
     Retrieve `TextEntry` with the `repoID` as the primary key.
    
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
    
     - Returns: An optional containing a `TextEntry` if retrieval succeeded and `nil` otherwise.
    */
    func getTextEntry(repoID: String) -> TextEntry? {
        /*
         
         */
        return self.realm.object(ofType: TextEntry.self, forPrimaryKey: repoID)
    }

    /**
     Retrieve `ImageEntry` with the `repoID` as the primary key.
    
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
    
     - Returns: An optional containing a `ImageEntry` if retrieval succeeded and `nil` otherwise.
    */
    func getImageEntry(repoID: String) -> ImageEntry? {
        return self.realm.object(ofType: ImageEntry.self, forPrimaryKey: repoID)
    }
    
    /**
     Retrieve `MetadataEntry` with the `repoID` as the primary key.
    
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
    
     - Returns: An optional containing a `MetadataEntry` if retrieval succeeded and `nil` otherwise.
    */
    func getMetadataEntry(repoID: String) -> MetadataEntry? {
        return self.realm.object(ofType: MetadataEntry.self, forPrimaryKey: repoID)
    }
    
    /**
     Get the datapoint count for the `DataEntry` corresponding to the given repo ID.
    
     - Parameters:
       - repoID: The repo ID corresponding to the dataset of this library.
    
     - Returns: The datapoint count.
    */
    func getDatapointCount(repoID: String) throws -> Int {
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

    /**
     Clear the Realm DB of all objects.
     
     - Throws: `DMLError` if clearing failed.
     */
    func clear() throws {
        do {
            try realm.write {
                self.realm.deleteAll()
            }
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmClear)
        }
        
    }
    
    /**
     Clear the entries corresponding to the given repo ID, if they exist.
    
     - Throws: `DMLError` if clearing failed.
    */
    func clear(repoID: String) throws {
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
