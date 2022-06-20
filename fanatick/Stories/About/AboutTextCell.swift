//
//  AboutTextCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class AboutTextCell: TableViewCell {
    
    let titleLabel = Label()
    let descriptionLabel = Label()
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        constrain(titleLabel, descriptionLabel) { title, description in
            title.top == title.superview!.top + K.Dimen.xSmallMargin
            title.leading == title.superview!.leading + K.Dimen.defaultMargin
            title.trailing == title.superview!.trailing - K.Dimen.defaultMargin
            
            description.top == title.bottom + K.Dimen.smallMargin
            description.leading == description.superview!.leading + K.Dimen.defaultMargin
            description.trailing == description.superview!.trailing - K.Dimen.defaultMargin
            description.bottom == description.superview!.bottom - K.Dimen.xSmallMargin  ~ UILayoutPriority(750)
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        descriptionLabel.font = UIFont.shFont(size: 14, fontType: .sfProDisplay, weight: .regular)
        descriptionLabel.textColor = .fanatickWhite
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .justified
        
        titleLabel.font = UIFont.shFont(size: 18, fontType: .sfProDisplay, weight: .medium)
        titleLabel.textColor = .fanatickWhite
        titleLabel.textAlignment = .center
        
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? AboutViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        let item = viewModel.abouts[indexPath.row - 1]
        
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        
    }
}
