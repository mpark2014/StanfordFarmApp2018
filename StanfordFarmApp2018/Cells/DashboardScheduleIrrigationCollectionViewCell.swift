//
//  DashboardScheduleIrrigationCollectionViewCell.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/7/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class DashboardScheduleIrrigationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var startConfirmButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteImageView: UIImageView!
    @IBOutlet weak var endConfirmView: UIView!
    @IBOutlet weak var startConfirmView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var endConfirmButton: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var hideEndConfirm:Bool = true {
        didSet {
            configureCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 4
        startConfirmView.layer.cornerRadius = 4
        deleteView.layer.cornerRadius = 4
        endConfirmView.layer.cornerRadius = 4
        deleteImageView.setImageColor(color: UIColor.white)
        configureCell()
    }
    
    func configureCell() {
        endConfirmView.isHidden = hideEndConfirm
        deleteView.isHidden = hideEndConfirm
        startLabel.isHidden = hideEndConfirm
        startConfirmView.isHidden = !hideEndConfirm
        
        endConfirmView.alpha = hideEndConfirm ? 0 : 1
        deleteView.alpha =  hideEndConfirm ? 0 : 1
        startLabel.alpha = hideEndConfirm ? 0 : 1
        startConfirmView.alpha = !hideEndConfirm ? 0 : 1
    }
    
    @IBAction func startConfirmButtonTapped(_ sender: Any) {
        var date = self.datePicker.date
        let timeInterval = floor(date.timeIntervalSince1970 / 60.0) * 60
        date = Date(timeIntervalSince1970: timeInterval)
        startLabel.text = "Start: \(date.formatDate())"
        
        UIView.animate(withDuration: 0.2, animations: {
            self.startConfirmView.alpha = 0
        }) { (complete) in
            self.startConfirmView.isHidden = true
            self.endConfirmView.isHidden = false
            self.deleteView.isHidden = false
            self.startLabel.isHidden = false
            UIView.animate(withDuration: 0.25, animations: {
                self.endConfirmView.alpha = 1
                self.deleteView.alpha = 1
                self.startLabel.alpha = 1
            })
        }
    }
    
    @IBAction func endConfirmOrDeleteTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.endConfirmView.alpha = 0
            self.deleteView.alpha = 0
            self.startLabel.alpha = 0
        }) { (complete) in
            self.endConfirmView.isHidden = true
            self.deleteView.isHidden = true
            self.startLabel.isHidden = true
            self.startConfirmView.isHidden = false
            UIView.animate(withDuration: 0.25, animations: {
                self.startConfirmView.alpha = 1
            })
        }
    }
}
