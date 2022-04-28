//
//  DefaultIAPRepository.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/17/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import AFNetworks
import SwiftyStoreKit

final class DefaultIAPRepository {
    
    private let manager: InAppPurchaseBillingRepository
    private let iTunesDataService: DataTransferService
    init(manager: InAppPurchaseBillingRepository, iTunesDataService: DataTransferService) {
        self.manager = manager
        self.iTunesDataService = iTunesDataService
    }
}

extension DefaultIAPRepository: IAPRepository {
    
    func requestProduct(_ completion: @escaping ProductsRequestCompletionHandler) {
        self.manager.requestProducts(completion)
    }
    
    func buyProduct(_ product: ProductIdentifier) {
        self.manager.buyProduct(product)
    }
    
    func isProductPurchased(_ productIdentifier: ProductIdentifier, completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(.success(self.manager.isProductPurchased(productIdentifier)))
    }
    
    func canMakePurchase(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(.success(self.manager.canMakePayment()))
    }
    
    func restorePurchase() {
        self.manager.restorePurchase()
    }
    
    func receiptValidation(completion: @escaping ValidatePurchaseCompletion) -> Cancellable? {
        let operation: OperationQueue = OperationQueue()
        operation.addOperation {
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: AppConfiguration().sharedSecretKey)
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { [self] result in
                if case .success(let receipt) = result {
                    var productIdentifier = ""
                    for item in IAPConfiguration().productIdentifiers {
                        if self.manager.isProductPurchased(item) {
                            productIdentifier = item
                            break
                        }
                    }
                    let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable,productId: productIdentifier,inReceipt: receipt)
                    switch purchaseResult {
                    case .purchased(let expiryDate, let items):

                        for item in items {
                            if self.isCurrentSubscriptionActive(expiryDate: item.subscriptionExpirationDate!) {
                                completion(.success(.restoreSuccessfully(id: item.productId, expireDate: expiryDate, originDate: item.originalPurchaseDate)))
                                break
                            }
                        }
                    case .expired( _, _):
                        completion(.success(.expire))
                    case .notPurchased:
                        completion(.failure(NSError(domain: "No Subscription found", code: 0, userInfo: nil)))
                    }
                }
            }
            return
        }
        return RepositoryTask(networkTask: nil, operation: operation)
    }

    func parseJSONDataResponse(jsonResponse: NSDictionary, completion: @escaping ValidatePurchaseCompletion) {
        var currentIsActive = false
        var expireDateStr: String = ""
        var productId: String = ""
        var currentTimeZDate: Date?
        guard let status = jsonResponse["status"] as? Int else { completion(.failure(NSError(domain: "receipt-data property was malformed", code: 0, userInfo: nil))); return}
        switch status {
            // The request to the App Store was not made using the HTTP POST request method.
        case 21000:
            completion(.failure(NSError(domain: "The request to the App Store was not made using the HTTP POST request method", code: 21000, userInfo: nil)))
            // This status code is no longer sent by the App Store.
        case 21001:
            completion(.failure(NSError(domain: "This status code is no longer sent by the App Store.", code: 21001, userInfo: nil)))
            // The data in the receipt-data property was malformed or the service experienced a temporary issue. Try again.
        case 21002:
            completion(.failure(NSError(domain: "The data in the receipt-data property was malformed or the service experienced a temporary issue. Try again.", code: 21002, userInfo: nil)))
            // The receipt could not be authenticated.
        case 21003:
            completion(.failure(NSError(domain: "The receipt could not be authenticated", code: 21003, userInfo: nil)))
            // The shared secret you provided does not match the shared secret on file for your account
        case 21004:
            completion(.failure(NSError(domain: "The shared secret you provided does not match the shared secret on file for your account.", code: 21004, userInfo: nil)))
            // The receipt server was temporarily unable to provide the receipt. Try again.
        case 21005:
            completion(.failure(NSError(domain: "The receipt server was temporarily unable to provide the receipt. Try again.", code: 21005, userInfo: nil)))
            // This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response.
            // Only returned for iOS 6-style transaction receipts for auto-renewable subscriptions
        case 21006:
            completion(.success(.expire))
            // This receipt is from the test environment, but it was sent to the production environment for verification.
        case 21007:
             completion(.failure(NSError(domain: "This receipt is from the test environment, but it was sent to the production environment for verification", code: 21007, userInfo: nil)))
            // This receipt is from the production environment, but it was sent to the test environment for verification.
        case 21008:
            completion(.failure(NSError(domain: "This receipt is from the production environment, but it was sent to the test environment for verification.", code: 21008, userInfo: nil)))
            // Internal data access error. Try again later.
        case 21009:
            completion(.failure(NSError(domain: "Internal data access error. Try again later. ", code: 21009, userInfo: nil)))
            // The user account cannot be found or has been deleted
        case 21010:
            completion(.failure(NSError(domain: "The user account cannot be found or has been deleted.", code: 21010, userInfo: nil)))
        default:
            guard let latestReceiptInfo = jsonResponse["latest_receipt_info"] as? [Dictionary<String, Any>]
            else {
                completion(.failure(NSError(domain: "malformed data", code: 0, userInfo: nil)))
                return
            }

            for latestDetails in latestReceiptInfo {
                if let originalTimeZ = latestDetails["original_purchase_date"],
                   let currentTimeZ = latestDetails["purchase_date"],
                   let productIdTemp = latestDetails["product_id"] as? String,
                   let expiresDateMs = latestDetails["expires_date"] as? String {
                    let dateFormatter1: DateFormatter = DateFormatter()
                    dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss VV" //convert date format
                    let originalTimeZDate = dateFormatter1.date(from: "\(originalTimeZ)")
                    currentTimeZDate = dateFormatter1.date(from: "\(currentTimeZ)")
                    if let originalDateStr = dateFormatter1.string(for: originalTimeZDate),
                       let currentDateStr = dateFormatter1.string(for: currentTimeZDate) {
                        print("Original Date " + originalDateStr)
                        print("Purchase Date " + currentDateStr)
                    }
                    let expireDate = dateFormatter1.date(from: expiresDateMs) ?? Date()
                    expireDateStr = "\(expireDate)"
                    print("Expire Date:  \(String(describing: dateFormatter1.string(for: expireDate)))")
                    print("Current Date: " + String(describing: dateFormatter1.string(from: Date())))
                    currentIsActive = isCurrentSubscriptionActive(expiryDate: expireDate)
                    productId = productIdTemp
                }
            }
            if currentIsActive {
                print("Restored successfully")
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                guard let expirationDate = formatter.date(from: expireDateStr) else { return }
                completion(.success(.restoreSuccessfully(id: productId, expireDate: expirationDate, originDate: currentTimeZDate ?? Date())))
            } else {
                print("Please renew your subscription to unlock all the features")
                completion(.success(.expire))
            }
        }
    }
    
    func isCurrentSubscriptionActive(expiryDate: Date) -> Bool {
        let currentDateTime = Date()
        print(expiryDate.timeIntervalSince(currentDateTime))
        return (expiryDate.timeIntervalSince(currentDateTime) > 0)
    }

}
