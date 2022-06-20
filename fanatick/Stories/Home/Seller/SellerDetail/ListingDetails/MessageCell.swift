//
//  MessageCell.swift
//  fanatick
//
//  Created by Yashesh on 20/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class MessageCell: TableViewCell {

    let labelTitle = Label()
    let labelSubTitle = Label()
    let stackView = UIStackView()
    
    override func addSubviews() {
        super.addSubviews()
        
        stackView.addArrangedSubview(labelTitle)
        stackView.addArrangedSubview(labelSubTitle)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        
        addSubview(stackView)
        constrain(stackView) { (stackView) in
            stackView.centerX == stackView.superview!.centerX
            stackView.centerY == stackView.superview!.centerY
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        labelTitle.text = LocalizedString("mark_as", story: .listingdetail)
        labelSubTitle.text = LocalizedString("transaction_completed", story: .listingdetail)
        
        labelTitle.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        labelTitle.textColor = .fanatickWhite
        labelTitle.textAlignment = .center
        
        labelSubTitle.font = UIFont.shFont(size: 30, fontType: .helveticaNeue, weight: .regular)
        labelSubTitle.textColor = .fanatickWhite
        labelSubTitle.textAlignment = .center
        
        isUserInteractionEnabled = false
    }
}
