//
//  ImageEntry.swift
//  Discreet-DML
//
//  Created by Neelesh on 3/3/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation
import RealmSwift

class ImageEntry: DataEntry {
    /*
     Dataset object representing a list of paths to images on device.
     */
    let images: List<String> = List<String>()
    let labels: List<String> = List<String>()

    convenience init(repoID: String, images: [String], labels: [String]) {
        /*
         repoID: repo ID associated with this entry.
         images: 1D array of image paths.
         labels: 1D array of labels for data.
         */
        self.init(repoID: repoID)
        self.addImages(images: images, labels: labels)
    }

    func addImages(images: [String], labels: [String]) {
        /*
         Add more images and labels to this entry.
         */
        self.images.append(objectsIn: images)
        self.labels.append(objectsIn: labels)
    }
    
    func getData() -> ([String], [String]) {
        /*
         Unwrap this entry as tuple of data and labels.
         */
        let unwrappedImages = Array(self.images)
        let unwrappedLabels = Array(self.labels)
        return (unwrappedImages, unwrappedLabels)
    }
    
    func setData(images: [String], labels: [String]) {
        /*
         Set the data for this entry with the given image paths and labels.
         */
        self.images.removeAll()
        self.labels.removeAll()
        self.addImages(images: images, labels: labels)
    }
    
    func getDatapointCount() -> Int {
        /*
         Return the number of datapoints.
         */
        return self.labels.count
    }
}
