//
//  MaterialTextField.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/1/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class MaterialButton: View {
    fileprivate let titleLabel = Label()
    fileprivate let rightArrow = UIImageView()
    fileprivate let nameLabel = Label()
    fileprivate let underline = View()
    fileprivate let button = Button()
    
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        
        get {
            return titleLabel.text
        }
    }
    
    var name: String? {
        set {
            nameLabel.text = newValue
        }
        
        get {
            return nameLabel.text
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            underline.backgroundColor = tintColor
            titleLabel.textColor = tintColor
            nameLabel.textColor = tintColor
            rightArrow.tintColor = tintColor
        }
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(button)
        addSubview(titleLabel)
        addSubview(rightArrow)
        addSubview(nameLabel)
        addSubview(underline)
        
        constrain(button, titleLabel, rightArrow, nameLabel, underline) { button, titleLabel, rightArrow, nameLabel, underline in
            button.edges == button.superview!.edges
            
            titleLabel.top == titleLabel.superview!.top + 5
            titleLabel.leading == titleLabel.superview!.leading + 5
            titleLabel.trailing == titleLabel.superview!.trailing - 5
            
            nameLabel.leading == titleLabel.leading
            nameLabel.trailing == titleLabel.trailing
            nameLabel.top == titleLabel.bottom + 10
            nameLabel.bottom == nameLabel.superview!.bottom - 10
            
            rightArrow.centerY == nameLabel.centerY
            rightArrow.trailing == rightArrow.superview!.trailing - 5
            
            underline.bottom == underline.superview!.bottom - 1
            underline.height == 1
            underline.leading == underline.superview!.leading
            underline.trailing == underline.superview!.trailing
        }
    }
    
    override func applyStyling() {
        super.applyStyling()

        tintColor = .fanatickWhite
        
        titleLabel.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light)
        nameLabel.font = UIFont.shFont(size: 20, fontType: .helveticaNeue, weight: .light)
        
        rightArrow.image = UIImage(named: "chevron_right")?.withRenderingMode(.alwaysTemplate)
    }

}

extension Reactive where Base: MaterialButton {
    var tap: ControlEvent<Void> {
        return base.button.rx.tap
    }
    
    var title: Binder<String?> {
        return base.titleLabel.rx.text
    }
    
    var attributedTitle: Binder<NSAttributedString?> {
        return base.titleLabel.rx.attributedText
    }
    
    var name: Binder<String?> {
        return base.nameLabel.rx.text
    }
    
    var attributedName: Binder<NSAttributedString?> {
        return base.nameLabel.rx.attributedText
    }
}
