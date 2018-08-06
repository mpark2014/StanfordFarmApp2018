//
//  DashboardIrrigationCollectionViewCell.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/6/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class DashboardIrrigationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var switchLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 4
    }
}
