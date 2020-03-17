//
//  EncoderTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 2/25/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import XCTest
@testable import DiscreetAI

class EncoderTests: XCTestCase {
    func testBasicEncoder() {
        do {
            let orchestrator = try! Orchestrator(repoID: testRepo, connectImmediately: false)
            let vocabList = testText.components(separatedBy: " ")
            let encoder = orchestrator.getBasicEncoder(vocabList: vocabList)
            let text = testText + " and jumped again"
            let encodings = encoder.encode(text: text)
            let expectedEncodings = Array(1...vocabList.count) + [1, 6, 0]
            XCTAssertEqual(expectedEncodings, encodings)
        }
    }
}
