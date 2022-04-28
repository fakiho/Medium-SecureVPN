//
//  NotificationObject.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/28/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

struct NotificationObject {
    var timelaps: Int
    var title: String
    var subtitle: String
}

extension NotificationObject: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(timelaps)
    }
}
