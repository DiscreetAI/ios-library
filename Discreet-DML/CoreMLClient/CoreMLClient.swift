//
//  CoreMLClient.swift
//  Discreet-DML
//
//  Created by Neelesh on 1/23/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//
import Foundation
import CoreML


class CoreMLClient {
    /*
     Handler for dealing with the Core ML API.
     */
    var modelLoader: ModelLoader?
    var realmClient: RealmClient?
    var weightsProcessor: WeightsProcessor?
    var communicationManager: CommunicationManager?
    
    var modelURL: URL?
    var currentJob: DMLJob?
    var losses: [String: [Double]]
    
    init(modelLoader: ModelLoader?, realmClient: RealmClient?, weightsProcessor: WeightsProcessor?) {
        /*
         modelLoader: instance of Model Loader
         realmClient: instance of Realm Client
         weightsProcessor: instance of Weights Processor
         */
        self.modelLoader = modelLoader
        self.realmClient = realmClient
        self.weightsProcessor = weightsProcessor
        
        let batchLoss: [Double] = []
        let trainLoss: [Double] = []
        self.losses = ["batchLoss": batchLoss, "trainLoss": trainLoss]
    }
    
    func configure(communicationManager: CommunicationManager?) {
        /*
         communicationManager: instance of Communication Manager
         
         NOTE: Since Core ML Client and Communication Manager are dependent on each other, this method is needed.
         */
        self.communicationManager = communicationManager
    }

    func train(job: DMLJob) throws {
        /*
         Load the model, prepare the model, and begin training the model.
         */
        self.currentJob = job
        let modelURL = try self.modelLoader!.loadModel()
        let metaDataEntry = realmClient!.getMetadataEntry(repoID: job.repoID)!
        let type = DataType(rawValue: metaDataEntry.dataType)
        
        var batchProvider: MLBatchProvider
        switch type {
        case .DOUBLE:
            batchProvider = DoubleBatchProvider(realmClient: self.realmClient!, repoID: job.repoID)
            break
        case .IMAGE:
            var model: MLModel
            do {
                model = try MLModel(contentsOf: modelURL)
            } catch {
                print(error.localizedDescription)
                throw DMLError.coreMLError(ErrorMessage.failedMLModel)
            }
            let constraint = model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
            batchProvider = ImagesBatchProvider(realmClient: realmClient!, repoID: job.repoID, imageConstraint: constraint)
        case .TEXT:
            print("Not supported yet!")
            return
        default:
            print("Unrecognized type!")
            return
        }
        
        job.omega = batchProvider.count
        job.modelURL = modelURL
                
        let handlers = MLUpdateProgressHandlers(
        forEvents: [.trainingBegin, .miniBatchEnd, .epochEnd],
        progressHandler: progressHandler,
        completionHandler: completionHandler)
                
        guard let updateTask = try? MLUpdateTask(forModelAt: modelURL, trainingData: batchProvider, configuration: nil, progressHandlers: handlers)
            else {
                print("Could't create an MLUpdateTask.")
                return
            }
        updateTask.resume()
        
    }
    
    public func finishedTraining(oldModelURL: URL, newModelURL: URL, learningRate: Double) throws {
        /*
         Callback for when training is finished. Calculate the gradients and communicate them to the cloud node.
         */
        print("Training complete.")
        let oldWeightsPath = makeWeightsPath(modelURL: oldModelURL)
        let newWeightsPath = makeWeightsPath(modelURL: newModelURL)
        print("Calculating gradients...")
        self.currentJob!.gradients = try self.weightsProcessor!.calculateGradients(oldWeightsPath: oldWeightsPath, newWeightsPath: newWeightsPath, learningRate: Float32(learningRate)
        )
        print("Finished calculating gradients!")
        _ = try self.communicationManager!.handleTrainingComplete(job: self.currentJob!)
        
    }
    
    func progressHandler(context: MLUpdateContext) {
        /*
         Progress handler for the model to use as it trains.
         */
        switch context.event {
        case .trainingBegin:
          // This is the first event you receive, just before training actually
          // starts. At this point, context.metrics is empty.
            print("Training begin")

        case .miniBatchEnd:
          // This event is triggered after each mini-batch. You can get the
          // index of this batch and the training loss from context.metrics.
            let batchIndex = context.metrics[.miniBatchIndex] as! Int
            let batchLoss = context.metrics[.lossValue] as! Double
            print("Mini batch \(batchIndex), loss: \(batchLoss)")
            self.losses["batchLoss"]!.append(batchLoss)
          

        case .epochEnd:

            // The only metric Core ML gives us is the training loss.
            let trainLoss = context.metrics[.lossValue] as! Double
            self.losses["trainLoss"]!.append(trainLoss)
        default:
            print("Unknown event")
        }
    }
    
    func completionHandler(context: MLUpdateContext) {
        /*
         Completion handler for the model to use after training as finished.
         */
        print("Training completed with state \(context.task.state.rawValue)")
        
        // This happens when there is some kind of error, for example if the
        // batch provider returns an invalid MLFeatureProvider object.
        if context.task.state == .failed {
          print("An error occurred.")
          return
        }

        let trainLoss = context.metrics[.lossValue] as! Double
        print("Final loss: \(trainLoss)")

        

        do {
            let oldModelURL = try renameModel(modelURL: self.currentJob!.modelURL)
            try saveUpdatedModel(context.model, to: self.currentJob!.modelURL)
            try self.finishedTraining(oldModelURL: oldModelURL, newModelURL: self.currentJob!.modelURL, learningRate: context.parameters[.learningRate] as! Double)
            print("Saved new model and communicated gradients!")
        } catch DMLError.coreMLError(ErrorMessage.failedRename) {
            print(DMLError.coreMLError(ErrorMessage.failedRename))
            print("Failed to rename old model!")
        } catch DMLError.coreMLError(ErrorMessage.failedModelUpdate) {
            print(DMLError.coreMLError(ErrorMessage.failedModelUpdate))
            print("Failed to save new model!")
        } catch {
            print(error.localizedDescription)
            print("Failed to communicate gradients!")
        }
        
    }
}
