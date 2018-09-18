//
//  File.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/6/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import Foundation
import UIKit

let greenColor = UIColor(red: 107/256, green: 170/256, blue: 53/256, alpha: 1.0)
let redColor = UIColor(red: 140/256, green: 21/256, blue: 21/256, alpha: 1.0)

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

extension Date {
    func formatDate1() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("M.d.yy, h:mm a")
        return dateFormatter.string(from: self)
    }
    
    func formatDate2() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("h:mm a")
        return dateFormatter.string(from: self)
    }
    
    func formatDate3() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        
        dateFormatter.dateFormat = "YY"
        let year = dateFormatter.string(from: self)
        
        dateFormatter.dateFormat = "MM"
        let month = dateFormatter.string(from: self)
        
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: self)
        
        dateFormatter.dateFormat = "HH"
        let hours = dateFormatter.string(from: self)
        
        dateFormatter.dateFormat = "mm"
        let minutes = dateFormatter.string(from: self)
        
        dateFormatter.dateFormat = "ss"
        let seconds = dateFormatter.string(from: self)
        
        let fullString = year + month + day + hours + minutes + seconds
        
        return Int(fullString)!
    }
}


func insertSortedIQueueItem(array: inout [iQueueItem], element: iQueueItem) {
    var i = array.count-1
    if array.count == 0 {
        array.append(element)
    } else {
        while i >= 0 {
            print("entered loop: i = \(i)")
            if element.start > array[i].start {
                if (i == array.count-1) {
                    array.append(element)
                } else {
                    print("inserted element")
                    array.insert(element, at: i)
                }
                return
            } else {
                if i == 0 {
                    array.insert(element, at: i)
                    return
                }
                i-=1
            }
        }
    }
}
