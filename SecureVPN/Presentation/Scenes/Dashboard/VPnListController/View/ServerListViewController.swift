//
//  ProfileListViewController.swift
//  VPN Guard
//
//  Created by Ali Fakih on 5/6/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit
import PlainPing
class ServerListViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            let textField = searchBar.value(forKey: "searchField") as? UITextField
            textField?.backgroundColor = .white
            textField?.textColor = .black
            textField?.leftView?.tintColor = .black
        }
    }
    
    var searchActive : Bool = false
    
    private var vpnServers: [Server] = [] {
        didSet {
            self.tableView.reloadData()
            if self.vpnServers.count > 0 {
                self.loaderView.isHidden = true
            }
        }
    }
    
    private var filteredServers: [Server] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = Fonts.mediumFont
            titleLabel.text = "Select Country"
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        viewModel.dismiss()
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.backgroundColor = .clear
        }
    }
    
    private(set) var viewModel: ServerListViewModel!
    
    class func create(viewModel: ServerListViewModel) -> UIViewController {
        let view = ServerListViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: VPNViewCell.identifier, bundle: nil), forCellReuseIdentifier: VPNViewCell.identifier)
        let backgroundTable = UIImageView(image: Images.backgroundGradient)
        backgroundTable.frame = tableView.frame
        tableView.backgroundView = backgroundTable
        bind(viewModel)
    }
    
    private func bind(_ viewModel: ServerListViewModel) {
        viewModel.items.observe(on: self, observerBlock: {[weak self] in self?.vpnServers = $0 })
    }
}

extension ServerListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {}
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {}
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
        tableView.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchActive = false;
            self.searchBar.showsCancelButton = false
            self.filteredServers = []
        }
        else {
            self.searchActive = true;
            self.searchBar.showsCancelButton = true
            self.filteredServers = vpnServers.filter { $0.serverDescription.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

extension ServerListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return self.filteredServers.count
        }
        return self.vpnServers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VPNViewCell.identifier) as? VPNViewCell else { fatalError() }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        if searchActive {
            cell.fillWith(configuration: filteredServers[indexPath.row])
        }
        else {
            cell.fillWith(configuration: vpnServers[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchActive {
            self.viewModel.didSelect(item: filteredServers[indexPath.row].toVPNAccount())
        }
        else {
            self.viewModel.didSelect(item: vpnServers[indexPath.row].toVPNAccount())
        }
    }
}
