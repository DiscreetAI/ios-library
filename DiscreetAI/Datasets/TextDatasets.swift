//
//  TextDatasets.swift
//  DiscreetAI
//
//  Created by Neelesh on 3/23/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation


enum TextDatasets: String {
    case SHAKESPEARE = "shakespeare-sample"
}

let textDataFunctions = [TextDatasets.SHAKESPEARE: getShakespeareData]

func isDefaultTextDataset(datasetID: String) -> Bool {
    return TextDatasets(rawValue: datasetID) != nil
}

func getShakespeareData() throws -> ([[Int]], [Int]) {
    let shakespearePath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("shakespeare/shakespeare.txt")

    var text: String
    do {
        text = try String(contentsOf: shakespearePath, encoding: .utf8)
    } catch {
        throw DMLError.dataError(ErrorMessage.error)
    }
    
    let encoderPath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("encoder.json").path
    let encoderDict = try parseJSON(stringOrFile: encoderPath, isString: false) as! NSDictionary
    let keys = encoderDict.allKeys as! [String]
    let encoder = BasicEncoder(vocabList: keys)
    
    return makeEncodedNgrams(encoder: encoder, text: text, n: 3)
}

func makeEncodedNgrams(encoder: BasicEncoder, text: String, n: Int) -> ([[Int]], [Int]) {
    let encodings = encoder.encode(text: text)
    var ngrams = [[Int]]()
    var labels = [Int]()
    for i in 0..<(encodings.count - (n - 1)) {
        ngrams.append(Array(encodings[i..<i + n - 1]))
        labels.append(encodings[i + n - 1])
    }
    return (ngrams, labels)
}
