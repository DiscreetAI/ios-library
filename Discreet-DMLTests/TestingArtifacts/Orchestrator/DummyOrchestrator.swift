//
//  DummyOrchestrator.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 2/3/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import XCTest
@testable import Discreet_DML

class DummyOrchestrator: Orchestrator {
    override init(repoID: String, connect: Bool = true) throws {
        try super.init(repoID: repoID, connect: false)
        self.communicationManager = DummyCommunicationManager(coreMLClient: self.coreMLClient)
        self.coreMLClient.weightsProcessor = WeightsProcessor(mpsHandler: nil)
        self.coreMLClient.modelLoader = ModelLoader(downloadModelURL: testModelURL)
        self.coreMLClient.configure(communicationManager: self.communicationManager)
    }
}
