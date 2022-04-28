//
//  Server.swift
//  Secure VPN
//
//  Created by Ali FAKIH on 24/04/2022.
//  Copyright © 2022 beApp. All rights reserved.
//

import Foundation

// MARK: - Server
struct Server: Equatable {
    let account: String
    let certificate: String
    let serverDescription: String
    let adjustToken: String
    let top: Bool
    let country: String
    let psk: String
    let flagIcon: String
    let server: String
    let remoteId: String
    let pro: Bool
    let password: String
    let localId: String

    func toVPNAccount() -> VPNAccount {
        Configuration(
            server: server,
            country: country,
            pro: pro,
            account: account,
            password: password,
            description: serverDescription,
            remoteID: remoteId,
            localID: localId,
            certificate: certificate,
            top: top,
            adjustToken: adjustToken)
    }
}

extension Server: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(server)
    }
}
