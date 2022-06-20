//
//  NavigationBar.swift
//  fanatick
//
//  Created by Yashesh on 11/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography

class NavigationBar: View {

    let leftButton = Button()
    let rightButton = Button()
    let labelTitle = Label()
    let labelDetailTitle = Label()
    let stackView = UIStackView()
    
    override func setupSubviews() {
        super.setupSubviews()
        addSubview(rightButton)
        addSubview(stackView)
        
        stackView.addArrangedSubview(labelTitle)
        stackView.addArrangedSubview(labelDetailTitle)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        
        constrain(rightButton, stackView) { (rightButton, stackView) in
            rightButton.top == rightButton.superview!.top + K.Dimen.topPadding + 3
            rightButton.trailing == rightButton.superview!.trailing - 10
            rightButton.height == 40
            rightButton.width == 40
            
            stackView.leading == stackView.superview!.leading + 22
            stackView.bottom == stackView.superview!.bottom - 17
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        backgroundColor = .fanatickYellow
        rightButton.setImage(UIImage.init(named: "icon_close_black"), for: UIControl.State.normal)
        
        labelTitle.textAlignment = .left
        labelDetailTitle.textAlignment = .left
        
        labelTitle.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        labelDetailTitle.font = UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .regular)
    }
    
    func set(title: String?, subtitle: String?) {
        labelTitle.text = title ?? ""
        labelDetailTitle.text = subtitle ?? ""
    }
}
