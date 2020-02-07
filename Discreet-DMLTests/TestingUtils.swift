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

public var testGradients: [[[Float32]]] = [[[1]]]

public var testOmega = 1

public var registrationMessage = try! makeDictionaryString(keys: ["node_type", "type"], values: [libraryName, registerName])

public var trainMessage = try! makeDictionaryString(keys: ["sessionID", "round", "action"], values: [testSession, testRound, trainName])

public var resultsMessage = try! makeDictionaryString(keys: ["gradients", "omega"], values: [testGradients, testRound])

public var updateMessage = try! makeDictionaryString(keys: ["type", "round", "session_id", "results"], values: [newUpdateName, testRound, testSession, resultsMessage])

public var (testImages, testLabels) = makeImagePaths()

public var testModelURL = URL(string: "https://ios-discreetai.s3-us-west-1.amazonaws.com/my_model.mlmodel")! 

public var simpleGradients: [[[Float32]]] = [[[-13.81011, -133.04008, -150.22589, -13.192558], [0, 0, 0, 0, 0, 0, 0, 0]]]
public var complexGradients: [[[Float32]]] = [
    [[95.57994842529297, -98.76066589355469, 148.50088500976562, -126.80604553222656], [0, 0, 0, 0, 0, 0, 0, 0]],
    [[31.69979476928711, 89.48539733886719, -114.56241607666016, 167.16433715820312], [0, 0, 0, 0, 0, 0, 0, 0]],
    [[157.56167602539062, -85.74986267089844, 213.60821533203125, -7.016921043395996], [0, 0, 0, 0, 0, 0, 0, 0]],
    [[167.75433349609375, 154.42352294921875, 16.086214065551758, -79.71075439453125], [0, 0, 0, 0, 0, 0, 0, 0]],
    [[79.56541442871094, -84.7736587524414, 48.14379119873047, 28.75021743774414], [0, 0, 0, 0, 0, 0, 0, 0]]
]



