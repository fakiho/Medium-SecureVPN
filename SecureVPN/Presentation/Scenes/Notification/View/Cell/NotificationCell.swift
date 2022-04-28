//
//  NotificationCell.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/28/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: NotificationCell.self)

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(title: String, subtitle: String, image: UIImage? = UIImage(named: "vp")) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.iconLabel.image = image
    }
}
