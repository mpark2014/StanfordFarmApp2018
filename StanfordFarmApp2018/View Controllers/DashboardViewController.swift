//
//  DashboardViewController.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/6/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var irrigationCollectionView: UICollectionView!
    @IBOutlet weak var sensorsView: UIView!
    @IBOutlet weak var samplingSettingsView: UIView!
    @IBOutlet weak var waterConsumptionVIew: UIView!
    @IBOutlet weak var chartsView: UIView!
    @IBOutlet weak var irrigationQueueView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var sensorsTableView: UITableView!
    @IBOutlet weak var scheduleIrrigationView: UIView!
    @IBOutlet weak var sensorsSamplingSettingsView: UIView!
    @IBOutlet weak var irrigationSamplingSettingsView: UIView!
    @IBOutlet weak var irrigationSamplingValue: UILabel!
    @IBOutlet weak var irrigationUpdatedLabel: UILabel!
    @IBOutlet weak var sensorsSamplingValue: UILabel!
    @IBOutlet weak var sensorsUpdatedLabel: UILabel!
    @IBOutlet weak var scheduleIrrigationCollectionView: UICollectionView!
    @IBOutlet weak var irrigationQueueTableView: UITableView!
    @IBOutlet weak var scheduleIrrigationLeftArrowImage: UIImageView!
    @IBOutlet weak var scheduleIrrigationLeftArrowButton: UIButton!
    @IBOutlet weak var scheduleIrrigationRightArrowImage: UIImageView!
    @IBOutlet weak var scheduleIrrigationRightArrowButton: UIButton!
    @IBOutlet weak var statusTableView: UITableView!
    
    var scheduledIrrigationStartValue:Date? = Date()
    
    private var aaChartModel: AAChartModel?
    private var aaChartView: AAChartView?
    private var isSensorSamplingModal: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        irrigationCollectionView.delegate = self
        irrigationCollectionView.dataSource = self
        sensorsTableView.delegate = self
        sensorsTableView.dataSource = self
        scheduleIrrigationCollectionView.delegate = self
        scheduleIrrigationCollectionView.dataSource = self
        irrigationQueueTableView.delegate = self
        irrigationQueueTableView.dataSource = self
        statusTableView.delegate = self
        statusTableView.dataSource = self
        
        irrigationQueueTableView.rowHeight = (irrigationQueueTableView.frame.height+1)/6
        
        sensorsView.layer.cornerRadius = 4
        samplingSettingsView.layer.cornerRadius = 4
        waterConsumptionVIew.layer.cornerRadius = 4
        chartsView.layer.cornerRadius = 4
        irrigationQueueView.layer.cornerRadius = 4
        statusView.layer.cornerRadius = 4
        scheduleIrrigationView.layer.cornerRadius = 4
        sensorsSamplingSettingsView.layer.cornerRadius = 4
        irrigationSamplingSettingsView.layer.cornerRadius = 4
        
        setupCallbacks()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureChart()
    }
    
    func setupCallbacks() {
        dataModel.dashboard_iFlag_Callback = {
            DispatchQueue.main.async() {
                self.irrigationCollectionView.reloadData()
            }
        }
        
        dataModel.dashboard_liveData_Callback = {
            DispatchQueue.main.async() {
                self.sensorsTableView.reloadData()
                self.updateChartData()
            }
        }
        
        dataModel.dashboard_settings_Callback = {
            DispatchQueue.main.async() {
                self.configureSamplingSettings()
            }
        }
        
        dataModel.dashboard_iQueueList_Callback = {
            DispatchQueue.main.async() {
                self.irrigationQueueTableView.reloadData()
            }
        }
        
        dataModel.dashboard_iQueueBed_Callback = {
            DispatchQueue.main.async() {
                self.statusTableView.reloadData()
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
            .chartType(AAChartType.Column)
            .colorsTheme(["#1e90ff","#ef476f","#ffd066","#04d69f","#25547c",])
            .title("")
            .subtitle("")
            .dataLabelEnabled(false)
            .tooltipValueSuffix(" Counts")
            .backgroundColor("#ffffff")
            .series([
                AASeriesElement()
                    .name("Sensor")
                    .data(dataModel.dashboard_chartData)
                    .toDic()!,
                ])
        
        self.configureChartStyle()
        aaChartView?.aa_drawChartWithChartModel(aaChartModel!)
    }
    
    func updateChartData() {
        let series = [AASeriesElement()
            .name("Sensor")
            .data(dataModel.dashboard_chartData)
            .toDic()!
        ]
        aaChartView?.aa_onlyRefreshTheChartDataWithChartModelSeries(series)
    }
    
    func configureChartStyle() {
        aaChartModel = aaChartModel?
            .categories(["BED 1", "BED 2", "BED 3", "BED 4", "BED 5", "BED 6", "BED 7", "BED 8", "BED 9", "BED 10", "BED 11", "BED 12", "BED 13", "BED 14", "BED 15"])
            .legendEnabled(false)
            .symbolStyle(AAChartSymbolStyleType.BorderBlank)
            .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0"])
            .animationType(AAChartAnimationType.Bounce)
            .animationDuration(500)
            .borderRadius(8)
    }
    
    func configureSamplingSettings() {
        if var iValue = dataModel.dashboard_settings["iInterval"] {
            let hours = iValue/(60*60)
            iValue -= (hours*60*60)
            
            let minutes = iValue/60
            iValue -= (minutes*60)
            
            let seconds = iValue
            
            irrigationSamplingValue.text = "\(hours>9 ? "" : "0")\(hours):\(minutes>9 ? "" : "0")\(minutes):\(seconds>9 ? "" : "0")\(seconds)"
        }
        
        if var sValue = dataModel.dashboard_settings["sInterval"] {
            let hours = sValue/(60*60)
            sValue -= (hours*60*60)
            
            let minutes = sValue/60
            sValue -= (minutes*60)
            
            let seconds = sValue
            
            sensorsSamplingValue.text = "\(hours>9 ? "" : "0")\(hours):\(minutes>9 ? "" : "0")\(minutes):\(seconds>9 ? "" : "0")\(seconds)"
        }
        
        if let iUValue = dataModel.dashboard_settings["iLastUpdated"] as? Int {
            let date = Date(timeIntervalSince1970: (Double(iUValue/1000)))
            irrigationUpdatedLabel.text = "Last Updated: \(date.formatDate1())"
        }
        
        if let sUValue = dataModel.dashboard_settings["sLastUpdated"] as? Int {
            let date = Date(timeIntervalSince1970: (Double(sUValue/1000)))
            sensorsUpdatedLabel.text = "Last Updated: \(date.formatDate1())"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func scheduleIrrigationRightTapped(_ sender: Any) {
        let currentIndex = Int(self.scheduleIrrigationCollectionView.contentOffset.x / self.scheduleIrrigationCollectionView.frame.width)
        if currentIndex < 5 {
            let currentIndexPath = IndexPath(item: currentIndex+1, section: 0)
            scheduleIrrigationCollectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func scheduleIrrigationLeftTapped(_ sender: Any) {
        let currentIndex = Int(self.scheduleIrrigationCollectionView.contentOffset.x / self.scheduleIrrigationCollectionView.frame.width)
        if currentIndex > 0 {
            let currentIndexPath = IndexPath(item: currentIndex-1, section: 0)
            scheduleIrrigationCollectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func didTapSamplingSettings_irrigation(_ sender: Any) {
        isSensorSamplingModal = false
        performSegue(withIdentifier: "samplingSettingsSegue", sender: self)
    }
    
    @IBAction func didTapSamplingSettings_sensors(_ sender: Any) {
        isSensorSamplingModal = true
        performSegue(withIdentifier: "samplingSettingsSegue", sender: self)
    }
    
    // MARK: - Collection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return 15
        case 1:
            return 15
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dashboardIrrigationCell", for: indexPath) as! DashboardIrrigationCollectionViewCell
            
            cell.mainTitle.text = "Bed " + String(indexPath.row+1)
            cell.irrigationSwitch = dataModel.dashboard_iFlagData["G\(indexPath.row+1)"]
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dashScheduleIrrigationCell", for: indexPath) as! DashboardScheduleIrrigationCollectionViewCell
            
            cell.mainTitle.text = "Bed " + String(indexPath.row+1)
            cell.startConfirmButton.tag = indexPath.row
            cell.endConfirmButton.tag = indexPath.row
            cell.deleteButton.tag = indexPath.row
            cell.hideEndConfirm = true
            cell.datePicker.date = Date()
            cell.startConfirmButton.addTarget(self, action: #selector(startConfirmButton(sender:)), for: .touchUpInside)
            cell.endConfirmButton.addTarget(self, action: #selector(endConfirmButton(sender:)), for: .touchUpInside)
            cell.deleteButton.addTarget(self, action: #selector(deleteConfirmButton(sender:)), for: .touchUpInside)
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    @IBAction func startConfirmButton(sender: UIButton) {
        print("Bed \(sender.tag+1) start confirm clicked")
        let currentIndex = Int(self.scheduleIrrigationCollectionView.contentOffset.x / self.scheduleIrrigationCollectionView.frame.width)
        let currentIndexPath = IndexPath(item: currentIndex, section: 0)
        let currentCell = scheduleIrrigationCollectionView.cellForItem(at: currentIndexPath) as! DashboardScheduleIrrigationCollectionViewCell

        currentCell.startConfirmButtonTappedConfigure()
        var date = currentCell.datePicker.date
        let timeInterval = floor(date.timeIntervalSince1970 / 60.0) * 60
        date = Date(timeIntervalSince1970: timeInterval)
        scheduledIrrigationStartValue = date
    }

    @IBAction func deleteConfirmButton(sender: UIButton) {
        print("Bed \(sender.tag+1) delete confirm clicked")
        let currentIndex = Int(self.scheduleIrrigationCollectionView.contentOffset.x / self.scheduleIrrigationCollectionView.frame.width)
        let currentIndexPath = IndexPath(item: currentIndex, section: 0)
        let currentCell = scheduleIrrigationCollectionView.cellForItem(at: currentIndexPath) as! DashboardScheduleIrrigationCollectionViewCell

        currentCell.endConfirmOrDeleteTappedConfigure()
        scheduledIrrigationStartValue = nil
    }

    @IBAction func endConfirmButton(sender: UIButton) {
        print("Bed \(sender.tag+1) end confirm clicked")
        let currentIndex = Int(self.scheduleIrrigationCollectionView.contentOffset.x / self.scheduleIrrigationCollectionView.frame.width)
        let currentIndexPath = IndexPath(item: currentIndex, section: 0)
        let currentCell = scheduleIrrigationCollectionView.cellForItem(at: currentIndexPath) as! DashboardScheduleIrrigationCollectionViewCell

        currentCell.endConfirmOrDeleteTappedConfigure()
        var date = currentCell.datePicker.date
        let timeInterval = floor(date.timeIntervalSince1970 / 60.0) * 60
        date = Date(timeIntervalSince1970: timeInterval)

        if date < Date() {
            // HANDLE ERROR
            print("ERROR1")
        } else if date <= scheduledIrrigationStartValue! {
            // HANDLE ERROR
            print("ERROR2")
        } else {
            print(scheduledIrrigationStartValue!)
            dataModel.post_iQueueItem(bed: currentIndex+1, start: scheduledIrrigationStartValue!.timeIntervalSince1970*1000, end: timeInterval*1000, type: 1, status: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 0:
            if let iSwitch = dataModel.dashboard_iFlagData["G\(indexPath.row+1)"] {
                dataModel.post_iFlag(bed: indexPath.row+1, iFlag: !iSwitch)
            }
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 0:
            return
        case 1:
            scheduledIrrigationStartValue = nil
            let scheduleIrrigationCell = cell as! DashboardScheduleIrrigationCollectionViewCell
            scheduleIrrigationCell.hideEndConfirm = true
            scheduleIrrigationCell.datePicker.date = Date()
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 0:
            var width = collectionView.frame.width
            width = (width - (4*16))/5
            var height = collectionView.frame.height
            height = (height - (2*16))/3
            return CGSize(width: width, height: height)
        case 1:
            var width = collectionView.frame.width
            width = width - (2*16)
            return CGSize(width: width, height: collectionView.frame.height)
        default:
            return CGSize()
        }
    }
    
    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return dataModel.dashboard_liveSensorData.count
        case 1:
            return dataModel.dashboard_iQueueArray.count
        case 2:
            return 15
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sensorsTableViewCell")! as! DashboardSensorTableViewCell
            
            let key = dataModel.dashboard_liveSensorDataKeys[indexPath.row]
            let sensorNo = key.dropFirst(3)
            let bedNo = key.dropLast(2)
            let dataStringified = "G\(bedNo) | Sensor \(sensorNo)"
            
            let value = dataModel.dashboard_liveSensorData[key] as! [String:Int]
            
            cell.selectionStyle = .none
            cell.isActive = (value["usage"] == 0) ? false : true
            cell.mainTitle.text = dataStringified
            cell.valueLabel.text = String(value["value"]!)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "irrigationQueueCell")! as! DashIrrigationQueueTableViewCell
            let item = dataModel.dashboard_iQueueArray[indexPath.row]
            cell.bedLabel.text = "Bed \(item.bedNo) | "
            cell.selectionStyle = .none
            
            if item.status == iQueueStatus.complete {
                cell.configureComplete()
                cell.deleteButton.tag = indexPath.row
                cell.deleteButton.addTarget(self, action: #selector(deleteiQueueItem(sender:)), for: .touchUpInside)
            } else {
                cell.configurePending()
            }
            
            if Calendar.current.isDate(item.end, inSameDayAs: item.start) {
                cell.detailLabel.text = "\(item.start.formatDate1()) - \(item.end.formatDate2())"
            } else {
                cell.detailLabel.text = "\(item.start.formatDate1()) - \(item.end.formatDate1())"
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "dashStatusCell")! as! DashboardStatusTableViewCell
            let array = dataModel.dashboard_iStatusDict["G\(indexPath.row+1)"]!
            cell.bedLabel.text = "G\(indexPath.row+1)"
            cell.selectionStyle = .none
            
            if array.isEmpty {
                cell.configureNone()
            } else {
                let item = array[0]
                cell.configureType(type: item.type, endTime: item.end.formatDate1())
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 0:
            return (tableView.frame.height+1)/10
        case 1:
            return (tableView.frame.height+1)/6
        case 2:
            return tableView.frame.height/6
        default:
            return 0
        }
    }
    
    @IBAction func deleteiQueueItem(sender: UIButton) {
        print("\(sender.tag+1) delete button clicked")
        dataModel.delete_iQueueItem(bed: nil, itemNo: sender.tag)
        self.irrigationQueueTableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "samplingSettingsSegue" {
            let destinationVC = segue.destination as! SamplingSettingsModalViewController
            destinationVC.isSensorSampling = isSensorSamplingModal
        }
    }
}
