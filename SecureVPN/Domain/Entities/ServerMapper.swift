//
//  ServerMapper.swift
//  Secure VPN
//
//  Created by Ali FAKIH on 24/04/2022.
//  Copyright © 2022 beApp. All rights reserved.
//

import Foundation

protocol ServerMapperType {
    func map(vpnServer: VPNServer) -> Server
}

public struct ServerMapper: ServerMapperType {
    func map(vpnServer: VPNServer) -> Server {
        Server(
            account: vpnServer.account,
            certificate: vpnServer.certificate,
            serverDescription: vpnServer.serverDescription,
            adjustToken: vpnServer.adjustToken,
            top: vpnServer.top == true,
            country: vpnServer.country,
            psk: vpnServer.psk ?? "",
            flagIcon: vpnServer.flagIcon,
            server: vpnServer.server,
            remoteId: vpnServer.remoteId,
            pro: vpnServer.pro,
            password: vpnServer.password,
            localId: vpnServer.localId ?? "")
    }
}
