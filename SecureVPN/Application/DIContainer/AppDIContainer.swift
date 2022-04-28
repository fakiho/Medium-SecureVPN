//
//  AppDIContainer.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import UIKit
import AFNetworks

final class AppDIContainer {
    
    // Long Lived dependencies
    lazy var appConfigurations = AppConfiguration()
    
    // MARK: - NETWORK
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.apiBaseURL)!,
                                          queryParameters: ["api_Key": appConfigurations.apiKey,
                                                           "language": NSLocale.preferredLanguages.first ?? "en"])
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    
    lazy var apiImageDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.flagApi)!)
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    
    lazy var iTunesDataTransferService: DataTransferService = {
        print(appConfigurations.iTunesURL)
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.iTunesURL)!)
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
   
    func makeVPNSceneDIContainer() -> VPNSceneDIContainer {
        let dependencies = VPNSceneDIContainer.Dependencies(apiDataTransferService: apiDataTransferService, 
                                                            iTunesDataTransferService: iTunesDataTransferService, 
                                                            imageDataTransferService: apiImageDataTransferService)
        
        return VPNSceneDIContainer(dependencies: dependencies)
    }
}

// MARK: - ADJUST CONFIGURATION
extension AppDIContainer {
    
    func handleDeeplink(deeplink: URL?, window: UIWindow?) {
        guard let deeplinkMain = deeplink else { return }
        UserDefaults.standard.setValue(deeplink?.absoluteString, forKey: "deeplinkURL")
        UserDefaults.standard.synchronize()
        if let queryParam = deeplinkMain.queryDictionary {
            //handleParam here
            let isPremium = queryParam["isPurchased"] as? String
            let deeplinkSession = DeeplinkUserSession(deeplink: deeplink?.absoluteString, isPurchased: (isPremium == "true"))
            let user = UserSession(profile: Profile(name:"",
                                                email: "",
                                                mobileNumber: "",
                                                avatar: "",
                                                products: []),
                               remoteSession: RemoteUserSession(token: UIDevice.current.identifierForVendor?.uuidString ?? "4499065"),
                               deeplinkUserSession: deeplinkSession)
            NotificationCenter.default.post(name: Notification.Name.DeepLinkFlow, object: user)
        }
    }
}

private extension URL {
    var queryDictionary: [String: Any]? {
        guard let query = self.query else { return nil }
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
            .components(separatedBy: "=")[1]
            .replacingOccurrences(of: "+", with: " ")
            .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        return queryStrings
    }
}

extension Notification.Name {
    static let DeepLinkFlow = Notification.Name("org.deeplink.flow-pixyEditor")
}
