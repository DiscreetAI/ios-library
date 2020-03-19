//
//  TestingUtils.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/20/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import RealmSwift
@testable import DiscreetAI

var testingUtilsPath = URL(fileURLWithPath: #file).deletingLastPathComponent().path + "/"

var testWebSocketURL = URL(string: "ws://localhost:8999")!

var testRepo = "testRepo"

var testDataset = "testDataset"

var testRemoteRepo = "49315aef7422d8a2a601f9d1bc88c907"

var testSession = "testSession"

var testRound = 1

var testGradients: [[Float32]] = [[1]]

var testOmega = 1

var registrationMessage = try! makeDictionaryString(keys: ["node_type", "type"], values: [libraryName, registerName])

var trainMessage = try! makeDictionaryString(keys: ["dataset_id", "session_id", "round", "action"], values: [testDataset, testSession, testRound, trainName])

var resultsMessage = try! makeDictionaryString(keys: ["gradients", "omega"], values: [testGradients, testRound])

var updateMessage = try! makeDictionaryString(keys: ["type", "round", "session_id", "results"], values: [newUpdateName, testRound, testSession, resultsMessage])

var testImages = ["path1", "path2"]

var testEncodings = [[1, 2], [3, 4]]

var testLabels = ["small", "large"]

var testEncodingLabels = [0, 6]

var testText = "and the quick brown fox jumped over lazy dog"

var (realImages, realLabels) = makeImagePaths()

var testModelURL = URL(string: "https://ios-discreetai.s3-us-west-1.amazonaws.com/my_model.mlmodel")!

var testImageModelURL = URL(fileURLWithPath: testingUtilsPath + "CoreMLClient/my_model.mlmodel")

var testTextModelURL = URL(fileURLWithPath: testingUtilsPath + "CoreMLClient/neural_ngram_updatable.mlmodel")

var simpleGradients: [[Float32]] = [[-13.81011, -133.04008, -150.22589, -13.192558], [0, 0, 0, 0, 0, 0, 0, 0]]
var complexGradients: [[Float32]] = [
    [95.57994842529297, -98.76066589355469, 148.50088500976562, -126.80604553222656], [0, 0, 0, 0, 0, 0, 0, 0],
    [31.69979476928711, 89.48539733886719, -114.56241607666016, 167.16433715820312], [0, 0, 0, 0, 0, 0, 0, 0],
    [157.56167602539062, -85.74986267089844, 213.60821533203125, -7.016921043395996], [0, 0, 0, 0, 0, 0, 0, 0],
    [167.75433349609375, 154.42352294921875, 16.086214065551758, -79.71075439453125], [0, 0, 0, 0, 0, 0, 0, 0],
    [79.56541442871094, -84.7736587524414, 48.14379119873047, 28.75021743774414], [0, 0, 0, 0, 0, 0, 0, 0]
]

func roundArr(arr: [Float32], places: Int) -> [Float32] {
    /*
     Util method to round numbers in an array to `places` decimal places.
     */
    func roundNum(num: Float32) -> Float32 {
        let multiple: Float32 = pow(10, Float32(places))
        return round(num * multiple) / multiple
    }
    return arr.map(roundNum)
}

func hardReset() {
    try! FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
}



