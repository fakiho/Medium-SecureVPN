//
//  UserSettingsStorage.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/18/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

protocol UserSettingsStorage {
    var versionNumber: String { get }
    var buildNumber: String { get }
    var resetCache: Bool { get set }
}
