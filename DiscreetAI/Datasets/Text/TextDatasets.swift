///
///  TextDatasets.swift
///  DiscreetAI
///
///  Created by Neelesh on 3/23/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation


/**
 Enum detailing the various default image datasets in the library.
*/
enum TextDatasets: String {
    /// A sample of `shakespeare.txt`
    case SHAKESPEARE = "shakespeare-sample"
}

/// The dictionary mapping text datasets to their appropriate data functions.
let textDataFunctions = [TextDatasets.SHAKESPEARE: getShakespeareData]

/**
 Helper function to determine whether the provided dataset ID corresponds to a default text dataset.

 - Parameters:
    - datasetID: The dataset ID corresponding to the desired dataset.

 - Returns: A boolean dictating whether the provided dataset ID corresponds to a default text dataset.
*/
func isDefaultTextDataset(datasetID: String) -> Bool {
    return TextDatasets(rawValue: datasetID) != nil
}

/**
 Data function to get the encodings and labels  of the `shakespeare.txt` sample.

 - Throws: `DMLError` if an error occurred while parsing the vocab list contained in the `encoder.json`.
 
 - Returns: Tuple corresponding to the sample data's encodings and labels.
*/
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

/**
 Helper function to encode the provided text and form the n-grams.
 
 - Parameters:
    - encoder: The encoder used to encode the dataset.
    - text: The text to encode.
    - n: The value of `n`. In the n-gram. In other words, each text datapoint will consist of the first n - 1 words, while the nth word is the label.
 
 - Returns: Tuple corresponding to the text's encodings and labels.
 */
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
