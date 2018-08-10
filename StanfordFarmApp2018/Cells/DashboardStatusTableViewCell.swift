//
//  DashboardStatusTableViewCell.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/10/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class DashboardStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var bedView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    func configureNone() {
        bedView.backgroundColor = UIColor.lightGray
        statusLabel.textColor = UIColor.lightGray
        
        let text = NSMutableAttributedString(string: "NO ACTIVITY", attributes: [.font : UIFont(name: "AvenirNext-Regular", size: 14)!])
        statusLabel.attributedText = text
    }
    
    func configureType(type: iQueueType, endTime: String) {
        bedView.backgroundColor = greenColor
        var statusString = ""
        
        switch type {
        case iQueueType.automatedScheduled:
            statusString = "AUTOMATED IRRIGATION"
        case iQueueType.manual:
            statusString = "MANUAL IRRIGATION"
        case iQueueType.scheduled:
            statusString = "SCHEDULED IRRIGATION"
        case iQueueType.sensor:
            statusString = "SENSOR BASED IRRIGATION"
        }
        
        let text1 = NSMutableAttributedString(string: "\(statusString)\r\n", attributes:
            [.font: UIFont(name: "AvenirNext-Bold", size: 16)!,
             .foregroundColor: greenColor])
        let text2 = NSMutableAttributedString(string: "UNTIL \(endTime.uppercased())", attributes:
            [.font: UIFont(name: "AvenirNext-Regular", size: 14)!,
             .foregroundColor: greenColor])
        text1.append(text2)
        statusLabel.attributedText = text1
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bedView.layer.cornerRadius = bedView.frame.height/2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
