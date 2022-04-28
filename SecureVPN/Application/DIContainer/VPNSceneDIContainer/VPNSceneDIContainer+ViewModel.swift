//
//  VPNSceneDIContainer+ViewModel.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/12/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

// MARK: - VIEW MODELS
extension VPNSceneDIContainer {
    
    func makeSplashViewModel() -> SplashViewModel {
        return DefaultSplashViewModel(userCredentialsUseCase: makeDefaultUserCredentialsUseCase(), userSettingsUseCase: makeDefaultUserSettingsUseCase())
    }
       
    func makeSettingsViewModel() -> SettingsViewModel {
       return DefaultSettingsViewModel(userSettingsUseCase: makeDefaultUserSettingsUseCase())
    }

    func makeDashboardViewModel() -> DashboardViewModel {
       let inAppPurchaseUseCase = makeInAppPurchaseUseCase(productIdentifiers: IAPConfiguration().productIdentifiers)
        return DefaultDashboardViewModel(networkVPNUseCase: makeNetworkVPNUseCase(), 
                                         inAppUseCase: inAppPurchaseUseCase, 
                                         userCredentialsUseCase: makeDefaultUserCredentialsUseCase(), 
                                         flagImageRepository: makeFlagImagesRepository(),
                                         serverRepo: makeServerStorageRepository())
    }
         
    func makeNotificationViewModel() -> NotificationViewModel {
        return DefaultNotificationViewModel(notificationUseCase: makeNotificationUseCase())
    }
    
    func makeInAppPurchaseViewModel(delegate: PurchaseDelegate) -> InAppPurchaseViewModel {
        return DefaultInAppPurchaseViewModel(inAppPurchaseUseCase: makeInAppPurchaseUseCase(), userCredentials: makeDefaultUserCredentialsUseCase(), purchaseDelegate: delegate)
    }
    
    func makeServerListViewModel(delegate: ServerListViewModelDelegate, servers: [Server]) -> ServerListViewModel {
        return DefaultServerListViewModel(delegate: delegate, servers: servers)
    }
}
