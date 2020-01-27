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
    var mpsHandler: MPSHandler!
    
    init() {}

    init(mpsHandler: MPSHandler) {
        self.mpsHandler = mpsHandler
    }
    
    private func readWeights(modelPath: String) ->  [[Float32]] {
        /*
         Read weights given the on device path.
         */
        let file: FileHandle = try! FileHandle(forReadingFrom: URL(string: modelPath)!)
        let b = try! unpack("<i", file.readData(ofLength: 4))
        let num_layers = b[0] as! Int
        // initialize array and dict
        var layerBytes = [(Int, Int)]()
        var layerData = [[Float32]]()
        while layerBytes.count < num_layers {
            let ret = try! unpack("<iiii", file.readData(ofLength: 16))
            let layerNum = ret[1] as? Int
            let numBytes = ret[3] as? Int
            layerBytes.append((layerNum!, numBytes!))
        }
        let floatString = String(repeating: "f", count: 1)
        let prefixString: String = "="
        let thisLayerData = try! unpack(prefixString + floatString, file.readData(ofLength: 4))
        for (layerNum, numBytes) in layerBytes {
            let numFloat: Int = numBytes / 4
            let floatString = String(repeating: "f", count: numFloat)
            let prefixString: String = "="
            let thisLayerData = try! unpack(prefixString + floatString, file.readData(ofLength: numBytes))
            if numBytes > 0 {
                let parsedDataDouble: [Double] = thisLayerData as! [Double]
                let parsedDataFloat32 = parsedDataDouble.map {
                    return Float32($0)
                }
                if (layerNum + 1) % 4 != 0 {
                    continue
                }
                layerData.append(parsedDataFloat32)
            } else {
                layerData.append([])
            }
        }
        file.closeFile()
        
        return layerData
    }
    
    private func calculateGradientsGPU(oldModelWeights: [[Float32]], newModelWeights: [[Float32]], learningRate:Float32) -> [[Float32]] {
        /*
         Calculate the gradients using GPU given the learning rate and paths to the old model and new one.
         */
        var gradients = [[Float32]]()

        for (oldLayerWeights, newLayerWeights) in zip(oldModelWeights, newModelWeights) {
            let count = oldLayerWeights.count
            let oldMPSMatrix = self.mpsHandler.createMPSVector(bytes: oldLayerWeights, count: count)
            let newMPSMatrix = self.mpsHandler.createMPSVector(bytes: newLayerWeights, count: count)
            var resultMatrix = self.mpsHandler.matrixSubtraction(m1: oldMPSMatrix, m2: newMPSMatrix)
            resultMatrix = self.mpsHandler.divideMatrixByConstant(m1: resultMatrix, constant: learningRate)
            gradients.append(self.mpsHandler.getData(m1: resultMatrix))
        }
        return gradients
    }
    
    private func calculateGradientsSurge(oldModelWeights: [[Float32]], newModelWeights: [[Float32]], learningRate:Float32) -> [[Float32]] {
        /*
         Calculate the gradients using Surge given the learning rate and paths to the old model and new one.
         */
        var gradients = [[Float32]]()

        for (oldLayerWeights, newLayerWeights) in zip(oldModelWeights, newModelWeights) {
            gradients.append(Surge.div(Surge.sub(oldLayerWeights, newLayerWeights), learningRate))
        }
        return gradients
    }
    
    public func calculateGradients(oldModelPath: String, newModelPath: String, learningRate: Float32, useGPU: Bool = true) -> [[Float32]] {
        
        let oldModelWeights = readWeights(modelPath: oldModelPath)
        let newModelWeights = readWeights(modelPath: newModelPath)
        
        let gradientsCalculator = useGPU ? calculateGradientsGPU : calculateGradientsSurge
        
        return gradientsCalculator(oldModelWeights, newModelWeights, learningRate)
    }
}
