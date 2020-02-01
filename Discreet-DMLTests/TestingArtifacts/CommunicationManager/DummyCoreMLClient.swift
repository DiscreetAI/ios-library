//
//  DummyCoreMLClient.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/31/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import Discreet_DML

public class DummyCoreMLClient : CoreMLClient {
    /*
     Dummy client so that dependency injection can be used during Communication Manager tests.
     */
    convenience init() {
        self.init(modelLoader: nil, realmClient: nil, weightsProcessor: nil)
    }
    
    override public func train(job: DMLJob) {}
}
