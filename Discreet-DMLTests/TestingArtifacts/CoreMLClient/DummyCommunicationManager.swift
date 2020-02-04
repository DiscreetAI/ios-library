//
//  DummyCommunicationManager.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/31/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import Discreet_DML

public class DummyCommunicationManager: CommunicationManager {
    /*
     Dummy Communication Manager to simulate communication and set the `success` variable for the training test to pass.
     */
    var success = false
    
    convenience init(coreMLClient: CoreMLClient) {
        self.init(coreMLClient: coreMLClient, repoID: testRepo)
    }
    
    override public func handleTrainingComplete(job: DMLJob) -> String {
        self.success = true
        return ""
    }
}
