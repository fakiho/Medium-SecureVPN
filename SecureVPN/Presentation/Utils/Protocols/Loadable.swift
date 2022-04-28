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

//extension UIViewController {
//
//    var activityIndicatorTag: Int { return 999999 }
//}
//
//extension UIViewController {
//
//    //Previous code
//
//
//    func startActivityIndicator(
//        style: UIActivityIndicatorView.Style = .gray,
//        location: CGPoint? = nil) {
//
//        //Set the position - defaults to `center` if no`location`
//
//        //argument is provided
//
//        let loc = location ?? self.view.center
//
//        //Ensure the UI is updated from the main thread
//
//        //in case this method is called from a closure
//
//        DispatchQueue.main.async {
//
//            //Create the activity indicator
//            let activityIndicator = UIActivityIndicatorView(style: style)
//            //Add the tag so we can find the view in order to remove it later
//            activityIndicator.color = Colors.yellowColor
//            activityIndicator.tag = self.activityIndicatorTag
//            //Set the location
//
//            activityIndicator.center = loc
//            activityIndicator.hidesWhenStopped = true
//            //Start animating and add the view
//
//            activityIndicator.startAnimating()
//            self.view.addSubview(activityIndicator)
//        }
//    }
//}
//extension UIViewController {
//
//    //Previous code
//
//
//     func stopActivityIndicator() {
//
//        //Again, we need to ensure the UI is updated from the main thread!
//
//        DispatchQueue.main.async {
//            //Here we find the `UIActivityIndicatorView` and remove it from the view
//            let indicatorActivityViews = self.view.subviews.filter({ $0.tag == self.activityIndicatorTag})
//            for view in indicatorActivityViews {
//                if let indicatorActivity = view as? UIActivityIndicatorView {
//                    indicatorActivity.stopAnimating()
//                    indicatorActivity.removeFromSuperview()
//                }
//            }
//        }
//    }
//}
