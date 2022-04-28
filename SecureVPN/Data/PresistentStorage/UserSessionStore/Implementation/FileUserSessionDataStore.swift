//
//  FileUserSessionDataStore.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/11/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

final class FileUserSessionDataStore {
    
    // MARK: - Properties
    var docsURL: URL? {
        return FileManager
            .default
            .urls(for: FileManager.SearchPathDirectory.documentDirectory,
            in: FileManager.SearchPathDomainMask.allDomainsMask).first
    }
    init() {}
}

// MARK: - IMPLEMENTATION
extension FileUserSessionDataStore: UserSessionDataStoreRepository {
    func readUserSession(completion: @escaping CredentialsCompletion) {
        guard let docsURL = docsURL else { completion(.failure(UserSessionError.invalidFilePath)); return}
        guard let jsonData = try? Data(contentsOf: docsURL.appendingPathComponent("user_session.json")) else {
            completion(.failure(UserSessionError.invalidData)); return}
        let decoder = JSONDecoder()
        do {
            let userSession = try decoder.decode(UserSession.self, from: jsonData)
            completion(.success(userSession))
        } catch { completion(.failure(UserSessionError.parsingError(error))) }
    }
    
    func saveUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(userSession)
            guard let docsURL = docsURL else { completion(.failure(UserSessionError.invalidFilePath)); return}
            do {
                try FileManager.default.removeItem(at: docsURL.appendingPathComponent("user_session.json"))
                try jsonData.write(to: docsURL.appendingPathComponent("user_session.json"))
                completion(.success(userSession))
            } catch {
                completion(.failure(UserSessionError.writeError(error)))
            }
        } catch {
            completion(.failure(UserSessionError.encodingFailure(error)))
        }
    }
    
    func deleteUserSession(completion: @escaping CredentialsCompletion) {
        guard let docsURL = docsURL else { completion(.failure(UserSessionError.invalidFilePath)); return}
        do {
            try FileManager.default.removeItem(at: docsURL.appendingPathComponent("user_session.json"))
            completion(.success(nil))
        } catch {
            completion(.failure(UserSessionError.deleteError(error)))
            return
        }
        
    }
    
    func updateUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) {
        self.saveUserSession(userSession: userSession, completion: completion)
    }
}
