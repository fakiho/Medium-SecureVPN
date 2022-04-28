//
//  SettingsViewController.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/18/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, StoryboardInstantiable, Alertable {
    
    private(set) var viewModel: SettingsViewModel!

    @IBOutlet weak var resetCacheSwitch: UISwitch!
    @IBOutlet weak var buildLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBAction func resetSwitchChange(_ sender: UISwitch) {
        self.viewModel.didChangeRestCache(value: sender.isOn)
    }
    
    class func create(viewModel: SettingsViewModel) -> SettingsViewController {
        let view = SettingsViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.backgroundColor
        bind(viewModel)
        self.viewModel.viewDidLoad()
    }
    
    private func bind(_ viewModel: SettingsViewModel) {
        viewModel.buildNumber.observe(on: self, observerBlock: { [weak self] in self?.buildLabel.text = $0})
        viewModel.versionNumber.observe(on: self, observerBlock: { [weak self] in print($0);self?.versionLabel.text = $0})
        viewModel.resetCache.observe(on: self, observerBlock: { [weak self] in self?.resetCacheSwitch.setOn($0, animated: true)})
    }
}
