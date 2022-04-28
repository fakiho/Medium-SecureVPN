//
//  UserSessionRepository.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/9/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public protocol UserSessionRepository {
    func readUserSession(completion: @escaping CredentialsCompletion) -> Cancellable?
    func signUp(newAccount: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable?
    func signIn(email: String, password: String, completion: @escaping CredentialsCompletion) -> Cancellable?
    func signOut(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable?
    func updateUserPurchase(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable?
    func updateUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable?
    func deleteKey(completion: @escaping CredentialsCompletion) -> Cancellable?
}
