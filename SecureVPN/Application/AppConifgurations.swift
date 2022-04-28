//
//  AppConfigurations.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

final class AppConfiguration
{
    lazy var weeklyKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "WeeklyIAP") as? String else {
            fatalError("Please provide Subscription Key")
        }
        return key
    }()
    
    
    lazy var monthlyKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "MonthlyIAP") as? String else {
            fatalError("Please provide Subscription Key")
        }
        return key
    }()
    
    lazy var yearlyKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "YearlyIAP") as? String else {
            fatalError("Please provide Subscription Key")
        }
        return key
    }()
    
    lazy var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
            fatalError("API Key must be provided / not empty in plist")
        }
        return apiKey
    }()

    lazy var apiBaseURL: String = {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
            fatalError("Base URL must be provided / not empty in plist")
        }
        return baseURL
    }()

    lazy var iTunesURL: String = {
        #if DEBUG
        guard let verifyReceiptURl = Bundle.main.object(forInfoDictionaryKey: "DEBUGiTunesURL") as? String else {
            fatalError("most provide a debug url for iTunes")
        }
        return verifyReceiptURl
        #elseif TESTFLIGHT
        guard let verifyReceiptURl = Bundle.main.object(forInfoDictionaryKey: "DEBUGiTunesURL") as? String else {
                   fatalError("most provide a url for iTunes")
        }
        return verifyReceiptURl
        #else
        guard let verifyReceiptURl = Bundle.main.object(forInfoDictionaryKey: "iTunesURL") as? String else {
                          fatalError("most provide a url for iTunes")
               }
        return verifyReceiptURl
        #endif
    }()

    lazy var sharedSecretKey: String = {
        guard let secretKey = Bundle.main.object(forInfoDictionaryKey: "SharedSecretKey") as? String else {
            fatalError("provide shared secret key")
        }
        print(secretKey)
        return secretKey
    }()
    
    lazy var productIdentifiers: Set<ProductIdentifier> = {
        return [weeklyKey, monthlyKey, yearlyKey]
    }()

    lazy var privacyPolicyURL: String = {
        guard let privacyPolicy = Bundle.main.object(forInfoDictionaryKey: "privacyPolicy") as? String else {
            fatalError("provide privacy policy url")
        }
        return privacyPolicy
    }()

    lazy var termsAndConditions: String = {
        guard let termsAndCondition = Bundle.main.object(forInfoDictionaryKey: "termsAndConditions") as? String else {
            fatalError("provide terms and condition url")
        }
        return termsAndCondition
    }()

    lazy var flagApi: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "flagApi") as? String else {
            fatalError("Invalid Flag url")
        }
        return url
    }()
}
