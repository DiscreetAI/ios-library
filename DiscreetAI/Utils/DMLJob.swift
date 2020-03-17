///
///  DMLJob.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/23/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation

/**
 DML Job for containing information needed for the update message.
 */
class DMLJob {
    
    /// The dataset ID corresponding to the desired dataset.
    var datasetID: String
    
    /// The session ID corresponding to this current training session.
    var sessionID: String
    
    /// The current round in this training session.
    var round: Int
    
    /// The calculated gradients after training.
    var gradients: [[Float32]]?
    
    /// The number of datapoints trained on.
    var omega: Int?
    
    /// The URL of the model on device.
    var modelURL: URL?

    
    /**
     Initializes the DML job with the information already known before training. The remaining information is manually set after training.
     
     - Parameters:
        - datasetID: The dataset ID corresponding to the desired dataset.
        - sessionID: The session ID corresponding to this current training session.
        - round: The current round in this training session.
     */
    init(datasetID: String, sessionID: String, round: Int) {
        self.datasetID = datasetID
        self.sessionID = sessionID
        self.round = round
    }
}
