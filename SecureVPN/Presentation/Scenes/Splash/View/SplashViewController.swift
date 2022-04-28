//
//  LauncherViewController.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit
import Lottie
import Firebase
import GoogleMobileAds

class SplashViewController: UIViewController, StoryboardInstantiable, Alertable, PurchaseDelegate {
    func didFinishPurchase() {
        
    }
    
    lazy var interstitial: GADInterstitial = {
        return GADInterstitial(adUnitID: AdsConfiguration().interstitialKey)
    }()

    private(set) var viewModel: SplashViewModel!
    lazy var animationView: AnimationView = {
        return AnimationView()
    }()
    let animation = Animation.named("launch_qualibrate")
    private var splashViewControllersFactory: SplashViewControllersFactory!
    
    final class func create(viewModel: SplashViewModel, splashViewControllersFactory: SplashViewControllersFactory) -> SplashViewController {
        let view = SplashViewController.instantiateViewController()
        view.viewModel = viewModel
        view.splashViewControllersFactory = splashViewControllersFactory
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.backgroundColor

        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        view.addSubview(animationView)
        
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.bind(to: viewModel)
        self.viewModel.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.play(fromProgress: 0,
        toProgress: 1,
        loopMode: .loop,
        completion: { finished in
            if finished {
                self.viewModel.didFinishAnimation()
            } else {
                print("playing")
            }
        })
    }
    
    private func bind(to viewModel: SplashViewModel) {
        viewModel.route.observe(on: self, observerBlock: { [weak self] in self?.handle($0)})
        viewModel.error.observe(on: self, observerBlock: { [weak self] in self?.showError($0)})
        viewModel.loadingType.observe(on: self, observerBlock: { [weak self] _ in self?.handleViewsVisibility() })
    }
    
    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: NSLocalizedString("Error", comment: ""), message: error)
    }
    
    private func handleViewsVisibility() {
        
    }
}

// MARK: - Handle Route
extension SplashViewController {
    func handle(_ route: SplashViewModelRoute) {
        switch route {
        case .initial:
            break
        case .showDashboard:
            let dashboard = splashViewControllersFactory.makeDashboardViewController()
            dashboard.modalPresentationStyle = .fullScreen
            self.present(dashboard, animated: true, completion: nil)
        case .showBilling:
            let billingVC = splashViewControllersFactory.makeInAppPurchaseViewController(dismissable: false, delegate: self)
            billingVC.modalPresentationStyle = .fullScreen
            self.present(billingVC, animated: true, completion: nil)
        }
    }
}

extension SplashViewController: GADInterstitialDelegate {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        viewModel.didReceiveAd()
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        viewModel.didFailToReceiveAd()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        viewModel.didDismissScreenAd()
    }
}

protocol SplashViewControllersFactory {
    
    func makeRootTabBarViewController() -> UIViewController
    func makeDashboardViewController() -> UIViewController
    func makeInAppPurchaseViewController(dismissable: Bool, delegate: PurchaseDelegate) -> UIViewController
    
}
