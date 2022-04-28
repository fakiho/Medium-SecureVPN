//
//  ViewInstantiable.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/9/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

public protocol ViewInstantiable: NSObjectProtocol {
    
    var defaultFileName: String { get }
    func instantiateView(_ bundle: Bundle?)
}

public extension ViewInstantiable where Self: UIView {
    
    var defaultFileName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    
    func instantiateView(_ bundle: Bundle? = nil) {
        let fileName = defaultFileName
        print(fileName)
        Bundle.main.loadNibNamed(fileName, owner: self, options: nil)
    }
}
