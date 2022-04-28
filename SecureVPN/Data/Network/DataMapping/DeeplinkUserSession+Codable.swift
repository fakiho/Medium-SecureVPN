//
//  DeeplinkUserSession+Codable.swift
//  Secure VPN
//
//  Created by Ali Fakih on 5/14/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

extension DeeplinkUserSession: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case deeplink
        case isPurchased
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.deeplink = try container.decodeIfPresent(String.self, forKey: .deeplink)
        self.isPurchased = try container.decode(Bool.self, forKey: .isPurchased)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deeplink, forKey: .deeplink)
        try container.encode(isPurchased, forKey: .isPurchased)
    }
}
