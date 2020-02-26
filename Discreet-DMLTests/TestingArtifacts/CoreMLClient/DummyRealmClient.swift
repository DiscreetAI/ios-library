//
//  DummyRealmClient.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/31/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import Discreet_DML

class DummyRealmClient: RealmClient {
    /*
     Dummy class for simulating data stored in Realm.
     */
    override init() throws {

    }

    override func getImageEntry(repoID: String) -> ImageEntry? {
        return Optional(ImageEntry(repoID: repoID, images: realImages, labels: realLabels))
    }

    override func getMetadataEntry(repoID: String) -> MetadataEntry? {
        return Optional(MetadataEntry(repoID: repoID, dataType: DataType.IMAGE))
    }
}
