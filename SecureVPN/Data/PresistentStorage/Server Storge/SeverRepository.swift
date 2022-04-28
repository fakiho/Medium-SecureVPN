//
//  SeverRepository.swift
//  Secure VPN
//
//  Created by Ali Fakih on 7/7/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

protocol ServerStorageRepository {
    func getServers(completion: @escaping((Result<[Server], Error>) -> Void))
    func saveServers(servers: [Server])
}
