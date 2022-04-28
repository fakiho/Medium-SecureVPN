//
//  NotificationUseCase.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/28/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

protocol NotificationUseCase {
    func recentsNotification(number: Int, completion: @escaping (Result<[NotificationObject], Error>) -> Void) -> OperationQueue
    func saveNotification(notification: NotificationObject, completion: @escaping (Result<[NotificationObject], Error>) -> Void) -> OperationQueue
}

final class DefaultNotificationUseCase {
    
    private(set) var notificationRepository: NotificationRepository
    init(notification: NotificationRepository) {
        self.notificationRepository = notification
    }
}

extension DefaultNotificationUseCase: NotificationUseCase {
    func recentsNotification(number: Int, completion: @escaping (Result<[NotificationObject], Error>) -> Void) -> OperationQueue {
        return self.notificationRepository.recentsNotification(number: number, completion: completion)
    }
    
    func saveNotification(notification: NotificationObject, completion: @escaping (Result<[NotificationObject], Error>) -> Void) -> OperationQueue {
        return self.notificationRepository.saveNotification(notification: notification, completion: completion)
    }
}
