//
//  EventView.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/7/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class EventView: View {
    let weekdayLabel = Label()
    let dateLabel = Label()
    let timeLabel = Label()
    let eventTitleLabel = Label()
    let venueNameLabel = Label()
    let locationLabel = Label()
    let priceLabel = Label()
    let currentLabel = Label()
    let buttonDownArrow = Button()

    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(weekdayLabel)
        addSubview(dateLabel)
        addSubview(timeLabel)
        addSubview(eventTitleLabel)
        addSubview(venueNameLabel)
        addSubview(locationLabel)
        addSubview(currentLabel)
        addSubview(priceLabel)
        addSubview(buttonDownArrow)
        
        constrain(weekdayLabel, dateLabel, timeLabel) { weekdayLabel, dateLabel, timeLabel in
            weekdayLabel.leading == weekdayLabel.superview!.leading + K.Dimen.smallMargin
            weekdayLabel.width == 80
            dateLabel.top == weekdayLabel.bottom + 1
            dateLabel.centerY == dateLabel.superview!.centerY + 4
            timeLabel.top == dateLabel.bottom + 3
            
            align(left: weekdayLabel, dateLabel, timeLabel)
            align(right: weekdayLabel, dateLabel, timeLabel)
        }
        
        constrain(weekdayLabel, eventTitleLabel, venueNameLabel, locationLabel) { weekdayLabel, eventTitleLabel, venueNameLabel, locationLabel in
            eventTitleLabel.top == weekdayLabel.top
            
            eventTitleLabel.leading == weekdayLabel.trailing + K.Dimen.smallMargin
            venueNameLabel.top == eventTitleLabel.bottom + 4
            locationLabel.top == venueNameLabel.bottom + 3
            align(right: eventTitleLabel, venueNameLabel, locationLabel)
            align(left: eventTitleLabel, venueNameLabel, locationLabel)
        }
        
        constrain(eventTitleLabel, priceLabel, currentLabel, buttonDownArrow) { eventTitleLabel, priceLabel, currentLabel, buttonDownArrow in
            eventTitleLabel.trailing == currentLabel.leading - K.Dimen.xSmallMargin
            
            buttonDownArrow.width == 40
            buttonDownArrow.trailing == buttonDownArrow.superview!.trailing
            buttonDownArrow.centerY == buttonDownArrow.superview!.centerY
            buttonDownArrow.height == 50
            
            currentLabel.top == eventTitleLabel.top
            currentLabel.trailing == buttonDownArrow.leading
            currentLabel.width == 60
            
            priceLabel.top == currentLabel.bottom + 12
            priceLabel.leading == currentLabel.leading
            priceLabel.trailing == currentLabel.trailing
        }
    }
    
    
    override func applyStyling() {
        super.applyStyling()
        
        dateLabel.font = UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular)
        dateLabel.textColor = .fanatickWhite
        dateLabel.textAlignment = .center
        
        weekdayLabel.font = UIFont.shFont(size: 17, fontType: .helveticaNeue, weight: .regular)
        weekdayLabel.textColor = .fanatickWhite
        weekdayLabel.textAlignment = .center
        
        timeLabel.font = UIFont.shFont(size: 10, fontType: .helveticaNeue, weight: .regular)
        timeLabel.textColor = .fanatickWhite
        timeLabel.textAlignment = .center
        
        eventTitleLabel.font = UIFont.shFont(size: 18, fontType: .sfProDisplay, weight: .medium)
        eventTitleLabel.textColor = .fanatickWhite
        
        venueNameLabel.font = UIFont.shFont(size: 10, fontType: .helveticaNeue, weight: .regular)
        venueNameLabel.textColor = .fanatickWhite
        
        locationLabel.font = UIFont.shFont(size: 10, fontType: .helveticaNeue, weight: .regular)
        locationLabel.textColor = .fanatickWhite
        
        currentLabel.textAlignment = .center
        currentLabel.text = LocalizedString("current").uppercased()
        currentLabel.textColor = .fanatickYellow
        currentLabel.font = UIFont.shFont(size: 10, fontType: .helveticaNeue, weight: .regular)
        
        priceLabel.textAlignment = .center
        priceLabel.textColor = .fanatickYellow
        priceLabel.font = UIFont.shFont(size: 14, fontType: .sfProDisplay, weight: .medium)
        priceLabel.numberOfLines = 2
    }
}
