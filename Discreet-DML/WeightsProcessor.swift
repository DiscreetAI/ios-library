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
    
    init() {
        
    }

    private func readWeights(modelPath: String) ->  [[Double]] {
        let file: FileHandle? = FileHandle(forReadingAtPath: modelPath)
        let b = try! unpack("<i", file!.readData(ofLength: 4))
        let num_layers = b[0] as! Int
        print(num_layers)
        // initialize array and dict
        var layerBytes = [(Int, Int)]()
        var layerData = [[Double]]()
        while layerBytes.count < num_layers {
            let ret = try! unpack("<iiii", file!.readData(ofLength: 16))
            //print(ret)
            let layerNum = ret[1] as? Int
            //print(layerNum!, "layernum")
            let numBytes = ret[3] as? Int
            //print(numBytes!, "numbytes")
            layerBytes.append((layerNum!, numBytes!))
        }
        print("creating layerData")
        let floatString = String(repeating: "f", count: 1)
        let prefixString: String = "="
        let thisLayerData = try! unpack(prefixString + floatString, file!.readData(ofLength: 4))
        for (layerNum, numBytes) in layerBytes {
            
            print((layerNum, numBytes))
            let numFloat: Int = numBytes / 4
            let floatString = String(repeating: "f", count: numFloat)
            let prefixString: String = "="
            let thisLayerData = try! unpack(prefixString + floatString, file!.readData(ofLength: numBytes))
            if numBytes > 0 {
                let parsedDataDouble = thisLayerData as! [Double]
                if (layerNum + 1) % 4 != 0 {
                    continue
                }
                print(parsedDataDouble)
                layerData.append(parsedDataDouble)
            } else {
                layerData.append([])
            }
        }
        file!.closeFile()
        
        return layerData
    }
    
    public func calculateGradients(oldModelPath: String, newModelPath: String, learningRate:Double) -> [[Double]] {
        let oldWeights = readWeights(modelPath: oldModelPath)
        let newWeights = readWeights(modelPath: newModelPath)
        var gradients = [[Double]]()
        
        print("calculations")
        for (oldWeightsArr, newWeightsArr) in zip(oldWeights, newWeights) {
            print(oldWeightsArr)
            print(newWeightsArr)
            gradients.append(Surge.div(Surge.sub(oldWeightsArr, newWeightsArr), learningRate))
        }
        return gradients
    }
    
}
