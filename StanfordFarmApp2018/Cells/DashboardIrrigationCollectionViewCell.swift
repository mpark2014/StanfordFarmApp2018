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
    
    var irrigationSwitch: Bool? {
        didSet {
            configureCell()
        }
    }
    
    func configureCell() {
        if let iBool = irrigationSwitch {
            if let sLabel = switchLabel {
                sLabel.text = iBool ? "ON" : "OFF"
                sLabel.textColor = iBool ? UIColor.white : UIColor.lightGray
                
                if let mLabel = mainTitle {
                    mLabel.textColor = iBool ? UIColor.white : UIColor.lightGray
                }
                
                if let mView = mainView {
                    mView.backgroundColor = iBool ? greenColor : UIColor.white
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 4
        configureCell()
    }
}
