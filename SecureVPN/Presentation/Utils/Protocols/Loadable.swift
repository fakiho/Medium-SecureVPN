//
//  Loadable.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/18/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

public protocol UIControllerLoadable {
    var activityIndicatorTag: Int { get }
    var viewIndicatorBackgroundTag: Int { get }
    func startActivityIndicator()
    func stopActivityIndicator()
}

public extension UIControllerLoadable where Self: UIViewController {
    var activityIndicatorTag: Int { return 66392 }
    var viewIndicatorBackgroundTag: Int { return 8793 }
    
    func startActivityIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let view: UIView = UIView(frame: self.view.bounds)
            view.tag = self.viewIndicatorBackgroundTag
            view.backgroundColor = .clear
            self.view.addSubview(view)
            
            var activityIndicator: UIActivityIndicatorView
            if #available(iOS 13.0, *) {
                activityIndicator = UIActivityIndicatorView(style: .large)
            } else {
                activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            }
            activityIndicator.tag = self.activityIndicatorTag
            activityIndicator.center = self.view.center
            activityIndicator.color = Colors.blueColor
            activityIndicator.startAnimating()
            activityIndicator.hidesWhenStopped = true
            self.view.addSubview(activityIndicator)
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            let backgroundViews = self.view.subviews.filter({ $0.tag == self.viewIndicatorBackgroundTag })
            for view in backgroundViews {
                view.removeFromSuperview()
            }
            let activityIndicatorViews = self.view.subviews.filter({ $0.tag == self.activityIndicatorTag })
            for view in activityIndicatorViews {
                if let activityIndicator = view as? UIActivityIndicatorView {
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                }
            }
        }
    }
    
}
