//
//  SubscriptionPeriodView.swift
//  Secure VPN
//
//  Created by Ali Fakih on 3/19/21.
//  Copyright © 2021 beApp. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionPeriodView: UIView {
    
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var buttonAction: (()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class func instanceFromNib() -> SubscriptionPeriodView
    {
        return  UINib(nibName: "SubscriptionPeriodView", bundle: nil).instantiate(withOwner: self, options: nil).first as! SubscriptionPeriodView
    }
    
    func setContent(product: SKProduct)
    {
        if product.productIdentifier.contains("weekly")
        {
            self.periodLabel.text = "Weekly"
        }
        else if product.productIdentifier.contains("monthly")
        {
            self.periodLabel.text = "Monthly"
        }
        else if product.productIdentifier.contains("yearly")
        {
            self.periodLabel.text = "Yearly"
        }
        
        self.priceLabel.text = "\(product.localizedPrice ?? "")"
    }
    
    func didSelect()
    {
        self.backgroundColor = UIColor.white
        self.layer.borderWidth = 3
    }
    
    func didUnselect()
    {
        self.backgroundColor = UIColor.init(red: 199.0/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1.0)
        self.layer.borderWidth = 0
    }
    
    @IBAction func productSectionAction(_ sender: UIButton)
    {
        if let buttonAction = self.buttonAction
        {
            buttonAction()
        }
    }
}
