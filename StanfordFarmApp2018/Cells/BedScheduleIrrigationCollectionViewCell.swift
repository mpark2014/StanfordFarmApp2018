//
//  BedScheduleIrrigationCollectionViewCell.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 9/12/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class BedScheduleIrrigationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        outerView.layer.borderColor = UIColor.lightGray.cgColor
        outerView.layer.cornerRadius = 4.0
        outerView.layer.borderWidth = 1.0
    }
    
    func configure(on: Bool) {
        if on {
            outerView.layer.borderWidth = 0
            outerView.backgroundColor = greenColor
            dayLabel.textColor = UIColor.white
            timeLabel.textColor = UIColor.white
        } else {
            outerView.layer.borderWidth = 1.0
            outerView.backgroundColor = UIColor.white
            dayLabel.textColor = UIColor.lightGray
            timeLabel.textColor = UIColor.lightGray
        }
    }
}
