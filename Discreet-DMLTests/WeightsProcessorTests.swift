//
//  WeightsProcessorTests.swift
//  Discreet-DMLTests
//
//  Created by Neelesh on 1/15/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import XCTest
import CoreML
@testable import Discreet_DML

class WeightsProcessorTests: XCTestCase {
    var oldDestinationURL: String? = nil
    var newDestinationURL: String? = nil
    var weightsProcessor = WeightsProcessor()
    var oldWeights: [[Double]] = [[0.21755897998809814, -0.39083409309387207, -0.8808399438858032, -0.921346127986908]]
    var newWeights: [[Double]] = [[0.355660080909729, 1.1114248037338257, 0.44956088066101074, -0.7894205451011658]]
    var expectedGradients = [[-13.81011, -133.04008, -150.22589, -13.192558]]
    var oldModelURL: URL = URL(string:"https://ios-discreetai.s3-us-west-1.amazonaws.com/old_model.mlmodel")!
    var newModelURL:URL = URL(string:"https://ios-discreetai.s3-us-west-1.amazonaws.com/new_model.mlmodel")!
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print(oldModelURL)
        print(newModelURL)
        oldDestinationURL = getWeights(url: oldModelURL)
        newDestinationURL = getWeights(url: newModelURL)
        print(oldDestinationURL!)
        print(newDestinationURL!)
    }
    
    func getWeights(url: URL) -> String {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
        }
        else if let dataFromURL = NSData(contentsOf: url) {
            if dataFromURL.write(to: destinationUrl, atomically: true) {
                print("file saved [\(destinationUrl.path)]")
            } else {
                print("error saving file")
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
        }
        let compiledUrl = try! MLModel.compileModel(at: destinationUrl)
        
        let fileManager = FileManager.default
        let appSupportDirectory = try! fileManager.url(for: .applicationSupportDirectory,
                in: .userDomainMask, appropriateFor: compiledUrl, create: true)
        // create a permanent URL in the app support directory
        let permanentUrl = appSupportDirectory.appendingPathComponent(compiledUrl.lastPathComponent)
        do {
            // if the file exists, replace it. Otherwise, copy the file to the destination.
            if fileManager.fileExists(atPath: permanentUrl.absoluteString) {
                _ = try fileManager.replaceItemAt(permanentUrl, withItemAt: compiledUrl)
            } else {
                try fileManager.copyItem(at: compiledUrl, to: permanentUrl)
            }
        } catch {
            print("Error during copy: \(error.localizedDescription)")
        }
        print(permanentUrl.path)
        return permanentUrl.path + "/model.espresso.weights"
    }

    func roundArr(arr: [Double], places: Int) -> [Double] {
        func roundNum(num: Double) -> Double {
            let multiple: Double = pow(10, Double(places))
            return round(num * multiple) / multiple
        }
        return arr.map(roundNum)
    }
    

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReadWeights() {
        let calculatedGradients: [[Double]] = weightsProcessor.calculateGradients(oldModelPath: oldDestinationURL!, newModelPath: newDestinationURL!, learningRate: 0.01)
        let roundedCalculatedGradients: [Double] = roundArr(arr: expectedGradients[0], places: 3)
        let roundedExpectedGradients: [Double] = roundArr(arr: calculatedGradients[0], places: 3)
        XCTAssertEqual(roundedExpectedGradients, roundedCalculatedGradients)
    }

}
