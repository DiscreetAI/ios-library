///
///  MPSUtils.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/20/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import MetalPerformanceShaders

/**
 Handler for dealing with all operations with MPS
*/
class MPSHandler {
    
    /// The main tool for setting up commands for the GPU.
    var device: MTLDevice!
    
    /// The main tool for executing commands on the GPU
    var commandQueue: MTLCommandQueue!

    /**
     Set up the device and command queue.
     
     - Throws: `DMLError` if the device is a simulator, as there is no GPU in a simulator.
    */
    init() throws {
        
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        
        #if targetEnvironment(simulator)
        print("Cannot use Metal Performance Shaders, currently in a simulator.")
        throw DMLError.mpsError(ErrorMessage.badDevice)
        #else
        print("Using Metal Performance Shaders.")
        #endif
    }

    /**
     Create a MPS Matrix (must be 2D) that is `rows` x `cols` given the buffer of data.
     
     - Parameters:
        - buffer: Buffer that holds the data.
        - rows: The number of rows in the data.
        - cols: The number of columns in the data.
     
     - Returns: A MPS Matrix that holds the given data with the provided dimensions.
     */
    private func createMPSMatrix(buffer: MTLBuffer, rows: Int, cols: Int) -> MPSMatrix {
        let rowBytes = cols * MemoryLayout<Float32>.size
        let matrixDescriptor: MPSMatrixDescriptor = MPSMatrixDescriptor(rows: rows, columns: cols, rowBytes: rowBytes, dataType: MPSDataType.float32)
        return MPSMatrix(buffer: buffer, descriptor: matrixDescriptor)
    }

    /**
     Create a MPS Matrix that is `rows` x `cols` with an empty buffer of data (i.e. the result matrix that will receive the result of the matrix multiplication)
    
     - Parameters:
        - rows: The number of rows in the data.
        - cols: The number of columns in the data.
    
     - Returns: An empty MPS Matrix with the provided dimensions.
    */
    private func createEmptyMPSMatrix(rows: Int, cols: Int) -> MPSMatrix {
        let buffer = device.makeBuffer(length: rows * cols * MemoryLayout<Float32>.size)!
        return createMPSMatrix(buffer: buffer, rows: rows, cols: cols)
    }

    /**
     Create a MPS Matrix that is `rows` x `cols` with the given data. The data must be 1D, and its length must be equal to the product of `rows` and `cols`.
    
     - Parameters:
        - bytes: A 1D array of floats holding all the data.
        - rows: The number of rows in the data.
        - cols: The number of columns in the data.
    
     - Returns: A MPS Matrix that holds the given data with the provided dimensions.
    */
    private func createFilledMPSMatrix(bytes: [Float32], rows: Int, cols: Int) -> MPSMatrix {
        let buffer = device.makeBuffer(bytes: bytes, length: rows * cols * MemoryLayout<Float32>.size)!
        return createMPSMatrix(buffer: buffer, rows: rows, cols: cols)
    }

    /**
     Create a MPS Matrix that is `length` x `length` and has `constant` along its main diagonal (0s otherwise).
    
     - Parameters:
        - constant: The constant along the main diagonal.
        - length: The number of rows and columns in the matrix..
    
     - Returns: A diagonal MPS Matrix with the given constant along the diagonal and the provided length.
    */
    private func createDiagonalMatrix(constant: Float32, length: Int) -> MPSMatrix {
        var arr: [[Float32]] = Array(repeating: Array(repeating: 0, count: length), count: length)
        for i in 0...length-1 {
            arr[i][i] = constant
        }
        return createFilledMPSMatrix(bytes: Array(arr.joined()), rows: length, cols: length)
    }

    /**
     Create a MPS Matrix that is `length` x `length` and has 1 along its main diagonal (0s otherwise).
    
     - Parameters:
        - length: The number of rows and columns in the matrix..
    
     - Returns: The identity Matrix with the provided length.
    */
    private func createIdentityMatrix(length: Int) -> MPSMatrix {
        return createDiagonalMatrix(constant: 1, length: length)
    }

    /**
     Copy the data from `m1` into a separate MPS Matrix.
     
     - Parameters:
        - m1: The matrix to be copied.
     
     - Returns: A new MPS Matrix that has the same data, rows and columns as `m1`.
    */
    private func copyMatrix(m1: MPSMatrix) -> MPSMatrix {
        let m2 = createEmptyMPSMatrix(rows: m1.rows, cols: m1.columns)
        let matrixDescriptor = MPSMatrixCopyDescriptor(sourceMatrix: m1, destinationMatrix: m2, offsets: MPSMatrixCopyOffsets())
        let kernel = MPSMatrixCopy(device: device, copyRows: m1.rows, copyColumns: m1.columns, sourcesAreTransposed: false, destinationsAreTransposed: false)
        let commandBuffer = commandQueue.makeCommandBuffer()!
        kernel.encode(commandBuffer: commandBuffer, copyDescriptor: matrixDescriptor)

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return m2
    }

    /**
     Matrix multiplication between `m1` and `m2` where the result is put in `resultMatrix` according to the following formula:
    
     `resultMatrix` = (`alpha` x  (`m1` x `m2`)) + (`beta` x `resultMatrix`)
     
     - Parameters:
        - m1: Represents the MPS matrix `m1` in the formula above.
        - m2: Represents the MPS matrix `m2` in the formula above.
        - resultMatrix: Represents the MPS matrix `resultMatrix` in the formula above.
        - alpha: Represents the constant `alpha` in the formula above.
        - beta: Represents the constant `beta` in the formula above.
    */
    private func matrixMultiplication(m1: MPSMatrix, m2: MPSMatrix, resultMatrix: MPSMatrix, alpha: Float32, beta: Float32) {
        let kernel = MPSMatrixMultiplication(device: device, transposeLeft: false, transposeRight: false, resultRows: m1.rows, resultColumns: m2.columns, interiorColumns: m1.columns, alpha: Double(alpha), beta: Double(beta))
        let commandBuffer = commandQueue.makeCommandBuffer()!
        kernel.encode(commandBuffer:commandBuffer, leftMatrix: m1, rightMatrix: m2, resultMatrix: resultMatrix)

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    /**
     Create an MPS Matrix given a 1D array of data.
     
     - Parameters:
        - bytes: The 1D array of floats holding all the data.
     
     - Returns: An MPS Matrix with 1 row holding the given 1D array of data.
    */
    func createMPSVector(bytes: [Float32]) -> MPSMatrix {
        return createFilledMPSMatrix(bytes: bytes, rows: 1, cols: bytes.count)
    }

    /**
     Add `m1` to `m2` and store the result in `m2`. If `inplace` is false, copy `m2` first.
     
     - Parameters:
        - m1: The first MPS matrix
        - m2: The second MPS matrix.
     
     - Returns:
        - The result of matrix addition between `m1` and `m2`.
    */
    func matrixAddition(m1: MPSMatrix, m2: MPSMatrix, inplace: Bool = true) -> MPSMatrix {
        var m2Result = m2
        if !inplace {
            m2Result = copyMatrix(m1: m2)
        }
        let identityMatrix = createIdentityMatrix(length: m1.rows)
        matrixMultiplication(m1: identityMatrix, m2: m1, resultMatrix: m2Result, alpha: 1, beta: 1)
        return m2
    }

    /**
     Subtract`m2` from `m1` .
     
     - Parameters:
        - m1: The first MPS matrix
        - m2: The second MPS matrix.
     
     - Returns:
        - The result of matrix subtraction between `m1` and `m2`.
    */
    func matrixSubtraction(m1: MPSMatrix, m2: MPSMatrix) -> MPSMatrix {
        return matrixAddition(m1: m1, m2: multiplyMatrixByConstant(m1: m2, constant: -1))
    }

    /**
     Multiply every entry in `m1` by `constant`.
     
     -  Parameters:
        - m1: The MPS matrix.
        - constant: The constant to multiply the matrix by.
     
     - Returns: The result of multiplying `m1` by `constant`.
     */
    func multiplyMatrixByConstant(m1: MPSMatrix, constant: Float32) -> MPSMatrix {
        /*
         Multiply every entry in `m1` by `constant`.
         */
        let resultMatrix = createEmptyMPSMatrix(rows: m1.rows, cols: m1.columns)
        let constantMatrix = createMPSVector(bytes: [constant])
        matrixMultiplication(m1: constantMatrix, m2: m1, resultMatrix: resultMatrix, alpha: 1, beta: 0)
        return resultMatrix
    }

    /**
     Divide every entry in `m1` by `constant`.
    
     -  Parameters:
        - m1: The MPS matrix.
        - constant: The constant to divide the matrix by.
    
    - Returns: The result of dividing `m1` by `constant`.
    */
    func divideMatrixByConstant(m1: MPSMatrix, constant: Float32) -> MPSMatrix {
        return multiplyMatrixByConstant(m1: m1, constant: 1/constant)
    }

    /**
     Get the underlying array of data from an MPS Matrix.
     
     - Parameters:
        - m1: The MPS matrix to get the data from.
     
     - Returns: The underlying array of data.
    */
    func getData(m1: MPSMatrix) -> [Float32] {
        let pointer = m1.data.contents()
        let float32Pointer = pointer.bindMemory(to: Float32.self, capacity: m1.columns)
        let float32Buffer = UnsafeBufferPointer(start: float32Pointer, count: m1.columns)
        return Array(float32Buffer)
    }
}
