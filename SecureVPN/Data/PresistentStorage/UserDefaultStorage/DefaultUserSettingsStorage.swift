//
//  DefaultUserSettingsStorage.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/18/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import UIKit
final class DefaultUserSettingsStorage {

    private var userDefaults: UserDefaults { return UserDefaults.standard }
    
    internal var resetCache: Bool {
        get {
            return userDefaults.bool(forKey: IdentifierConstants.Settings.resetCache)
        }
        set {
            userDefaults.set(newValue, forKey: IdentifierConstants.Settings.resetCache)
        }
    }
    
    internal var versionNumber: String {
        get {
            return UIApplication.versionNumber
        }
        
        set {
            userDefaults.set(newValue, forKey: IdentifierConstants.Settings.versionNumber)
        }
    }
    
    internal var buildNumber: String {
        get {
            return UIApplication.buildNumber
        }
        
        set {
            userDefaults.set(newValue, forKey: IdentifierConstants.Settings.buildNumber)
        }
    }
}

extension DefaultUserSettingsStorage: UserSettingsStorageRepository {
    func setCacheSettings(isCacheEnabled: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        resetCache = isCacheEnabled
        completion(.success(isCacheEnabled))
    }
    
    func readCacheSettings(completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(.success(resetCache))
    }
    
    func getBuildNumber(completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success(buildNumber))
    }
    
    func setBuildNumber(buildNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        self.buildNumber = buildNumber
        completion(.success(buildNumber))
    }
    
    func getVersionNumber(completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success(versionNumber))
    }
    
    func setVersionNumber(versionNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        self.versionNumber = versionNumber
        completion(.success(versionNumber))
    }
}

extension DefaultUserSettingsStorage: UserSettingsStorage {}

private extension UIApplication {
    static var appVersion: String {
        let versionNumber = Bundle.main.infoDictionary?[IdentifierConstants.InfoPlist.versionNumber] as? String
        let buildNumber = Bundle.main.infoDictionary?[IdentifierConstants.InfoPlist.buildNumber] as? String

        let formattedBuildNumber = buildNumber.map {
            return "(\($0))"
        }

        return [versionNumber, formattedBuildNumber].compactMap { $0 }.joined(separator: " ")
    }
    
    static var versionNumber: String {
        let vn = Bundle.main.infoDictionary?[IdentifierConstants.InfoPlist.versionNumber] as? String
        return "\(vn ?? "")"
    }
    
    static var buildNumber: String {
        let bn = Bundle.main.infoDictionary?[IdentifierConstants.InfoPlist.buildNumber] as? String
        return "\(bn ?? "")"
    }
}

struct IdentifierConstants {
    struct InfoPlist {
        static let versionNumber = "CFBundleShortVersionString"
        static let buildNumber = "CFBundleVersion"
    }
    
    struct Settings {
        static let versionNumber = "CFBundleShortVersionString"
        static let buildNumber = "CFBundleVersion"
        static let resetCache = "RESET_CACHE"
    }
}
