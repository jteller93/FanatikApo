//
//  UIView+Helper.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit

extension UIView {
    func addDropShadow() {
        addShadow(color: .black, alpha: 0.3, x: 0, y: 1, blur: 12, spread: 0)
    }
    
    func addShadow(color: UIColor = .black,
                   alpha: Float = 0.5,
                   x: CGFloat = 0,
                   y: CGFloat = 2,
                   blur: CGFloat = 4,
                   spread: CGFloat = 0) {
        
        layer.applySketchShadow(color: color, alpha: alpha, x: x, y: y, blur: blur, spread: spread)
        layer.masksToBounds = false
        layer.drawsAsynchronously = true
    }
    
    func hideWithAlpha() {
        isHidden = true
        alpha = 0
    }
    
    func showWithAlpha() {
        isHidden = false
        alpha = 1
    }
    
    func image() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        
        let topGradientView = UIView()
        topGradientView.frame =  CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height * 0.60)
        addSubview(topGradientView)
        topGradientView.isUserInteractionEnabled = false
        topGradientView.superview?.isUserInteractionEnabled = false
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = topGradientView.bounds
            print()
        topGradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        let bottomView = UIView()
        bottomView.frame = CGRect.init(x: 0, y: topGradientView.frame.height, width: gradientLayer.frame.width, height: frame.size.height * 0.40)
        addSubview(bottomView)
        bottomView.backgroundColor = colorBottom
    }
}
