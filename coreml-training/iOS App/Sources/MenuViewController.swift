import UIKit
import CoreML
import DiscreetAI

/**
  The app's main screen.
 */
var orchestrator: Orchestrator!

class MenuViewController: UITableViewController {
  @IBOutlet var backgroundTrainingSwitch: UISwitch!
  @IBOutlet weak var repoIDLabel: UITextField!
  @IBOutlet weak var instructionLabel: UILabel!
  @IBOutlet weak var apiKeyLabel: UITextField!
  @IBOutlet weak var errorLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: nil, action: nil)

    Models.copyEmptyNearestNeighbors()
    Models.copyEmptyNeuralNetwork()
    
    if orchestrator != nil {
      repoIDLabel.text = orchestrator.repoID
      apiKeyLabel.text = orchestrator.apiKey
    }
    
    instructionLabel.text = "Please enter your repo ID and API key before \nconnecting to the server."
    instructionLabel.numberOfLines = 0
    errorLabel.numberOfLines = 0
    overrideUserInterfaceStyle = .dark
  }

  private func showErrorMessage(message: String) {
    errorLabel.isHidden = false
    errorLabel.text = message
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "TrainNeuralNetwork" || identifier == "TrainingData" {
      if repoIDLabel.text! == "" {
        showErrorMessage(message: "Please fill in the repo ID.")
        return false
      }
      
      if apiKeyLabel.text! == "" {
        showErrorMessage(message: "Please fill in the API key.")
        return false
      }
      
      do {
        if orchestrator != nil {
          if orchestrator.repoID != repoIDLabel.text && orchestrator.apiKey != apiKeyLabel.text {
            orchestrator.disconnect()
          }
        } else {
          orchestrator = try Orchestrator(repoID: repoIDLabel.text!, apiKey: apiKeyLabel.text!, connectImmediately: true)
        }
        errorLabel.isHidden = true
        errorLabel.text = ""
      } catch DMLError.userError(let errorMessage) {
        showErrorMessage(message: errorMessage.rawValue)
        return false
      } catch {
        showErrorMessage(message: "An unknown error occurred.")
        return false
      }
    }
    return true
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "TrainingData" {
      let viewController = segue.destination as! DataViewController
      viewController.imagesByLabel = ImagesByLabel(dataset: trainingDataset)
      viewController.title = "Training Data"
    } else if segue.identifier == "TrainNeuralNetwork" {
      let viewController = segue.destination as! TrainNeuralNetworkViewController
      viewController.model = Models.loadTrainedNeuralNetwork()
      viewController.trainingDataset = trainingDataset
      viewController.validationDataset = testingDataset
    }
  }

  @IBAction func loadBuiltInDataSet() {
    trainingDataset.copyBuiltInImages()
    testingDataset.copyBuiltInImages()
  }

  @IBAction func resetToEmptyNearestNeighbors() {
    Models.deleteTrainedNearestNeighbors()
    Models.copyEmptyNearestNeighbors()
  }

  @IBAction func resetToEmptyNeuralNetwork() {
    Models.deleteTrainedNeuralNetwork()
    Models.copyEmptyNeuralNetwork()
    history.delete()
  }

  @IBAction func resetToTuriNeuralNetwork() {
    Models.deleteTrainedNeuralNetwork()
    Models.copyTuriNeuralNetwork()
    history.delete()
  }

  @IBAction func backgroundTrainingSwitchTapped(_ sender: UISwitch) {
    settings.isBackgroundTrainingEnabled = backgroundTrainingSwitch.isOn
  }
}
