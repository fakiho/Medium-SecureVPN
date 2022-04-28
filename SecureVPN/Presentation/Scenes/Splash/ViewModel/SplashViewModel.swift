//
//  LauncherViewModel.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import UIKit

enum SplashViewModelRoute {
    case initial
    case showDashboard
    case showBilling
}

enum SplashViewModelLoading {
    case none
    case fullScreen
    case nextPage
}

protocol SplashViewModelInput {
    func viewDidLoad()
    func didFinishAnimation()
    func didReceiveAd()
    func didFailToReceiveAd()
    func didDismissScreenAd()
    func didMove()
    
}

protocol SplashViewModelOutput {
    var route: Observable<SplashViewModelRoute> { get }
    var loadingType: Observable<SplashViewModelLoading> { get }
    var error: Observable<String> { get }
}

protocol SplashViewModel: SplashViewModelInput, SplashViewModelOutput { }

final class DefaultSplashViewModel: SplashViewModel {
    
    // MARK: - USE CASES
    private let userCredentialsUseCase: UserCredentialsUseCase
    private let userSettingsUseCase: UserSettingsUseCase
    private var session: UserSession?
    
    // MARK: - Init
    init(userCredentialsUseCase: UserCredentialsUseCase, userSettingsUseCase: UserSettingsUseCase) {
        self.userCredentialsUseCase = userCredentialsUseCase
        self.userSettingsUseCase = userSettingsUseCase
    }
    
    private var nextScreen: SplashViewModelRoute = .initial
    
    // MARK: - OUTPUT
    var route: Observable<SplashViewModelRoute> = Observable(.initial)
    var loadingType: Observable<SplashViewModelLoading> = Observable(.fullScreen)
    var error: Observable<String> = Observable("")
    var counter = 0
    // MARK: - METHODS
    private var checkSessionLoadTask: Cancellable? { willSet { checkSessionLoadTask?.cancel(); print("check session task cancelled") } }
    private var deleteSessionLoadTask: Cancellable? { willSet { deleteSessionLoadTask?.cancel(); print("delete Session task cancelled")} }
    private var updateLoadTask: Cancellable? { willSet { updateLoadTask?.cancel(); print("update session load task cancelled inAppPurchase")}}
    
    private func deleteSession() {
        deleteSessionLoadTask = self.userCredentialsUseCase.deleteSession { [weak self] _ in
            guard let self = self else { return }
            self.checkSession()
        }
    }
    
    private func observeStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(deeplinkObserver(_:)), name: Notification.Name.DeepLinkFlow, object: nil)
    }
    
    @objc func deeplinkObserver(_ notification: Notification) {
        /*guard let deeplinkSession = notification.object as? DeeplinkUserSession else { print("Invalid Deeplink Session"); return }
        if var tempSession = session {
            tempSession.deeplinkUser = deeplinkSession
            session = tempSession
            session?.logSession()
            //updateUserSession()
        } else {
            print("User session Found nil, please be caution!")
        }*/
        guard let deeplinkSession = notification.object as? UserSession else { print("Invalid Deeplink Session"); return }
        session = deeplinkSession
        session?.logSession()
        updateUserSession()
    }
    
    private func updateUserSession() {
        guard let tempUserSession = session else { return }
        self.updateLoadTask = self.userCredentialsUseCase.updateUserSession(userSession: tempUserSession, completion: { [weak self] (result) in
            guard let session = try? result.get() else { return }
            self?.session = session
            self?.checkSession()
        })
    }
}

// MARK: - IMPLEMENTATION INPUT
extension DefaultSplashViewModel {
    
    func viewDidLoad() {
        observeStatus()
        checkSession()
        
    }
    
    func checkSession() {        
        checkSessionLoadTask = userCredentialsUseCase.readUserSession { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userSession):
                guard let userSession = userSession else {return}
                if userSession.deeplinkUser.isValidDeeplinkUser() && userSession.isProActive()
                {
                    self.route.value = .showDashboard
                }
                else if userSession.deeplinkUser.isValidDeeplinkUser()
                {
                    self.route.value = .showBilling
                }
                else
                {
                    self.route.value = .showDashboard
                }
            case .failure( _):
                /*self.route.value = .showDashboard
                return*/
                DispatchQueue.global().asyncAfter(deadline: .now() + 6)
                {
                    if self.session == nil
                    {
                        self.route.value = .showDashboard
                    }
                }
                
                
                
                
                
                /*if self.counter == 6
                {
                    self.route.value = .showDashboard
                }
                else
                {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1)
                    {
                        self.counter = self.counter + 1
                        self.checkSession()
                    }
                }*/
                /*DispatchQueue.global().asyncAfter(deadline: .now() + 6) {
                    self.route.value = .showDashboard
                }*/
            }
        }
    }
    
    func didMove() {
       
    }
    
    func didFinishAnimation() {
        self.userSettingsUseCase.readCacheSettings { [weak self] _ in
            guard let self = self else { return }
            self.deleteSession()
        }
    }
    
    func didReceiveAd() {
        print("received ad")
    }
    
    func didFailToReceiveAd() {
    }
    
    func didDismissScreenAd() {
    }
}
