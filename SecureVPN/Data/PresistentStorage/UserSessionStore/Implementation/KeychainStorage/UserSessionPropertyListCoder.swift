//
//  UserSessionPropertyListCoder.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/17/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public class UserSessionPropertyListCoder: UserSessionCoding {
    
    init() {}
    
    public func encode(userSession: UserSession) -> Data {
        // swiftlint:disable:next force_try
        return try! PropertyListEncoder().encode(userSession)
    }
    
    public func decode(data: Data) -> UserSession {
        // swiftlint:disable:next force_try
        return try! PropertyListDecoder().decode(UserSession.self, from: data)
    }
}
