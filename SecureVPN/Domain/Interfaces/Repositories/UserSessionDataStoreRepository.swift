//
//  UserSessionDataStoreRepository.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/10/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public protocol UserSessionDataStoreRepository {
    
    func readUserSession(completion: @escaping CredentialsCompletion)
    func saveUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion)
    func deleteUserSession(completion: @escaping CredentialsCompletion)
    func updateUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion)
}
