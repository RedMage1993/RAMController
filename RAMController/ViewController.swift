//
//  ViewController.swift
//  RAMController
//
//  Created by Fritz Ammon on 11/18/19.
//  Copyright © 2019 Fritz Ammon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var ramUsageLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            self.updateMemoryUsageProgressBar()
        }
    }
}

extension ViewController {
    func updateMemoryUsageProgressBar() {
        guard let ramUsage = RamGuy().calculateRAMUsage() else { return }
        
        let percentage = Float(Double(ramUsage.usedRam) / Double(ProcessInfo.processInfo.physicalMemory))

        
        ramUsageLabel.text = "\(percentage * 100.0)%"
        progressBar.progress = percentage
    }
}
