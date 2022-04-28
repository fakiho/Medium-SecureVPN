//
//  IAPConfiguration.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/1/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

final class IAPConfiguration {
    
    lazy var IAPMonthlyKey: String = {
        guard let monthlyKey = Bundle.main.object(forInfoDictionaryKey: "MonthlyIAP") as? String else {
            fatalError("Monthly Product Key must be provided in plist")
        }
        return monthlyKey
    }()
    
    lazy var IAPWeeklyKey: String = {
        guard let weeklyKey = Bundle.main.object(forInfoDictionaryKey: "WeeklyIAP") as? String else {
            fatalError("Weekly Key must be provided")
        }
        return weeklyKey
    }()
    
    lazy var IAPYearlyKey: String = {
        guard let yearlyKey = Bundle.main.object(forInfoDictionaryKey: "YearlyIAP") as? String else {
            fatalError("Yearly Key must be provided")
        }
        return yearlyKey
    }()
    
    lazy var productIdentifiers: Set<ProductIdentifier> = {
        return [IAPMonthlyKey, IAPWeeklyKey, IAPYearlyKey]
    }()
}
