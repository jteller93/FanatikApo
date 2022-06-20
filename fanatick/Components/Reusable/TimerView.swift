//
//  TimerView.swift
//  fanatick
//
//  Created by Yashesh on 02/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography

class TimerView: View {

    let stackView = UIStackView()
    let labelTime = Label()
    let labelTimeLeft = Label()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(stackView)
        stackView.addArrangedSubview(labelTime)
        stackView.addArrangedSubview(labelTimeLeft)
        stackView.axis = .vertical
        
        constrain(stackView) { (stackView) in
            stackView.centerX == stackView.superview!.centerX
            stackView.centerY == stackView.superview!.centerY
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        labelTimeLeft.text = LocalizedString("time_left", story: .general)
        labelTimeLeft.font = UIFont.shFont(size: 11, fontType: .helveticaNeue, weight: .regular)
        labelTimeLeft.textColor = .fanatickWhite
        
        labelTime.text = "15:00"
        labelTime.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .bold)
        labelTime.textColor = .fanatickWhite
    }
}
