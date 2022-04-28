//
//  UserSessionDataStorage.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/10/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

protocol UserSessionDataStorage {
    
    func readUserSession(completion: @escaping CredentialsCompletion) -> OperationQueue
    func saveUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) -> OperationQueue
    func deleteUserSession(completion: @escaping CredentialsCompletion) -> OperationQueue
    func updateUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) -> OperationQueue
}
