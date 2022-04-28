//
//  DefaultVPNManager.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/23/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import NetworkExtension

final class DefaultVPNManager: VPNRepository {
    
    var selectedVPN: String = ""
    var activatedVPN: String = ""
    
    func loadPreferences(completion: @escaping () -> Void) {
        #if !targetEnvironment(simulator)
        manager.loadFromPreferences { error in
            assert(error == nil, "Failed to load preferences \(error?.localizedDescription ?? "Unknown Error")")
            completion()
        }
        #endif
        
    }
    
    private func saveVPNProtocol(account: VPNAccount, completion: @escaping () -> Void) {
        #if targetEnvironment(simulator)
            assert(false, "I'm afraid you can not connect VPN in simulators.")
        #endif
        var neVPNProtocol: NEVPNProtocol
        switch account.type {
        case .IPSec:
            neVPNProtocol = makeIPSecProtocol(from: account)
        case .IKEv2:
            neVPNProtocol = makeIKEv2Protoocol(from: account)
        }
        
        neVPNProtocol.disconnectOnSleep = false
        neVPNProtocol.serverAddress = account.server
        neVPNProtocol.username = account.account
        neVPNProtocol.passwordReference = account.getPasswordRef()
        manager.localizedDescription = "SECURE VPN"
        manager.protocolConfiguration = neVPNProtocol
        manager.isEnabled = true
        manager.saveToPreferences { error in
            if let err = error {
                print("Failed to save Preferences: \(err.localizedDescription)")
            } else {
                completion()
            }
        }
    }
    
    private func makeIPSecProtocol(from account: VPNAccount) -> NEVPNProtocolIPSec {
        let ipSecProtocol = NEVPNProtocolIPSec()
        ipSecProtocol.useExtendedAuthentication = true
        ipSecProtocol.localIdentifier = account.localID ?? "VPN"
        ipSecProtocol.remoteIdentifier = account.remoteID
        if account.pskEnabled {
            ipSecProtocol.authenticationMethod = .sharedSecret
            ipSecProtocol.sharedSecretReference = account.getPSKRef()
        } else {
            ipSecProtocol.authenticationMethod = .none
        }
        
        return ipSecProtocol
    }
    
    private func  makeIKEv2Protoocol(from account: VPNAccount) -> NEVPNProtocolIKEv2 {
        let protocolIKEv2 = NEVPNProtocolIKEv2()
        protocolIKEv2.useExtendedAuthentication = true
        protocolIKEv2.localIdentifier = account.localID
        protocolIKEv2.remoteIdentifier = account.remoteID
        if account.pskEnabled
        {
            protocolIKEv2.authenticationMethod = .sharedSecret
            protocolIKEv2.sharedSecretReference = account.getPSKRef()
            protocolIKEv2.passwordReference = account.getPasswordRef()
        }
        else
        {
            protocolIKEv2.authenticationMethod = .none
        }
        protocolIKEv2.deadPeerDetectionRate = .medium

        return protocolIKEv2
    }
    
    func connect() {
         let conf = Configuration(server: "144.202.9.42",
                                  country: "usa", 
                                  pro: true,
                                  account: "myusername", 
                                  password: "hSyeI1H8Wsybb5qDk5abBrJ7LCu3bPbJrax9aFG77FiiJZu3eUepLwvg9pjjEL3",
                                  psk: "SEXapPAm5x5OXktAzes9nxE3NvilpmIH1orpE2cIzgfWRZgQDYZ1Wm3thlfXXwn", 
                                  description: "Vultr USA", 
                                  remoteID: "securevpn.com.myserver",
                                  localID: nil,
                                  certificate: "",
                                  top: true,
                                  adjustToken: "")
       conf.saveToDefaults()
        loadPreferences { [weak self] in
            self?.saveVPNProtocol(account: conf) {
                do {
                    try self?.manager.connection.startVPNTunnel()
                } catch  NEVPNError.configurationInvalid {
                    print("Invalid Config")
                } catch NEVPNError.configurationDisabled {
                    print("Config disabled")
                } catch let error as NSError {
                    print(error.localizedDescription)
                    NotificationCenter.default.post(
                        name: NSNotification.Name.NEVPNStatusDidChange,
                        object: nil
                    )
                }
            }
        }
    }
    
    func saveAndConnect(_ account: VPNAccount) {

        save(config: account) { [weak self] in
            _ = self?.connectVPN()
        }
    }
    
    func disconnect() {
        manager.connection.stopVPNTunnel()
    }
    
    func removeProfile() {
        manager.removeFromPreferences { [weak self] _ in
            self?.manager.removeFromPreferences { _ in
                
            }
        }
    }
    
    func save(config: VPNAccount, completion: @escaping () -> Void) {
        config.saveToDefaults()
        loadPreferences { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.saveVPNProtocol(account: config, completion: completion)
        }
    }
    
    public func saveAndConnect(_ config: Configuration) {
        save(config: config) { [weak self] in
            guard let self = self else { return }
            _ = self.connectVPN()
        }
    }
    
    func connectVPN() -> Bool {
        debugPrint("!!!!! Establishing Connection !!!!!")
        do {
            try self.manager.connection.startVPNTunnel()
            return true
        } catch NEVPNError.configurationInvalid {
            debugPrint("Failed to start tunnel (configuration invalid)")
        } catch NEVPNError.configurationDisabled {
            debugPrint("Failed to start tunnel (configuration disabled)")
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
            NotificationCenter.default.post(name: Notification.Name.NEVPNStatusDidChange, object: nil)
            return false
        }
        
        return false
    }
}
