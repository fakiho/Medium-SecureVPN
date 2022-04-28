//
//  RootTabBarController.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/6/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit
import Lottie

class RootTabBarController: UITabBarController, StoryboardInstantiable {
    
    var controllers: [VPNSceneDIContainer.TabViewControllerItem] = []
    final class func create(with controllers: [VPNSceneDIContainer.TabViewControllerItem]) -> RootTabBarController {
        
        let view = RootTabBarController.instantiateViewController()
        view.controllers = controllers
        
        return view
    }
    
    override func viewDidLoad() {
        _ = controllers.map {
            if #available(iOS 13.0, *) {
                $0.viewController.tabBarItem = UITabBarItem(title: $0.title, image: UIImage(systemName: $0.image), selectedImage: nil)
            } else {
                $0.viewController.tabBarItem = UITabBarItem(title: $0.title, image: UIImage(named: $0.image), selectedImage: UIImage(named: $0.image))
            }
        }
        viewControllers = controllers.map { $0.viewController }
    }
    
    override func tabBar(_ tabBar: UITabBar, didBeginCustomizing items: [UITabBarItem]) {
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
}
