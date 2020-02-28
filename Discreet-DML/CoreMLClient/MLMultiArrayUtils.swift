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
    static func from(_ arr: [Int]) -> MLMultiArray {
        /*
        Load 1D Int Array as MLMultiArray
        */
        var shape = Array(repeating: 1, count: 1)
        shape[shape.count - 1] = arr.count
        let o = try! MLMultiArray(shape: shape as [NSNumber], dataType: .int32)
        let ptr = UnsafeMutablePointer<Int32>(OpaquePointer(o.dataPointer))
        for (i, item) in arr.enumerated() {
            ptr[i] = Int32(item)
        }
        return o
    }
    
    static func from(_ arr: [Int], dims: Int) -> MLMultiArray {
        /*
        Load 1D Int Array as MLMultiArray
        */
        var shape = Array(repeating: 1, count: dims)
        shape[shape.count - 1] = arr.count
        let o = try! MLMultiArray(shape: shape as [NSNumber], dataType: .int32)
        let ptr = UnsafeMutablePointer<Int32>(OpaquePointer(o.dataPointer))
        for (i, item) in arr.enumerated() {
            ptr[i] = Int32(item)
        }
        return o
    }
    
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
    
    /**
      Returns a new MLMultiArray with the specified dimensions.
      - Note: This does not copy the data but uses a pointer into the original
        multi-array's memory. The caller is responsible for keeping the original
        object alive, for example using `withExtendedLifetime(originalArray) {...}`
    */
    @nonobjc public func reshape(to dimensions: [Int]) throws -> MLMultiArray {
      let newCount = dimensions.reduce(1, *)
      precondition(newCount == count, "Cannot reshape \(shape) to \(dimensions)")

      var newStrides = [Int](repeating: 0, count: dimensions.count)
      newStrides[dimensions.count - 1] = 1
      for i in stride(from: dimensions.count - 1, to: 0, by: -1) {
        newStrides[i - 1] = newStrides[i] * dimensions[i]
      }

      let newShape_ = dimensions.map { NSNumber(value: $0) }
      let newStrides_ = newStrides.map { NSNumber(value: $0) }

      return try MLMultiArray(dataPointer: self.dataPointer,
                              shape: newShape_,
                              dataType: self.dataType,
                              strides: newStrides_)
    }
}
