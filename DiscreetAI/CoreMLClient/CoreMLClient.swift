///
///  CoreMLClient.swift
///  Discreet-DML
///
///  Created by Neelesh on 1/23/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation
import CoreML


/**
 Client for dealing with the Core ML API.
*/
class CoreMLClient {
    
    /// An instance of the Model Loader for retrieving the model.
    var modelLoader: ModelLoader?
    
    /// An instance of the Realm Client for retrieving the data.
    var realmClient: RealmClient?
    
    /// An instance of the Weights Processor for calculating the gradients.
    var weightsProcessor: WeightsProcessor?
    
    /// An instance of the Communication Manager for communicating the update message.
    var communicationManager: CommunicationManager?
    
    /// The URL of the model on device.
    var modelURL: URL?
    
    /// The job currently being handled.
    var currentJob: DMLJob?
    
    /// Metrics for the current training job. Currently just loss.
    /// TODO: Do something with these metrics and add more metrics.
    var losses = [String: [Double]]()
    
    var isTraining: Bool
    
    var inProgressHandler: Bool
    /**
     Initializes the Core ML Client for training on jobs. Still needs to be configured with the Communication Manager before training. Set up the metrics too.
     
     TODO: Throw a DMLError if training is attempted while the client is not configured with the Communication Manager.
     
     - Parameters:
        - modelLoader: An instance of the Model Loader for retrieving the model.
        - realmClient: An instance of the Realm Client for retrieving the data.
        - weightsProcessor: An instance of the Weights Processor for calculating the gradients.
     */
    init(modelLoader: ModelLoader?, realmClient: RealmClient?, weightsProcessor: WeightsProcessor?) {
        self.modelLoader = modelLoader
        self.realmClient = realmClient
        self.weightsProcessor = weightsProcessor
        self.isTraining = false
        self.inProgressHandler = false
    }
    
    /**
     Configure the Core ML Client with an instance of the Communication Manager.
     
     NOTE: Since Core ML Client and Communication Manager are dependent on each other, this method is needed.
     
     - Parameters:
        - communicationManager: An instance of the Communication Manager for communicating the update message.
     */
    func configure(communicationManager: CommunicationManager?) {
        self.communicationManager = communicationManager
    }

    /**
     Load the model, prepare the model and begin training the model.
     
     - Parameters:
        - job: The DML Job associated with this training round.
     
     - Throws: `DMLError` if an error occurred during loading, preparing or training.
     */
    func train(job: DMLJob) throws {
        self.isTraining = true
        if let trainJob = try makeTrainJob(job: job) {
            self.currentJob = trainJob
            print("Making handlers")
            
            let handlers = MLUpdateProgressHandlers(
                forEvents: [.trainingBegin, .miniBatchEnd, .epochEnd],
                progressHandler: progressHandler,
                completionHandler: realCompletionHandler)
                    
            let updateTask = try! MLUpdateTask(forModelAt: trainJob.modelURL!, trainingData: trainJob.batchProvider!, configuration: nil, progressHandlers: handlers)
            
            updateTask.resume()
        } else {
            print("No dataset found!")
        }
    }
    
    func makeTrainJob(job: DMLJob) throws -> DMLJob? {
        let modelURL = try self.modelLoader!.loadModel(sessionID: job.sessionID)
        
        var model: MLModel
        var inputName: String
        var predictedFeatureName: String

        print("Making MLModel")
        do {
            model = try MLModel(contentsOf: modelURL)
            (inputName, predictedFeatureName) = getModelNames(model: model)
        } catch {
            print(error.localizedDescription)
            throw DMLError.coreMLError(ErrorMessage.failedMLModel)
        }
        
        let type = self.realmClient?.getDataEntryType(datasetID: job.datasetID)
        
        if (type == nil) {
            _ = try self.communicationManager?.handleNoDataset(job: job)
            return nil
        }
        
        print("Getting Batch Provider")
        
        var batchProvider: MLBatchProvider
        switch type! {
            case .TEXT:
                batchProvider = TextBatchProvider(realmClient: self.realmClient!, datasetID: job.datasetID, inputName: inputName, predictedFeatureName: predictedFeatureName)
                break
            case .IMAGE:
                let constraint = model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
                batchProvider = ImagesBatchProvider(realmClient: realmClient!, datasetID: job.datasetID, imageConstraint: constraint, inputName: inputName, predictedFeatureName: predictedFeatureName)
        }
        
        if (batchProvider.count == 0) {
            _ = try self.communicationManager?.handleNoDataset(job: job)
            return nil
        }
        
        
        
        job.omega = batchProvider.count
        job.modelURL = modelURL
        job.batchProvider = batchProvider
        
        return job
    }
    
    func newJob(job: DMLJob) throws {
        self.isTraining = true
        if let trainJob = try makeTrainJob(job: job) {
            self.currentJob = trainJob
        } else {
            print("No dataset found!")
        }
    }
    
    /**
     Callback for when training is finished. Calculate the gradients and communicate them to the cloud node.
     
     - Throws: `DMLError` if an error occurred during gradient calculation or communication of the update message.
     */
    func finishedTraining(oldModelURL: URL, newModelURL: URL, learningRate: Double) throws {
        print("Training complete with repo ID: \(self.currentJob!.repoID!).")
        let oldWeightsPath = makeWeightsPath(modelURL: oldModelURL)
        let newWeightsPath = makeWeightsPath(modelURL: newModelURL)
        print("Calculating gradients... with repo ID: \(self.currentJob!.repoID!).")
        self.currentJob!.gradients = try self.weightsProcessor!.calculateGradients(oldWeightsPath: oldWeightsPath, newWeightsPath: newWeightsPath, learningRate: Float32(learningRate)
        )
        print("Finished calculating gradients with repo ID: \(self.currentJob!.repoID!).")
        _ = try self.communicationManager!.handleTrainingComplete(job: self.currentJob!)
        #if targetEnvironment(simulator)
        #else
        try self.modelLoader!.deleteModelFolder(sessionID: self.currentJob!.sessionID)
        #endif
        self.isTraining = false
    }
    
    /**
     Progress handler for the model to use as it trains.
     */
    func progressHandler(context: MLUpdateContext) {
        switch context.event {
        case .trainingBegin:
            print("Training begin with repo ID: \(self.currentJob!.repoID!).")
        case .miniBatchEnd:
            let batchIndex = context.metrics[.miniBatchIndex] as! Int
            let batchLoss = context.metrics[.lossValue] as! Double
            print("Mini batch \(batchIndex), loss: \(batchLoss) with repo ID: \(self.currentJob!.repoID!).")
            //self.losses["batchLoss"]!.append(batchLoss)
        case .epochEnd:
            print(context.parameters[.epochs])
            
            self.inProgressHandler = true
            let trainLoss = context.metrics[.lossValue] as! Double
            print(trainLoss)
            self.completionHandler(context: context)
            
            while self.currentJob == nil {
               RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
            }
            
            self.isTraining = true
            
            
            //self.losses["trainLoss"]!.append(trainLoss)
        default:
            print("Unknown event")
        }
    }
    
    /**
     Completion handler for the model to use after training as finished. Handler any errors encountered here, since handlers cannot throw errors.
     */
    func completionHandler(context: MLUpdateContext) {
        print("Training completed with state \(context.task.state.rawValue) with repo ID: \(self.currentJob!.repoID!).")
        if context.task.state == .completed {
            print("YAY")
        }
        if context.task.state == .cancelling {
            print("BOOO")
        }
        if context.task.state == .suspended {
            print("OOP")
        }
        if context.task.state == .failed {
            print("An error occurred with repo ID: \(self.currentJob!.repoID!).")
            try! self.communicationManager!.handleTrainingError(job: self.currentJob!)
            return
        }
//        else {
//            let trainLoss = context.metrics[.lossValue] as! Double
//            print("Final loss: \(trainLoss) with repo ID: \(self.currentJob!.repoID!).")
//        }

        do {
            let oldModelURL = try renameModel(modelURL: self.currentJob!.modelURL!)
            print(oldModelURL.path, self.currentJob?.modelURL?.path)
            try saveUpdatedModel(context.model, to: self.currentJob!.modelURL!)
            context.model.accessibilityValue = "";
            try self.finishedTraining(oldModelURL: oldModelURL, newModelURL: self.currentJob!.modelURL!, learningRate: context.parameters[.learningRate] as! Double)
            print("Saved new model and communicated gradients with repo ID: \(self.currentJob!.repoID!).")
        } catch DMLError.coreMLError(ErrorMessage.failedRename) {
            print(DMLError.coreMLError(ErrorMessage.failedRename))
            self.isTraining = false
            print("Failed to rename old model!")
        } catch DMLError.coreMLError(ErrorMessage.failedModelUpdate) {
            print(DMLError.coreMLError(ErrorMessage.failedModelUpdate))
            print("Failed to save new model!")
        } catch {
            print(error.localizedDescription)
            print("Failed to communicate gradients!")
        }
        self.isTraining = false
        self.currentJob = nil
    }
    
    func realCompletionHandler(context: MLUpdateContext) {
        print("Should not have reached this!!!")
    }
}
