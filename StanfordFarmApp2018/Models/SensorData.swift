//
//  SensorData.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 9/11/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import Foundation
import FirebaseDatabase

let dataModel = DataModel()

class DataModel {
    var ref: DatabaseReference!
    
    var g1DownloadedCallback: (() -> (Void))?
    var dashboard_iFlag_Callback: (() -> (Void))?
    var dashboard_liveData_Callback: (() -> (Void))?
    var dashboard_settings_Callback: (() -> (Void))?
    var dashboard_iQueueList_Callback: (() -> (Void))?
    var dashboard_iQueueBed_Callback: (() -> (Void))?
    
    var dashboard_iFlagData:[String:Bool]! = [:]
    var dashboard_liveSensorDataKeys:[String] = []
    var dashboard_liveSensorData:[String:[String:Int]]! = [:]
    var dashboard_chartData:[Int]! = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var dashboard_settings:[String:Int]! = [:]
    var dashboard_iQueueArray:[iQueueItem] = []
    var dashboard_iStatusDict:[String:[iQueueItem]]! = ["G1":[],"G2":[],"G3":[],"G4":[],"G5":[],"G6":[],"G7":[],"G8":[],"G9":[],"G10":[],"G11":[],"G12":[],"G13":[],"G14":[],"G15":[]]
    
    var G1:[String:[[Int]]] = ["sensor1":[]]
    var G2:[String:[[Int]]] = ["sensor1":[]]
    var G3:[String:[[Int]]] = ["sensor1":[]]
    var G4:[String:[[Int]]] = ["sensor1":[]]
    var G5:[String:[[Int]]] = ["sensor1":[]]
    var G6:[String:[[Int]]] = ["sensor1":[]]
    
    init() {
        firebaseGet_Dashboard()
        firebaseGet_SensorData()
    }
    
    // MARK: - Get Firebase Data
    
    func firebaseGet_SensorData() {
        self.ref = Database.database().reference()
        
        ref.child("Settings/Test/Database/G1/sensor1")
            .queryLimited(toLast: 10)
            .observe(DataEventType.childAdded, with: { (snapshot) in
                let item = snapshot.value! as! [String:Int]
                
                let timestamp = item["timestamp"]!
                let date = Date(timeIntervalSince1970: (Double(timestamp)/1000))
                let value = item["value"]!
                print(date.formatDate3())
                let dataTuple = [date.formatDate3(), value]
                self.G1["sensor1"]!.append(dataTuple)
                
                self.g1DownloadedCallback?()
            })
    }
    
    func firebaseGet_Dashboard() {
        // Firebase GET request
        self.ref = Database.database().reference()
        
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
            self.parse_iQueueList(snapshot: snapshot)
        }
        ref.child("iQueueList").queryOrdered(byChild: "start").observe(DataEventType.childChanged) { (snapshot) in
            self.parse_iQueueList(snapshot: snapshot)
        }
        
        // REVIEW/FIX THIS
        ref.child("iQueueBed").queryOrdered(byChild: "start").observe(DataEventType.childAdded) { (snapshot) in
            self.parse_iQueueBed(snapshot: snapshot)
        }
        ref.child("iQueueBed").queryOrdered(byChild: "start").observe(DataEventType.childChanged) { (snapshot) in
            self.parse_iQueueBed(snapshot: snapshot)
        }
    }
    
    // MARK: - Firebase Parse Methods
    
    func parse_iFlagData(snapshot: DataSnapshot) {
        let key = snapshot.key
        let item = ((snapshot.value as! Int) == 0) ? false : true
        self.dashboard_iFlagData[key] = item
        self.dashboard_iFlag_Callback?()
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
    
    func parse_iQueueBed(snapshot: DataSnapshot) {
        let bedString = snapshot.key
        var iStatusArray = self.dashboard_iStatusDict[bedString]!
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
            if !(iStatusArray.contains(item)) && now > start && now < end {
                insertSortedIQueueItem(array: &iStatusArray, element: item)
            }
        }
        self.dashboard_iStatusDict[bedString] = iStatusArray
        self.dashboard_iQueueBed_Callback?()
    }
}
