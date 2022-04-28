//
//  AppAppearance.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import UIKit

final class AppAppearance {
    static func setupAppearance () {
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        if #available(iOS 13, *) {
            UITabBar.appearance().tintColor = .systemYellow
            UITabBar.appearance().barTintColor = Colors.tabBarTintColor
            UITabBar.appearance().unselectedItemTintColor = .white
        } else {
            UITabBar.appearance().tintColor = .systemYellow
            UITabBar.appearance().barTintColor = Colors.secondTabBarTintColor
            UITabBar.appearance().unselectedItemTintColor = .white
        }
    }
}
extension UIViewController {
    var preferredStatusBarStyle: UIStatusBarStyle {
         return .lightContent
     }
}
