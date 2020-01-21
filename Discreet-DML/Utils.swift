//
//  Utils.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/18/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML

public func roundArr(arr: [Double], places: Int) -> [Double] {
    /*
     Util method to round numbers in an array to `places` decimal places.
     */
    func roundNum(num: Double) -> Double {
        let multiple: Double = pow(10, Double(places))
        return round(num * multiple) / multiple
    }
    return arr.map(roundNum)
}
