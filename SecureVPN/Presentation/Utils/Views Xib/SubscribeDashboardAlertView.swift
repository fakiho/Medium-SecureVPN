//
//  SubscribeDashboardAlertView.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/9/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit
import os

class SubscribeDashboardAlertView: UIView, ViewInstantiable {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textView: UILabel! {
        didSet {
            textView.font = Fonts.mediumFont
            textView.textColor = Colors.white
            textView.numberOfLines = 2
        }
    }
    @IBOutlet weak var buttonPurchase: UIButton! {
        didSet {
            buttonPurchase.backgroundColor = Colors.yellowColor
            buttonPurchase.titleLabel?.font = Fonts.boldButtonFont
            buttonPurchase.clipsToBounds = true
            buttonPurchase.layer.cornerRadius = buttonPurchase.layer.bounds.height / 2
        }
    }
    
    public var subscribeActionMonthly: (() -> Void)?
    
    @IBAction func subscribeAction(_ sender: UIButton) {
        subscribeActionMonthly?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        instantiateView()
        addSubview(contentView)
        contentView.backgroundColor = Colors.mainPurpleColor
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 20
        contentView.addShadow(location: .top)
    }
}
