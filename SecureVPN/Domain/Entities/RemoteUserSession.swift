//
//  RemoteUserSession.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/9/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public typealias AuthToken = String
public struct RemoteUserSession {
    let token: AuthToken
     
    public init(token: AuthToken) {
        self.token = token
    }
}
extension RemoteUserSession: Equatable {
 
    public static func == (lhs: RemoteUserSession, rhs: RemoteUserSession) -> Bool {
        return lhs.token == rhs.token
    }
}
