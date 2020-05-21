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
    var orchestrator: Orchestrator?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: nil, action: nil)
        
        if orchestrator != nil {
            repoIDLabel.text = orchestrator!.repoID
            apiKeyLabel.text = orchestrator!.apiKey
        }
        
        errorLabel.numberOfLines = 0
        overrideUserInterfaceStyle = .dark
    }
    
    private func showErrorMessage(message: String) -> Bool {
        errorLabel.isHidden = false
        errorLabel.text = message
        return false
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if repoIDLabel.text! == "" {
            return showErrorMessage(message: "Please fill in the repo ID.")
        }
        
        if apiKeyLabel.text! == "" {
            return showErrorMessage(message: "Please fill in the API key.")
        }
        
        do {
            orchestrator?.disconnect()
            if let orchestrator = try Orchestrator(repoID: repoIDLabel.text!, apiKey: apiKeyLabel.text!, connectImmediately: true) {
                self.orchestrator = orchestrator
                errorLabel.isHidden = true
                errorLabel.text = ""
                return true
            } else {
                return showErrorMessage(message: "Authentication failed! Please check to make sure your repo ID and API key are correct!")
            }
        } catch DMLError.userError(let errorMessage) {
            return showErrorMessage(message: errorMessage.rawValue)
        } catch {
            print(error.localizedDescription)
            return showErrorMessage(message: "An unknown error occurred.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! MainMenuController
        viewController.title = "Main Menu"
        viewController.orchestrator = orchestrator
    }
}
