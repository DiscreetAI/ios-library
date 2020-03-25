///
///  ImageDatasets.swift
///  DiscreetAI
///
///  Created by Neelesh on 3/20/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation


/**
 Enum detailing the various default image datasets in the library.
 */
enum ImageDatasets: String {
    /// A sample of the MNIST dataset
    case MNIST = "mnist-sample"
}

/// The dictionary mapping image datasets to their appropriate data functions.
let imageDataFunctions = [ImageDatasets.MNIST: getMNISTData]

/**
 Helper function to determine whether the provided dataset ID corresponds to a default image dataset.
 
 - Parameters:
    - datasetID: The dataset ID corresponding to the desired dataset.
 
 - Returns: A boolean dictating whether the provided dataset ID corresponds to a default image dataset.
 */
func isDefaultImageDataset(datasetID: String) -> Bool {
    return ImageDatasets(rawValue: datasetID) != nil
}

/**
 Data function to get the image paths and labels of the MNIST sample.
 
 - Returns: Tuple corresponding to the sample data's image paths and labels.
 */
func getMNISTData() -> ([String], [String]) {
    let imagesFolder = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("mnist")
    var examples: [String] = []
    var labels: [String] = []
    for label in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] {
        let url = documentsDirectory.appendingPathComponent(label)
        if !fileManager.fileExists(atPath: url.path) {
            try! fileManager.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
        
        let labelURL = imagesFolder.appendingPathComponent(label)
        let fileURLs = try! FileManager.default.contentsOfDirectory(at: labelURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        
        for fromURL in fileURLs {
            let filename = fromURL.lastPathComponent
            let copyDestination = url.appendingPathComponent(filename)
            if !fileManager.fileExists(atPath: copyDestination.path) {
                try! fileManager.copyItem(at: fromURL, to: copyDestination)
            }
            examples.append("\(label)/\(filename)")
            labels.append(label)
        }
    }
    return (examples, labels)
}
