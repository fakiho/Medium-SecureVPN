//
//  AdsConfiguration.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/23/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

final class AdsConfiguration {
    lazy var interstitialKey: String = {
        #if TESTADS
        guard let interstitialKey = Bundle.main.object(forInfoDictionaryKey: "InterstitialKeyTest") as? String else {
            fatalError()
        }
        return interstitialKey
        #else
        guard let interstitialKey = Bundle.main.object(forInfoDictionaryKey: "InterstitialKey") as? String else {
            fatalError()
        }
        return interstitialKey
        #endif
    }()
}
