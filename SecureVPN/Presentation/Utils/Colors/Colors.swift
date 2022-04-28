//
//  Colors.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/13/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

class Colors {
    
    class func defaultColor(hex: String?) -> UIColor {
        if let hex = hex {
            return UIColor(hex: hex) 
        }
        return UIColor.systemPurple
    }
    
    class var backgroundColor: UIColor { return UIColor.white }
    
    class var mainPurpleColor: UIColor { return defaultColor(hex: "#6236FF") }
    
    class var lightBlue: UIColor { defaultColor(hex: "#32e7f7") }
    
    class var systemPurple: UIColor { defaultColor(hex: "#05335f")}
    
    class var yellowColor: UIColor { defaultColor(hex: "#F8E71C") }
    
    class var blueColor: UIColor { defaultColor(hex: "#235598") }
    
    class var systemTealColor: UIColor { defaultColor(hex: "#55C7FF") }
    
    class var black: UIColor { return UIColor.black }
    
    class var darkGray: UIColor { return UIColor.darkGray }
    
    class var white: UIColor { return UIColor.white }
    
    class var tabBarTintColor: UIColor { return defaultColor(hex: "#AF52DE") }
    
    class var secondTabBarTintColor: UIColor { return UIColor.systemBlue }
    
    class var lightGray: UIColor { return UIColor.lightGray }
    
    class var greenColor: UIColor { return defaultColor(hex: "#4CD964")}
    
    class var redColor: UIColor { return defaultColor(hex: "#FA3939")}
}

private extension UIColor {
    
   convenience init(hex: String, alpha: CGFloat = 1.0) {
      var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

      if cString.hasPrefix("#") { cString.removeFirst() }

      if cString.count != 6 {
        self.init(hex: "ff0000") // return red color for wrong hex input
        return
      }

      var rgbValue: UInt64 = 0
      Scanner(string: cString).scanHexInt64(&rgbValue)

      self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha)
    }
}
