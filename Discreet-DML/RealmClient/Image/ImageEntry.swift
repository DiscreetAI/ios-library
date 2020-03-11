///
///  ImageEntry.swift
///  Discreet-DML
///
///  Created by Neelesh on 3/3/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import RealmSwift

/**
 Dataset object representing a list of paths to images on device and labels.
*/
class ImageEntry: DataEntry {
    
    /// The list of image paths referring to images stored in the application.
    let images: List<String> = List<String>()
    
    /// The labels for each of the images at the image paths.
    let labels: List<String> = List<String>()

    /**
     Initializes the `ImageEntry` object with the starting images and labels.
     
     - Parameters:
        - repoID: The repo ID corresponding to the dataset of this library.
        - images: The 1D array of image paths referring to images stored in the application.
        - labels: The labels for each of the images at the image paths.
     */
    convenience init(repoID: String, images: [String], labels: [String]) {
        self.init(repoID: repoID)
        self.addImages(images: images, labels: labels)
    }

    /**
     Add more image paths and labels to this entry.
     
     - Parameters:
        - images: The 1D array of image paths referring to images stored in the application.
        - labels: The labels for each of the text datapoints.
     */
    func addImages(images: [String], labels: [String]) {
        self.images.append(objectsIn: images)
        self.labels.append(objectsIn: labels)
    }
    
    /**
     Get the images and labels from this entry.
     
     - Returns: A tuple (`images`, `labels`) where `images` refers to the stored image paths and `labels` refers to the corresponding labels.
     */
    func getData() -> ([String], [String]) {
        let unwrappedImages = Array(self.images)
        let unwrappedLabels = Array(self.labels)
        return (unwrappedImages, unwrappedLabels)
    }
    
    /**
     Replace any image data already stored for the given repo ID with the provided image paths and labels.
    
     - Parameters:
        - images: The 1D array of image paths referring to images stored in the application.
        - labels: The labels for each of the text datapoints.
    */
    func setData(images: [String], labels: [String]) {
        self.images.removeAll()
        self.labels.removeAll()
        self.addImages(images: images, labels: labels)
    }
    
    /**
     Get the datapoint count for this entry.
     
     - Returns: The datapoint count.
     */
    func getDatapointCount() -> Int {
        return self.labels.count
    }
}
