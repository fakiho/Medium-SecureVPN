//
//  ServerStorage.swift
//  Secure VPN
//
//  Created by Ali Fakih on 7/7/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

final class DefaultServerStorage: ServerStorageRepository {
    private let serversKey = "SEVRER_STORAGE_KEY"
    private var userDefaults: UserDefaults { return UserDefaults.standard }
    
    private var serversQueries: [Server] {
        get {
            if let queryData = userDefaults.object(forKey: serversKey) as? Data {
                let decoder = JSONDecoder()
                if let serverQuery = try? decoder.decode([Server].self, from: queryData) {
                    return serverQuery
                }
            }
            return []
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                userDefaults.set(encoded, forKey: serversKey)
            }
        }
    }
    
    func getServers(completion: @escaping((Result<[Server], Error>) -> Void)) {
        completion(.success(self.serversQueries))
    }
    
    func saveServers(servers: [Server]) {
        self.serversQueries = servers
    }
}
