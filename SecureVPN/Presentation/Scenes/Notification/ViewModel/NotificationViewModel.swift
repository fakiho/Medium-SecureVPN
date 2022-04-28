//
//  NotificationViewModel.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/29/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

enum NotificationViewModelLoading {
    case initial
    case load
    case finish
}

protocol NotificationViewModelInput {
    func viewDidLoad()
}

protocol NotificationViewModelOutput {
    var loadingType: Observable<NotificationViewModelLoading> { get }
    var items: Observable<[NotificationObject]> { get }
    var isEmpty: Observable<Bool> { get }
}

protocol NotificationViewModel: NotificationViewModelOutput, NotificationViewModelInput {}

final class DefaultNotificationViewModel: NotificationViewModel {
    
    private(set) var notificationUseCase: NotificationUseCase
    init(notificationUseCase: NotificationUseCase) {
        self.notificationUseCase = notificationUseCase
    }
    
    //OPERATION
    private var loadTask: OperationQueue? { willSet { loadTask?.cancelAllOperations()} }
    
    // MARK: - OUTPUT
    var loadingType: Observable<NotificationViewModelLoading> = Observable(.initial)
    var items: Observable<[NotificationObject]> = Observable([])
    var isEmpty: Observable<Bool> = Observable(true)
}

// MARK: - INPUT
extension DefaultNotificationViewModel {
    func viewDidLoad() {
        self.loadingType.value = .load
        self.loadTask = self.notificationUseCase.recentsNotification(number: 10, completion: { [weak self] result in
            guard let self = self else { return }
            do {
                self.items.value = try result.get()
                self.isEmpty.value = self.items.value.isEmpty
            } catch {
                self.isEmpty.value = true
            }
            self.loadingType.value = .finish
        })
    }
}
