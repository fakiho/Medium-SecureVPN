//
//  UserSessionRepository.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/9/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import AFNetworks
import UIKit

public class DefaultUserSessionRepository {
    
    private let dataTransferService: DataTransferService
    private let dataStorage: UserSessionDataStorage
    
    private var mockSession: UserSession {
        return UserSession(profile: Profile(name: "", 
                                            email: "", 
                                            mobileNumber: "",
                                            avatar: "",
                                            products: []),
                           remoteSession: RemoteUserSession(token: UIDevice.current.identifierForVendor?.uuidString ?? "4499065"), 
                           deeplinkUserSession: DeeplinkUserSession(deeplink: nil))
    }
    
    init(dataTransferService: DataTransferService, dataStorageRepository: UserSessionDataStorage) {
        self.dataTransferService = dataTransferService
        self.dataStorage = dataStorageRepository
    }
    
}
extension DefaultUserSessionRepository: UserSessionRepository {
    public func readUserSession(completion: @escaping CredentialsCompletion) -> Cancellable? {
        _ = APIEndpoints.requestToken(token: "")
        var operation: OperationQueue?
        operation = self.dataStorage.readUserSession(completion: completion)        
        return RepositoryTask(networkTask: nil, operation: operation)
    }
    
    public func signUp(newAccount: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable? {
        
        let endPoint = APIEndpoints.signUp(newAccount: newAccount)
        var operation: OperationQueue?
        let networkTask = dataTransferService.request(with: endPoint) { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let data):
                operation = strongSelf.dataStorage.saveUserSession(userSession: data, completion: completion)
            case .failure:
                operation = strongSelf.dataStorage.saveUserSession(userSession: strongSelf.mockSession, completion: completion)
            }
        }
        
        return RepositoryTask(networkTask: networkTask, operation: operation)
    }
    
    public func signIn(email: String, password: String, completion: @escaping CredentialsCompletion) -> Cancellable? {
        let endpoint = APIEndpoints.signIn(email: email, password: password)
        var operation: OperationQueue?
        let networkTask = dataTransferService.request(with: endpoint) { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let data):
                operation = strongSelf.dataStorage.updateUserSession(userSession: data, completion: completion)
            case .failure:
                operation = strongSelf.dataStorage.saveUserSession(userSession: strongSelf.mockSession, completion: completion)
            }
        }
        return RepositoryTask(networkTask: networkTask, operation: operation)
    }
    
    public func signOut(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable? {
        
        let endpoint = APIEndpoints.signOut(userSession: userSession)
        var operation: OperationQueue?
        let networkTask = dataTransferService.request(with: endpoint) { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let data):
                operation = strongSelf.dataStorage.deleteUserSession(completion: completion)
                completion(.success(data))
            case .failure:
                operation = strongSelf.dataStorage.deleteUserSession(completion: completion)
            }
        }
        return RepositoryTask(networkTask: networkTask, operation: operation)
    }
    
    public func updateUserPurchase(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable? {
        let endPoint = APIEndpoints.updatePurchase(userSession: userSession)
        var operation: OperationQueue?
        let networkTask = dataTransferService.request(with: endPoint) { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let data):
                operation = strongSelf.dataStorage.updateUserSession(userSession: data, completion: completion)
            case .failure:
                operation = strongSelf.dataStorage.updateUserSession(userSession: userSession, completion: completion)
            }
        }
        return RepositoryTask(networkTask: networkTask, operation: operation)
    }
    
    public func updateUserSession(userSession: UserSession, completion: @escaping CredentialsCompletion) -> Cancellable? {
        let endPoint = APIEndpoints.requestToken(token: userSession.remoteSession.token)
        var operation: OperationQueue?
        let networkTask = dataTransferService.request(with: endPoint) { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let data):
                operation = strongSelf.dataStorage.updateUserSession(userSession: data, completion: completion)
            case .failure:
                operation = strongSelf.dataStorage.updateUserSession(userSession: userSession, completion: completion)
            }
        }
        return RepositoryTask(networkTask: networkTask, operation: operation)
    }
    
    public func deleteKey(completion: @escaping CredentialsCompletion) -> Cancellable? {
        var operation: OperationQueue?
        operation = self.dataStorage.deleteUserSession(completion: completion)
        return RepositoryTask(networkTask: nil, operation: operation)
    }
}
