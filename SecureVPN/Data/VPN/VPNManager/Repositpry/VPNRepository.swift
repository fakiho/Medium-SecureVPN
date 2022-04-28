//
//  VPNManager.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/23/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import NetworkExtension

protocol VPNRepository {
    var manager: NEVPNManager { get }
    var selectedVPN: String { get set }
    var activatedVPN: String { get set }
    var status: NEVPNStatus { get set }
    func loadPreferences(completion: @escaping () -> Void)
    func save(config: VPNAccount, completion: @escaping () -> Void)
    func connect()
    func saveAndConnect(_ account: VPNAccount)
    func disconnect()
    func removeProfile()
    func registerNotification()
    
}
extension VPNRepository {
    
    var manager: NEVPNManager {
        return NEVPNManager.shared()
    }
    
    var status: NEVPNStatus {
        get {
            return manager.connection.status
        }
        set {
            registerNotification()
        }
    }
    
    func registerNotification() {
        NotificationCenter.default.post(name: NSNotification.Name.NEVPNStatusDidChange, object: nil, userInfo: ["status": status])
    }
}
