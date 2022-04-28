//
//  Profile+Codable.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/9/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
extension Profile: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case mobileNumber
        case avatar
        case products
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.mobileNumber = try container.decode(String.self, forKey: .mobileNumber)
        self.avatar = try container.decode(String.self, forKey: .avatar)
        self.products = try container.decode([UserProduct].self, forKey: .products)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(mobileNumber, forKey: .mobileNumber)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(products, forKey: .products)
    }
}
