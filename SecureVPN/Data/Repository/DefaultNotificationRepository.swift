//
//  DefaultNotificationRepository.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/28/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

final class DefaultNotificationRepository {
    
    private(set) var storage: NotificationStorageRepository
    init(storage: NotificationStorageRepository) {
        self.storage = storage
    }
}

extension DefaultNotificationRepository: NotificationRepository {
    func recentsNotification(number: Int, completion: @escaping (Result<[NotificationObject], Error>) -> Void) -> OperationQueue {
        return self.storage.recentsNotification(number: number, completion: completion)
    }
    
    func saveNotification(notification: NotificationObject, completion: @escaping (Result<[NotificationObject], Error>) -> Void) -> OperationQueue {
        return self.storage.saveNotification(notification: notification, completion: completion)
    }
}
