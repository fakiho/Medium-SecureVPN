//
//  Server.swift
//  Secure VPN
//
//  Created by Ali Fakih on 5/20/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
//   let server = try VPNServer(json)
//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).
// MARK: - Server
struct VPNServer: Equatable {
    let account: String
    let certificate: String
    let serverDescription: String
    let adjustToken: String
    let top: Bool?
    let country: String
    let psk: String?
    let flagIcon: String
    let server: String
    let remoteId: String
    let pro: Bool
    let password: String
    let localId: String?
}

// MARK: Server convenience initializers and mutators
extension VPNServer {

    func with(
        account: String? = nil,
        certificate: String? = nil,
        serverDescription: String? = nil,
        adjustToken: String? = nil,
        top: Bool? = nil,
        country: String? = nil,
        psk: String? = nil,
        flagIcon: String? = nil,
        server: String? = nil,
        remoteId: String? = nil,
        pro: Bool? = nil,
        password: String? = nil,
        localId: String? = nil
    ) -> VPNServer {
        return VPNServer(
            account: account ?? self.account,
            certificate: certificate ?? self.certificate,
            serverDescription: serverDescription ?? self.serverDescription,
            adjustToken: adjustToken ?? self.adjustToken,
            top: top ?? self.top,
            country: country ?? self.country,
            psk: psk ?? self.psk,
            flagIcon: flagIcon ?? self.flagIcon,
            server: server ?? self.server,
            remoteId: remoteId ?? self.remoteId,
            pro: pro ?? self.pro,
            password: password ?? self.password,
            localId: localId ?? self.localId
        )
    }
}

