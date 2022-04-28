//
//  DataTransferService.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/9/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import AFNetworks

struct APIEndpoints {}

// MARK: - AUTH Implementation
extension APIEndpoints: AuthRemoteAPI {
    static func signIn(email: String, password: String) -> Endpoint<UserSession> {
        return Endpoint(path: "api/login",
                        headerParameters: ["email": email, "password": password])
    }
    
    static func signUp(newAccount: UserSession) -> Endpoint<UserSession> {
        return Endpoint(path: "api/register",
                        bodyParameters: ["email": newAccount.profile.email])
    }
    
    static func signOut(userSession: UserSession) -> Endpoint<UserSession> {
        return Endpoint(path: "api/logout",
                        headerParameters: ["token": userSession.remoteSession.token])
    }
    
    static func requestToken(token: String) -> Endpoint<UserSession> {
        return Endpoint(path: "api/getToken",
                        headerParameters: ["token": token])
    }
    
    static func updatePurchase(userSession: UserSession) -> Endpoint<UserSession> {
        return Endpoint(path: "api/purchaseUpdate",
                        headerParameters: ["token": userSession.remoteSession.token])
    }
    
    static func flagImage(path: String) -> Endpoint<Data> {
        return Endpoint(path: path, bodyJsonSerializationOption: nil)
    }
}

// MARK: - iTunes implementation
extension APIEndpoints: iTunesRemoteApi {
    static func validate(receiptString: Data?, sharedSecretKey: String = AppConfiguration().sharedSecretKey) -> Endpoint<Data> {
        return Endpoint(path: "verifyReceipt", 
                        method: .post,
                        headerParameters: [:], 
                        bodyParameters: ["receipt-data": receiptString as Any, "password": sharedSecretKey as Any], 
                        queryParameters: [:],
                        bodyJsonSerializationOption: JSONSerialization.WritingOptions.prettyPrinted)
    }
}
