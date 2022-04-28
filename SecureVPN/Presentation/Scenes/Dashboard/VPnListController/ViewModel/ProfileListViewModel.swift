//
//  ProfileListViewModel.swift
//  VPN Guard
//
//  Created by Ali Fakih on 5/6/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

protocol ServerListViewModelDelegate: class {
    func vpnListDidSelect(configuration: VPNAccount)
    func closeView()
}

protocol ServerListViewModelInput {
    func viewWillAppear()
    func didSelect(item: VPNAccount)
    func dismiss()
}

protocol ServerListViewModelOutput {
    var items: Observable<[Server]> { get }
}

protocol ServerListViewModel: ServerListViewModelInput, ServerListViewModelOutput {}

final class DefaultServerListViewModel: ServerListViewModel {
    
    private weak var delegate: ServerListViewModelDelegate?
    
    init(delegate: ServerListViewModelDelegate, servers: [Server]) {
        self.delegate = delegate
        self.items.value = servers
    }
    // MARK: - OUTPUT
    var items: Observable<[Server]> = Observable([])
    
}

// MARK: - INPUT
extension DefaultServerListViewModel {
    func viewWillAppear() {
        
    }
    
    func didSelect(item: VPNAccount) {
        delegate?.vpnListDidSelect(configuration: item)
        dismiss()
    }
    func dismiss() {
        delegate?.closeView()
    }
}
