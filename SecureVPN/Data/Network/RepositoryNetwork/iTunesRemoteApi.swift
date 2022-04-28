//
//  iTunesRemoteApi.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/19/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import AFNetworks

public protocol iTunesRemoteApi {
    static func validate(receiptString: Data?, sharedSecretKey: String) -> Endpoint<Data>
}
