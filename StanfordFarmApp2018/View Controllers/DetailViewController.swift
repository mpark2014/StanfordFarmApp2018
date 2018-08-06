//
//  DetailViewController.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/1/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail + "\r\n" + (String(describing: data))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    var data: [String:[String:AnyObject]]? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

