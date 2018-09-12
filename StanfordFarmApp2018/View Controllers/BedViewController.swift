//
//  BedViewController.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/8/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class BedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartsView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var manualIrrigationControlView: UIView!
    @IBOutlet weak var manualIrrigationControlWidth: NSLayoutConstraint!
    @IBOutlet weak var manualIrrigationControlTitle: UILabel!
    @IBOutlet weak var scheduleCollectionView: UICollectionView!
    @IBOutlet weak var scheduleIrrigationView: UIView!
    @IBOutlet weak var sensorsSelectionView: UIView!
    
    private var chartData: Array<Any> = []
    private var aaChartModel: AAChartModel?
    private var aaChartView: AAChartView?
    
    var bedNo: Int? {
        didSet {
            configure()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleCollectionView.delegate = self
        scheduleCollectionView.dataSource = self
        
        chartsView.layer.cornerRadius = 4.0
        manualIrrigationControlView.layer.cornerRadius = 4.0
        scheduleIrrigationView.layer.cornerRadius = 4.0
        sensorsSelectionView.layer.cornerRadius = 4.0
        
        dataModel.g1DownloadedCallback = {
            self.chartData = dataModel.G1["sensor1"]!
            self.updateChartData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        manualIrrigationControlWidth.constant = ((self.view.frame.width - (16.0*7.0)) / 6.0)
        self.view.layoutIfNeeded()
        
        configureChart()
    }
    
    func configure() {
        if let bedNo = self.bedNo {
            titleLabel.text = "Bed \(bedNo)"
            manualIrrigationControlTitle.text = "Bed \(bedNo)"
        }
    }
    
    // MARK: - Chart Settings
    
    func configureChart() {
        aaChartView = AAChartView()
        aaChartView?.frame = self.chartView.frame
        self.chartsView.addSubview(aaChartView!)
        aaChartView?.scrollEnabled = false
        aaChartView?.isClearBackgroundColor = true
        
        aaChartModel = AAChartModel()
            .chartType(AAChartType.Line)
            .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0"])
            .title("")
            .subtitle("")
            .yAxisTitle("Counts")
            .dataLabelEnabled(false)
            .tooltipValueSuffix(" Counts")
            .backgroundColor("#ffffff")
            .legendEnabled(false)
            .animationType(AAChartAnimationType.Bounce)
            .animationDuration(500)
            .series([
                AASeriesElement()
                    .name("Sensor 1")
                    .zIndex(1)
                    .marker([
                        "fillColor":"#fe117c" ,
                        "lineWidth": 2,
                        "lineColor":"white"
                        ])
                    .data(self.chartData)
                    .toDic()!,
                ])
        
        aaChartView?.aa_drawChartWithChartModel(aaChartModel!)
    }
    
    func updateChartData() {
        let series = [AASeriesElement()
            .name("Sensor 1")
            .data(self.chartData)
            .toDic()!
        ]
        
        aaChartView?.aa_onlyRefreshTheChartDataWithChartModelSeries(series)
    }
    
    // MARK: - Collection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BedScheduleCollectionViewCell", for: indexPath) as! BedScheduleIrrigationCollectionViewCell
        var dayString = ""
        
        switch indexPath.row {
        case 0:
            dayString = "MON"
        case 1:
            dayString = "TUE"
        case 2:
            dayString = "WED"
        case 3:
            dayString = "THU"
        case 4:
            dayString = "FRI"
        case 5:
            dayString = "SAT"
        case 6:
            dayString = "SUN"
        default:
            dayString = ""
        }
        
        cell.dayLabel.text = dayString
        cell.timeLabel.text = ""
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Schedule Irrigation for Day
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.frame.width
        width = (width - (6*8))/7
        return CGSize(width: width, height: collectionView.frame.height)
    }
}
