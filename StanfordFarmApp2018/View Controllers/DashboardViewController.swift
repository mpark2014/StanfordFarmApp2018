//
//  DashboardViewController.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/6/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var irrigationCollectionView: UICollectionView!
    @IBOutlet weak var activeSensorsView: UIView!
    @IBOutlet weak var samplingSettingsView: UIView!
    @IBOutlet weak var waterConsumptionVIew: UIView!
    @IBOutlet weak var chartsView: UIView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var toDoView: UIView!
    @IBOutlet weak var chartView: UIView!
    
    var ref: DatabaseReference!
    var data:[String:Bool]! = [:]
    
    private var aaChartModel: AAChartModel?
    private var aaChartView: AAChartView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        irrigationCollectionView.delegate = self
        irrigationCollectionView.dataSource = self
        
        activeSensorsView.layer.cornerRadius = 4
        samplingSettingsView.layer.cornerRadius = 4
        waterConsumptionVIew.layer.cornerRadius = 4
        chartsView.layer.cornerRadius = 4
        messagesView.layer.cornerRadius = 4
        calendarView.layer.cornerRadius = 4
        toDoView.layer.cornerRadius = 4
        
        firebaseGet()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureChart()
    }
    
    func configureChart() {
        aaChartView = AAChartView()
        aaChartView?.frame = self.chartView.frame
        self.chartsView.addSubview(aaChartView!)
        aaChartView?.scrollEnabled = false
        aaChartView?.isClearBackgroundColor = true
        
        aaChartModel = AAChartModel()
            .chartType(AAChartType.Column)
            .colorsTheme(["#1e90ff","#ef476f","#ffd066","#04d69f","#25547c",])
            .title("")
            .subtitle("")
            .dataLabelEnabled(false)
            .tooltipValueSuffix("℃")
            .backgroundColor("#ffffff")
            .animationType(AAChartAnimationType.Bounce)
            .series([
                AASeriesElement()
                    .name("Tokyo")
                    .data([7.0, 6.9, 9.5, 14.5, 18.2, 21.5])
                    .toDic()!,
                AASeriesElement()
                    .name("New York")
                    .data([0, 0.8, 5.7, 11.3, 17.0, 22.0])
                    .toDic()!,
                
//                AASeriesElement()
//                    .name("Berlin")
//                    .data([0.9, 0.6, 3.5, 8.4, 13.5, 17.0])
//                    .toDic()!,
//                AASeriesElement()
//                    .name("London")
//                    .data([3.9, 4.2, 5.7, 8.5, 11.9, 15.2])
//                    .toDic()!,
                ])
        
        self.configureChartStyle()
        aaChartView?.aa_drawChartWithChartModel(aaChartModel!)
    }
    
    func configureChartStyle() {
        aaChartModel = aaChartModel?
            .categories(["BED 1", "BED 2", "BED 3", "BED 4", "BED 5", "BED 6"])
            .legendEnabled(false)
            .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0"])
            .animationType(AAChartAnimationType.Bounce)
            .animationDuration(1000)
            .borderRadius(18)
    }
    
    func firebaseGet() {
        // Firebase GET request
        self.ref = Database.database().reference()
        
        ref.child("iFlag").observe(DataEventType.childAdded, with: { (snapshot) in
            let key = snapshot.key
            let item = ((snapshot.value as! Int) == 0) ? false : true
            self.data[key] = item
            
            DispatchQueue.main.async() {
                self.irrigationCollectionView.reloadData()
            }
        })
        
        ref.child("iFlag").observe(DataEventType.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let item = ((snapshot.value as! Int) == 0) ? false : true
            self.data[key] = item
            
            DispatchQueue.main.async() {
                self.irrigationCollectionView.reloadData()
            }
        })
    }
    
    // MARK: Collection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = irrigationCollectionView.dequeueReusableCell(withReuseIdentifier: "dashboardIrrigationCell", for: indexPath) as! DashboardIrrigationCollectionViewCell
        
        cell.mainTitle.text = "Bed " + String(indexPath.row+1)
        cell.irrigationSwitch = self.data["G\(indexPath.row+1)"]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let iSwitch = self.data["G\(indexPath.row+1)"] {
            self.ref.child("iFlag/G\(indexPath.row+1)").setValue(!iSwitch)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = collectionView.frame.width
        width = (width - (7*16))/6
        return CGSize(width: width, height: collectionView.frame.height)
        
    }
}
