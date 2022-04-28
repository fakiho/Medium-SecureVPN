//
//  Server+Codable.swift
//  Secure VPN
//
//  Created by Ali FAKIH on 24/04/2022.
//  Copyright © 2022 beApp. All rights reserved.
//

import Foundation

extension Server: Codable {
    init(from decoder: Decoder) throws {
        let container       = try decoder.container(keyedBy: CodingKeys.self)
        self.account        =  try container.decode(String.self, forKey: .account)
        self.certificate    = try container.decode(String.self, forKey: .certificate)
        self.serverDescription    = try container.decode(String.self, forKey: .serverDescription)
        self.adjustToken    = try container.decode(String.self, forKey: .adjustToken)
        self.top            = try container.decode(Bool.self, forKey: .top)
        self.country        = try container.decode(String.self, forKey: .country)
        self.psk            = try container.decode(String.self, forKey: .psk)
        self.flagIcon       = try container.decode(String.self, forKey: .flagIcon)
        self.server         = try container.decode(String.self, forKey: .server)
        self.remoteId       = try container.decode(String.self, forKey: .remoteId)
        self.pro            = try container.decode(Bool.self, forKey: .pro)
        self.password       = try container.decode(String.self, forKey: .password)
        self.localId        = try container.decode(String.self, forKey: .localId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(server, forKey: .server)
        try container.encode(country, forKey: .country)
        try container.encode(pro, forKey: .pro)
        try container.encode(server, forKey: .server)
        try container.encode(account, forKey: .account)
        try container.encode(password, forKey: .password)
        try container.encode(psk, forKey: .psk)
        try container.encode(serverDescription, forKey: .serverDescription)
        try container.encode(localId, forKey: .localId)
        try container.encode(certificate, forKey: .certificate)
        try container.encode(top, forKey: .top)
        try container.encode(adjustToken, forKey: .adjustToken)
        try container.encode(flagIcon, forKey: .flagIcon)
    }

    enum CodingKeys: String, CodingKey {
        case account = "account"
        case certificate = "certificate"
        case serverDescription = "description"
        case adjustToken = "adjustToken"
        case top = "top"
        case country = "country"
        case psk = "psk"
        case flagIcon = "flagIcon"
        case server = "server"
        case remoteId = "remoteID"
        case pro = "pro"
        case password = "password"
        case localId = "localID"
    }
}
