//
//  Utils.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/18/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML

public var registerName = "REGISTER"

public var libraryName = "LIBRARY"

public var trainName = "TRAIN"

public var newUpdateName = "NEW_UPDATE"

public var stopName = "STOP"

public func roundArr(arr: [Float32], places: Int) -> [Float32] {
    /*
     Util method to round numbers in an array to `places` decimal places.
     */
    func roundNum(num: Float32) -> Float32 {
        let multiple: Float32 = pow(10, Float32(places))
        return round(num * multiple) / multiple
    }
    return arr.map(roundNum)
}


public func jsonify(object: Any) throws -> String {
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

public func parseJSON(stringOrFile: String, isString: Bool) throws -> Any {
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

public func makeDictionaryString(keys: [String], values: [Any]) throws -> String {
    /*
     Make a Dictionary with the given keys and values, and then turn it into a String.
     */
    var dict: [String: Any] = [:]
    for (key, value) in zip(keys, values) {
        dict[key] = value
    }
    return try jsonify(object: dict)
}

public func makeWebSocketURL(repoID: String) -> URL {
    /*
     Make URL for cloud WebSocket given the repo ID.
     */
    return URL(string: "ws://\(repoID).au4c4pd2ch.us-west-1.elasticbeanstalk.com")!
}

public func makeModelDownloadURL(repoID: String) -> URL {
    /*
    Make URL for model hosted on cloud given the repo ID.
    */
     return URL(string: "http://\(repoID).au4c4pd2ch.us-west-1.elasticbeanstalk.com/ios/model.mlmodel")!
}

public func makeWeightsPath(modelURL: URL) -> String {
    /*
     Make path to the weights given the URL to the compiled model.
     */
    return modelURL.path + "/model.espresso.weights"
}
