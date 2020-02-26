//
//  MPSUtils.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/20/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import MetalPerformanceShaders

class MPSHandler {
    /*
     Handling for dealing with all operations with MPS
     */
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!

    init() throws {
        /*
         Set up the device and command queue.
         */
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        
        #if targetEnvironment(simulator)
        print("Cannot use Metal Performance Shaders, currently in a simulator.")
        throw DMLError.mpsError(ErrorMessage.badDevice)
        #else
        print("Using Metal Performance Shaders.")
        #endif
    }

    private func createMPSMatrix(buffer: MTLBuffer, rows: Int, cols: Int) -> MPSMatrix {
        /*
         Create a MPS Matrix (must be 2D) that is `rows` x `cols` given the buffer of data.
         */
        let rowBytes = cols * MemoryLayout<Float32>.size
        let matrixDescriptor: MPSMatrixDescriptor = MPSMatrixDescriptor(rows: rows, columns: cols, rowBytes: rowBytes, dataType: MPSDataType.float32)
        return MPSMatrix(buffer: buffer, descriptor: matrixDescriptor)
    }

    private func createEmptyMPSMatrix(rows: Int, cols: Int) -> MPSMatrix {
        /*
         Create a MPS Matrix that is `rows` x `cols` with an empty buffer of data (i.e. the result matrix that will receive the result of the matrix multiplication)
         */
        let buffer = device.makeBuffer(length: rows * cols * MemoryLayout<Float32>.size)!
        return createMPSMatrix(buffer: buffer, rows: rows, cols: cols)
    }

    private func createFilledMPSMatrix(bytes: [Float32], rows: Int, cols: Int) -> MPSMatrix {
        /*
         Create a MPS Matrix that is `rows` x `cols` with the given data. The data must be 1D, and its length must be equal to the product of `rows` and `cols`.
         */
        let buffer = device.makeBuffer(bytes: bytes, length: rows * cols * MemoryLayout<Float32>.size)!
        return createMPSMatrix(buffer: buffer, rows: rows, cols: cols)
    }

    private func createDiagonalMatrix(constant: Float32, length: Int) -> MPSMatrix {
        /*
         Create a MPS Matrix that is `length` x `length` and has `constant` along its main diagonal (0s otherwise).
         */
        var arr: [[Float32]] = Array(repeating: Array(repeating: 0, count: length), count: length)
        for i in 0...length-1 {
            arr[i][i] = constant
        }
        return createFilledMPSMatrix(bytes: Array(arr.joined()), rows: length, cols: length)
    }

    private func createIdentityMatrix(length: Int) -> MPSMatrix {
        /*
        Create a MPS Matrix that is `length` x `length` and is the identity matrix.
        */
        return createDiagonalMatrix(constant: 1, length: length)
    }

    private func copyMatrix(m1: MPSMatrix) -> MPSMatrix {
        /*
         Copy the data from `m1` into a separate MPS Matrix.
         */
        let m2 = createEmptyMPSMatrix(rows: m1.rows, cols: m1.columns)
        let matrixDescriptor = MPSMatrixCopyDescriptor(sourceMatrix: m1, destinationMatrix: m2, offsets: MPSMatrixCopyOffsets())
        let kernel = MPSMatrixCopy(device: device, copyRows: m1.rows, copyColumns: m1.columns, sourcesAreTransposed: false, destinationsAreTransposed: false)
        let commandBuffer = commandQueue.makeCommandBuffer()!
        kernel.encode(commandBuffer: commandBuffer, copyDescriptor: matrixDescriptor)

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return m2
    }

    private func matrixMultiplication(m1: MPSMatrix, m2: MPSMatrix, resultMatrix: MPSMatrix, alpha: Float32, beta: Float32) {
        /*
         Matrix multiplication between `m1` and m2` where the result is put in `resultMatrix` according to the following formula:
         
         `resultMatrix` = (`alpha` * `m1` * `m2`) + (`beta` * `resultMatrix`)
         */
        let kernel = MPSMatrixMultiplication(device: device, transposeLeft: false, transposeRight: false, resultRows: m1.rows, resultColumns: m2.columns, interiorColumns: m1.columns, alpha: Double(alpha), beta: Double(beta))
        let commandBuffer = commandQueue.makeCommandBuffer()!
        kernel.encode(commandBuffer:commandBuffer, leftMatrix: m1, rightMatrix: m2, resultMatrix: resultMatrix)

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    func createMPSVector(bytes: [Float32], count: Int) -> MPSMatrix {
        /*
         Create an MPS Matrix given a 1D array of data.
         */
        return createFilledMPSMatrix(bytes: bytes, rows: 1, cols: count)
    }

    func matrixAddition(m1: MPSMatrix, m2: MPSMatrix, inplace: Bool = true) -> MPSMatrix {
        /*
         Add `m1` to `m2` and store the result in `m2`. If `inplace` is false, copy `m2` first.
         */
        var m2Result = m2
        if !inplace {
            m2Result = copyMatrix(m1: m2)
        }
        let identityMatrix = createIdentityMatrix(length: m1.rows)
        matrixMultiplication(m1: identityMatrix, m2: m1, resultMatrix: m2Result, alpha: 1, beta: 1)
        return m2
    }

    func matrixSubtraction(m1: MPSMatrix, m2: MPSMatrix) -> MPSMatrix {
        /*
         Subtract `m2` from `m1`.
         */
        return matrixAddition(m1: m1, m2: multiplyMatrixByConstant(m1: m2, constant: -1))
    }

    func multiplyMatrixByConstant(m1: MPSMatrix, constant: Float32) -> MPSMatrix {
        /*
         Multiply every entry in `m1` by `constant`.
         */
        let resultMatrix = createEmptyMPSMatrix(rows: m1.rows, cols: m1.columns)
        let constantMatrix = createMPSVector(bytes: [constant], count: 1)
        matrixMultiplication(m1: constantMatrix, m2: m1, resultMatrix: resultMatrix, alpha: 1, beta: 0)
        return resultMatrix
    }

    func divideMatrixByConstant(m1: MPSMatrix, constant: Float32) -> MPSMatrix {
        /*
         Divide every entry in `m1` by `constant`.
         */
        return multiplyMatrixByConstant(m1: m1, constant: 1/constant)
    }

    func getData(m1: MPSMatrix) -> [Float32] {
        /*
         Get the underlying array of data from an MPS Matrix.
         */
        let pointer = m1.data.contents()
        let float32Pointer = pointer.bindMemory(to: Float32.self, capacity: m1.columns)
        let float32Buffer = UnsafeBufferPointer(start: float32Pointer, count: m1.columns)
        return Array(float32Buffer)
    }
}
