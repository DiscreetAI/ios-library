//
//  Utils.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/18/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML

var registerName = "REGISTER"

var libraryName = "LIBRARY"

var trainName = "TRAIN"

var newUpdateName = "NEW_UPDATE"

var stopName = "STOP"

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


func jsonify(object: Any) throws -> String {
    /*
     Turn an object (Dictionary, Int, etc.) into a String
     
     TODO: Do proper error handling here.
     */
    var data: Data
    do {
        data = try JSONSerialization.data(withJSONObject: object, options: [])
    } catch {
        print(error.localizedDescription)
        throw DMLError.communicationManagerError(ErrorMessage.failedJsonify)
    }
    return String(data: data, encoding: String.Encoding.utf8)!
}

func parseJSON(stringOrFile: String, isString: Bool) throws -> Any {
    /*
     Turn a String into JSON.
     
     TODO: Do proper error handling here.
     */
    var data: Data
    do {
        data = isString ? Data(stringOrFile.utf8) : try Data(contentsOf: URL(fileURLWithPath: stringOrFile), options: .mappedIfSafe)
        return try JSONSerialization.jsonObject(with: data)
    } catch {
        print(error.localizedDescription)
        throw DMLError.communicationManagerError(ErrorMessage.failedParse)
    }
    
}

func makeDictionaryString(keys: [String], values: [Any]) throws -> String {
    /*
     Make a Dictionary with the given keys and values, and then turn it into a String.
     */
    var dict: [String: Any] = [:]
    for (key, value) in zip(keys, values) {
        dict[key] = value
    }
    return try jsonify(object: dict)
}

func makeWebSocketURL(repoID: String) -> URL {
    /*
     Make URL for cloud WebSocket given the repo ID.
     */
    return URL(string: "ws://\(repoID).au4c4pd2ch.us-west-1.elasticbeanstalk.com")!
}

func makeCloudNodeURL(repoID: String) -> URL {
    /*
    Make URL for model hosted on cloud given the repo ID.
    */
     return URL(string: "http://\(repoID).au4c4pd2ch.us-west-1.elasticbeanstalk.com")!
}

func makeModelDownloadURL(repoID: String) -> URL {
    return makeCloudNodeURL(repoID: repoID).appendingPathComponent("/my_model.mlmodel")
}

func makeWeightsPath(modelURL: URL) -> String {
    /*
     Make path to the weights given the URL to the compiled model.
     */
    return modelURL.path + "/model.espresso.weights"
}
