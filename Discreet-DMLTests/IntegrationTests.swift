//
//  IntegrationTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 2/3/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import XCTest
@testable import Discreet_DML

class IntegrationTests: XCTestCase {
    let orchestrator = Orchestrator(repoID: testRepo)
    let (images, labels) = makeImagePaths()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIntegration() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        orchestrator.storeImages(images: images, labels: labels)
        
    }
}
