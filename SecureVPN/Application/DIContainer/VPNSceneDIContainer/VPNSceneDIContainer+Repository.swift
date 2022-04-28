//
//  VPNSceneDIContainer+Repository.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/12/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import os
import UIKit

// MARK: - REPOSITORY
extension VPNSceneDIContainer {
    
    private func makeNotificationStorage() -> NotificationStorageRepository {
        return DefaultNotificationStorage(maxStorage: 50)
    }
    
    internal func makeUserSessionDataStorageRepository() -> UserSessionDataStorage {
       
        #if USER_SESSION_DATASTORE_FILE_BASED
        os_log("FileUserSessionDataStore")
           return FileUserSessionDataStore()
        #else
        let coder = makeUserSessionCoder()
        return DefaultKeychainStorage(userSessionCoder: coder)
       #endif
    }
    
    private func makeUserSessionCoder() -> UserSessionCoding {
        return UserSessionPropertyListCoder()
    }
       
    private func makeDefaultUserSessionRepository() -> UserSessionRepository {
        return DefaultUserSessionRepository(dataTransferService: dependencies.apiDataTransferService, dataStorageRepository: makeUserSessionDataStorageRepository())
    }

    internal func makeNetworkVPNManager() -> VPNRepository {
       return DefaultVPNManager()
    }
    
    internal func makeNetworkVPNManagerRepository() -> DVPNRepository {
        return DefaultVPNRepository(vpnManager: makeNetworkVPNManager(), dataTransfer: dependencies.apiDataTransferService)
    }
    
    private func makeIAPManager() -> InAppPurchaseBillingRepository {
        return IAPManager(productIds: IAPConfiguration().productIdentifiers)
    }
    
    internal func makeInAppPurchaseRepository() -> IAPRepository {
        return DefaultIAPRepository(manager: makeIAPManager(), iTunesDataService: dependencies.iTunesDataTransferService)
    }
    
    internal func makeNotificationRepository() -> NotificationRepository {
        return DefaultNotificationRepository(storage: makeNotificationStorage())
    }
    
    internal func makeFlagImagesRepository() -> FlagImagesRepository {
        return DefaultImageFlagRepository(dataTransferService: dependencies.imageDataTransferService, imageNotFoundData: UIImage(named: "not_found")?.pngData())
    }
    
    internal func makeServerStorageRepository() -> ServerStorageRepository {
        return DefaultServerStorage()
    }
}
