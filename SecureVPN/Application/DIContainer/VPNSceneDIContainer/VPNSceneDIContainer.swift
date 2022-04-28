//
//  VPNSceneDIContainer.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit
import AFNetworks
import os
final class VPNSceneDIContainer {
    
    struct TabViewControllerItem {
        
        enum TabBarItemTag: Int {
            case home = 0
            case notification = 1
            case settings = 2
        }
        
        let title: String
        let image: String
        let viewController: UIViewController
        let tag: TabBarItemTag
        
        init(title: String, image: String, viewController: UIViewController, tag: TabBarItemTag) {
            self.title = title
            self.image = image
            self.viewController = viewController
            self.tag = tag
        }
    }
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let iTunesDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }
    
    //Long-Lived Dependencies
    lazy var iapConfiguration = IAPConfiguration()
    internal let dependencies: Dependencies
    lazy var userSettingStorage: UserSettingsStorageRepository = DefaultUserSettingsStorage()
    var userSession: UserSession?
    let sharedUserSessionRepository: UserSessionRepository
    
    init(dependencies: Dependencies) {
        func makeUserSessionDataStorageRepository() -> UserSessionDataStorage {
            #if USER_SESSION_DATASTORE_FILE_BASED
            os_log("FileUserSessionDataStore")
               return FileUserSessionDataStore()
            #else
            func makeUserSessionCoder() -> UserSessionCoding {
                return UserSessionPropertyListCoder()
            }
            let coder = makeUserSessionCoder()
            return DefaultKeychainStorage(userSessionCoder: coder)
           #endif
        }
        
        func makeUserSessionRepository() -> UserSessionRepository {
            return DefaultUserSessionRepository(dataTransferService: dependencies.apiDataTransferService, dataStorageRepository: makeUserSessionDataStorageRepository())
        }
        
        self.dependencies = dependencies
        self.sharedUserSessionRepository = makeUserSessionRepository()
    }
}

extension VPNSceneDIContainer: SplashViewControllersFactory { }
