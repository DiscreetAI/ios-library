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

public var trainMessage = makeDictionaryString(keys: ["sessionID", "round", "action"], values: ["test", 1, "TRAIN"])

public var (testImages, testLabels) = makeImagePaths()

public var testModelURL = URL(string: "https://ios-discreetai.s3-us-west-1.amazonaws.com/my_model.mlmodel")! 
