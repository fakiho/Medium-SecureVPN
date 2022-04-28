//
//  RootNavigationController.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/17/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController, StoryboardInstantiable {

    class func create(rootController: UIViewController) -> RootNavigationController {
        let view = RootNavigationController.instantiateViewController()
        view.isNavigationBarHidden = true
        view.pushViewController(rootController, animated: true)
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
