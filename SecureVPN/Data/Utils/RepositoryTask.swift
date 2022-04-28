//
//  RepositoryTask.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/17/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import AFNetworks

struct RepositoryTask: Cancellable {
    let networkTask: NetworkCancellable?
    let operation: OperationQueue?
    func cancel() {
        networkTask?.cancel()
        operation?.cancelAllOperations()
    }
}
