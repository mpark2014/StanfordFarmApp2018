//
//  DashboardSensorTableViewCell.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/6/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class DashboardSensorTableViewCell: UITableViewCell {

    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIView!
    
    var isActive: Bool? {
        didSet {
            configureView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.layer.cornerRadius = activityIndicator.frame.width/2
    }
    
    func configureView() {
        if let aBool = isActive {
            if let aIndicator = activityIndicator {
                aIndicator.isHidden = !aBool
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
