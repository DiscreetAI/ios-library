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
