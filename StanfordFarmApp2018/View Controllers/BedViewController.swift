//
//  BedViewController.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/8/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit

class BedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartsView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var manualIrrigationControlView: UIView!
    @IBOutlet weak var manualIrrigationControlWidth: NSLayoutConstraint!
    @IBOutlet weak var manualIrrigationControlTitle: UILabel!
    @IBOutlet weak var manualIrrigationControlStatus: UILabel!
    @IBOutlet weak var scheduleCollectionView: UICollectionView!
    @IBOutlet weak var scheduleIrrigationView: UIView!
    @IBOutlet weak var sensorsSelectionView: UIView!
    @IBOutlet weak var sensorsSelectionTableView: UITableView!
    
    private var chartData: Array<Any> = []
    private var aaChartModel: AAChartModel?
    private var aaChartView: AAChartView?
    var scheduleModal_dayString = ""
    
    var bedNo: Int? {
        didSet {
            configure()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sensorsSelectionTableView.delegate = self
        sensorsSelectionTableView.dataSource = self
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
        
        dataModel.bed_iFlag_Callback = {
            self.configure()
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
            
            if let iBool = dataModel.dashboard_iFlagData["G\(bedNo)"] {
                manualIrrigationControlStatus.text = iBool ? "ON" : "OFF"
                manualIrrigationControlStatus.textColor = iBool ? UIColor.white : UIColor.lightGray
                manualIrrigationControlTitle.textColor = iBool ? UIColor.white : UIColor.lightGray
                manualIrrigationControlView.backgroundColor = iBool ? greenColor : UIColor.white
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func irrigateBed(_ sender: Any) {
        if let bedNo = self.bedNo {
            if let iSwitch = dataModel.dashboard_iFlagData["G\(bedNo)"] {
                dataModel.post_iFlag(bed: bedNo, iFlag: !iSwitch)
            }
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
        switch indexPath.row {
        case 0:
            scheduleModal_dayString = "MONDAY"
        case 1:
            scheduleModal_dayString = "TUESDAY"
        case 2:
            scheduleModal_dayString = "WEDNESDAY"
        case 3:
            scheduleModal_dayString = "THURSDAY"
        case 4:
            scheduleModal_dayString = "FRIDAY"
        case 5:
            scheduleModal_dayString = "SATURDAY"
        case 6:
            scheduleModal_dayString = "SUNDAY"
        default:
            scheduleModal_dayString = ""
        }
        
        performSegue(withIdentifier: "editScheduleSegue", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.frame.width
        width = (width - (6*8))/7
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sensorsSelectionTableViewCell")!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.frame.height/7)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editScheduleSegue" {
            let destinationVC = segue.destination as! ScheduleIrrigationModalViewController
            destinationVC.dayTitle = scheduleModal_dayString
        }
    }
}
