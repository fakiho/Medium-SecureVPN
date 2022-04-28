//
//  InAppPurchaseUseCase.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/1/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

public protocol InAppPurchaseUseCase {
    func requestProduct(_ completion: @escaping ProductsRequestCompletionHandler)
    func buyProduct(_ product: ProductIdentifier)
    func isProductPurchased(_ productIdentifier: ProductIdentifier, completion: @escaping (Result<Bool, Error>) -> Void)
    func canMakePurchase(_ completion: @escaping(Result<Bool, Error>) -> Void)
    func restorePurchase()
    func receiptValidation(completion: @escaping ValidatePurchaseCompletion) -> Cancellable?
}

public class DefaultInAppPurchaseUseCase {
    
    private var purchaseRepository: IAPRepository
    init(inAppRepository: IAPRepository) {
        self.purchaseRepository = inAppRepository
    }
}

extension DefaultInAppPurchaseUseCase: InAppPurchaseUseCase {
    
    public func requestProduct(_ completion: @escaping ProductsRequestCompletionHandler) {
        self.purchaseRepository.requestProduct(completion)
    }

    
    public func buyProduct(_ product: ProductIdentifier) {
        SwiftyStoreKit.purchaseProduct(product, atomically: true) { (result) in
            if case .success(let purchase) = result {
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: AppConfiguration().sharedSecretKey)
                SwiftyStoreKit.verifyReceipt(using: appleValidator) { (result) in
                    if case .success(let receipt) = result {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                                           ofType: .autoRenewable,
                                           productId: product,
                                           inReceipt: receipt)
                        
                        //let purchaseResult: VerifySubscriptionResult
                        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: purchaseResult)
                    } else {
                        // receipt verification error
                        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: "failure")
                    }
                }
            } else {
                // purchase error
                NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: "failure")
            }
        }
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.purchaseRepository.isProductPurchased(productIdentifier, completion: completion)
    }
    
    public func canMakePurchase(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        self.purchaseRepository.canMakePurchase(completion)
    }
    
    public func restorePurchase() {
        self.purchaseRepository.restorePurchase()
    }
    
    public func receiptValidation(completion: @escaping ValidatePurchaseCompletion) -> Cancellable? {
        return self.purchaseRepository.receiptValidation(completion: completion)
    }
}
