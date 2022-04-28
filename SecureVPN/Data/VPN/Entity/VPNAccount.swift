//
//  VPNAccount.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/23/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

protocol VPNAccount {
    
    var type: VPNType { get }
    
    var country: String { get }
    var pro: Bool { get }
    var server: String { get }
    var account: String? { get }
    var password: String { get }
    var onDemand: Bool { get }
    var psk: String? { get }
    var pskEnabled: Bool { get }
    
    var description: String { get }
    var remoteID: String { get }
    var localID: String? { get }
    var certificate: String { get }
    var top: Bool { get }
    var adjustToken: String { get }
    func getPasswordRef() -> Data?

    func getPSKRef() -> Data?
    
    static func loadFromDefaults() -> VPNAccount
    
    func saveToDefaults()
}

enum VPNType: Int, Codable {
    case IPSec = 0
    case IKEv2 = 1
}
