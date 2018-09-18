//
//  SensorData.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 9/11/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Charts

let dataModel = DataModel()

class DataModel {
    var ref: DatabaseReference!
    
    // Callbacks
    var dashboard_iFlag_Callback: (() -> ())?
    var dashboard_liveData_Callback: (() -> ())?
    var dashboard_settings_Callback: (() -> ())?
    var dashboard_iQueueList_Callback: (() -> ())?
    var dashboard_iQueueBed_Callback: (() -> ())?
    
    var bed_iFlag_Callback: (() -> ())?
    var bed_iSchedule_Callback: (() -> ())?
    var bed_iQueueBed_Callback: (() -> ())?
    var bed_sensorDataDownloadedCallback: (() -> ())?
    
    // Data Stores
    var dashboard_iFlagData:[String:Bool]! = [:]
    var dashboard_liveSensorDataKeys:[String] = []
    var dashboard_liveSensorData:[String:[String:Int]]! = [:]
    var dashboard_chartData:[Int]! = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var dashboard_settings:[String:Int]! = [:]
    var dashboard_iQueueArray:[iQueueItem] = []
    var dashboard_iStatusDict:[String:[iQueueItem]]! = ["G1":[],"G2":[],"G3":[],"G4":[],"G5":[],"G6":[],"G7":[],"G8":[],"G9":[],"G10":[],"G11":[],"G12":[],"G13":[],"G14":[],"G15":[]]
    
    var bed_iQueueDict:[String:[iQueueItem]]! = ["G1":[],"G2":[],"G3":[],"G4":[],"G5":[],"G6":[],"G7":[],"G8":[],"G9":[],"G10":[],"G11":[],"G12":[],"G13":[],"G14":[],"G15":[]]
    var bed_iScheduleData:[String:[String:(String, String)]] = [:]
    var bed_sensorDataDictCharts:[String:[String:[ChartDataEntry]]] = [:]
    
    init() {
        ref = Database.database().reference()
        self.firebaseGet_Dashboard()
        self.firebaseGet_Bed()
    }
    
    // MARK: - Get Firebase Data
    
    func firebaseGet_Dashboard() {
        ref.child("iFlag").observe(DataEventType.childAdded, with: { (snapshot) in
            self.parse_iFlagData(snapshot: snapshot)
        })
        ref.child("iFlag").observe(DataEventType.childChanged, with: { (snapshot) in
            self.parse_iFlagData(snapshot: snapshot)
        })
        
        ref.child("Live").observe(DataEventType.childAdded, with: { (snapshot) in
            self.parse_liveData(snapshot: snapshot)
        })
        ref.child("Live").observe(DataEventType.childChanged, with: { (snapshot) in
            self.parse_liveData(snapshot: snapshot)
        })
        
        ref.child("Settings").observe(DataEventType.childAdded, with: { (snapshot) in
            self.parse_settings(snapshot: snapshot)
        })
        ref.child("Settings").observe(DataEventType.childChanged, with: { (snapshot) in
            self.parse_settings(snapshot: snapshot)
        })
        
        ref.child("iQueueList").queryOrdered(byChild: "start").observe(DataEventType.childAdded) { (snapshot) in
            print("iQueueList: Child Added")
            self.parse_iQueueList(snapshot: snapshot)
        }
        ref.child("iQueueList").queryOrdered(byChild: "start").observe(DataEventType.childChanged) { (snapshot) in
            print("iQueueList: Child Changed")
            self.parse_iQueueList(snapshot: snapshot)
        }
        ref.child("iQueueList").observe(.childRemoved) { (snapshot) in
            print("iQueueList: Child Removed")
            self.parse_iQueueListRemoved(snapshot: snapshot)
        }
    }
    
    func firebaseGet_Bed() {
        ref.child("iQueueBed").queryOrdered(byChild: "start").observe(DataEventType.childAdded) { (snapshot) in
            print("iQueueBed: Child Added")
            self.parse_iQueueBed(snapshot: snapshot)
        }
        ref.child("iQueueBed").queryOrdered(byChild: "start").observe(DataEventType.childChanged) { (snapshot) in
            print("iQueueBed: Child Changed")
            self.parse_iQueueBed(snapshot: snapshot)
        }
        ref.child("iQueueBed").observe(.childRemoved) { (snapshot) in
            print("iQueueBed: Child Removed")
            self.parse_iQueueBedRemove(snapshot: snapshot)
        }
        
        ref.child("iSchedule").observe(DataEventType.childAdded, with: { (snapshot) in
            self.parse_iScheduleData(snapshot: snapshot)
        })
        ref.child("iSchedule").observe(DataEventType.childChanged, with: { (snapshot) in
            self.parse_iScheduleData(snapshot: snapshot)
        })
    }
    
    func firebaseGet_SensorData(forBed: Int) {
        if bed_sensorDataDictCharts["G\(forBed)"] == nil {
            retrieveSensorData(forBed: forBed)
        } else {
            self.bed_sensorDataDownloadedCallback?()
        }
    }
    
    func retrieveSensorData(forBed: Int) {
        var i = 1
        
        while dashboard_liveSensorDataKeys.contains("\(((forBed<10) ? "0" : ""))\(forBed):\(i)") {
            self.bed_sensorDataDictCharts["G\(forBed)"] = [:]
            self.bed_sensorDataDictCharts["G\(forBed)"]!["sensor\(i)"] = []
            i+=1
        }
        
        for sensor in self.bed_sensorDataDictCharts["G\(forBed)"]!.keys {
            ref.child("Database/G\(forBed)/\(sensor)").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    let allEvents = snapshot.value! as! [String:[String:Int]]
                    for (_, value) in allEvents {
                        let timestamp = value["timestamp"]!
                        let value = value["value"]!
                        let chartDataValue = ChartDataEntry(x: Double(timestamp), y: Double(value))
                        self.bed_sensorDataDictCharts["G\(forBed)"]![sensor]!.append(chartDataValue)
                    }
                }
                self.bed_sensorDataDownloadedCallback?()
            }
        }
    }
    
    // MARK: - Post to Firebase Database
    
    func post_iFlag(bed: Int, iFlag: Bool) {
        self.ref.child("iFlag/G\(bed)").setValue(iFlag)
    }
    
    func post_iQueueItem(bed: Int, start: Double, end: Double, type: Int, status: Int) {
        let iQueueListItem = [
            "bed": bed,
            "blockBed": "G\(bed)",
            "end": end,
            "start": start,
            "type": type,
            "status": status
            ] as [String:Any]
        
        let iQueueBedItem = [
            "end": end,
            "start": start,
            "bed": bed,
            "type": type,
            "status": status
            ] as [String:Any]
        
        let reference = self.ref.child("iQueueList").childByAutoId()
        reference.setValue(iQueueListItem)
        let uuid = reference.key
        self.ref.child("iQueueBed/G\(bed)/\(uuid)").setValue(iQueueBedItem)
    }
    
    func post_scheduledIrrigationTime(bed: Int, day: String, start: Date, end: Date) {
        let calendar = Calendar.init(identifier: .gregorian)
        let startHour = calendar.component(.hour, from: start)
        let startMinute = calendar.component(.minute, from: start)
        let endHour = calendar.component(.hour, from: end)
        let endMinute = calendar.component(.minute, from: end)
        
        let iScheduleItem = [
            "startHour": startHour,
            "startMinute": startMinute,
            "endHour": endHour,
            "endMinute": endMinute
        ] as [String:Any]
        
        self.ref.child("iSchedule/G\(bed)/\(day)").setValue(iScheduleItem)
    }
    
    func post_sensorSamplingRate(seconds: Int) {
        self.ref.child("Settings/sInterval").setValue(seconds)
    }
    
    func post_irrigationSamplingRate(seconds: Int) {
        self.ref.child("Settings/iInterval").setValue(seconds)
    }
    
    // MARK: - Delete Firebase Data
    
    func delete_iQueueItem(bed: Int?, itemNo: Int) {
        let item = (bed==nil) ? self.dashboard_iQueueArray[itemNo] : self.bed_iQueueDict["G\(bed!)"]![itemNo]
        
        if item.status == iQueueStatus.complete {
            self.ref.child("iQueueBed/\(item.bedString)/\(item.uuid)").removeValue()
            self.ref.child("iQueueList/\(item.uuid)").removeValue()
            
            dataModel.dashboard_iQueueArray.remove(at: dataModel.dashboard_iQueueArray.index(of: item)!)
            dataModel.bed_iQueueDict[item.bedString]!.remove(at: dataModel.bed_iQueueDict[item.bedString]!.index(of: item)!)
        }
    }
    
    func delete_iScheduleItem(bed: Int, day: String) {
        self.ref.child("iSchedule/G\(bed)/\(day)").removeValue()
        dataModel.bed_iScheduleData["G\(bed)"]!.removeValue(forKey: day)
    }
    
    func delete_codeDirectedItem(path: String) {
        self.ref.child(path).removeValue()
    }
    
    // MARK: - Firebase Parse Methods
    
    func parse_iFlagData(snapshot: DataSnapshot) {
        let key = snapshot.key
        let item = ((snapshot.value as! Int) == 0) ? false : true
        self.dashboard_iFlagData[key] = item
        self.dashboard_iFlag_Callback?()
        self.bed_iFlag_Callback?()
    }
    
    func parse_liveData(snapshot: DataSnapshot) {
        let key = snapshot.key
        let bedNo = Int(String(key.dropFirst()))!
        let value = (snapshot.value as! [String:[String:Int]])
        
        for (marker, item) in value {
            let sensorNo = Int(String(marker.dropFirst(6)))!
            let liveDataKey = (bedNo<10) ? "0\(bedNo):\(sensorNo)" : "\(bedNo):\(sensorNo)"
            self.dashboard_liveSensorData[liveDataKey] = item
            
            if sensorNo == 1 {
                self.dashboard_chartData[bedNo-1] = item["value"] as! Int
            }
        }
        
        // BAD CODE. CHANGE...
        self.dashboard_liveSensorDataKeys = Array(self.dashboard_liveSensorData.keys)
        self.dashboard_liveSensorDataKeys.sort()
        self.dashboard_liveData_Callback?()
    }
    
    func parse_settings(snapshot: DataSnapshot) {
        let key = snapshot.key
        if let value = snapshot.value as? Int {
            self.dashboard_settings[key] = value
            self.dashboard_settings_Callback?()
        }
    }
    
    func parse_iQueueList(snapshot: DataSnapshot) {
        let uuid = snapshot.key
        let value = snapshot.value as! [String:Any]
        let bed = value["bed"] as! Int
        let bedString = value["blockBed"] as! String
        let start = Date(timeIntervalSince1970: Double((value["start"] as! Int)/1000))
        let end = Date(timeIntervalSince1970: Double((value["end"] as! Int)/1000))
        let type = iQueueType(rawValue: value["type"] as! Int)!
        let status = iQueueStatus(rawValue: value["status"] as! Int)!
        let item = iQueueItem(uuid: uuid, bedNo: bed, bedString: bedString, start: start, end: end, type: type, status: status)
        
        if !self.dashboard_iQueueArray.contains(item) {
            insertSortedIQueueItem(array: &(self.dashboard_iQueueArray), element: item)
        } else {
            let index = self.dashboard_iQueueArray.index(of: item)
            self.dashboard_iQueueArray[index!] = item
        }
        
        self.dashboard_iQueueList_Callback?()
    }
    
    func parse_iQueueListRemoved(snapshot: DataSnapshot) {
        let uuid = snapshot.key
        let value = snapshot.value as! [String:Any]
        let bed = value["bed"] as! Int
        let bedString = value["blockBed"] as! String
        let start = Date(timeIntervalSince1970: Double((value["start"] as! Int)/1000))
        let end = Date(timeIntervalSince1970: Double((value["end"] as! Int)/1000))
        let type = iQueueType(rawValue: value["type"] as! Int)!
        let status = iQueueStatus(rawValue: value["status"] as! Int)!
        let item = iQueueItem(uuid: uuid, bedNo: bed, bedString: bedString, start: start, end: end, type: type, status: status)
        
        if self.dashboard_iQueueArray.contains(item) {
            self.dashboard_iQueueArray.remove(at: self.dashboard_iQueueArray.index(of: item)!)
        }
        
        self.dashboard_iQueueList_Callback?()
    }
    
    // REVIEW/FIX THIS
    func parse_iQueueBed(snapshot: DataSnapshot) {
        let bedString = snapshot.key
        var iStatusArray: [iQueueItem] = []
        var bed_iQueueArray: [iQueueItem] = []
        let value = snapshot.value as! [String:[String:Any]]
        
        for (snapshotUuid, snapshotItem) in value {
            let uuid = snapshotUuid
            let start = Date(timeIntervalSince1970: Double((snapshotItem["start"] as! Int)/1000))
            let end = Date(timeIntervalSince1970: Double((snapshotItem["end"] as! Int)/1000))
            let now = Date()
            let type = iQueueType(rawValue: snapshotItem["type"] as! Int)!
            let status = iQueueStatus(rawValue: snapshotItem["status"] as! Int)!
            let bed = snapshotItem["bed"] as! Int
            let item = iQueueItem(uuid: uuid, bedNo: bed, bedString: bedString, start: start, end: end, type: type, status: status)
            if !bed_iQueueArray.contains(item) {
                insertSortedIQueueItem(array: &bed_iQueueArray, element: item)
            } else {
                bed_iQueueArray[bed_iQueueArray.index(of: item)!] = item
            }
            if !(iStatusArray.contains(item)) && now > start && now < end {
                insertSortedIQueueItem(array: &iStatusArray, element: item)
            }
        }
        
        self.bed_iQueueDict[bedString] = bed_iQueueArray
        self.dashboard_iStatusDict[bedString] = iStatusArray
        self.dashboard_iQueueBed_Callback?()
        self.bed_iQueueBed_Callback?()
    }
    
    func parse_iQueueBedRemove(snapshot: DataSnapshot) {
        let bedString = snapshot.key
        let value = snapshot.value as! [String:[String:Any]]
        
        if let iBedArray = bed_iQueueDict[bedString] {
            for (snapshotUuid, snapshotItem) in value {
                let uuid = snapshotUuid
                let start = Date(timeIntervalSince1970: Double((snapshotItem["start"] as! Int)/1000))
                let end = Date(timeIntervalSince1970: Double((snapshotItem["end"] as! Int)/1000))
                let type = iQueueType(rawValue: snapshotItem["type"] as! Int)!
                let status = iQueueStatus(rawValue: snapshotItem["status"] as! Int)!
                let bed = snapshotItem["bed"] as! Int
                let item = iQueueItem(uuid: uuid, bedNo: bed, bedString: bedString, start: start, end: end, type: type, status: status)
                
                if iBedArray.contains(item) {
                    bed_iQueueDict[bedString]!.remove(at: (bed_iQueueDict[bedString]?.index(of: item))!)
                    self.bed_iQueueBed_Callback?()
                }
                
                if dashboard_iStatusDict[bedString] != nil {
                    if dashboard_iStatusDict[bedString]!.contains(item) {
                        dashboard_iStatusDict[bedString]!.remove(at: (dashboard_iStatusDict[bedString]?.index(of: item))!)
                        self.dashboard_iQueueBed_Callback?()
                    }
                }
            }
        }
    }
    
    func parse_iScheduleData(snapshot: DataSnapshot) {
        let bedString = snapshot.key
        let value = snapshot.value as! [String:Any]
        let dayKeys = value.keys
        
        for dayKey in dayKeys {
            let iScheduleItem = value[dayKey] as! [String:Any]
            var startHour = iScheduleItem["startHour"] as! Int
            let startMinute = iScheduleItem["startMinute"] as! Int
            var endHour = iScheduleItem["endHour"] as! Int
            let endMinute = iScheduleItem["endMinute"] as! Int
            var start_ampm = "AM"
            var end_ampm = "AM"
            
            if startHour == 0 {
                startHour = 12
            } else if startHour > 12 {
                startHour -= 12
                start_ampm = "PM"
            }
            
            if endHour == 0 {
                endHour = 12
            } else if endHour > 12 {
                endHour -= 12
                end_ampm = "PM"
            }
            
            let startString = "\(startHour):" + (startMinute<10 ? "0\(startMinute)" : String(startMinute)) + " \(start_ampm)"
            let endString = "\(endHour):" + (endMinute<10 ? "0\(endMinute)" : String(endMinute)) + " \(end_ampm)"
            
            let iScheduleItemTuple = (startString,endString)
            
            if self.bed_iScheduleData[bedString] == nil {
                self.bed_iScheduleData[bedString] = [dayKey:iScheduleItemTuple]
            } else {
                self.bed_iScheduleData[bedString]![dayKey] = iScheduleItemTuple
            }
        }
        
        self.bed_iSchedule_Callback?()
    }
}
