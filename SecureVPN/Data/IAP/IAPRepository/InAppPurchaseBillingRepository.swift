//
//  InAppPurchaseBillingRepository.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/17/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import StoreKit

protocol InAppPurchaseBillingRepository: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    func requestProducts(_ completion: @escaping ProductsRequestCompletionHandler)
    func buyProduct(_ productIdentifier: ProductIdentifier)
    func buyProduct(_ product: SKProduct)
    func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool
    func canMakePayment() -> Bool
    func restorePurchase()
    func refreshReceipt(completion: @escaping () -> Void)
}
