//
//  UserSettingsUseCase.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/22/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public protocol UserSettingsUseCase {
    func setCacheSettings(isCacheEnabled: Bool, completion: @escaping (Result<Bool, Error>) -> Void)
    func readCacheSettings(completion: @escaping(Result<Bool, Error>) -> Void)
    func getBuildNumber(completion: @escaping (Result<String, Error>) -> Void)
    func setBuildNumber(buildNumber: String, completion: @escaping (Result<String, Error>) -> Void)
    func getVersionNumber(completion: @escaping (Result<String, Error>) -> Void)
    func setVersionNumber(versionNumber: String, completion: @escaping (Result<String, Error>) -> Void)
}

final class DefaultUserSettingsUseCase {
    
    private var settingsRepository: UserSettingsStorageRepository
    init(settingsRepository: UserSettingsStorageRepository) {
        self.settingsRepository = settingsRepository
    }
}

extension DefaultUserSettingsUseCase: UserSettingsUseCase {
    func setCacheSettings(isCacheEnabled: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        settingsRepository.setCacheSettings(isCacheEnabled: isCacheEnabled, completion: completion)
    }
    
    func readCacheSettings(completion: @escaping (Result<Bool, Error>) -> Void) {
        settingsRepository.readCacheSettings { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                if value {
                    self.settingsRepository.setCacheSettings(isCacheEnabled: !value, completion: completion)
                }
            case .failure:
                break
            }
        }
    }
    
    func getBuildNumber(completion: @escaping (Result<String, Error>) -> Void) {
        settingsRepository.getBuildNumber(completion: completion)
    }
    
    func setBuildNumber(buildNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        settingsRepository.setBuildNumber(buildNumber: buildNumber, completion: completion)
    }
    
    func getVersionNumber(completion: @escaping (Result<String, Error>) -> Void) {
        settingsRepository.getVersionNumber(completion: completion)
    }
    
    func setVersionNumber(versionNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        settingsRepository.setVersionNumber(versionNumber: versionNumber, completion: completion)
    }
}
