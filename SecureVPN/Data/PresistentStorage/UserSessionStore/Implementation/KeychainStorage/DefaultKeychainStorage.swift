//
//  DefaultKeychainStorage.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/17/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import UIKit

public protocol UserSessionCoding {
    func encode(userSession: UserSession) -> Data
    func decode(data: Data) -> UserSession
}

public final class DefaultKeychainStorage {
    
    private enum UserSessionKeychainKeys: String {
        case userSession = "USERSESSION"
    }
    private var mockSession: UserSession {
        return UserSession(profile: Profile(name: "", 
                                            email: "",
                                            mobileNumber: "",
                                            avatar: "", 
                                            products: []),
                           remoteSession: RemoteUserSession(token: UIDevice.current.identifierForVendor?.uuidString ?? "4499065"), 
                           deeplinkUserSession: DeeplinkUserSession(deeplink: nil))
    }
    private let userSessionCoder: UserSessionCoding
    
    init(userSessionCoder: UserSessionCoding) {
        self.userSessionCoder = userSessionCoder
    }
    
    var docsURL: URL? {
        return FileManager
            .default
            .urls(for: FileManager.SearchPathDirectory.documentDirectory,
            in: FileManager.SearchPathDomainMask.allDomainsMask).first
    }
    
    private func readUserSessionAsync(completion: @escaping CredentialsCompletion) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            guard let docsURL = self.docsURL else { completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil))); return }
            do {
                let jsonData = try Data(contentsOf: docsURL.appendingPathComponent("user.json"))
                let decoder = JSONDecoder()
                let user = try decoder.decode(UserSession.self, from: jsonData)
                completion(.success(user))
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    private func saveUserSessionAsync(userSession: UserSession, completion: @escaping CredentialsCompletion) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(userSession)
                guard let docsURL = self.docsURL else { completion(.failure(NSError(domain: "", code: 0, userInfo: nil))); return }
                try jsonData.write(to: docsURL.appendingPathComponent("user.json"))
                completion(.success(userSession))
            }
            catch {
                completion(.failure(error)); return
            }
        }
    }

    private func deleteUserSessionAsync(completion: @escaping CredentialsCompletion) {
        guard let docsURL = docsURL else { return }
        do {
            try FileManager.default.removeItem(at: docsURL.appendingPathComponent("user.json"))
            
        } catch { return }

    }
}

extension DefaultKeychainStorage: UserSessionDataStorage {
    
    public func readUserSession(completion: @escaping CredentialsCompletion) -> OperationQueue {
        let operation = OperationQueue()
        operation.addOperation { [weak self] in
            guard let self = self else { return }
            self.readUserSessionAsync(completion: completion)
        }
        return operation
    }
    
    public func saveUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) -> OperationQueue {
        let operation = OperationQueue()
        operation.addOperation { [weak self] in
            guard let self = self else { return }
            self.saveUserSessionAsync(userSession: userSession, completion: completion)
        }
        return operation
    }
    
    public func deleteUserSession(completion: @escaping CredentialsCompletion) -> OperationQueue {
        let operation = OperationQueue()
        operation.addOperation { [weak self] in
            guard let self = self else { return }
            self.deleteUserSessionAsync(completion: completion)
        }
        return operation
    }
    
    public func updateUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) -> OperationQueue {
        let operation = OperationQueue()
        operation.addOperation { [weak self] in
            guard let self = self else { return }
            self.saveUserSessionAsync(userSession: userSession, completion: completion)
            print("Log in block")
            userSession.logSession()
        }
        return operation
    }
   
}
