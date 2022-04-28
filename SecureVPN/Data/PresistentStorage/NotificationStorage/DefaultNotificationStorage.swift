//
//  DefaultNotificationStorage.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/28/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

final class DefaultNotificationStorage {
    private let maxStorageLimit: Int
    private let recentNotificationKey = "NotificationKey"
    private var userDefault: UserDefaults { return UserDefaults.standard }
    
    private var notificationQueries: [NotificationObject] {
        get {
            if let queryData = userDefault.object(forKey: recentNotificationKey) as? Data {
                let decoder = JSONDecoder()
                if let notificationListQuery = try? decoder.decode(NotificationListUDS.self, from: queryData) {
                    return notificationListQuery.list.map(NotificationObject.init)
                }
            }
            return []
        }
        
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(NotificationListUDS(list: newValue.map(NotificationQueryUDS.init))) {
                userDefault.set(encoded, forKey: recentNotificationKey)
            }
        }
    }
    
    init(maxStorage: Int) {
        self.maxStorageLimit = maxStorage
    }
    
    fileprivate func removeOldQueries(_ queries: [NotificationObject]) -> [NotificationObject] {
        return queries.count <= maxStorageLimit ? queries : Array(queries[0 ..< maxStorageLimit])
    }
}

extension DefaultNotificationStorage: NotificationStorageRepository {
    func recentsNotification(number: Int, completion: @escaping (Result<[NotificationObject], Error>) -> Void) -> OperationQueue {
        let operation = OperationQueue()
        operation.addOperation { [weak self] in
            guard let self = self else {return}
            var queries = self.notificationQueries
            queries = queries.count < self.maxStorageLimit ? queries : Array(queries[0 ..< number])
            completion(.success(queries))
        }
        return operation
    }
    
    func saveNotification(notification: NotificationObject, completion: @escaping (Result<[NotificationObject], Error>) -> Void) -> OperationQueue {
        let operation = OperationQueue()
        operation.addOperation { [weak self] in
            guard let self = self else { return }
            var queries = self.notificationQueries
            queries = queries.filter { $0 != notification }
            queries.insert(notification, at: 0)
            self.notificationQueries = self.removeOldQueries(queries)
            completion(.success(queries))
        }
        return operation
    }
}
