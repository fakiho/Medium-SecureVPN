//
//  Profile.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/9/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public struct Profile {
    public let name: String
    public let email: String
    public let mobileNumber: String
    public let avatar: String
    public var products: [UserProduct]
    
    public init(name: String, email: String, mobileNumber: String, avatar: String, products: [UserProduct]) {
        self.name = name
        self.email = email
        self.mobileNumber = mobileNumber
        self.avatar = avatar
        self.products = products
    }
}
extension Profile: Equatable { }
