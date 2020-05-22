import UIKit
import CoreML
import DiscreetAI

/**
 View controller for the "Training Neural Network" screen.
 */
class TrainingStatusController: UIViewController {
    @IBOutlet var statusLabel: UILabel!
    
    var orchestrator: Orchestrator!
    var lastState: String!
    var statusTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lastState = orchestrator.getState()
        self.statusLabel.text = lastState
        self.statusLabel.numberOfLines = 0
        
        if statusTimer == nil {
            self.statusTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                let newStatus = self.orchestrator.getState()
                if self.lastState != newStatus {
                    self.lastState = newStatus
                    self.statusLabel.text! += "\n\n" + self.lastState
                }
            }
        }
        
        overrideUserInterfaceStyle = .dark
    }
    
    deinit {
        print(self, #function)
    }
}





