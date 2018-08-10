//
//  File.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/6/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import Foundation
import UIKit

let greenColor = UIColor(red: 107/255, green: 170/255, blue: 53/255, alpha: 1.0)

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
}
