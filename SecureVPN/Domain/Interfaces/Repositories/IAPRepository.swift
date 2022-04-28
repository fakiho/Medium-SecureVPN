//
//  IAPManager.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import StoreKit

public enum PurchaseStatus {
    case restoreSuccessfully(id: String, expireDate: Date, originDate: Date)
    case purchasedSuccessfully(id: String, expireDate: Date, originDate: Date)
    case restoreFailed(error: String)
    case purchaseFailed(error: String)
    case error(error: String)
    case expire
    case active(date: Date)
    case activeTestEnv
}
public typealias ValidatePurchaseCompletion = ((Result<PurchaseStatus, Error>) -> Void)
protocol IAPRepository {
    func requestProduct(_ completion: @escaping ProductsRequestCompletionHandler)
    func buyProduct(_ product: ProductIdentifier)
    func isProductPurchased(_ productIdentifier: ProductIdentifier, completion: @escaping (Result<Bool, Error>) -> Void)
    func canMakePurchase(_ completion: @escaping(Result<Bool, Error>) -> Void)
    func restorePurchase()
    func receiptValidation(completion: @escaping ValidatePurchaseCompletion) -> Cancellable?
}

public typealias ProductIdentifier = String
//success: Bool, _ products: [SKProduct]
public typealias ProductsRequestCompletionHandler = (Result<[SKProduct]?, Error>) -> Void
