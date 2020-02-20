import UIKit
import CoreML

/**
 View controller for the "Training Neural Network" screen.
 */
class TrainNeuralNetworkViewController: UIViewController {
    @IBOutlet var statusLabel: UILabel!
    
    var model: MLModel!
    var trainingDataset: ImageDataset!
    var validationDataset: ImageDataset!
    var trainer: NeuralNetworkTrainer!
    var lastState: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trainer = NeuralNetworkTrainer(modelURL: Models.trainedNeuralNetworkURL,
                                       trainingDataset: trainingDataset,
                                       validationDataset: validationDataset,
                                       imageConstraint: imageConstraint(model: model))
        if !orchestrator.isConnected() {
            lastState = orchestrator.getState()
            self.statusLabel.text = lastState
            self.statusLabel.textColor = UIColor.white
            self.statusLabel.numberOfLines = 0
            self.statusLabel.sizeToFit()
            
            orchestrator.clearData()
            var images = [String]()
            var labels = [String]()
            
            for i in 0..<trainingDataset.count {
                let image = self.trainingDataset.image(at: i)!
                
                let randomString = UUID().uuidString + ".jpg"
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let imageURL = documentsURL.appendingPathComponent(randomString)
                
                if let data = image.jpegData(compressionQuality: 1) {
                    try? data.write(to: imageURL)
                    print("Successfully saved \(imageURL.path) to the app!")
                }
                
                let label = self.trainingDataset.label(at: i)
                images.append(imageURL.path)
                labels.append(label)
            }
            
            orchestrator.storeImages(images: images, labels: labels)
            
            orchestrator.connect()
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                let newStatus = orchestrator.getState()
                if self.lastState != newStatus {
                    self.lastState = newStatus
                    self.statusLabel.text! += "\n\n" + self.lastState
                }
            }
        } else {
            lastState = orchestrator.getState()
            self.statusLabel.text = lastState
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    deinit {
        print(self, #function)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(self, #function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // The user tapped the back button.
        stopTraining()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func appWillResignActive() {
        stopTraining()
    }
    
    @IBAction func oneEpochTapped(_ sender: Any) {
        startTraining(epochs: 1)
    }
    
    @IBAction func tenEpochsTapped(_ sender: Any) {
        startTraining(epochs: 10)
    }
    
    @IBAction func fiftyEpochsTapped(_ sender: Any) {
        startTraining(epochs: 50)
    }
    
    @IBAction func stopTapped(_ sender: Any) {
        stopTraining()
    }
    
    @IBAction func learningRateSliderMoved(_ sender: UISlider) {
        settings.learningRate = pow(10, Double(sender.value))
        updateLearningRateLabel()
    }
    
    @IBAction func augmentationSwitchTapped(_ sender: UISwitch) {
        settings.isAugmentationEnabled = sender.isOn
    }
    
    func updateLearningRateLabel() {
    }
    
    func updateButtons() {
    }
}

extension TrainNeuralNetworkViewController {
    func startTraining(epochs: Int) {
        guard trainingDataset.count > 0 else {
            statusLabel.text = "No training images"
            return
        }
        
        updateButtons()
        
        trainer.train(epochs: epochs, learningRate: settings.learningRate, callback: trainingCallback)
    }
    
    func stopTraining() {
        trainer.cancel()
        trainingStopped()
    }
    
    func trainingStopped() {
        updateButtons()
    }
    
    func trainingCallback(callback: NeuralNetworkTrainer.Callback) {
        DispatchQueue.main.async {
            switch callback {
            case let .epochEnd(trainLoss, valLoss, valAcc):
                history.addEvent(trainLoss: trainLoss, validationLoss: valLoss, validationAccuracy: valAcc)
                
                let indexPath = IndexPath(row: history.count - 1, section: 0)
                
            case .completed(let updatedModel):
                self.trainingStopped()
                
                // Replace our model with the newly trained one.
                self.model = updatedModel
                
            case .error:
                self.trainingStopped()
            }
        }
    }
}

extension TrainNeuralNetworkViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        history.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        32
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        cell.textLabel?.text = history.events[indexPath.row].displayString
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }
}

fileprivate extension History.Event {
    var displayString: String {
        var s = String(format: "%5d   ", epoch + 1)
        s += String(String(format: "%6.4f", trainLoss).prefix(6))
        s += "   "
        s += String(String(format: "%6.4f", validationLoss).prefix(6))
        s += "     "
        s += String(String(format: "%5.2f", validationAccuracy * 100).prefix(5))
        return s
    }
}
