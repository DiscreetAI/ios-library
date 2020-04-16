import UIKit
import CoreML
import DiscreetAI

/**
 The app's main screen.
 */


class LoginController: UITableViewController {
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var repoIDLabel: UITextField!
    @IBOutlet var apiKeyLabel: UITextField!
    @IBOutlet var errorLabel: UILabel!
    var orchestrator: Orchestrator!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: nil, action: nil)
        
        if orchestrator != nil {
            repoIDLabel.text = orchestrator.repoID
            apiKeyLabel.text = orchestrator.apiKey
        } else {
            repoIDLabel.text = "87398da407199e962693360ce3894f64"
            apiKeyLabel.text = "3757611061d2771bc34aeae96748f12988a90e3f1f98981640fd5f857cf6c739"
        }
        
        errorLabel.numberOfLines = 0
        overrideUserInterfaceStyle = .dark
    }
    
    private func showErrorMessage(message: String) {
        errorLabel.isHidden = false
        errorLabel.text = message
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
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
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! MainMenuController
        viewController.title = "Main Menu"
        viewController.orchestrator = orchestrator
    }
}
