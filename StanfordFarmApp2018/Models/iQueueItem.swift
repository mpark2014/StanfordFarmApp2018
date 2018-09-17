//
//  IrrigationQueueItem.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/9/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import Foundation

enum iQueueType: Int {
    case manual
    case scheduled
    case automatedScheduled
    case sensor
}

enum iQueueStatus: Int {
    case pending
    case complete
}

class iQueueItem: Equatable, CustomStringConvertible {
    let uuid: String
    let bedNo: Int
    let bedString: String
    let start: Date
    let end: Date
    let type: iQueueType
    let status: iQueueStatus
    
    var description : String {
        return self.uuid
    }
    
    init(uuid: String, bedNo: Int, bedString: String, start: Date, end: Date, type: iQueueType, status: iQueueStatus) {
        self.uuid = uuid
        self.bedNo = bedNo
        self.bedString = bedString
        self.start = start
        self.end = end
        self.type = type
        self.status = status
    }
    
    static func == (lhs: iQueueItem, rhs: iQueueItem) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
