//
//  AboutHeaderCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class AboutHeaderCell: TableViewCell {
    let logo = UIImageView()
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(logo)
        
        constrain(logo) { logo in
            logo.leading == logo.superview!.leading + 60
            logo.trailing == logo.superview!.trailing - 60
            logo.top == logo.superview!.top
            logo.bottom == logo.superview!.bottom ~ UILayoutPriority(750)
            logo.height == logo.width * 102 / 251
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        logo.image = UIImage(named: "icon_logo")
    }
}
