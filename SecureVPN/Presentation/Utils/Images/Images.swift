//
//  Images.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/13/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

class Images {
    
    class func defaultImage(name: String = "default", with renderMode: UIImage.RenderingMode = .alwaysOriginal) -> UIImage? {
        return UIImage(named: name)?.withRenderingMode(renderMode)
    }
    
    class var radioCheck: UIImage? {defaultImage(name: "check") }
    class var radioUncheck: UIImage? {defaultImage(name: "uncheck") }
    class var disconnectedVPN: UIImage? {defaultImage(name: "vpnDisconnected", with: .alwaysTemplate)}
    class var connectedVPN: UIImage? {defaultImage(name: "vpnConnected", with: .alwaysTemplate)}
    class var circle: UIImage? {defaultImage(name: "circleConnectBorder", with: .alwaysTemplate)}
    class var statusPro: UIImage? {defaultImage(name: "statusPro", with: .alwaysOriginal)}
    class var statusNotPro: UIImage? {defaultImage(name: "statusNotPro", with: .alwaysOriginal)}
    class var backgroundGradient: UIImage? { defaultImage(name: "smallBackground", with: .alwaysOriginal)}
}
