//
//  VPNSceneDIContainer+UseCases.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/12/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

// MARK: - USE CASES
extension VPNSceneDIContainer {

    func makeDefaultUserCredentialsUseCase() -> UserCredentialsUseCase {
        return DefaultUserCredentialsUseCase(userSessionRepository: sharedUserSessionRepository)
    }
    
    func makeDefaultUserSettingsUseCase() -> UserSettingsUseCase {
        return DefaultUserSettingsUseCase(settingsRepository: userSettingStorage)
    }
    
    func makeNetworkVPNUseCase() -> NetworkVPNUseCase {
        return DefaultNetworkVPNUseCase(vpnManager: makeNetworkVPNManagerRepository())
    }
    
    func makeInAppPurchaseUseCase(productIdentifiers: Set<ProductIdentifier> = IAPConfiguration().productIdentifiers) -> InAppPurchaseUseCase {
        return DefaultInAppPurchaseUseCase(inAppRepository: makeInAppPurchaseRepository())
    }
    
    func makeNotificationUseCase() -> NotificationUseCase {
        return DefaultNotificationUseCase(notification: makeNotificationRepository())
    }
}
