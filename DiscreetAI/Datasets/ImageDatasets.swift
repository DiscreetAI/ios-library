//
//  MNIST.swift
//  DiscreetAI
//
//  Created by Neelesh on 3/20/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation


enum ImageDatasets: String {
    case MNIST = "mnist-sample"
}

let imageDataFunctions = [ImageDatasets.MNIST: getMNISTData]

func isDefaultImageDataset(datasetID: String) -> Bool {
    return ImageDatasets(rawValue: datasetID) != nil
}

func getMNISTData() -> ([String], [String]) {
    let imagesFolder = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("mnist")
    var examples: [String] = []
    var labels: [String] = []
    for label in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] {
        let url = documentsDirectory.appendingPathComponent(label)
        if fileManager.fileExists(atPath: url.path) {
            try! fileManager.removeItem(atPath: url.path)
        }
        try! fileManager.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        for fromURL in fileURLs(at: imagesFolder.appendingPathComponent(label)) {
            let filename = fromURL.lastPathComponent
            try! fileManager.copyItem(at: fromURL, to: url.appendingPathComponent(filename))
            examples.append("\(label)/\(filename)")
            labels.append(label)
        }
    }
    return (examples, labels)
}

func fileURLs(at url: URL) -> [URL] {
    return contentsOfDirectory(at: url)!
}

private func contentsOfDirectory(at url: URL) -> [URL]? {
  try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
}

private func labelURL(imagesFolder: URL, for label: String) -> URL {
  imagesFolder.appendingPathComponent(label)
}

private func imageURL(imagesFolder: URL, for label: String, filename: String) -> URL {
    labelURL(imagesFolder: imagesFolder, for: label).appendingPathComponent(filename)
}

private func imageURL(imagesFolder: URL, for example: (String, String)) -> URL {
    imageURL(imagesFolder: imagesFolder, for: example.1, filename: example.0)
}

@discardableResult func copyIfNotExists(from: URL, to: URL) -> Bool {
    print(from.path, to.path)
    if !FileManager.default.fileExists(atPath: to.path) {
        do {
            try FileManager.default.copyItem(at: from, to: to)
            return true
        } catch {
            print("Error: \(error)")
        }
    }
    return false
}
