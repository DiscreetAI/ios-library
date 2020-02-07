//
//  WeightsProcessor.swift
//  Discreet-DML
//
//  Created by Neelesh on 12/18/19.
//  Copyright © 2019 DiscreetAI. All rights reserved.
//

import Foundation
import Surge


class WeightsProcessor {
    /*
     Handle all processing of the physical weights file.
     */
    var mpsHandler: MPSHandler?
    var useGPU: Bool

    init(mpsHandler: MPSHandler?) {
        /*
         mpsHandler: Client for dealing with operations in MPS.
         useGPU: If we have a valid client, use it when we calculate gradients.
         */
        self.mpsHandler = mpsHandler
        self.useGPU = self.mpsHandler == nil ? false : true
    }
    
    public func readWeights(modelPath: String) throws ->  [[[Float32]]] {
        /*
         Read weights given the on device path.
         */
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
        // initialize array and dict
        var layerBytes = [(Int, Int)]()
        var layerData = [[[Float32]]]()
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
        var thisLayerData: [[Float32]] = []
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
                thisLayerData.insert(parsedDataFloat32, at: 0)
                if (layerNum + 1) % 4 == 0 {
                    layerData.append(thisLayerData)
                    thisLayerData = []
                }
            }
        }
        file.closeFile()
        
        return layerData
    }
    
    private func calculateGradientsGPU(oldWeights: [[[Float32]]], newWeights: [[[Float32]]], learningRate:Float32) -> [[[Float32]]] {
        /*
         Calculate the gradients using GPU given the learning rate and paths to the old model and new one.
         */
        var gradients = [[[Float32]]]()

        for (oldLayerWeights, newLayerWeights) in zip(oldWeights, newWeights) {
            var layerGradients = [[Float32]]()
            for (oldWeight, newWeight) in zip(oldLayerWeights, newLayerWeights) {
                let count = oldLayerWeights.count
                let oldMPSMatrix = self.mpsHandler!.createMPSVector(bytes: oldWeight, count: count)
                let newMPSMatrix = self.mpsHandler!.createMPSVector(bytes: newWeight, count: count)
                var resultMatrix = self.mpsHandler!.matrixSubtraction(m1: oldMPSMatrix, m2: newMPSMatrix)
                resultMatrix = self.mpsHandler!.divideMatrixByConstant(m1: resultMatrix, constant: learningRate)
                layerGradients.append(self.mpsHandler!.getData(m1: resultMatrix))
            }
            gradients.append(layerGradients)
        }
        return gradients
    }
    
    private func calculateGradientsSurge(oldWeights: [[[Float32]]], newWeights: [[[Float32]]], learningRate:Float32) -> [[[Float32]]] {
        /*
         Calculate the gradients using Surge given the learning rate and paths to the old model and new one.
         */
        
        var gradients = [[[Float32]]]()

        for (oldLayerWeights, newLayerWeights) in zip(oldWeights, newWeights) {
            var layerGradients = [[Float32]]()
            for (var oldWeight, var newWeight) in zip(oldLayerWeights, newLayerWeights) {
                if oldWeight.count > newWeight.count {
                    oldWeight = oldWeight.dropLast(oldWeight.count - newWeight.count)
                    print("rip")
                } else if oldWeight.count < newWeight.count {
                    newWeight = newWeight.dropLast(newWeight.count - oldWeight.count)
                    print("rip2")
                }
                let difference = Surge.sub(oldWeight, newWeight)
                let quotient = Surge.div(difference, learningRate)
                layerGradients.append(quotient)
            }
            gradients.append(layerGradients)
        }
        return gradients
    }
    
    public func calculateGradients(oldWeightsPath: String, newWeightsPath: String, learningRate: Float32) throws -> [[[Float32]]] {
        /*
         Calculate gradients with the appropriate gradients calculator.
         */
        let oldWeights = try readWeights(modelPath: oldWeightsPath)
        let newWeights = try readWeights(modelPath: newWeightsPath)
        
        let gradientsCalculator = self.useGPU ? calculateGradientsGPU : calculateGradientsSurge
        return gradientsCalculator(oldWeights, newWeights, learningRate)
    }
}
