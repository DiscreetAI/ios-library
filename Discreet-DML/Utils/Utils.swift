//
//  Utils.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/18/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML

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


public func jsonify(object: Any) -> String {
    /*
     Turn an object (Dictionary, Int, etc.) into a String
     
     TODO: Do proper error handling here.
     */
    let data: Data = try! JSONSerialization.data(withJSONObject: object, options: [])
    return String(data: data, encoding: String.Encoding.utf8)!
}

public func parseJSON(jsonString: String) -> NSDictionary {
    /*
     Turn a String into a Dictionary object
     
     TODO: Do proper error handling here.
     */
    let data = Data(jsonString.utf8)
    let json = try! JSONSerialization.jsonObject(with: data) as! NSDictionary
    return json
}

public func makeDictionaryString(keys: [String], values: [Any]) -> String {
    /*
     Make a Dictionary with the given keys and values, and then turn it into a String.
     */
    var dict: [String: Any] = [:]
    for (key, value) in zip(keys, values) {
        dict[key] = value
    }
    return jsonify(object: dict)
}
