//
//  NotificationQueryStorage.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/28/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

protocol NotificationStorageRepository {
    func recentsNotification(number: Int, completion: @escaping (Result<[NotificationObject], Error>) -> Void) -> OperationQueue
    func saveNotification(notification: NotificationObject, completion: @escaping (Result<[NotificationObject], Error>) -> Void) -> OperationQueue
}
