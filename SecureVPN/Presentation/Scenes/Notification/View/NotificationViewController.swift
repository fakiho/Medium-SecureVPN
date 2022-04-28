//
//  NotificationViewController.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/29/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit
import Lottie

class NotificationViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = Fonts.titleFont
            titleLabel.text = "Recent Logs"
        }
    }
    
    private var notifications: [NotificationObject] = [] {
        didSet {
            self.reload()
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.backgroundColor = Colors.backgroundColor
            tableView.tableHeaderView?.backgroundColor = Colors.backgroundColor
            tableView.tableFooterView?.backgroundColor = Colors.backgroundColor
            tableView.register(UINib(nibName: NotificationCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: NotificationCell.reuseIdentifier)
        }
    }
    
    var viewModel: NotificationViewModel!
    
    class func create(viewModel: NotificationViewModel) -> NotificationViewController {
        let view = NotificationViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.backgroundColor
        bind(viewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidLoad()
    }
    
    private func bind(_ viewModel: NotificationViewModel) {
        viewModel.loadingType.observe(on: self, observerBlock: {[weak self] in self?.handleLoading($0)})
        viewModel.isEmpty.observe(on: self, observerBlock: {[weak self] in self?.handleEmptyData($0)})
        viewModel.items.observe(on: self, observerBlock: {[weak self] in self?.notifications = $0})
    }
    
    private func handleEmptyData(_ isEmpty: Bool) {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.text = "EMPTY"
        label.textColor = Colors.white
        label.font = Fonts.boldFont
        
        let emptyBoxView = UIImageView(image: UIImage(named: "empty_box"))
        emptyBoxView.contentMode = .scaleAspectFit
        emptyBoxView.clipsToBounds = true
        emptyBoxView.frame = CGRect(origin: self.tableView.bounds.origin, size: CGSize(width: 50, height: 50))
        let view = UIView(frame: self.tableView.frame)
        let stackView = UIStackView(arrangedSubviews: [emptyBoxView, label])
        stackView.frame.size.width = 200
        stackView.frame.size.height = 200
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.center = self.view.center
        view.addSubview(stackView)
        self.tableView.backgroundView = isEmpty ? view : nil
    }
    
    private func handleLoading(_ type: NotificationViewModelLoading) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func reload() {
        self.tableView.reloadData()
    }
}

// MARK: - TableViewDataSource & TableViewDelegate

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseIdentifier, 
                                                       for: indexPath) as? NotificationCell 
        else { 
            fatalError("Cannot dequeue reusable cell \(NotificationCell.self) with reuseIdentifier: \(NotificationCell.reuseIdentifier)")
        }
        let notification = notifications[indexPath.row]
        cell.setContent(title: notification.title, subtitle: notification.subtitle)
        return cell
    }    
}
