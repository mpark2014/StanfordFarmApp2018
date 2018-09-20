//
//  DataSettingsModalViewController.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 9/18/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class DataSettingsModalViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var backgroundDismissButton: UIButton!
    @IBOutlet weak var downloadCsvView: UIView!
    @IBOutlet weak var downloadCsvLabel: UILabel!
    @IBOutlet weak var downloadCsvActivityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var downloadCsvButton: UIButton!
    @IBOutlet weak var clearBedDataView: UIView!
    @IBOutlet weak var clearBedDataLabel: UILabel!
    @IBOutlet weak var clearBedDataActivityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var clearBedDataButton: UIButton!
    
    private var clearBedDataFirstClick = true
    
    var bedNo: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.layer.cornerRadius = 4.0
        downloadCsvView.layer.cornerRadius = 4.0
        clearBedDataView.layer.cornerRadius = 4.0
        
        clearBedDataActivityMonitor.isHidden = true
        downloadCsvActivityMonitor.isHidden = true
        
        dataModel.bed_sensorDataSettingsModalCallback = {
            self.clearBedDataLabel.text = "SUCCESS"
            self.clearBedDataActivityMonitor.isHidden = true
            self.clearBedDataActivityMonitor.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: {
                self.clearBedDataLabel.alpha = 1
            }, completion: { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        
        dataModel.bed_downloadCsvCallback = { csvText, path in
            do {
                try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
                vc.excludedActivityTypes = [
                    UIActivityType.assignToContact,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.postToFlickr,
                    UIActivityType.addToReadingList,
                    UIActivityType.markupAsPDF,
                    UIActivityType.postToWeibo,
                    UIActivityType.postToVimeo,
                    UIActivityType.postToTencentWeibo,
                    UIActivityType.postToTwitter,
                    UIActivityType.postToFacebook,
                    UIActivityType.openInIBooks
                ]
                vc.popoverPresentationController?.sourceView = self.downloadCsvView
                vc.popoverPresentationController?.sourceRect = self.downloadCsvView.bounds
                self.present(vc, animated: true, completion: {
                    self.downloadCsvActivityMonitor.isHidden = true
                    self.downloadCsvActivityMonitor.stopAnimating()
                    
                    self.downloadCsvLabel.isHidden = false
                    self.downloadCsvLabel.text = "SUCCESS"
                })
                self.present(vc, animated: true, completion: nil)
            } catch {
                print("Failed to create file")
                print("\(error)")
                self.downloadCsvLabel.isHidden = false
                self.downloadCsvLabel.text = "FAILED"
            }
        }
    }

    @IBAction func didTapOutside(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadCSV(_ sender: Any) {
        if let bedNo = self.bedNo {
            self.downloadCsvLabel.isHidden = true
            self.downloadCsvActivityMonitor.isHidden = false
            self.downloadCsvActivityMonitor.startAnimating()
            self.downloadCsvButton.isEnabled = false
            
            let fileName = "G\(bedNo)_sensorData_\(Date().formatDate4()).csv"
            let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            dataModel.downloadCSV(forBed: bedNo, path: path)
        }
    }
    
    @IBAction func clearBedData(_ sender: Any) {
        if let bed = self.bedNo {
            if clearBedDataFirstClick {
                UIView.animate(withDuration: 0.2, animations: {
                    self.clearBedDataLabel.alpha = 0
                }) { (_) in
                    self.clearBedDataLabel.text = "ARE YOU SURE?"
                    UIView.animate(withDuration: 0.2, animations: {
                        self.clearBedDataLabel.alpha = 1
                    })
                }
                clearBedDataFirstClick = false
            } else {
                clearBedDataButton.isEnabled = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.clearBedDataLabel.alpha = 0
                }) { (_) in
                    self.clearBedDataActivityMonitor.isHidden = false
                    self.clearBedDataActivityMonitor.startAnimating()
                    dataModel.delete_bedSensorData(bed: bed)
                    dataModel.bed_sensorDataSettingsModalCallback?()
                    self.clearBedDataFirstClick = true
                }
            }
        }
    }
}
