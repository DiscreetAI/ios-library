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
    var realm: Realm
    
    /// The repo ID corresponding to the registered application.
    var repoID: String
    
    var metadataEntry: MetadataEntry!

    /**
     Initialize the Realm Client.
     
     - Throws: `DMLError` if an error occurred during Realm setup.
     */
    init(repoID: String) throws {
        do {
            self.realm = try Realm()
            
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmSetup)
        }
        
        self.repoID = repoID
        try self.setUpMetadataEntry()
        try self.setUpSampleDatasets()
    }
    
    /**
     Add the encodings and labels under the given `datasetID`. Create a `MetadataEntry` and `TextEntry` if they don't exist and set the encodings/labels to the `TextEntry`
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
        - encodings: The encoded text data, which is an array of text datapoint, each of which consists of a 1D array of integer encodings.
        - labels: The labels for each of the text datapoints.
     
     - Throws: `DMLError` if an error occurred while writing to Realm.
     */
    func addTextData(datasetID: String, encodings: [[Int]], labels: [Int]) throws {
        do {
            try self.realm.write {
                if let textEntry = getTextEntry(datasetID: datasetID) {
                    textEntry.addEncodings(encodings: encodings, labels: labels)
                } else {
                    let textEntry = TextEntry(repoID: self.repoID, datasetID: datasetID, encodings: encodings, labels: labels)
                    self.metadataEntry.addDataEntry(dataEntry: textEntry)
                    self.realm.add(textEntry)
                }
            }
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmWrite)
        }
    }

    /**
     Add the images and labels under the given `datasetID`. Create a `MetadataEntry` and `ImageEntry` if they don't exist and set the images/labels to the `ImageEntry`
    
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
        - images: The 1D array of image paths referring to images stored in the application's documents directory.
        - labels: The labels for each of the images at the image paths.
    
     - Throws: `DMLError` if an error occurred while writing to Realm.
    */
    func addImageData(datasetID: String, images: [String], labels: [String]) throws {
        do {
            try self.realm.write {
                if let imageEntry = getImageEntry(datasetID: datasetID) {
                    imageEntry.addImages(images: images, labels: labels)
                } else {
                    let imageEntry = ImageEntry(repoID: self.repoID, datasetID: datasetID, images: images, labels: labels)
                    self.metadataEntry.addDataEntry(dataEntry: imageEntry)
                    self.realm.add(imageEntry)
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
        - datasetID: The dataset ID corresponding to the desired dataset.
        - image: The image path to remove from the stored data.
    
     - Throws: `DMLError` if the image path does not exist.
    */
    func removeImageDatapoint(datasetID: String, image: String) throws {
        if let imageEntry = getImageEntry(datasetID: datasetID) {
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
        - datasetID: The dataset ID corresponding to the desired dataset.
        - index: The index corresponding to the image path to be removed from the stored data.
     
     - Throws: `DMLError` if the provided index is invalid..
    */
    func removeImageDatapoint(datasetID: String, index: Int) throws {
        /*
         Remove image datapoint at provided index.
         */
        if let imageEntry = getImageEntry(datasetID: datasetID) {
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
     Retrieve `TextEntry` using the `datasetID` to form the primary key.
    
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
    
     - Returns: An optional containing a `TextEntry` if retrieval succeeded and `nil` otherwise.
    */
    func getTextEntry(datasetID: String) -> TextEntry? {
        return self.realm.object(ofType: TextEntry.self, forPrimaryKey: makePrimaryKey(repoID: self.repoID, datasetID: datasetID))
    }

    /**
     Retrieve `ImageEntry` using the `datasetID` to form the primary key.
    
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
    
     - Returns: An optional containing a `ImageEntry` if retrieval succeeded and `nil` otherwise.
    */
    func getImageEntry(datasetID: String) -> ImageEntry? {
        return self.realm.object(ofType: ImageEntry.self, forPrimaryKey: makePrimaryKey(repoID: self.repoID, datasetID: datasetID))
    }
    
    /**
     Retrieve the list of data entries.
     
     - Returns: The list of data entries.
     */
    func getDataEntries() -> [DataEntry] {
        return self.metadataEntry.getDataEntries()
    }
    
    /**
     Retrieve data entry using the `datasetID` to form the primary key.
    
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
    
     - Returns: An optional containing a `DataEntry` if retrieval succeeded and `nil` otherwise.
    */
    func getDataEntry(datasetID: String) -> DataEntry? {
        return self.metadataEntry.getDataEntry(datasetID: datasetID)
    }
    
    /**
     Remove the data entry with the provided `datasetID` from the list of data entries, if it exists.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
     
     - Returns: Boolean determining whether the removal was successful or not.
     */
    func removeDataEntry(datasetID: String) -> Bool {
        if self.metadataEntry.removeDataEntry(datasetID: datasetID) != nil {
            return true
        } else {
            return false
        }
    }
    
    /**
     Determine whether a data entry with the given `datasetID` exists.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
     
     - Returns: Boolean determining whether the specified data entry exists or not.
     */
    func containsDataEntry(datasetID: String) -> Bool {
        return self.getDataEntry(datasetID: datasetID) != nil
    }
    
    /**
     Determine the data type of the data entry with the given `datasetID`, if it exists.
    
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
    
     - Returns: An optional containing the data type if the specified data entry exists or `nil` otherwise.
    */
    func getDataEntryType(datasetID: String) -> DataType? {
        if let dataEntry = self.getDataEntry(datasetID: datasetID) {
            return DataType(rawValue: dataEntry.dataType)
        } else {
            return nil
        }
    }
    
    /**
     Set up the metadata entry. Called upon initialization of the Realm Client or upon clearing the entirety of Realm.
     
     - Throws: `DMLError` if an error occurred creating the metadata entry if it didn't exist already.
     */
    func setUpMetadataEntry() throws {
        var metadataEntry = self.realm.object(ofType: MetadataEntry.self, forPrimaryKey: self.repoID)
        
        if metadataEntry == nil {
            metadataEntry = MetadataEntry(repoID: self.repoID)
            do {
                try self.realm.write {
                    self.realm.add(metadataEntry!)
                }
            } catch {
                print(error.localizedDescription)
                throw DMLError.realmError(ErrorMessage.failedRealmWrite)
            }
        }
        self.metadataEntry = metadataEntry!
        print(self.metadataEntry.getDataEntries())
    }
    
    func setUpSampleDatasets() throws {
        for (imageDataset, dataFunction) in imageDataFunctions {
            if !self.containsDataEntry(datasetID: imageDataset.rawValue) {
                let (images, labels) = dataFunction()
                try self.addImageData(datasetID: imageDataset.rawValue, images: images, labels: labels)
            }
        }
        
        for (textDataset, dataFunction) in textDataFunctions {
            if !self.containsDataEntry(datasetID: textDataset.rawValue) {
                let (encodings, labels) = try dataFunction()
                try self.addTextData(datasetID: textDataset.rawValue, encodings: encodings, labels: labels)
            }
        }
    }
    
    func isDefaultDataset(datasetID: String) -> Bool {
        return isDefaultImageDataset(datasetID: datasetID) || isDefaultTextDataset(datasetID: datasetID)
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
            try self.setUpMetadataEntry()
            try self.setUpSampleDatasets()
        } catch {
            print(error.localizedDescription)
            throw DMLError.realmError(ErrorMessage.failedRealmClear)
        }
        
    }
    
    /**
     Clear the entry corresponding to the given dataset ID, if it exists.
    
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
     
     - Throws: `DMLError` if clearing failed.
    */
    func clear(datasetID: String) throws {
        do {
            try self.realm.write {
                if let type = self.getDataEntryType(datasetID: datasetID) {
                    var dataEntry: DataEntry
                    switch type {
                    case .TEXT:
                        dataEntry = getTextEntry(datasetID: datasetID)!
                        break
                    case .IMAGE:
                        dataEntry = getImageEntry(datasetID: datasetID)!
                        break
                    }
                    self.realm.delete(dataEntry)
                    if let entry = self.metadataEntry.removeDataEntry(datasetID: datasetID) {
                        self.realm.delete(entry)
                    }
                }
            }
        } catch {
            throw DMLError.userError(ErrorMessage.failedRealmClear)
        }
        
    }
}
