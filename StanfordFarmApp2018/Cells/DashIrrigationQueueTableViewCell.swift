//
//  DashIrrigationQueueTableViewCell.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/9/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class DashIrrigationQueueTableViewCell: UITableViewCell {

    @IBOutlet weak var bedLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
