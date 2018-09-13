//
//  ScheduleIrrigationModalViewController.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 9/12/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class ScheduleIrrigationModalViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cancelImageView: UIImageView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var removeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var dayTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.layer.cornerRadius = 4.0
        cancelView.layer.cornerRadius = 4.0
        confirmView.layer.cornerRadius = 4.0
        removeView.layer.cornerRadius = 4.0
        cancelImageView.setImageColor(color: UIColor.white)
        
        if let dayTitle = self.dayTitle {
            titleLabel.text = "\(dayTitle) IRRIGATION"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapConfirm(_ sender: Any) {
    }
    
    @IBAction func didTapRemove(_ sender: Any) {
    }
}
