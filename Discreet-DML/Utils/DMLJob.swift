//
//  DMLJob.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/23/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation


class DMLJob {
    var repoID: String
    var sessionID: String
    var round: Int
    var gradients: [[[Float32]]]!
    var omega: Int!
    var modelURL: URL!

    init(repoID: String, sessionID: String, round: Int) {
        self.repoID = repoID
        self.sessionID = sessionID
        self.round = round
    }

    init(repoID: String, sessionID: String, round: Int, gradients: [[[Float32]]], omega: Int) {
        self.repoID = repoID
        self.sessionID = sessionID
        self.round = round
        self.gradients = gradients
        self.omega = omega
    }
}
