//
//  HomeCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/3/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class HomeEventCell: TableViewCell {
    let topSeparator = View()
    let backgroundImage = UIImageView()
    let eventView = EventView()
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(topSeparator)
        contentView.addSubview(backgroundImage)
        contentView.addSubview(eventView)
        constrain(topSeparator, backgroundImage) { topSeparator, backgroundImage in
            topSeparator.height == 9
            topSeparator.leading == topSeparator.superview!.leading
            topSeparator.top == topSeparator.superview!.top + 1
            topSeparator.trailing == topSeparator.superview!.trailing
            
            backgroundImage.top == topSeparator.bottom + 1
            backgroundImage.leading == backgroundImage.superview!.leading
            backgroundImage.trailing == backgroundImage.superview!.trailing
            backgroundImage.bottom == backgroundImage.superview!.bottom ~ UILayoutPriority(750)
            backgroundImage.height == backgroundImage.width * 83 / 373
        }
        
        constrain(topSeparator, eventView) { top, eventView in
            eventView.top == top.bottom
            eventView.leading == eventView.superview!.leading
            eventView.trailing == eventView.superview!.trailing
            eventView.bottom == eventView.superview!.bottom
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        topSeparator.addBorders(.fanatickWhite)
        
        eventView.priceLabel.isHidden = true
        eventView.currentLabel.isHidden = true
    }
    
    override func load<VM>(viewModel: VM?, indexPath: IndexPath) where VM : ViewModel {
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        if let viewModel = viewModel as? BuyerHomeViewModel {
            let event = viewModel.futureEvents.value[indexPath.row]
            updateViews(event: event)
        } else if let viewModel = viewModel as? SearchViewModel {
            let event = viewModel.events.value[indexPath.row]
            updateViews(event: event)
        } else {
            eventView.weekdayLabel.text = ""
            eventView.dateLabel.text = ""
            eventView.timeLabel.text = ""
            eventView.eventTitleLabel.text = ""
            eventView.venueNameLabel.text = ""
            eventView.locationLabel.text = ""
        }
    }
    
    private func updateViews(event: Event) {
        if let startAt = event.startAt, let date = Date.init(fromString: startAt, format: .isoDateTimeMilliSec) {
            eventView.weekdayLabel.text = date.toString(format: DateFormatType.custom("EEE")).uppercased()
            eventView.dateLabel.text = date.toString(format: DateFormatType.custom("MM/dd"))
            eventView.timeLabel.text = date.toString(format: DateFormatType.custom("HH:mm a"))
        } else {
            eventView.weekdayLabel.text = ""
            eventView.dateLabel.text = ""
            eventView.timeLabel.text = ""
        }
        
        eventView.eventTitleLabel.text = event.name
        eventView.venueNameLabel.text = event.venue?.name
        eventView.locationLabel.text = "\(event.venue?.location?.city ?? ""), \(event.venue?.location?.state ?? "")"
    }
}

