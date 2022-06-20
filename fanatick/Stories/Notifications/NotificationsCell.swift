//
//  NotificationsCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class NotificationsCell: TableViewCell {
    let dateLabel = Label()
    let titleLabel = Label()
    let container = View()
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(container)
        container.addSubview(dateLabel)
        container.addSubview(titleLabel)
        
        constrain(dateLabel, titleLabel, container) { dateLabel, titleLabel, container in
            container.edges == inset(container.superview!.edges,
                                     K.Dimen.xSmallMargin,
                                     K.Dimen.defaultMargin,
                                     K.Dimen.xSmallMargin,
                                     K.Dimen.defaultMargin)
            
            dateLabel.top == dateLabel.superview!.top + K.Dimen.xSmallMargin
            dateLabel.leading == dateLabel.superview!.leading + K.Dimen.xSmallMargin
            dateLabel.width == 100
            
            titleLabel.top == titleLabel.superview!.top + K.Dimen.smallMargin
            titleLabel.bottom == titleLabel.superview!.bottom - K.Dimen.smallMargin
            titleLabel.leading == dateLabel.trailing + K.Dimen.smallMargin
            titleLabel.trailing == titleLabel.superview!.trailing - K.Dimen.defaultMargin
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        container.addBorders(.fanatickWhite)
        container.backgroundColor = .clear
        
        dateLabel.font = UIFont.shFont(size: 12, fontType: .helveticaNeue, weight: .regular)
        dateLabel.textColor = .fanatickYellow
        
        titleLabel.font = UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .fanatickWhite
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? NotificationsViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        let notification = viewModel.notifications.value[indexPath.row]
        
        if let createdAr = notification.createdAt, let date = Date.init(fromString: createdAr, format: .isoDateTimeMilliSec) {
            dateLabel.text = date.adjust(DateComponentType.day, offset: 0).toNotificationsTime()
        } else {
            dateLabel.text = ""
        }
        
        titleLabel.text = notification.description
    }
}

extension Date {
    func toNotificationsTime() -> String {
        if compare(.isToday) {
            return LocalizedString("today", story: .general)
        } else if compare(.isYesterday) {
            return LocalizedString("yesterday", story: .general)
        } else {
            return toString(format: .custom("MM/dd/yyy"))
        }
    }
}
