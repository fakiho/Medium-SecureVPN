//
//  VPNProfiles.swift
//  VPN Guard
//
//  Created by Ali Fakih on 5/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

final class VPNProfile {
    static let vpnProfile: [VPNAccount] = [
        Configuration(server: "uk.freeikev2vpn.com",
                      country: "gb.png",
                      pro: false,
                      account: "freeikev2vpn.com",
                      password: "free",
                      description: "London",
                      remoteID: "uk.freeikev2vpn.com",
                      localID: nil,
                      certificate: "",
                      top: false,
                      adjustToken: ""),

        Configuration(server: "securevpn.beapp.online",
                      country: "usa", pro: false,
                      account: "username",
                      password: "password",
                      description: "New Jersey",
                      remoteID: "securevpn.beapp.online",
                      localID: "securevpn.beapp.online",
                      certificate: "",
                      top: false,
                      adjustToken: ""),

        Configuration(server: "minerva.beapp.online",
                      country: "usa",
                      pro: false,
                      account: "username",
                      password: "password",
                      description: "New Jersey",
                      remoteID: "minerva.beapp.online",
                      localID: "minerva.beapp.online",
                      certificate: "",
                      top: false,
                      adjustToken: ""),

        Configuration(server: "uk.freeikev2vpn.com",
                      country: "uk",
                      pro: false,
                      account: "freeikev2vpn.com",
                      password: "free",
                      description: "London",
                      remoteID: "uk.freeikev2vpn.com",
                      localID: nil,
                      certificate: "",
                      top: false,
                      adjustToken: "")]
}
