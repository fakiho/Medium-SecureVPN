//
//  DashboardViewModel.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/6/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import NetworkExtension
import StoreKit
import os
import IPAPI

enum DashboardViewModelRoute {
    case initial
    case inAppPurchaseView
    case purchased
    case showPurchaseDeeplink
    case showAds
    case showServers(delegate: ServerListViewModelDelegate)
    case closeServers
    case showUpdate
    case none
}

enum DashboardViewModelLoading {
    case none
    case fullScreen
    case connecting
    case connected
    case disconnected
    case disconnecting
}

enum DashboardViewModelActivity {
    case none
    case loading
}

protocol DashboardViewModelInput {
    func viewDidLoad()
    func didConnect()
    func didDisconnect()
    func didDayPass()
    func didDimiss()
    func connectDisconnect()
    func onPurchaseModelClick()
    func viewDidAppear()
    func didReceiveAd()
    func didFailToReceiveAd()
    func didDismissScreenAd()
    func showServer()
    func updateFlagImage()
    func purchaseStatusDidChange()

}

protocol DashboardViewModelOutput {
    var route: Observable<DashboardViewModelRoute> { get }
    var loadingType: Observable<DashboardViewModelLoading> { get }
    var activityType: Observable<DashboardViewModelActivity> { get }
    var error: Observable<String> { get }
    var status: Observable<NetworkVPNStatus> { get }
    var premiumStatus: Observable<Bool?> { get }
    var vpnAccount: Observable<VPNAccount?> { get }
    var currentIP: Observable<String> { get }
    var serverList: Observable<[Server]> { get }
    var flag: Observable<Data?> { get }
    var onInterstitialUpdate: ((String) -> Void)? { get set }
    var loadRequestAd: Observable<Bool> { get }
}

protocol DashboardViewModel: DashboardViewModelInput, DashboardViewModelOutput {}

final class DefaultDashboardViewModel: DashboardViewModel {
    
    // MARK: - USE Cases
    private var networkVPNUseCase: NetworkVPNUseCase
    private var inAppPurchaseUseCase: InAppPurchaseUseCase
    private var userCredentialsUseCase: UserCredentialsUseCase
    private var userSession: UserSession?
    private var products: [SKProduct] = []
    private let flagImageRepository: FlagImagesRepository
    private var didReceiveAds: Bool = false
    private(set) var serverRepository: ServerStorageRepository
    
    init(networkVPNUseCase: NetworkVPNUseCase,
         inAppUseCase: InAppPurchaseUseCase,
         userCredentialsUseCase: UserCredentialsUseCase,
         flagImageRepository: FlagImagesRepository,
         serverRepo: ServerStorageRepository
    ) {
        self.networkVPNUseCase = networkVPNUseCase
        self.inAppPurchaseUseCase = inAppUseCase
        self.userCredentialsUseCase = userCredentialsUseCase
        self.flagImageRepository = flagImageRepository
        self.serverRepository = serverRepo
    }

    // MARK: - Load Task
    private var loadSessionLoadTask: Cancellable? { willSet { loadSessionLoadTask?.cancel(); print("load Session dashboard cancelled")}}
    private var validationLoadTask: Cancellable? { willSet { validationLoadTask?.cancel() }}
    private var updateLoadTask: Cancellable? { willSet { updateLoadTask?.cancel(); print("update session load task cancelled inAppPurchase")}}
    private var loadServerTask: Cancellable? { willSet { loadServerTask?.cancel() }}
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() }}

    // MARK: - OUTPUT
    var route: Observable<DashboardViewModelRoute> = Observable(.none)
    var loadingType: Observable<DashboardViewModelLoading> = Observable(.none)
    var activityType: Observable<DashboardViewModelActivity> = Observable(.none)
    var error: Observable<String> = Observable("")
    var status: Observable<NetworkVPNStatus> = Observable(.invalid)
    var premiumStatus: Observable<Bool?> = Observable(nil)
    //var vpnAccount: Observable<VPNAccount> = Observable(VPNProfile.vpnProfile.filter { !$0.pro }.first!)
    var vpnAccount: Observable<VPNAccount?> = Observable(nil)
    var currentIP: Observable<String> = Observable("")
    var serverList: Observable<[Server]> = Observable([])
    var flag: Observable<Data?> = Observable(nil)
    var onInterstitialUpdate: ((String) -> Void)?
    var loadRequestAd: Observable<Bool> = Observable(true)

    // MARK: - Methods
    private func observeStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(statusDidChange(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(inAppPurchaseStatusDidChange(_:)), name: NSNotification.Name.IAPHelperPurchaseNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deeplinkObserver(_:)), name: Notification.Name.DeepLinkFlow, object: nil)
    }
    
    @objc func deeplinkObserver(_ notification: Notification) {
        guard let deeplinkSession = notification.object as? DeeplinkUserSession else { print("Invalid Deeplink Session"); return }
        if var tempSession = userSession {
            tempSession.deeplinkUser = deeplinkSession
            userSession = tempSession
            userSession?.logSession()
            updateUserSession()
        } else {
            print("User session Found nil, please be caution!")
        }
    }
    
    @objc
    func inAppPurchaseStatusDidChange(_ notification: Notification) {
        print("notification purchase received in dashboard")
        checkSession()
    }
    
    @objc
    private func statusDidChange(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else { return }
        let status = connection.status
        handleVPNStatus(status)
    }
    
    private func handleVPNStatus(_ vpnStatus: NEVPNStatus) {
        switch vpnStatus {
        case .invalid:
            self.status.value = .invalid
            self.loadingType.value = .none
        case .disconnected:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [status, loadingType] in
                status.value = .disconnected
                loadingType.value = .disconnected
            }
        case .connecting:
            self.status.value = .connecting
            self.loadingType.value = .connecting
        case .connected:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [status, loadingType] in
                status.value = .connected
                loadingType.value = .connected
            }
        case .reasserting:
            self.status.value = .reasserting
            self.loadingType.value = .none
        case .disconnecting:
            self.status.value = .disconnecting
            self.loadingType.value = .disconnecting
        @unknown default:
            break
        }
        loadIP()
    }

    func checkPurchasedProducts() {
        if (userSession?.deeplinkUser.isValidDeeplinkUser() ?? false) && (!(self.premiumStatus.value ?? false)) {
            route.value = .showPurchaseDeeplink
        }
    }

    private func updateUserSession() {
        guard let tempUserSession = userSession else { return }
        self.updateLoadTask = userCredentialsUseCase
            .updateUserSession(userSession: tempUserSession, completion: { [weak self] _ in
                self?.checkSession()
            })
    }

    private func checkSession() {
        self.loadSessionLoadTask = self.userCredentialsUseCase.readUserSession(completion: { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let tempSession):
                self.userSession = tempSession
                self.userSession?.logSession()
                guard let session = self.userSession else { return }
                self.premiumStatus.value = session.isProActive()
            case .failure(let error):
                self.error.value = error.localizedDescription
                self.route.value = .initial
            }
        })
    }

    private func loadIP() {
        IPAPI.Service.default.fetch { [weak self] (result, _) in
            guard let self = self else { return }
            self.currentIP.value = result?.ip ?? ""
        }
    }

    private func validateSubscription() {
        guard var session = userSession else { return }
        self.validationLoadTask = self.inAppPurchaseUseCase.receiptValidation(completion: { [weak self] result in
            guard let self = self else { return }
            var userProducts: [UserProduct] = []
            do {
                let subsStatus = try result.get()
                switch subsStatus {
                case .restoreSuccessfully(id: let id,
                                          expireDate: let expireDate,
                                          originDate: let originDate):
                    let userProduct: UserProduct = UserProduct(
                        transactionDate: originDate,
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
                            self.premiumStatus.value = session.isProActive()
                            self.loadingType.value = .none
                        }
                    }
                case .expire:
                    self.premiumStatus.value = false
                    self.loadingType.value = .none
                default:
                    self.loadingType.value = .none
                }
            } catch {
                self.loadingType.value = .none
            }
        })
        checkPurchasedProducts()
    }

    private func loadServers() {
        activityType.value = .loading
        loadServerTask = networkVPNUseCase.getServers { [weak serverList, weak activityType, serverRepository] (result) in
            do {
                let servers = try result.get()
                activityType?.value = .none
                serverList?.value = servers.sorted(by: { (s1, s2) -> Bool in
                    if s1.top && !s2.top {
                        //this will return true: s1 is top, s2 is not
                        return true
                    }
                    if !s1.top && s2.top {
                        //this will return false: s2 is top, s1 is not
                        return false
                    }
                    if s1.top == s2.top {
                        //if both save the same top, then return depending on the description value
                        return s1.serverDescription < s2.serverDescription
                        
                    }
                    return false
                })
                
                serverRepository.saveServers(servers: servers)
            } catch {
                print(error)
            }
        }
    }

    private func updateOnFirstLaunch() {
        let fLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
        if !fLaunch {
            route.value = .showUpdate
            UserDefaults.standard.set(true, forKey: "firstLaunch")
        }
    }

    private func showRate() {
        if #available( iOS 10.3, *) {
            let frate = UserDefaults.standard.bool(forKey: "frate")
            if !frate {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(true, forKey: "frate")
            }
        }
    }

    private func prepareAds() {
        if didReceiveAds && (!(premiumStatus.value == true)) {
            route.value = .showAds
            loadRequestAd.value = true
            didReceiveAds = false
        }
    }
}

// MARK: - INPUT. View event methods
extension DefaultDashboardViewModel {
    func viewDidLoad() {
        onInterstitialUpdate?(AdsConfiguration().interstitialKey)
        observeStatus()
        networkVPNUseCase.loadVPNConfig {}
        loadIP()
        loadServers()
        loadRequestAd.value = true
        prepareAds()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.updateOnFirstLaunch()
        }
    }

    func didConnect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if arc4random() % 2 == 0 {
                self?.showRate()
            }
        }
        networkVPNUseCase.connect(configuration: vpnAccount.value!)
    }

    func didDayPass() {
        
    }
    
    func didDisconnect() {
        networkVPNUseCase.disconnect()
    }
    
    func didDimiss() {}

    func connectDisconnect() {
        if didReceiveAds && (!(premiumStatus.value == true)) {
            route.value = .showAds
            loadRequestAd.value = true
            didReceiveAds = false
            return
        }

        if status.value == .connected || status.value == .connecting {
            networkVPNUseCase.disconnect()
        } else if (status.value == .disconnected || status.value == .disconnecting || status.value == .invalid) && (premiumStatus.value ?? false || !(vpnAccount.value?.pro == true)) {
            networkVPNUseCase.connect(configuration: vpnAccount.value!)
        } else {
            route.value = .inAppPurchaseView
        }
    }

    func onPurchaseModelClick() {
        self.route.value = .inAppPurchaseView
    }

    func viewDidAppear() {
        self.checkSession()
    }

    func didReceiveAd() {
        didReceiveAds = true
        
    }

    func didDismissScreenAd() {}

    func didFailToReceiveAd() {}

    func showServer() {
        if !(status.value == .connected) {
            route.value = .showServers(delegate: self)
        }
    }

    func updateFlagImage() {
        let path = vpnAccount.value!.country
        imageLoadTask = flagImageRepository.image(with: path, completion: { [weak self] result in
            self?.flag.value = try? result.get()
        })
    }

    func purchaseStatusDidChange() {
        checkSession()
        validateSubscription()
        userSession?.logSession()
    }
}

extension DefaultDashboardViewModel: ServerListViewModelDelegate {
    func vpnListDidSelect(configuration: VPNAccount) {
        vpnAccount.value = configuration
        print("configuration selected \(configuration.description)")
        updateFlagImage()
    }

    func closeView() {
        route.value = .closeServers
    }
}
