//
//  UserSession.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/9/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public struct UserSession {
    
    public var profile: Profile
    public var remoteSession: RemoteUserSession
    public var deeplinkUser: DeeplinkUserSession
    
    public init(profile: Profile, remoteSession: RemoteUserSession, deeplinkUserSession: DeeplinkUserSession) {
        self.profile = profile
        self.remoteSession = remoteSession
        self.deeplinkUser = deeplinkUserSession
    }
    
    public func isProActive() -> Bool {
        var inAppPurchased: Bool = false
        for product in profile.products {
            if product.isPurchaseActive() {
                inAppPurchased = true
                break
            }
        }
        return inAppPurchased || deeplinkUser.isPurchased
    }
    
    func logSession() {
        print("profile \(profile)")
        print("Profile.Name \(profile.name)")
        print("Profile.email \(profile.email)")
        print("Profile.mobileNumber \(profile.mobileNumber)")
        print("Profile.product count \(profile.products.count)")
        print("User IS ACTIVE: \(isProActive())")
        
        print("*********** DEEPLINK ***********")
        print("is Valid Deeplink User: \(self.deeplinkUser.isValidDeeplinkUser())")
        print("deeplink: \(String(describing: self.deeplinkUser.deeplink))")
        print("is Pro Deeplink: \(self.deeplinkUser.isPurchased)")
        print("*********** END DEEPLINK ***********")
        
        for p in profile.products {
            print("product identifier \(p.productIdentifier)")
            print("product Transaction status \(p.transactionState)")
            print("product Transaction applicationUserName \(String(describing: p.applicationUserName))")
            print("product Transaction Purchase Date: \(String(describing: p.transactionDate))")
            print("product Transaction expire Date: \(String(describing: p.expireDate))")
            print("Current Date \(String(describing: Date()))")
        }
        print("Remote Session: \(remoteSession.self)")
        print("Remote Session Token: \(remoteSession.token)")
    }
}

extension UserSession: Equatable {
    public static func == (lhs: UserSession, rhs: UserSession) -> Bool {
        return lhs.profile == rhs.profile &&
            lhs.remoteSession == rhs.remoteSession
    }
}
