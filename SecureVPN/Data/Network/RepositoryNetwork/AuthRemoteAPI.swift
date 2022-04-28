//
//  AuthRemoteAPI.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/11/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import AFNetworks

public protocol AuthRemoteAPI {
    static func signIn(email: String, password: String) -> Endpoint<UserSession>
    static func signUp(newAccount: UserSession) -> Endpoint<UserSession>
    static func signOut(userSession: UserSession) -> Endpoint<UserSession>
    static func updatePurchase(userSession: UserSession) -> Endpoint<UserSession>
    static func requestToken(token: String) -> Endpoint<UserSession>
}
