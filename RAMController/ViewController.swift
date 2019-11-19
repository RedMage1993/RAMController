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
    
    @IBOutlet weak var unitPicker: UIPickerView!
    @IBOutlet weak var sizeTextField: UITextField!

    var timer: Timer?
    
    var unitSize: UnitSize = .bytes
    
    var data: [UInt8]?
    
    let numberToolbar: UIToolbar = UIToolbar()
    
    lazy var lastSizeInput: String? = sizeTextField.text
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            self.updateMemoryUsageProgressBar()
        }
        
        unitPicker.delegate = self
        unitPicker.dataSource = self
        
        sizeTextField.text = "0"
        
        numberToolbar.barStyle = UIBarStyle.blackTranslucent
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSize)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Apply", style: .plain, target: self, action: #selector(applySize))
        ]

        numberToolbar.sizeToFit()
        
        sizeTextField.inputAccessoryView = numberToolbar
    }
    
    @IBAction func useButtonTapped(_ sender: Any) {
        sizeTextField.resignFirstResponder()
        
        guard let size = Int(sizeTextField.text ?? "") else { return }
        
        guard size > 0 else { return freeMem() }
        
        let numOfBytesToUse = size * unitSize.numOfBytes
        
        guard let ramUsage = RamGuy().calculateRAMUsage(),
              numOfBytesToUse < ramUsage.freeRam
        else { return showError() }
        
        data = nil
        data = Array<UInt8>(repeating: 0, count: numOfBytesToUse)
    }
    
    @IBAction func freeButtonTapped(_ sender: Any) {
        sizeTextField.resignFirstResponder()
        
        freeMem()
    }
    
    @objc func applySize() {
        lastSizeInput = sizeTextField.text
        sizeTextField.resignFirstResponder()
    }

    @objc func cancelSize() {
        sizeTextField.text = lastSizeInput
        sizeTextField.resignFirstResponder()
    }
}

extension ViewController {
    func showError() {
        let alert = UIAlertController(title: "RAMController", message: "Not enough free memory.", preferredStyle: .alert)
        self.present(alert, animated: true)
    }
    
    func freeMem() {
        data = nil
    }
    
    func updateMemoryUsageProgressBar() {
        guard let ramUsage = RamGuy().calculateRAMUsage() else { return }
        
        let percentage = Float(Double(ramUsage.usedRam) / Double(ProcessInfo.processInfo.physicalMemory))

        
        ramUsageLabel.text = "\(percentage * 100.0)%"
        progressBar.progress = percentage
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    enum UnitSize {
        case bytes
        case kilobytes
        case megabytes
        
        static let allValues = [bytes, kilobytes, megabytes]
        
        var numOfBytes: Int {
            switch self {
            case .bytes:
                return 1
            case .kilobytes:
                return 1000
            case .megabytes:
                return 1000000
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UnitSize.allValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(describing: UnitSize.allValues[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        unitSize = UnitSize.allValues[row]
    }
}
