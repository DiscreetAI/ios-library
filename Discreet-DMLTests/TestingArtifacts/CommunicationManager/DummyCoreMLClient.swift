//
//  DummyCoreMLClient.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/23/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
@testable import Discreet_DML

class DummyCoreMLClient : CoreMLClient {
    /*
     Dummy client so that dependency injection can be used during Communication Manager tests.
     */
    
    init() {
        super.init(modelURL: URL(string: "dummy")!)
    }
    
    override func train(job: DMLJob, callback: (DMLJob) -> (String)) {
        
    }
}
