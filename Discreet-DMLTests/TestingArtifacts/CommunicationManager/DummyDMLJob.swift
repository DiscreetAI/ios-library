//
//  DummyDMLJob.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 3/10/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import Discreet_DML

class DummyDMLJob: DMLJob {
    override init(datasetID: String, sessionID: String, round: Int) {
        super.init(datasetID: datasetID, sessionID: sessionID, round: round)
        self.gradients = testGradients
        self.omega = testOmega
    }
}
