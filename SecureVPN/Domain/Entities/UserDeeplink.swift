//
//  UserDeeplink.swift
//  Secure VPN
//
//  Created by Ali Fakih on 5/14/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public struct DeeplinkUserSession {
    
    var deeplink: String?
    var isPurchased: Bool = false
    
    public init(deeplink: String?, isPurchased: Bool = false) {
        self.deeplink = deeplink
        self.isPurchased = isPurchased
    }
    
    public func isValidDeeplinkUser() -> Bool {
        return self.deeplink != nil
    }
}
