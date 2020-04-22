//
//  MainMenu.swift
//  DiscreetAIDemoApp
//
//  Created by Neelesh on 4/16/20.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import Foundation
import UIKit
import DiscreetAI


class MainMenuController: UITableViewController {
    var orchestrator: Orchestrator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Main Menu", style: .plain, target: nil, action: nil)
        
        
        overrideUserInterfaceStyle = .dark
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Data" {
            let viewController = segue.destination as! DataViewController
            let imagesByLabel = ImagesByLabel(dataset: trainingDataset, orchestrator: orchestrator)
            viewController.imagesByLabel = imagesByLabel
            viewController.title = "Data"
        } else if segue.identifier == "Training Status" {
            let viewController = segue.destination as! TrainingStatusController
            viewController.orchestrator = orchestrator
            viewController.title = "Training Status"
        }
    }
    
    @IBAction func loadBuiltInDataSet() {
        trainingDataset.copyBuiltInImages()
    }
}
