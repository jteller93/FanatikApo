//
//  InputAccessoryView.swift
//  fanatick
//
//  Created by Yashesh on 31/05/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Cartography

class InputAccessoryView: View {
    
    let buttonCancel = Button()
    let buttonDone   = Button()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(buttonCancel)
        addSubview(buttonDone)
        
        constrain(self, buttonCancel, buttonDone) { (`self`, buttonCancel, buttonDone) in
            
            buttonCancel.height == frame.height
            buttonCancel.leading == self.leading + 7
            buttonCancel.centerY == self.centerY
            
            buttonDone.trailing == self.trailing - 7
            buttonDone.centerY == self.centerY
            buttonDone.height == frame.height
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        backgroundColor = .fanaticLightGray_66_66_66
        
        buttonCancel.setTitle(LocalizedString("cancel", story: .general), for: UIControl.State.normal)
        buttonCancel.setTitleColor(.fanatickWhite, for: .normal)
        buttonCancel.titleLabel?.font = UIFont.shFont(size: 15, fontType: .sfProDisplay, weight: .regular)
        buttonDone.setTitle(LocalizedString("done", story: .general), for: UIControl.State.normal)
        buttonDone.setTitleColor(.fanatickYellow, for: .normal)
        buttonDone.titleLabel?.font = UIFont.shFont(size: 15, fontType: .sfProDisplay, weight: .bold)
    }
    
    func hideCancelButton() {
        buttonCancel.isHidden = true
    }
}
