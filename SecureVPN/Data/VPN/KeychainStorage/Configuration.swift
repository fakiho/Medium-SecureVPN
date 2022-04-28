//
//  Configuration.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/24/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public class Configuration {
    // swiftlint:disable all
    static let COUNTRY_KEY = "COUNTRY_KEY"
    static let PRO_KEY = "PRO_KEY"
    static let SERVER_KEY = "SERVER_KEY"
    static let ACCOUNT_KEY = "ACCOUNT_KEY"
    static let PASSWORD_KEY = "PASSWORD_KEY"
    static let ONDEMAND_KEY = "ONDEMAND_KEY"
    static let PSK_KEY = "PSK_KEY"
    
    static let DESC_KEY = "DESCRIPTION_KEY"
    static let REMOTEID_KEY = "REMOTEID_KEY"
    static let LOCALID_KEY = "LOCALID_KEY"
    static let CERT_KEY = "CERT_KEY"
    static let TOP_KEY = "TOP_KEY"
    static let ADJTOKEN_KEY = "ADJTOKEN_KEY"

    static let KEYCHAIN_PASSWORD_KEY = "KEYCHAIN_PASSWORD_KEY"
    static let KEYCHAIN_PSK_KEY = "KEYCHAIN_PSK_KEY"

    public let server: String
    public let account: String?
    public let password: String
    public let onDemand: Bool
    public let psk: String?
    public var pskEnabled: Bool {
        return psk != nil
    }
    
    public let description: String
    public let remoteID: String
    public let localID: String?
    public var country: String
    public var pro: Bool
    public var certificate: String
    public var top: Bool
    public var adjustToken: String

    init(server: String,
         country: String,
         pro: Bool,
         account: String,
         password: String,
         onDemand: Bool = false,
         psk: String? = nil,
         description: String,
         remoteID: String,
         localID: String?,
         certificate: String,
         top: Bool,
         adjustToken: String) {
        self.server = server
        self.account = account
        self.country = country
        self.pro = pro
        self.password = password
        self.onDemand = onDemand
        self.psk = psk
        
        self.description = description
        self.remoteID = remoteID
        self.localID = localID
        self.certificate = certificate
        self.top = top
        self.adjustToken = adjustToken
    }
    
    func getPasswordRef() -> Data? {
        KeychainWrapper.standard.set(password, forKey: Configuration.KEYCHAIN_PASSWORD_KEY)
        return KeychainWrapper.standard.dataRef(forKey: Configuration.KEYCHAIN_PASSWORD_KEY)
    }
    
    func getPSKRef() -> Data? {
        
        KeychainWrapper.standard.set(psk ?? "", forKey: Configuration.KEYCHAIN_PSK_KEY)
        return KeychainWrapper.standard.dataRef(forKey: Configuration.KEYCHAIN_PSK_KEY)
    }
    
    static func loadFromDefaults() -> VPNAccount {
        let def = UserDefaults.standard
        let server = def.string(forKey: Configuration.SERVER_KEY) ?? ""
        let account = def.string(forKey: Configuration.ACCOUNT_KEY) ?? ""
        let password = def.string(forKey: Configuration.PASSWORD_KEY) ?? ""
        let onDemand = def.bool(forKey: Configuration.ONDEMAND_KEY)
        let psk = def.string(forKey: Configuration.PSK_KEY)
        
        let description = def.string(forKey: Configuration.DESC_KEY) ?? ""
        let remoteID = def.string(forKey: Configuration.REMOTEID_KEY) ?? ""
        let localID = def.string(forKey: Configuration.LOCALID_KEY)
        let certificate = def.string(forKey: Configuration.CERT_KEY) ?? ""

        let country = def.string(forKey: Configuration.COUNTRY_KEY) ?? ""
        let pro = def.bool(forKey: Configuration.PRO_KEY) 
        let top = def.bool(forKey: Configuration.TOP_KEY)
        let adjustToken = def.string(forKey: Configuration.ADJTOKEN_KEY) ?? ""

        return Configuration(
            server: server,
            country: country,
            pro: pro,
            account: account,
            password: password,
            onDemand: onDemand,
            psk: psk,
            description: description,
            remoteID: remoteID,
            localID: localID,
            certificate: certificate,
            top: top,
            adjustToken: adjustToken
        )
    }
    
    func saveToDefaults() {
        let def = UserDefaults.standard
        def.set(server, forKey: Configuration.SERVER_KEY)
        def.set(account, forKey: Configuration.ACCOUNT_KEY)
        def.set(password, forKey: Configuration.PASSWORD_KEY)
        def.set(onDemand, forKey: Configuration.ONDEMAND_KEY)
        def.set(psk, forKey: Configuration.PSK_KEY)
        def.set(description, forKey: Configuration.DESC_KEY)
        def.set(remoteID, forKey: Configuration.REMOTEID_KEY)
        def.set(localID, forKey: Configuration.LOCALID_KEY)
        def.set(country, forKey: Configuration.COUNTRY_KEY)
        def.set(pro, forKey: Configuration.PRO_KEY)
        def.set(certificate, forKey: Configuration.CERT_KEY)
        def.set(top, forKey: Configuration.TOP_KEY)
        def.set(adjustToken, forKey: Configuration.ADJTOKEN_KEY)
    }
}
extension Configuration: VPNAccount {
    var type: VPNType {
        return .IKEv2
    }
}
