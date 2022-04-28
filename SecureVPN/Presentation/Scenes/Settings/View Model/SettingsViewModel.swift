//
//  SettingsViewModel.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/22/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

enum SettingsViewModelRouting {
    
}

enum SettingsViewModelLoadingType {
    
}

protocol SettingsViewModelOutput {
    var resetCache: Observable<Bool> { get }
    var buildNumber: Observable<String> { get }
    var versionNumber: Observable<String> { get }
}

protocol SettingsViewModelInput {
    func viewDidLoad()
    func didChangeRestCache(value: Bool)
}

protocol SettingsViewModel: SettingsViewModelInput, SettingsViewModelOutput { }

public final class DefaultSettingsViewModel: SettingsViewModel {
    
    private var userSettingUseCase: UserSettingsUseCase
    
    init(userSettingsUseCase: UserSettingsUseCase) {
        self.userSettingUseCase = userSettingsUseCase
    }
    
    // MARK: - METHODS
    private func loadSettings() {
        self.userSettingUseCase.getBuildNumber { [weak self] result in
            guard let self = self else { return }
            guard let value = try? result.get() else { return }
            self.buildNumber.value = value
        }
        
        self.userSettingUseCase.getVersionNumber { [weak self] result in
            guard let self = self else { return }
            guard let value = try? result.get() else { return }
            self.versionNumber.value = value
        }
        
        self.userSettingUseCase.readCacheSettings { [weak self] result in
            guard let self = self else { return }
            guard let value = try? result.get() else { return }
            self.resetCache.value = value
        }
    }
    
    // MARK: - OUTPUT
    var resetCache: Observable<Bool> = Observable(false)
    var buildNumber: Observable<String> = Observable("")
    var versionNumber: Observable<String> = Observable("")
}

// MARK: - INPUT
extension DefaultSettingsViewModel {
    func viewDidLoad() {
        loadSettings()
    }
    
    func didChangeRestCache(value: Bool) {
        self.userSettingUseCase.setCacheSettings(isCacheEnabled: value) { [weak self] result in
            guard let value = try? result.get() else {
                return
            }
            self?.resetCache.value = value
        }
    }
}
