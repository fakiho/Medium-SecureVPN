//
//  RoundedCornerRadioButton.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/13/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

class RoundedCornerRadioButton: UIView, ViewInstantiable {
    
    public var onClick: (() -> Void)?
    private var isChecked: Bool = true
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var radioImageView: UIImageView! {
        didSet {
            handleRadioImage()
        }
    }
    @IBOutlet weak var priceLabel: UILabel! {
        didSet {
            priceLabel.font = Fonts.semiBoldFont
            nameLabel.textColor = Colors.black
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.font = Fonts.semiBoldFont
            nameLabel.textColor = Colors.black
        }
    }
    
    @IBAction func onClickAction(_ sender: UIButton) {
        self.onClick?()
        self.isChecked.toggle()
        handleRadioImage()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        instantiateView()
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        makeRoundedCornerNdBorder()
    }
    
    private func makeRoundedCornerNdBorder() {
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = Colors.systemPurple.cgColor
        self.contentView.backgroundColor = Colors.white
    }
    
    private func handleRadioImage() {
//        radioImageView.image = isChecked ? Images.radioUncheck : Images.radioCheck
        radioImageView.image = Images.radioCheck
    }
}
