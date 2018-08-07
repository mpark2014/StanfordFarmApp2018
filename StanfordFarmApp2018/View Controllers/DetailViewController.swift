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
    @IBOutlet weak var dashContainer: UIView!
    @IBOutlet weak var bedContainer: UIView!
    
    var detailItem: String? {
        didSet {
            configureView()
        }
    }
    
    var isBed: Bool? {
        didSet {
            configureView()
        }
    }
    
    var data: [String:[String:AnyObject]]? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail + "\r\n" + (String(describing: data))
            }
        }
        
        if let bed = isBed {
            if let dContainer = dashContainer {
                if let bContainer = bedContainer {
                    dContainer.isHidden = bed ? true : false
                    bContainer.isHidden = bed ? false : true
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
}

