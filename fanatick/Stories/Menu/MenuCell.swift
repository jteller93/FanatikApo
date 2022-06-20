//
//  MenuCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/19/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class MenuCell: TableViewCell {
    let titleLabel = Label()
    let icon = UIImageView()
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(icon)
        
        constrain(titleLabel, icon) { titleLabel, icon in
            titleLabel.top == titleLabel.superview!.top + K.Dimen.smallMargin
            titleLabel.bottom == titleLabel.superview!.bottom - K.Dimen.smallMargin
            titleLabel.leading == titleLabel.superview!.leading + menuWidth / 3
            
            icon.centerY == titleLabel.centerY
            icon.trailing == titleLabel.leading - K.Dimen.smallMargin
            icon.width == 20
            icon.height == 20
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        titleLabel.textColor = .fanatickWhite
        titleLabel.font = UIFont.shFont(size: 18, fontType: .helveticaNeue, weight: .regular)
        
        icon.contentMode = .scaleAspectFit
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? MenuViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        let item = viewModel.items.value[indexPath.row - 1]
        icon.image = item == viewModel.selectedItem.value ?
            item.item.selectedIcon :
            item.item.unselectedIcon
        titleLabel.text = item.item.title
    }
}
