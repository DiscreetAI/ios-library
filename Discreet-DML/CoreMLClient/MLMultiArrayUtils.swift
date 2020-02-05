//
//  MLMultiArray+Utils.swift
//  CoreMLBert
//
//  Created by Julien Chaumond on 27/06/2019.
//  Copyright © 2019 Hugging Face. All rights reserved.
//
import Foundation
import CoreML

extension MLMultiArray {
    /*
     Utils for loading data into or from MLMultiArrays
     */
    static func from(_ arr: [Double]) throws -> MLMultiArray {
        /*
         Load 1D Double Array as MLMultiArray
         */
        var shape = Array(repeating: 1, count: 1)
        shape[shape.count - 1] = arr.count
        var o: MLMultiArray
        do {
            o = try MLMultiArray(shape: shape as [NSNumber], dataType: .int32)
        } catch {
            print(error.localizedDescription)
            throw DMLError.dataError(ErrorMessage.failedDoubleData)
        }
        let ptr = UnsafeMutablePointer<Double>(OpaquePointer(o.dataPointer))
        for (i, item) in arr.enumerated() {
            ptr[i] = Double(item)
        }
        return o
    }

    static func toIntArray(_ o: MLMultiArray) -> [Int] {
        /*
         Load MLMultiArray as 1D Int Array.
         */
        var arr = Array(repeating: 0, count: o.count)
        let ptr = UnsafeMutablePointer<Int32>(OpaquePointer(o.dataPointer))
        for i in 0..<o.count {
            arr[i] = Int(ptr[i])
        }
        return arr
    }

    static func toDoubleArray(_ o: MLMultiArray) -> [Double] {
        /*
         Load MLMultiArray as 1D Double Array.
         */
        var arr: [Double] = Array(repeating: 0, count: o.count)
        let ptr = UnsafeMutablePointer<Double>(OpaquePointer(o.dataPointer))
        for i in 0..<o.count {
            arr[i] = Double(ptr[i])
        }
        return arr
    }
}
