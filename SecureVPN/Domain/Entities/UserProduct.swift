//
//  UserProduct.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/12/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public struct UserProduct {
    var transactionDate: Date
    var expireDate: Date
    var transactionState: Int
    var productIdentifier: String
    var applicationUserName: String?
    var status: Bool
    
    func isPurchaseActive() -> Bool {
        let userDef = UserDefaults.standard
        if userDef.bool(forKey: productIdentifier) {
            return isCurrentSubscriptionActive(exDate: expireDate)
        }
        return false
    }
    
    private func isCurrentSubscriptionActive(exDate: Date) -> Bool {
        let currentDateTime = Date()

        return (exDate.timeIntervalSince(currentDateTime) > 0)
    }
}

extension UserProduct: Equatable {}
