//
//  OSLogExtension.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import os

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let network = OSLog(subsystem: subsystem, category: "Network")
    static let SKStore = OSLog(subsystem: subsystem, category: "SKStore")
}
