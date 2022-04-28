//
//  DefaultVPNRepository.swift
//  Secure VPN
//
//  Created by Ali Fakih on 5/20/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import AFNetworks
import Firebase

final class DefaultVPNRepository {
    
    private(set) var vpnManager: VPNRepository!
    private let dataTransferService: DataTransferService
    private let mapper: ServerMapperType

    init(vpnManager: VPNRepository, dataTransfer: DataTransferService, mapper: ServerMapperType = ServerMapper()) {
        self.vpnManager = vpnManager
        self.dataTransferService = dataTransfer
        self.mapper = mapper
    }
}

extension DefaultVPNRepository: DVPNRepository {
    func connect(configuration: VPNAccount) {
        vpnManager.saveAndConnect(configuration)
    }
    
    func getStatus(completion: @escaping (NetworkVPNStatus) -> Void) {
        switch vpnManager.status {
        case .invalid:
           completion(NetworkVPNStatus.invalid)
        case .disconnected:
           completion(NetworkVPNStatus.disconnected)
        case .connecting:
            completion(NetworkVPNStatus.connecting)
        case .connected:
            completion(NetworkVPNStatus.connected)
        case .reasserting:
            completion(NetworkVPNStatus.reasserting)
        case .disconnecting:
            completion(NetworkVPNStatus.disconnecting)
        @unknown default:
            break
       }
    }
    
    func disconnect() {
        vpnManager.disconnect()
    }
    
    func loadVPNConfig(completion: @escaping () -> Void) {
         vpnManager.loadPreferences(completion: completion)
    }
    
    func getServers(completion: @escaping (Result<[Server], Error>) -> Void) -> Cancellable?
    {
        getListFromFB(completion: completion)
    }

    private func getListFromFB(completion: @escaping (Result<[Server], Error>) -> Void) -> Cancellable? {
        let operation = OperationQueue()
        operation.addOperation { [weak self] in
            let db = Firestore.firestore()
            db.collection("iOS").getDocuments { (querySnapshot, error) in
                if let err = error {
                    print("Error getting documents: \(err)")
                } else {
                    guard let self = self else {
                        print("error retaining self")
                        return
                    }
                    completion(.success(self.parseServers(querySnapshot)))
                }
            }
        }
        return RepositoryTask(networkTask: nil, operation: operation)
    }

    private func parseServers(_ querySnapshot: QuerySnapshot?) -> [Server] {
        var servers: [Server] = []
        for document in querySnapshot!.documents {
            print("\(document.documentID) => \(document.data())")
            guard let data = try? JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted) else {
                print("Invalid data parse")
                continue
            }

            guard let server = try? VPNServer(data: data) else {
                print("API Violation")
                continue
            }
            servers.append(self.mapper.map(vpnServer: server))
        }
        return servers
    }
}
