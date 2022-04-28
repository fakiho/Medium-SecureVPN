//
//  NotificationQueryUDS+Mapping.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/28/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

struct NotificationListUDS: Codable {
    var list: [NotificationQueryUDS]
}

struct NotificationQueryUDS: Codable {
    let title: String
    let description: String
    let timelaps: Int
}

extension NotificationQueryUDS {
    init(notificationObject: NotificationObject) {
        self.title = notificationObject.title
        self.description = notificationObject.subtitle
        self.timelaps = notificationObject.timelaps
    }
}

extension NotificationObject {
    init(notificationUDS: NotificationQueryUDS) {
        self.title = notificationUDS.title
        self.subtitle = notificationUDS.description
        self.timelaps = notificationUDS.timelaps
    }
}
