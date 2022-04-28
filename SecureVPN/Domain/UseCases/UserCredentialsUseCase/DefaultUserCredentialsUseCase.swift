//
//  DefaultUserCredentialsUseCase.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/10/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public typealias CredentialsCompletion = (Result<UserSession?, Error>) -> Void
public protocol UserCredentialsUseCase {
    func readUserSession(completion: @escaping CredentialsCompletion) -> Cancellable?
    func signUp(newAccount: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable?
    func signIn(email: String, password: String, completion: @escaping CredentialsCompletion) -> Cancellable?
    func signOut(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable?
    func deleteSession(completion: @escaping CredentialsCompletion) -> Cancellable?
    func updateUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable?
    func updateUserPurchase(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable?
}

final class DefaultUserCredentialsUseCase: UserCredentialsUseCase {
    
    private let userSessionRepository: UserSessionRepository
    
    init(userSessionRepository: UserSessionRepository) {
        self.userSessionRepository = userSessionRepository
    }
    
    // MARK: - Use Case
    func readUserSession(completion: @escaping CredentialsCompletion) -> Cancellable? {
        return userSessionRepository.readUserSession(completion: completion)
    }
    
    func signUp(newAccount: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable? {
        return userSessionRepository.signUp(newAccount: newAccount, completion: completion)
    }
    
    func signIn(email: String, password: String, completion: @escaping CredentialsCompletion) -> Cancellable? {
        return userSessionRepository.signIn(email: email, password: password, completion: completion)
    }
    
    func signOut(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable? {
        return userSessionRepository.signOut(userSession: userSession, completion: completion)
    }
    
    func deleteSession(completion: @escaping CredentialsCompletion) -> Cancellable? {
        return userSessionRepository.deleteKey(completion: completion)
    }
        
    func updateUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable? {
        return userSessionRepository.updateUserSession(userSession: userSession, completion: completion)
    }
    
    func updateUserPurchase(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable? {
        return userSessionRepository.updateUserPurchase(userSession: userSession, completion: completion)
    }
}
