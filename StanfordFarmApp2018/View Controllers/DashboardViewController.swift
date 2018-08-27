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
    
    var ref: DatabaseReference!
    var iFlagData:[String:Bool]! = [:]
    var liveSensorData:[String:[String:Int]]! = [:]
    var settings:[String:Int]! = [:]
    var chartData:[Int]! = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var scheduledIrrigationStartValue:Date? = Date()
    var iQueueArray:[iQueueItem] = []
    var iStatusDict:[String:[iQueueItem]]! = ["G1":[],"G2":[],"G3":[],"G4":[],"G5":[],"G6":[],"G7":[],"G8":[],"G9":[],"G10":[],"G11":[],"G12":[],"G13":[],"G14":[],"G15":[]]
    
    private var aaChartModel: AAChartModel?
    private var aaChartView: AAChartView?
    
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
        
        sensorsView.layer.cornerRadius = 4
        samplingSettingsView.layer.cornerRadius = 4
        waterConsumptionVIew.layer.cornerRadius = 4
        chartsView.layer.cornerRadius = 4
        irrigationQueueView.layer.cornerRadius = 4
        statusView.layer.cornerRadius = 4
        scheduleIrrigationView.layer.cornerRadius = 4
        sensorsSamplingSettingsView.layer.cornerRadius = 4
        irrigationSamplingSettingsView.layer.cornerRadius = 4
        
        firebaseGet()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureChart()
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
            .animationType(AAChartAnimationType.Bounce)
            .series([
                AASeriesElement()
                    .name("Sensor")
                    .data(chartData)
                    .toDic()!,
                ])
        
        self.configureChartStyle()
        aaChartView?.aa_drawChartWithChartModel(aaChartModel!)
    }
    
    func updateChartData() {
        aaChartModel = aaChartModel?
            .series([
                AASeriesElement()
                    .name("Sensor")
                    .data(chartData)
                    .toDic()!,
                ])
        
        aaChartView?.aa_drawChartWithChartModel(aaChartModel!)
    }
    
    func configureChartStyle() {
        aaChartModel = aaChartModel?
            .categories(["BED 1", "BED 2", "BED 3", "BED 4", "BED 5", "BED 6", "BED 7", "BED 8", "BED 9", "BED 10", "BED 11", "BED 12", "BED 13", "BED 14", "BED 15"])
            .legendEnabled(false)
            .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0"])
            .animationType(AAChartAnimationType.Bounce)
            .animationDuration(1000)
            .borderRadius(8)
    }
    
    func configureSamplingSettings() {
        if var iValue = self.settings["iInterval"] {
            let hours = iValue/(60*60)
            iValue -= (hours*60*60)
            
            let minutes = iValue/60
            iValue -= (minutes*60)
            
            let seconds = iValue
            
            irrigationSamplingValue.text = "\(hours>9 ? "" : "0")\(hours):\(minutes>9 ? "" : "0")\(minutes):\(seconds>9 ? "" : "0")\(seconds)"
        }
        
        if var sValue = self.settings["sInterval"] {
            let hours = sValue/(60*60)
            sValue -= (hours*60*60)
            
            let minutes = sValue/60
            sValue -= (minutes*60)
            
            let seconds = sValue
            
            sensorsSamplingValue.text = "\(hours>9 ? "" : "0")\(hours):\(minutes>9 ? "" : "0")\(minutes):\(seconds>9 ? "" : "0")\(seconds)"
        }
        
        if let iUValue = self.settings["iLastUpdated"] as? Int {
            let date = Date(timeIntervalSince1970: (Double(iUValue/1000)))
            irrigationUpdatedLabel.text = "Last Updated: \(date.formatDate1())"
        }
        
        if let sUValue = self.settings["sLastUpdated"] as? Int {
            let date = Date(timeIntervalSince1970: (Double(sUValue/1000)))
            sensorsUpdatedLabel.text = "Last Updated: \(date.formatDate1())"
        }
    }
    
    func firebaseGet() {
        // Firebase GET request
        self.ref = Database.database().reference()
        
        ref.child("iFlag").observe(DataEventType.childAdded, with: { (snapshot) in
            let key = snapshot.key
            let item = ((snapshot.value as! Int) == 0) ? false : true
            self.iFlagData[key] = item
            
            DispatchQueue.main.async() {
                self.irrigationCollectionView.reloadData()
            }
        })
        
        ref.child("Live").observe(DataEventType.childAdded, with: { (snapshot) in
            let key = snapshot.key
            var keyMut = key
            let value = (snapshot.value as! [String:[String:Int]])
            
            for (marker, item) in value {
                var markerMut = marker
                markerMut.insert(" ", at: markerMut.index(before: markerMut.endIndex))
                self.liveSensorData["\(key) | \(markerMut.capitalized)"] = item
                
                if marker.last == "1" {
                    if let bedNo = Int(String(keyMut.dropFirst())) {
                        self.chartData[bedNo-1] = item["value"] as! Int
                    }
                }
            }
            
            DispatchQueue.main.async() {
                self.sensorsTableView.reloadData()
                self.updateChartData()
            }
        })
        
        ref.child("Settings").observe(DataEventType.childAdded, with: { (snapshot) in
            let key = snapshot.key
            let value = snapshot.value as! Int
            self.settings[key] = value
            
            DispatchQueue.main.async() {
                self.configureSamplingSettings()
            }
        })
        
        ref.child("iQueueList").queryOrdered(byChild: "start").observe(.childAdded) { (snapshot) in
            let uuid = snapshot.key
            let value = snapshot.value as! [String:Any]
            let bed = value["bed"] as! Int
            let bedString = value["blockBed"] as! String
            let start = Date(timeIntervalSince1970: Double((value["start"] as! Int)/1000))
            let end = Date(timeIntervalSince1970: Double((value["end"] as! Int)/1000))
            let now = Date()
            let type = iQueueType(rawValue: value["type"] as! Int)
            let item = iQueueItem(uuid: uuid, bedNo: bed, bedString: bedString, start: start, end: end, type: type!)
            
            if !self.iQueueArray.contains(item) {
                insertSortedIQueueItem(array: &(self.iQueueArray), element: item)
            }
            
            DispatchQueue.main.async() {
                self.irrigationQueueTableView.reloadData()
            }
        }
        
        // INSERT MORE IQUEUELIST WATCHDOGS
        
        ref.child("iQueueBed").queryOrdered(byChild: "start").observe(.childAdded) { (snapshot) in
            let bedString = snapshot.key
            var iStatusArray = self.iStatusDict[bedString]!
            let value = snapshot.value as! [String:[String:Any]]
            
            for (snapshotUuid, snapshotItem) in value {
                let uuid = snapshotUuid
                let start = Date(timeIntervalSince1970: Double((snapshotItem["start"] as! Int)/1000))
                let end = Date(timeIntervalSince1970: Double((snapshotItem["end"] as! Int)/1000))
                let now = Date()
                let type = iQueueType(rawValue: snapshotItem["type"] as! Int)!
                let bed = snapshotItem["bed"] as! Int
                let item = iQueueItem(uuid: uuid, bedNo: bed, bedString: bedString, start: start, end: end, type: type)
                if !(iStatusArray.contains(item)) && now > start && now < end {
                    insertSortedIQueueItem(array: &iStatusArray, element: item)
                }
            }
            
            self.iStatusDict[bedString] = iStatusArray
            DispatchQueue.main.async() {
                self.statusTableView.reloadData()
            }
        }
        
        ref.child("iFlag").observe(DataEventType.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let item = ((snapshot.value as! Int) == 0) ? false : true
            self.iFlagData[key] = item
            
            DispatchQueue.main.async() {
                self.irrigationCollectionView.reloadData()
            }
        })
        
        ref.child("Live").observe(DataEventType.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let value = (snapshot.value as! [String:[String:Int]])
            
            for (marker, item) in value {
                var markerMut = marker
                markerMut.insert(" ", at: markerMut.index(before: markerMut.endIndex))
                self.liveSensorData["\(key) | \(markerMut.capitalized)"] = item
                
                if marker.last == "1" {
                    if let bedNo = Int(String(key.last!)) {
                        self.chartData[bedNo-1] = item["value"] as! Int
                    }
                }
            }
            
            DispatchQueue.main.async() {
                self.sensorsTableView.reloadData()
                self.updateChartData()
            }
        })
        
        ref.child("Settings").observe(DataEventType.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let value = snapshot.value as! Int
            self.settings[key] = value
            
            DispatchQueue.main.async() {
                self.configureSamplingSettings()
            }
        })
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
            cell.irrigationSwitch = self.iFlagData["G\(indexPath.row+1)"]
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
        
        var date = currentCell.datePicker.date
        let timeInterval = floor(date.timeIntervalSince1970 / 60.0) * 60
        date = Date(timeIntervalSince1970: timeInterval)
        scheduledIrrigationStartValue = date
    }
    
    @IBAction func deleteConfirmButton(sender: UIButton) {
        print("Bed \(sender.tag+1) delete confirm clicked")
        scheduledIrrigationStartValue = nil
    }
    
    @IBAction func endConfirmButton(sender: UIButton) {
        print("Bed \(sender.tag+1) end confirm clicked")
        let currentIndex = Int(self.scheduleIrrigationCollectionView.contentOffset.x / self.scheduleIrrigationCollectionView.frame.width)
        let currentIndexPath = IndexPath(item: currentIndex, section: 0)
        let currentCell = scheduleIrrigationCollectionView.cellForItem(at: currentIndexPath) as! DashboardScheduleIrrigationCollectionViewCell
        
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
            
            let iQueueListItem = [
                "bed": currentIndex+1,
                "blockBed": "G\(currentIndex+1)",
                "end": timeInterval*1000,
                "start": scheduledIrrigationStartValue!.timeIntervalSince1970*1000,
                "type": 1
                ] as [String:Any]
            let reference = self.ref.child("iQueueList").childByAutoId()
            reference.setValue(iQueueListItem)
            let uuid = reference.key
            
            let iQueueBedItem = [
                "end": timeInterval*1000,
                "start": scheduledIrrigationStartValue!.timeIntervalSince1970*1000,
                "bed": currentIndex+1,
                "type": 1
                ] as [String:Any]
            self.ref.child("iQueueBed/G\(currentIndex+1)/\(uuid)").setValue(iQueueBedItem)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 0:
            if let iSwitch = self.iFlagData["G\(indexPath.row+1)"] {
                self.ref.child("iFlag/G\(indexPath.row+1)").setValue(!iSwitch)
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 0:
            var width = collectionView.frame.width
            width = (width - (7*16))/6
            return CGSize(width: width, height: collectionView.frame.height)
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
            return liveSensorData.count
        case 1:
            return iQueueArray.count
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
            var keys = Array(liveSensorData.keys)
            print(keys)
            keys.sort()
            let key = keys[indexPath.row]
            let value = liveSensorData[key] as! [String:Int]
            
            cell.isActive = (value["usage"] == 0) ? false : true
            cell.mainTitle.text = key
            cell.valueLabel.text = String(value["value"]!)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "irrigationQueueCell")! as! DashIrrigationQueueTableViewCell
            let item = iQueueArray[indexPath.row]
            cell.bedLabel.text = "Bed \(item.bedNo) | "
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(deleteiQueueItem(sender:)), for: .touchUpInside)
            
            if Calendar.current.isDate(item.end, inSameDayAs: item.start) {
                cell.detailLabel.text = "\(item.start.formatDate1()) - \(item.end.formatDate2())"
            } else {
                cell.detailLabel.text = "\(item.start.formatDate1()) - \(item.end.formatDate1())"
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "dashStatusCell")! as! DashboardStatusTableViewCell
            let array = iStatusDict["G\(indexPath.row+1)"]!
            cell.bedLabel.text = "G\(indexPath.row+1)"
            
            if array.isEmpty {
                cell.configureNone()
            } else {
                let item = array[0]
                cell.configureType(type: item.type, endTime: item.end.formatDate1())
                print(iStatusDict["G\(indexPath.row+1)"])
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @IBAction func deleteiQueueItem(sender: UIButton) {
        print("Bed \(sender.tag+1) delete button clicked")
        let item = self.iQueueArray[sender.tag]
        self.ref.child("iQueueBed/\(item.bedString)/\(item.uuid)").removeValue()
        self.ref.child("iQueueList/\(item.uuid)").removeValue()
        let index = IndexPath(row: sender.tag, section: 0)
        self.iQueueArray.remove(at: sender.tag)
        self.irrigationQueueTableView.deleteRows(at: [index], with: .none)
        self.irrigationQueueTableView.reloadData()
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
    
}
