//
//  NetworkVPNUseCase.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/23/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public enum NetworkVPNStatus: String {
    case invalid = "Press to allow VPN"
    case disconnected = "Tap to Connect"
    case connecting = "Connecting"
    case connected = "Tap to disconnect"
    case reasserting = "Reasserting"
    case disconnecting = "Disconnecting"
}

protocol NetworkVPNUseCase {
    func connect(configuration: VPNAccount)
    func getStatus(completion: @escaping (NetworkVPNStatus) -> Void)
    func disconnect()
    func loadVPNConfig(completion: @escaping () -> Void)
    func getServers(completion: @escaping (Result<[Server], Error>) -> Void) -> Cancellable?
}

final class DefaultNetworkVPNUseCase: NetworkVPNUseCase {
    
    private(set) var vpnManager: DVPNRepository
    
    init(vpnManager: DVPNRepository) {
        self.vpnManager = vpnManager
    }
    
    func connect(configuration: VPNAccount) {
        vpnManager.connect(configuration: configuration)
    }
    
    func getStatus(completion: @escaping (NetworkVPNStatus) -> Void) {
       
    }
    
    func disconnect() {
        vpnManager.disconnect()
    }
    
    func loadVPNConfig(completion: @escaping () -> Void) {
       vpnManager.loadVPNConfig(completion: completion)
    }
    
    func getServers(completion: @escaping (Result<[Server], Error>) -> Void) -> Cancellable? {
        return vpnManager.getServers(completion: completion)
    }
}
