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
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var dayInt: Int?
    var dayString = ""
    var bedNo: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.layer.cornerRadius = 4.0
        cancelView.layer.cornerRadius = 4.0
        confirmView.layer.cornerRadius = 4.0
        removeView.layer.cornerRadius = 4.0
        cancelImageView.setImageColor(color: UIColor.white)
        
//        startDatePicker.date = Calendar(identifier: .gregorian).startOfDay(for: Date())
//        endDatePicker.date = Calendar(identifier: .gregorian).startOfDay(for: Date())
        
        if let dayInt = self.dayInt {
            switch dayInt {
            case 0:
                dayString = "MONDAY"
            case 1:
                dayString = "TUESDAY"
            case 2:
                dayString = "WEDNESDAY"
            case 3:
                dayString = "THURSDAY"
            case 4:
                dayString = "FRIDAY"
            case 5:
                dayString = "SATURDAY"
            case 6:
                dayString = "SUNDAY"
            default:
                dayString = ""
            }
            titleLabel.text = "\(dayString) IRRIGATION"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapConfirm(_ sender: Any) {
        if let bedNo = self.bedNo {
            if let _ = self.dayInt {
                let start = startDatePicker.date
                let end = endDatePicker.date
                if start<end {
                    dataModel.post_scheduledIrrigationTime(bed: bedNo, day: dayString, start: start, end: end)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func didTapRemove(_ sender: Any) {
        if let bedNo = self.bedNo {
            if let _ = self.dayInt {
                dataModel.delete_iScheduleItem(bed: bedNo, day: dayString)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
