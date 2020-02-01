//
//  DummyRealmClient.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/31/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import Discreet_DML

public class DummyRealmClient: RealmClient {
    /*
     Dummy class for simulating data stored in Realm.
     */
    override init() {
        
    }
    
    override public func getImageEntry(repoID: String) -> ImageEntry? {
        let (images, labels) = makeImagePaths()
        return Optional(ImageEntry(repoID: repoID, images: images, labels: labels))
    }
    
    override public func getMetadataEntry(repoID: String) -> MetadataEntry? {
        return Optional(MetadataEntry(repoID: repoID, dataType: DataType.IMAGE))
    }
}
