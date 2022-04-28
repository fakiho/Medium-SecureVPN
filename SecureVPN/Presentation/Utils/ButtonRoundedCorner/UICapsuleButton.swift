//
//  CapsuleButton.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/12/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

@IBDesignable
class UICapsuleButton: UIButton {
    
    @IBInspectable private(set) var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = bounds.size.height / 2
            pulsate()
        }
    }
    
    private let capsuleLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeColor = UIColor.clear.cgColor
        shape.lineWidth = 10
        shape.fillColor = UIColor.white.withAlphaComponent(0.3).cgColor
        shape.lineCap = .round
        return shape
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeCapsule()
        pulsate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeCapsule()
        pulsate()
    }
    
    private func makeCapsule() {
        clipsToBounds = true
        cornerRadius = frame.height / 2
        layoutIfNeeded()
        setNeedsLayout()
    }
    
    private func setupShapes() {
        setNeedsLayout()
        layoutIfNeeded()
        
        let backgroundLayer = CAShapeLayer()
        let capsulePath = UIBezierPath(arcCenter: self.center, radius: bounds.size.height / 2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        capsuleLayer.frame = bounds
        capsuleLayer.path = capsulePath.cgPath
        capsuleLayer.position = self.center
        self.layer.addSublayer(capsuleLayer)
        
        backgroundLayer.path = capsulePath.cgPath
        backgroundLayer.lineWidth = 10
        backgroundLayer.fillColor = UIColor.blue.cgColor
        backgroundLayer.lineCap = .round
        self.layer.addSublayer(backgroundLayer)
    }
    
    private func capsulePulse() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.2
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        capsuleLayer.add(animation, forKey: "pulsing")
    }
    
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 0.98
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: nil)
    }
    
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.3
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 2
        layer.add(flash, forKey: nil)
    }
}
