//
//  UserSettingsRepository.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/18/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public protocol UserSettingsStorageRepository {
    func setCacheSettings(isCacheEnabled: Bool, completion: @escaping (Result<Bool, Error>) -> Void)
    func readCacheSettings(completion: @escaping(Result<Bool, Error>) -> Void)
    func getBuildNumber(completion: @escaping (Result<String, Error>) -> Void)
    func setBuildNumber(buildNumber: String, completion: @escaping (Result<String, Error>) -> Void)
    func getVersionNumber(completion: @escaping (Result<String, Error>) -> Void)
    func setVersionNumber(versionNumber: String, completion: @escaping (Result<String, Error>) -> Void)
}
