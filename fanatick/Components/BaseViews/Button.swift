//
//  Button.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/11/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    // To use white border when button is not enable
    var isDisabled: Bool = true {
        didSet {
            if isDisabled {
                layer.borderColor = UIColor.fanatickWhite.cgColor
                layer.borderWidth = 1.0
            } else {
                layer.borderWidth = 0.0
            }
            isEnabled = !isDisabled
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupSubviews()
        applyStyling()
        addObservers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        applyStyling()
        addObservers()
    }
    
    func applyStyling() {
        
    }
    
    func addObservers() {
        
    }
    
    func setupSubviews() {
    }
    
    func defaultYellowStyling(fontSize: CGFloat = 16,
                              cornerRadius: CGFloat? = nil,
                              borderColor: UIColor? = nil,
                              cornersMask:CACornerMask? = nil) {
        
        styling(fontSize: fontSize,
                backgroundColor: .fanatickYellow,
                textColor: .fanatickBlack,
                cornerRadius: cornerRadius,
                borderColor: borderColor,
                cornersMask: cornersMask)
    }
    
    func defaultWhiteStyling(fontSize: CGFloat = 16,
                              cornerRadius: CGFloat? = nil,
                              borderColor: UIColor? = nil,
                              cornersMask:CACornerMask? = nil) {
        
        styling(fontSize: fontSize,
                backgroundColor: .fanatickWhite,
                textColor: .fanatickBlack,
                cornerRadius: cornerRadius,
                borderColor: borderColor,
                cornersMask: cornersMask)
    }
    
    func styling(fontSize: CGFloat = 16,
                 backgroundColor: UIColor = .fanatickWhite,
                 textColor: UIColor = .fanatickBlack,
                             cornerRadius: CGFloat? = nil,
                             borderColor: UIColor? = nil,
                             cornersMask:CACornerMask?) {
        
        if cornerRadius != nil {
            layer.cornerRadius = cornerRadius!
            layer.masksToBounds = true
            
        }
        
        if borderColor != nil {
            layer.borderColor = borderColor!.cgColor
            layer.borderWidth = 1
        }
        
        if cornersMask != nil {
            clipsToBounds = true
            layer.maskedCorners = cornersMask!
        }
        
        titleLabel?.font = UIFont.shFont(size: fontSize, fontType: .helveticaNeue, weight: .regular)
        setBackgroundImage(UIImage.image(color: backgroundColor), for: .normal)
        setBackgroundImage(UIImage.image(color: .clear), for: .disabled)
        setTitleColor(textColor, for: .normal)
        setTitleColor(UIColor.gray.withAlphaComponent(0.7), for: .disabled)
        setTitleColor(textColor.withAlphaComponent(0.5), for: .highlighted)
    }
    
//    func defaultYellowStyling(fontSize: CGFloat = 16,
//                              cornerRadius: CGFloat = K.Dimen.button / 2,
//                              borderColor: UIColor? = nil, corners:CACornerMask) {
//        
//        if borderColor != nil {
//            layer.borderColor = borderColor!.cgColor
//            layer.borderWidth = 1
//        }
//        
//        styling(fontSize:fontSize, backgroundColor: .fanatickYellow, corners: corners, radius: cornerRadius)
//        setTitleColor(.fanatickBlack, for: UIControl.State.normal)
//    }
//    
//    func defaultWhiteStyling(fontSize: CGFloat = 16,
//                              cornerRadius: CGFloat = K.Dimen.button / 2,
//                              borderColor: UIColor? = nil, corners:CACornerMask) {
//        
//        
//        styling(fontSize:fontSize,
//                backgroundColor: .fanatickWhite,
//                corners: corners,
//                radius: cornerRadius)
//        
//    }
//    
//    func styling(fontSize:CGFloat = 16, textColor: UIColor = .fanatickWhite, backgroundColor: UIColor, corners:CACornerMask, radius: CGFloat, borderColor: UIColor? = nil) {
//        
//        
//        if borderColor != nil {
//            layer.borderColor = borderColor!.cgColor
//            layer.borderWidth = 1
//        }
//        
//        clipsToBounds = true
//        layer.cornerRadius = radius
//        setBackgroundImage(UIImage.image(color: backgroundColor), for: .normal)
//        setBackgroundImage(UIImage.image(color: .clear), for: .disabled)
//        layer.maskedCorners = corners
//        titleLabel?.font = UIFont.shFont(size: fontSize, fontType: .sfProDisplay, weight: .regular)
//        setTitleColor(textColor, for: UIControl.State.normal)
//    }
}
