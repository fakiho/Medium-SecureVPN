//
//  UserSession+Codable.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/9/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

extension UserSession: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case profile
        case remoteSession
        case deeplinkSession
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.profile = try container.decode(Profile.self, forKey: .profile)
        self.remoteSession = try container.decode(RemoteUserSession.self, forKey: .remoteSession)
        self.deeplinkUser = try container.decode(DeeplinkUserSession.self, forKey: .deeplinkSession)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(profile, forKey: .profile)
        try container.encode(remoteSession, forKey: .remoteSession)
        try container.encode(deeplinkUser, forKey: .deeplinkSession)
    }
}
