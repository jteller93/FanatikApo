//
//  DigitalTicketHeaderCell.swift
//  fanatick
//
//  Created by Yashesh on 03/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography

class DigitalTicketHeaderCell: View {

    let labelTitle          = Label()

    override func setupSubviews() {
        super.setupSubviews()
        addSubview(labelTitle)
        
        constrain(labelTitle) { (labelTitle) in
            
            labelTitle.centerX == labelTitle.superview!.centerX
            labelTitle.centerY == labelTitle.superview!.centerY
            labelTitle.top == labelTitle.superview!.top + 34
            labelTitle.bottom == labelTitle.superview!.bottom - 34
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        labelTitle.text = LocalizedString("You_have_selected_a_digital_delivery_method_Please_upload_your_tickets_now", story: .ticketinfo)
        labelTitle.numberOfLines = 0
        labelTitle.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        labelTitle.textAlignment = .center
        labelTitle.textColor = .fanatickWhite
    }
}
