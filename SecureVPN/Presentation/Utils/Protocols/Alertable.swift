//
//  Alertable.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

public protocol Alertable { }

public extension Alertable where Self: UIViewController {
    func showAlert(title: String, message: String, style: UIAlertController.Style = .alert, completion: (() -> Void)? = nil, action: ((UIAlertAction) -> Void)? = nil ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: action))
        self.present(alertController, animated: true, completion: completion)
    }
}
