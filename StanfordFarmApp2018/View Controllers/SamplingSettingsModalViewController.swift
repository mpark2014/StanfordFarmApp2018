//
//  SamplingSettingsModalViewController.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 9/12/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class SamplingSettingsModalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var mainPickerView: UIPickerView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var isSensorSampling: Bool?
    var currentSamplingRate: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.layer.cornerRadius = 4.0
        cancelView.layer.cornerRadius = 4.0
        confirmView.layer.cornerRadius = 4.0
        
        mainPickerView.dataSource = self
        mainPickerView.delegate = self
        
        titleLabel.text = (isSensorSampling! ? "SENSOR" : "IRRIGATION") + " SAMPLING RATE"
        
        if let isSensorSampling = self.isSensorSampling {
            if var totalSeconds = dataModel.dashboard_settings[isSensorSampling ? "sInterval" : "iInterval"] {
                let hours = totalSeconds/(60*60)
                totalSeconds -= hours*60*60
                
                let minutes = totalSeconds/60
                totalSeconds -= minutes*60
                
                let seconds = totalSeconds
                
                mainPickerView.selectRow(hours, inComponent: 0, animated: false)
                mainPickerView.selectRow(minutes, inComponent: 1, animated: false)
                mainPickerView.selectRow(seconds, inComponent: 2, animated: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapConfirm(_ sender: Any) {
        let hours = mainPickerView.selectedRow(inComponent: 0)
        let minutes = mainPickerView.selectedRow(inComponent: 1)
        let seconds = mainPickerView.selectedRow(inComponent: 2)
        let totalSeconds = (hours*60*60) + (minutes*60) + (seconds)
        if (totalSeconds != dataModel.dashboard_settings[isSensorSampling! ? "sInterval" : "iInterval"]) && (totalSeconds >= 5) {
            isSensorSampling! ? dataModel.post_sensorSamplingRate(seconds: totalSeconds) : dataModel.post_irrigationSamplingRate(seconds: totalSeconds)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Picker View Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 24
        } else {
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row<10 ? "0\(row)" : String(row)
    }
}
