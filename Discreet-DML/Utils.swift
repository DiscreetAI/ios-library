//
//  Utils.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/18/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import CoreML

public func getWeights(url: URL) -> String {
    /*
     Util method to download a .mlmodel file and compile it.
     */
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
    return permanentUrl.path + "/model.espresso.weights"
}

public func roundArr(arr: [Double], places: Int) -> [Double] {
    /*
     Util method to round numbers in an array to `places` decimal places.
     */
    func roundNum(num: Double) -> Double {
        let multiple: Double = pow(10, Double(places))
        return round(num * multiple) / multiple
    }
    return arr.map(roundNum)
}
