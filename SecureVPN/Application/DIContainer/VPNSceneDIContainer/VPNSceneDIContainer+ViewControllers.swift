//
//  VPNSceneDIContainer+ViewControllers.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/12/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

// MARK: - VIEW CONTROLLERS
extension VPNSceneDIContainer {

    /* Root View*/
    func makeRootViewController(rootController: UIViewController) -> UINavigationController {
       return RootNavigationController.create(rootController: rootController)
    }

    /* Splash View */
    func makeSplashViewController() -> UIViewController {
       return SplashViewController.create(viewModel: makeSplashViewModel(), splashViewControllersFactory: self )
    }

    /* RootTabBarView */
    func makeRootTabBarViewController() -> UIViewController {
        var platform: Bool = false
        if #available(iOS 13, *) {
            platform = true
        }
       return RootTabBarController.create(with: [
        VPNSceneDIContainer.TabViewControllerItem(title: "Home", image: platform ? "bolt.horizontal.icloud" : "dashboard", viewController: makeDashboardViewController(), tag: .home),
        VPNSceneDIContainer.TabViewControllerItem(title: "Notification", image: platform ? "bell" : "notification", viewController: makeNotificationController(), tag: .notification),
        VPNSceneDIContainer.TabViewControllerItem(title: "Settings", image: platform ? "gear" : "settings", viewController: makeSettingsController(), tag: .settings)
       ])
    }
       
    /* Dashboard View */
    func makeDashboardViewController() -> UIViewController {
       return DashboardViewController.create(viewModel: makeDashboardViewModel(), dashboardFactory: self)
    }

    /* Notification View */
    func makeNotificationController() -> UIViewController {
       return NotificationViewController.create(viewModel: makeNotificationViewModel())
    }

    /* Settings View */
    func makeSettingsController() -> UIViewController {
       return SettingsViewController.create(viewModel: makeSettingsViewModel())
    }

    /* In App Purchase View */
    func makeInAppPurchaseViewController(dismissable: Bool, delegate: PurchaseDelegate) -> UIViewController {
        return InAppPurchaseProViewController.create(viewModel: makeInAppPurchaseViewModel(delegate: delegate), inAppPurchaseViewControllersFactory: self, isDismissable: dismissable)
    }
    
    func makeServerListViewController(delegate: ServerListViewModelDelegate, servers: [Server]) -> UIViewController {
        return ServerListViewController.create(viewModel: makeServerListViewModel(delegate: delegate, servers: servers))
    }
}

extension VPNSceneDIContainer: DashboardViewControllerFactory, InAppPurchaseViewControllersFactory {}
