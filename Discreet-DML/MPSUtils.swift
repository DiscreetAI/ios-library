//
//  MPSUtils.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/20/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import MetalPerformanceShaders

public var device: MTLDevice = MTLCreateSystemDefaultDevice()!
public var commandQueue: MTLCommandQueue = device.makeCommandQueue()!

private func createMPSMatrix(buffer: MTLBuffer, rows: Int, cols: Int) -> MPSMatrix {
    let rowBytes = cols * MemoryLayout<Float32>.size
    let matrixDescriptor: MPSMatrixDescriptor = MPSMatrixDescriptor(rows: rows, columns: cols, rowBytes: rowBytes, dataType: MPSDataType.float32)
    return MPSMatrix(buffer: buffer, descriptor: matrixDescriptor)
}

private func createEmptyMPSMatrix(rows: Int, cols: Int) -> MPSMatrix {
    let buffer = device.makeBuffer(length: rows * cols * MemoryLayout<Float32>.size)!
    return createMPSMatrix(buffer: buffer, rows: rows, cols: cols)
}

private func createFilledMPSMatrix(bytes: [Float32], rows: Int, cols: Int) -> MPSMatrix {
    let buffer = device.makeBuffer(bytes: bytes, length: rows * cols * MemoryLayout<Float32>.size)!
    return createMPSMatrix(buffer: buffer, rows: rows, cols: cols)
}

private func createDiagonalMatrix(constant: Float32, length: Int) -> MPSMatrix {
    var arr: [[Float32]] = Array(repeating: Array(repeating: 0, count: length), count: length)
    for i in 0...length-1 {
        arr[i][i] = constant
    }
    return createFilledMPSMatrix(bytes: Array(arr.joined()), rows: length, cols: length)
}

private func createIdentityMatrix(length: Int) -> MPSMatrix {
    return createDiagonalMatrix(constant: 1, length: length)
}

private func matrixMultiplication(m1: MPSMatrix, m2: MPSMatrix, resultMatrix: MPSMatrix, alpha: Float32, beta: Float32) {
    let kernel = MPSMatrixMultiplication(device: device, transposeLeft: false, transposeRight: false, resultRows: m1.rows, resultColumns: m2.columns, interiorColumns: m1.columns, alpha: Double(alpha), beta: Double(beta))
    let commandBuffer = commandQueue.makeCommandBuffer()!
    kernel.encode(commandBuffer:commandBuffer, leftMatrix: m1, rightMatrix: m2, resultMatrix: resultMatrix)
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
}

public func createMPSVector(bytes: [Float32], count: Int) -> MPSMatrix {
    return createFilledMPSMatrix(bytes: bytes, rows: 1, cols: count)
}

public func matrixAddition(m1: MPSMatrix, m2: MPSMatrix) -> MPSMatrix {
    var identityMatrix = createIdentityMatrix(length: m1.rows)
    matrixMultiplication(m1: identityMatrix, m2: m1, resultMatrix: m2, alpha: 1, beta: 1)
    return m2
}

public func matrixSubtraction(m1: MPSMatrix, m2: MPSMatrix) -> MPSMatrix {
    return matrixAddition(m1: m1, m2: multiplyMatrixByConstant(m1: m2, constant: -1))
}

public func multiplyMatrixByConstant(m1: MPSMatrix, constant: Float32) -> MPSMatrix {
    var resultMatrix = createEmptyMPSMatrix(rows: m1.rows, cols: m1.columns)
    var constantMatrix = createMPSVector(bytes: [constant], count: 1)
    matrixMultiplication(m1: constantMatrix, m2: m1, resultMatrix: resultMatrix, alpha: 1, beta: 0)
    return resultMatrix
}

public func divideMatrixByConstant(m1: MPSMatrix, constant: Float32) -> MPSMatrix {
    return multiplyMatrixByConstant(m1: m1, constant: 1/constant)
}

public func getData(m1: MPSMatrix) -> [Float32] {
    let pointer = m1.data.contents()
    let float32Pointer = pointer.bindMemory(to: Float32.self, capacity: m1.columns)
    let float32Buffer = UnsafeBufferPointer(start: float32Pointer, count: m1.columns)
    return Array(float32Buffer)
}
