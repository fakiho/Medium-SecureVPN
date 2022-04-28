//
//  DVPNRepository.swift
//  Secure VPN
//
//  Created by Ali Fakih on 5/20/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
protocol DVPNRepository {
    func connect(configuration: VPNAccount)
    func getStatus(completion: @escaping (NetworkVPNStatus) -> Void)
    func disconnect()
    func loadVPNConfig(completion: @escaping () -> Void)
    func getServers(completion: @escaping (Result<[Server], Error>) -> Void) -> Cancellable?
}
