//
//  TestingUtils.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/20/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import Discreet_DML

public var testingUtilsPath = URL(fileURLWithPath: #file).deletingLastPathComponent().path + "/TestingArtifacts/"

public var testRepo = "testRepo"

public var testSession = "testSession"

public var testRound = 1

public var registerName = "REGISTER"

public var libraryName = "LIBRARY"

public var registrationMessage = try! makeDictionaryString(keys: ["node_type", "type"], values: ["library", "REGISTER"])

public var trainMessage = try! makeDictionaryString(keys: ["sessionID", "round", "action"], values: ["test", 1, "TRAIN"])

public var resultsMessage = try! makeDictionaryString(keys: ["gradients", "omega"], values: [[[1]], 1])

public var updateMessage = try! makeDictionaryString(keys: ["type", "round", "session_id", "results"], values: ["NEW_UPDATE", 1, "test", resultsMessage])

public var (testImages, testLabels) = makeImagePaths()

public var testModelURL = URL(string: "https://ios-discreetai.s3-us-west-1.amazonaws.com/my_model.mlmodel")! 
