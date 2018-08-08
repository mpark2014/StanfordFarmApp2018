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
    @IBOutlet weak var addView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 4
        addView.layer.cornerRadius = 4
    }
}
