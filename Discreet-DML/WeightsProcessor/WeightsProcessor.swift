///
///  WeightsProcessor.swift
///  Discreet-DML
///
///  Created by Neelesh on 12/18/19.
///  Copyright © 2019 DiscreetAI. All rights reserved.
///

import Foundation
import Surge

/**
 Handle all processing of the physical weights file.
*/
class WeightsProcessor {
    
    /// An instance of the MPS Handler for interacting with Metal Performance Shaders
    var mpsHandler: MPSHandler?
    /// A boolean dictating whether the GPU should be used for gradient calculation.
    var useGPU: Bool

    /**
     Initialize the Weights Processor for testing.
     */
    init() {
        self.mpsHandler = nil
        self.useGPU = false
    }
    /**
     Initialize the Weights Processor for production.
          
     - Parameters:
        - mpsHandler: Client for dealing with operations in MPS.
     */
    init(mpsHandler: MPSHandler) {
        self.mpsHandler = mpsHandler
        self.useGPU = true
    }
    
    /**
     Read the weights from the weights file given its on device path.
     
     - Parameters:
        - modelPath: The path to the weights file
     
     - Throws: `DMLError` if an error occurred during the reading of the weights.
     
     - Returns: A 2D array consisting of the weights of the model.
     */
    private func readWeights(modelPath: String) throws ->  [[Float32]] {
        var file: FileHandle
        do {
            file = try FileHandle(forReadingFrom: URL(string: modelPath)!)
        } catch {
            print(error.localizedDescription)
            throw DMLError.weightsProcessorError(ErrorMessage.failedFileHandle)
        }
        var b: [Unpackable]
        do {
            b = try unpack("<i", file.readData(ofLength: 4))
        } catch {
            print(error.localizedDescription)
            throw DMLError.weightsProcessorError(ErrorMessage.failedUnpack)
        }
        let num_layers = b[0] as! Int
        var layerBytes = [(Int, Int)]()
        var layerData = [[Float32]]()
        while layerBytes.count < num_layers {
            var ret: [Unpackable]
            do {
                ret = try unpack("<iiii", file.readData(ofLength: 16))
            } catch {
                print(error.localizedDescription)
                throw DMLError.weightsProcessorError(ErrorMessage.failedUnpack)
            }
            let layerNum = ret[1] as? Int
            let numBytes = ret[3] as? Int
            layerBytes.append((layerNum!, numBytes!))
        }
        let floatString = String(repeating: "f", count: 1)
        let prefixString: String = "="
        do {
            _ = try unpack(prefixString + floatString, file.readData(ofLength: 4))
        } catch {
            print(error.localizedDescription)
            throw DMLError.weightsProcessorError(ErrorMessage.failedUnpack)
        }
        var bias = [Float32]()
        for (layerNum, numBytes) in layerBytes {
            let numFloat: Int = numBytes / 4
            let floatString = String(repeating: "f", count: numFloat)
            let prefixString: String = "="
            var weightsData: [Unpackable]
            do {
                weightsData = try unpack(prefixString + floatString, file.readData(ofLength: numBytes))
            } catch {
                print(error.localizedDescription)
                throw DMLError.weightsProcessorError(ErrorMessage.failedUnpack)
            }
            if layerNum % 2 == 0 {
                continue
            }
            if numBytes > 0 {
                let parsedDataDouble: [Double] = weightsData as! [Double]
                let parsedDataFloat32 = parsedDataDouble.map {
                    return Float32($0)
                }
                if (layerNum + 1) % 4 == 0 {
                    layerData.append(parsedDataFloat32)
                    layerData.append(bias)
                } else {
                    bias = parsedDataFloat32
                }
            }
        }
        file.closeFile()
        
        return layerData
    }
    
    /**
     Calculate the gradients using GPU given the learning rate and paths to the old model and new one.
     
     - Parameters:
        - oldWeights: The old weights of the model.
        - newWeights: The new weights of the model.
        - learningRate: The learning rate of the model.
     
     - Returns: The gradients resulting from this round of training.
     */
    private func calculateGradientsGPU(oldWeights: [[Float32]], newWeights: [[Float32]], learningRate:Float32) -> [[Float32]] {
        var gradients = [[Float32]]()

        for (var oldWeight, newWeight) in zip(oldWeights, newWeights) {
            oldWeight = oldWeight.dropLast(oldWeight.count - newWeight.count)
            let oldMPSMatrix = self.mpsHandler!.createMPSVector(bytes: oldWeight)
            let newMPSMatrix = self.mpsHandler!.createMPSVector(bytes: newWeight)
            var resultMatrix = self.mpsHandler!.matrixSubtraction(m1: oldMPSMatrix, m2: newMPSMatrix)
            resultMatrix = self.mpsHandler!.divideMatrixByConstant(m1: resultMatrix, constant: learningRate)
            gradients.append(self.mpsHandler!.getData(m1: resultMatrix))
        }
            
        return gradients
    }
    
    /**
    Calculate the gradients using Surge given the learning rate and paths to the old model and new one.
    
    - Parameters:
       - oldWeights: The old weights of the model.
       - newWeights: The new weights of the model.
       - learningRate: The learning rate of the model.
    
    - Returns: The gradients resulting from this round of training.
    */
    private func calculateGradientsSurge(oldWeights: [[Float32]], newWeights: [[Float32]], learningRate:Float32) -> [[Float32]] {
        var gradients = [[Float32]]()

        for (oldWeight, newWeight) in zip(oldWeights, newWeights) {
            let difference = Surge.sub(oldWeight.dropLast(oldWeight.count - newWeight.count), newWeight)
            let quotient = Surge.div(difference, learningRate)
            gradients.append(quotient)
        }
            
        return gradients
    }
    
    /**
     Read the old and new weights and calculate the gradients with the appropriate gradients calculator.
    
     - Parameters:
        - oldWeightsPath: The path to the old weights of the model.
        - newWeightsPath: The path to the new weights of the model.
        - learningRate: The learning rate of the model.
     
     - Throws: `DMLError` if an error occurred during the reading of the model weights.
    
     - Returns: The gradients resulting from this round of training.
    */
    func calculateGradients(oldWeightsPath: String, newWeightsPath: String, learningRate: Float32) throws -> [[Float32]] {
        print("Reading weights...")
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime
        let oldWeights = try readWeights(modelPath: oldWeightsPath)
        let newWeights = try readWeights(modelPath: newWeightsPath)
        let diff = (info.systemUptime - begin)
        print("Finished reading weights!")
        print("Took \(diff) seconds to finish!")
        
        let gradientsCalculator = self.useGPU ? calculateGradientsGPU : calculateGradientsSurge
        return gradientsCalculator(oldWeights, newWeights, learningRate)
    }
}
