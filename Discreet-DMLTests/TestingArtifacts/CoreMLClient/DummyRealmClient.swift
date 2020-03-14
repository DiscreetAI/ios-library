//
//  DummyRealmClient.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/31/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import Discreet_DML

class DummyImageRealmClient: RealmClient {
    /*
     Dummy class for simulating image data stored in Realm.
     */

    override func getImageEntry(datasetID: String) -> ImageEntry? {
        return Optional(ImageEntry(repoID: self.repoID, datasetID: datasetID, images: realImages, labels: realLabels))
    }

    override func getDataEntryType(datasetID: String) -> DataType? {
        return DataType.IMAGE
    }
}

class DummyTextRealmClient: RealmClient {
    /*
     Dummy class for simulating text data stored in Realm.
     */
    
    
    override func getTextEntry(datasetID: String) -> TextEntry? {
        return Optional(TextEntry(repoID: self.repoID, datasetID: datasetID, encodings: realEncodings, labels: realEncodingLabels))
    }
    
    override func getDataEntryType(datasetID: String) -> DataType? {
        return DataType.TEXT
    }
}
