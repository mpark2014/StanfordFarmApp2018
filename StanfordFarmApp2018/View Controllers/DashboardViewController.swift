//
//  DashboardViewController.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/6/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var irrigationCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        irrigationCollectionView.delegate = self
        irrigationCollectionView.dataSource = self
    }

    // MARK: Collection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = irrigationCollectionView.dequeueReusableCell(withReuseIdentifier: "dashboardIrrigationCell", for: indexPath) as! DashboardIrrigationCollectionViewCell
        
        cell.mainTitle.text = "Bed " + String(indexPath.row+1)
        cell.switchLabel.text = "OFF"
        
        return cell
    }
}
