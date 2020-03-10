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
    override init(repoID: String, sessionID: String, round: Int, gradients: [[Float32]], omega: Int) {
        super.init(repoID: repoID, sessionID: sessionID, round: round)
        self.gradients = gradients
        self.omega = omega
    }
}
