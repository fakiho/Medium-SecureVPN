//
//  FakeUserSessionDataStore.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/10/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

enum UserSessionError: Error {
    case readError(Error)
    case writeError(Error)
    case deleteError(Error)
    case notFound
    case invalidFilePath
    case invalidData
    case parsingError(Error)
    case encodingFailure(Error)
}

public class FakeUserSessionDataStore {
    
    // MARK: - Properties
    let hasToken: Bool
    
    init(hasToken: Bool) {
        self.hasToken = hasToken
    }
    
    private func runHasToken() -> UserSession? {
        debugPrint("Try to read use session from fake disk… ")
        debugPrint(" simulating having user session with token 4321… ")
        debugPrint(" returning user session with token 4321… ")
        
        let profile = Profile(name: "", email: "", mobileNumber: "", avatar: "", products: [])
        let remoteSession = RemoteUserSession(token: "4321")
        return UserSession(profile: profile, remoteSession: remoteSession, deeplinkUserSession: DeeplinkUserSession(deeplink: nil))
    }
    
    private func runDoesNotHaveToken() -> UserSession? {
        debugPrint("Try to read user session from fake disk… ")
        debugPrint(" simulating empty disk… ")
        debugPrint(" return nil… ")
        return nil
    }
}
extension FakeUserSessionDataStore: UserSessionDataStoreRepository {
    public func readUserSession(completion: @escaping CredentialsCompletion) {
        completion(hasToken ? .success(runHasToken()) : .failure(UserSessionError.notFound))
       
    }
    
    public func saveUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) {
        completion(.success(userSession))
    }
    
    public func deleteUserSession(completion: @escaping CredentialsCompletion) {
        completion(.success(nil))
    }
    
    public func updateUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) {
        completion(.success(nil))
    }
}
