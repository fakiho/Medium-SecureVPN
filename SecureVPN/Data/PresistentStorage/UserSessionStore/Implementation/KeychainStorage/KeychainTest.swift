//
//  Keychain.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/17/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

enum KeychainUserSessionDataStoreError: Error {

  case typeCast
  case unknown
}

class KeychainTest {
    // MARK: - Methods
      static func findItem(query: KeychainItemQuery) throws -> Data? {
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
          SecItemCopyMatching(query.asDictionary(), UnsafeMutablePointer($0))
        }

        if status == errSecItemNotFound {
          return nil
        }
        guard status == noErr else {
          throw KeychainUserSessionDataStoreError.unknown
        }
        guard let itemData = queryResult as? Data else {
          throw KeychainUserSessionDataStoreError.typeCast
        }

        return itemData
      }

      static func save(item: KeychainItemWithData) throws {
        let status = SecItemAdd(item.asDictionary(), nil)
        guard status == noErr else {
          throw KeychainUserSessionDataStoreError.unknown
        }
      }

      static func update(item: KeychainItemWithData) throws {
        let status = SecItemUpdate(item.attributesAsDictionary(), item.dataAsDictionary())
        guard status == noErr else {
          throw KeychainUserSessionDataStoreError.unknown
        }
      }

      static func delete(item: KeychainItem) throws {
        let status = SecItemDelete(item.asDictionary())
        guard status == noErr || status == errSecItemNotFound else {
          throw KeychainUserSessionDataStoreError.unknown
        }
    }
}

class KeychainItem {
    let service: NSString = "online.beapp.SecureVPNCloud"
   let itemClass = kSecClass as String
    let itemService = kSecAttrService as String

    // MARK: - Methods
    func asDictionary() -> CFDictionary {
      let item: [String: AnyObject] = [itemClass: kSecClassGenericPassword,
                                       itemService: service]
      return item as CFDictionary
    }
}

class KeychainItemWithData: KeychainItem {
    // MARK: - Properties
    let data: AnyObject
    let itemData = kSecValueData as String

    // MARK: - Methods
    init(data: Data) {
      self.data = data as AnyObject
    }

    override func asDictionary() -> CFDictionary {
      let item: [String: AnyObject] = [itemClass: kSecClassGenericPassword,
                                       itemService: service,
                                       itemData: data]
      return item as CFDictionary
    }

    func attributesAsDictionary() -> CFDictionary {
      let attributes: [String: AnyObject] = [itemClass: kSecClassGenericPassword,
                                             itemService: service]
      return attributes as CFDictionary
    }

    func dataAsDictionary() -> CFDictionary {
      let justData: [String: AnyObject] = [itemData: data]
      return justData as CFDictionary
    }
}

class KeychainItemQuery: KeychainItem {
    // MARK: - Properties
    let matchLimit = kSecMatchLimit as String
    let returnData = kSecReturnData as String

    // MARK: - Methods
    override func asDictionary() -> CFDictionary {
      let query: [String: AnyObject] = [itemClass: kSecClassGenericPassword,
                                        itemService: service,
                                        matchLimit: kSecMatchLimitOne,
                                        returnData: kCFBooleanTrue]
      return query as CFDictionary
    }
}
