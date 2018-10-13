//
//  UIView Gradient Extension.swift
//  testt
//
//  Created by Юрий Есин on 15.08.2018.
//  Copyright © 2018 Roman Esin. All rights reserved.
//

import UIKit

extension UIView {
    func makeGradientWithColors(_ colors: [CGColor], start: CGPoint = CGPoint(x: 0, y: 0), end: CGPoint = CGPoint(x: 0, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.position = CGPoint.zero
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.maskedCorners = layer.maskedCorners
        
        layer.addSublayer(gradientLayer)
    }
    
    func roundCorners(_ cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
    }
}
