//
//  ProTipCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import ActiveLabel
import UIKit

class ProTipCell: TableViewCell {
    let fanatipLogo = UIImageView()
    let protipLogo = UIImageView()
    let descriptionLabel = ActiveLabel()
    
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(fanatipLogo)
        contentView.addSubview(protipLogo)
        contentView.addSubview(descriptionLabel)
        
        constrain(fanatipLogo, protipLogo, descriptionLabel) { fanatipLogo, protipLogo, descriptionLabel in
            
            fanatipLogo.leading == fanatipLogo.superview!.leading + 60
            fanatipLogo.trailing == fanatipLogo.superview!.trailing - 60
            fanatipLogo.top == fanatipLogo.superview!.top
            fanatipLogo.height == fanatipLogo.width * 102 / 251
            
            protipLogo.top == fanatipLogo.centerY + 40
            protipLogo.width == fanatipLogo.width * 150 / 250
            protipLogo.centerX == fanatipLogo.centerX
            protipLogo.height == protipLogo.width
            
            descriptionLabel.top == protipLogo.bottom + K.Dimen.smallMargin
            descriptionLabel.bottom == descriptionLabel.superview!.bottom - K.Dimen.defaultMargin
            descriptionLabel.leading == descriptionLabel.superview!.leading + K.Dimen.defaultMargin
            descriptionLabel.trailing == descriptionLabel.superview!.trailing - K.Dimen.defaultMargin
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        descriptionLabel.font = UIFont.shFont(size: 14, fontType: .sfProDisplay, weight: .regular)
        descriptionLabel.textColor = .fanatickWhite
        descriptionLabel.enabledTypes = [.url]
        descriptionLabel.numberOfLines = 0
        descriptionLabel.URLColor = UIColor.fanatickYellow

        fanatipLogo.image = UIImage(named: "fanaTips")
        
        protipLogo.image = UIImage(named: "proTip")
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? ProTipViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        descriptionLabel.text = LocalizedString("tip_text", story: .notifications)
        descriptionLabel.handleURLTap { (url) in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        descriptionLabel.sizeToFit()
    }
}
