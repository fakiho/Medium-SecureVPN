//
//  InAppPurchaseProViewModel.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import StoreKit

enum InAppPurchaseViewModelRoute {
    case initial
    case back
}

enum InAppPurchaseViewModelLoading {
    case none
    case purchasing
    case purchased
    case fetchingProducts
    case restoring
    case restored
}

protocol InAppPurchaseViewModelInput {
    func viewDidLoad()
    func userDidPurchase(with subscription: PurchaseType)
    func dismiss()
    func restore()
}

protocol InAppPurchaseViewModelOutput {
    var route: Observable<InAppPurchaseViewModelRoute> { get }
    var loadingType: Observable<InAppPurchaseViewModelLoading> { get }
    var error: Observable<String> { get }
    var message: Observable<String> { get }
    var products: Observable<[SKProduct]> { get }
}

enum PurchaseType {
    case none
    case week
    case month
    case year
}

protocol InAppPurchaseViewModel: InAppPurchaseViewModelInput, InAppPurchaseViewModelOutput {}

final class DefaultInAppPurchaseViewModel: InAppPurchaseViewModel {
    
    // MARK: - USE CASES
    private var inAppPurchaseUseCase: InAppPurchaseUseCase
    private var userCredentialsUseCase: UserCredentialsUseCase
    private var userSession: UserSession?
    private weak var purchaseDelegate: PurchaseDelegate?
    
    init(inAppPurchaseUseCase: InAppPurchaseUseCase, userCredentials: UserCredentialsUseCase, purchaseDelegate: PurchaseDelegate) {
        self.inAppPurchaseUseCase = inAppPurchaseUseCase
        self.userCredentialsUseCase = userCredentials
        self.purchaseDelegate = purchaseDelegate
    }
    
    // MARK: - Load Task
    private var updateLoadTask: Cancellable? { willSet { updateLoadTask?.cancel(); print("update session load task cancelled inAppPurchase")} }
    private var checkSessionLoadTask: Cancellable? { willSet { checkSessionLoadTask?.cancel(); print("check session in app purchase cancelled")} }
    
    private var validateLoadTask: Cancellable? { willSet { validateLoadTask?.cancel() }}
    
    private func observe() {
         NotificationCenter.default.addObserver(self, selector: #selector(inAppPurchaseStatusDidChange(_:)), name: NSNotification.Name.IAPHelperPurchaseNotification, object: nil)
    }
    
    private func registerNotification() {
        var date: Date = Date()
        guard let userSessionTemp = userSession else {return}
        for product in userSessionTemp.profile.products {
            if product.isPurchaseActive() {
                date = product.expireDate
            }
        }
        let content = UNMutableNotificationContent()
        content.title = "Subscription"
        content.body = "Your Subscription has ended, please renew it to re-activate to stay secure"
        content.categoryIdentifier = "End Subs"
        content.sound = .default
        let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: false)
        // Initializing the Notification Request object to add to the Notification Center
        let request = UNNotificationRequest(identifier: "End Subs", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        // Adding the notification to the center
        center.add(request) { (error) in
           if (error) != nil {
               print(error!.localizedDescription)
           }
        }
    }
    
    @objc
    func inAppPurchaseStatusDidChange(_ notification: Notification) {
        if let transaction = notification.object as? SKPaymentTransaction {
            if transaction.transactionState == .purchased {
                self.validateSubscription(completion: { [weak self] in
                    guard let self = self else { return }
                    for product in self.userSession?.profile.products ?? [] {
                        if product.isPurchaseActive() {
                            self.message.value = "Subscription Activated Expire date \(product.expireDate)"
                            self.loadingType.value = .purchased
                            self.route.value = .back
                            self.registerNotification()
                        }
                    }
                })
            } else if transaction.transactionState == .restored {
                let transactionID = transaction.transactionIdentifier ?? ""
                self.validateSubscription(completion: { [weak self] in
                    guard let self = self else { return }
                    for product in self.userSession?.profile.products ?? [] {
                        if product.isPurchaseActive() {
                            if transactionID.contains("weekly") {
                                self.message.value = "Weekly subscription restored"
                            } else if transactionID.contains("month") {
                                self.message.value = "Monthly subscription restored"
                            } else if transactionID.contains("yearly") {
                                self.message.value = "Yearly subscription restored"
                            }
                        } else {
                            self.message.value = "We didn't find any subscription to restore!"
                        }
                    }
                    if self.userSession?.profile.products.isEmpty != nil {
                        self.message.value = "We didn't find any subscription to restore!"
                    }
                    self.loadingType.value = .restored
                    self.route.value = .back
                })
            } else {
                self.loadingType.value = .none
            }
        }
        purchaseDelegate?.didFinishPurchase()
    }

    private func validateSubscription(completion: @escaping () -> Void) {
        self.loadingType.value = .purchasing
        guard var session = userSession else { return }
        self.validateLoadTask = self.inAppPurchaseUseCase.receiptValidation(completion: { [weak self] result in
            guard let self = self else { return }
            var userProducts: [UserProduct] = []
            do {
                let subsStatus = try result.get()
                switch subsStatus {
                case .restoreSuccessfully(id: let id, expireDate: let expireDate, originDate: let originDate):
                    let userProduct: UserProduct = UserProduct(transactionDate: originDate,
                                                               expireDate: expireDate,
                                                               transactionState: 0,
                                                               productIdentifier: id,
                                                               applicationUserName: "",
                                                               status: true)
                    userProducts.append(userProduct)
                    session.profile = Profile(name: session.profile.name,
                                              email: session.profile.email,
                                              mobileNumber: session.profile.mobileNumber,
                                              avatar: session.profile.avatar,
                                              products: userProducts)
                    session.logSession()
                    self.updateLoadTask = self.userCredentialsUseCase.updateUserPurchase(userSession: session) { _ in
                        DispatchQueue.main.async {
                            self.loadingType.value = .none
                        }
                        self.readSession(completion: completion)
                    }
                case .purchasedSuccessfully(id: let id, expireDate: let expireDate, originDate: let originDate):
                    let userProduct: UserProduct = UserProduct(transactionDate: originDate,
                                                               expireDate: expireDate,
                                                               transactionState: 0,
                                                               productIdentifier: id,
                                                               applicationUserName: "",
                                                               status: true)
                    userProducts.append(userProduct)
                    session.profile = Profile(name: session.profile.name,
                                              email: session.profile.email,
                                              mobileNumber: session.profile.mobileNumber,
                                              avatar: session.profile.avatar,
                                              products: userProducts)
                    session.logSession()
                    self.updateLoadTask = self.userCredentialsUseCase.updateUserPurchase(userSession: session) { _ in
                        DispatchQueue.main.async {
                            self.loadingType.value = .none
                        }
                        self.readSession(completion: completion)
                    }
                case .expire:
                    DispatchQueue.main.async {
                        self.loadingType.value = .none
                    }
                    self.readSession(completion: completion)
                default:
                    break
                }
            } catch
            {
                DispatchQueue.main.async {
                    self.loadingType.value = .none
                    print("ERROR: " + error.localizedDescription)
                }
            }
        })
    }
    
    private func fetchProducts() {
        self.inAppPurchaseUseCase.requestProduct { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let products):
                if var tempProduct = products {
                    let weeklyProduct = tempProduct.filter { $0.productIdentifier.contains("weekly") }
                    
                    if let firstItem = weeklyProduct.first {
                        let index = tempProduct.firstIndex(of: firstItem)
                        tempProduct.remove(at: index ?? 0)
                        tempProduct.insert(firstItem, at: 0)
                    }
                    self.products.value = tempProduct
                }
                self.loadingType.value = .none
            case .failure(let error):
                self.error.value = error.localizedDescription
                self.loadingType.value = .none
            }
        }
    }
    
    private func readSession(completion: @escaping () -> Void) {
        self.checkSessionLoadTask = self.userCredentialsUseCase.readUserSession { [weak self] result in
            guard let self = self else { return }
            self.userSession = try? result.get()
            completion()
        }
    }
    // MARK: - Output
    var route: Observable<InAppPurchaseViewModelRoute> = Observable(.initial)
    var loadingType: Observable<InAppPurchaseViewModelLoading> = Observable(.none)
    var error: Observable<String> = Observable("")
    var products: Observable<[SKProduct]> = Observable([])
    var message: Observable<String> = Observable("")
    
    deinit {
        if #available(iOS 9, *) {
            return
        } else {
            NotificationCenter.default.removeObserver(self)
        }  
    }
}

// MARK: - INPUT
extension DefaultInAppPurchaseViewModel {
    func viewDidLoad() {
        self.loadingType.value = .fetchingProducts
        self.fetchProducts()
        self.checkSessionLoadTask = self.userCredentialsUseCase.readUserSession { [weak self] result in
            guard let self = self else { return }
            self.userSession = try? result.get()
        }
        observe()
    }
    
    func userDidPurchase(with subscription: PurchaseType) {
        switch subscription {
        case .week:
            self.loadingType.value = .purchasing
            let weeklyIdentifier = IAPConfiguration().IAPWeeklyKey
            purchase(identifier: weeklyIdentifier)
        case .month:
            self.loadingType.value = .purchasing
            let monthlyIdentifier = IAPConfiguration().IAPMonthlyKey
            purchase(identifier: monthlyIdentifier)
        case .year:
            self.loadingType.value = .purchasing
            let yearlyIdentifier = IAPConfiguration().IAPYearlyKey
            purchase(identifier: yearlyIdentifier)
        case .none: break
        }
    }

    private func getTypePurchase(product: UserProduct) -> String {
        var title: String = ""
        if product.productIdentifier.contains("weekly") { title = "1 Week" }
        if product.productIdentifier.contains("monthly") { title = "1 Month" }
        if product.productIdentifier.contains("yearly") { title = "1 Year" }
        return title
    }
    
    private func purchase(identifier: ProductIdentifier) {
        if let tempUserSession = userSession {
            if !tempUserSession.profile.products.isEmpty {
                for p in tempUserSession.profile.products {
                    if p.isPurchaseActive() {
                        self.error.value = "You have already \(getTypePurchase(product: p)) subscription activated."
                        return
                    }
                }
            }
        }
        let relatedProduct = products.value.filter { $0.productIdentifier == identifier }
        if !products.value.isEmpty && !relatedProduct.isEmpty {
            self.inAppPurchaseUseCase.buyProduct(identifier)
        } else {
            error.value = "Subscription Not Available"
        }
    }
    
    func dismiss() {
        self.route.value = .back
    }

    func restore() {
        self.loadingType.value = .purchasing
        self.inAppPurchaseUseCase.restorePurchase()
    }
}
