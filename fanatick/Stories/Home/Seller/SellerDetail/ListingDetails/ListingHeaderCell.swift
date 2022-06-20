
//
//  ListingHeaderCell.swift
//  fanatick
//
//  Created by Yashesh on 10/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class ListingHeaderCell: TableViewCell {
    let backgroundImage = UIImageView()
    let eventView = EventView()
    let bottomContainer = View()
    let bottomSeparator = View()
    let ticketInfo = TicketInfoView()
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(backgroundImage)
        contentView.addSubview(eventView)
        contentView.addSubview(bottomContainer)
        
        bottomContainer.addSubview(ticketInfo)
        bottomContainer.addSubview(bottomSeparator)
        
        constrain(backgroundImage, eventView, bottomContainer) {backgroundImage, eventView, bottomContainer in
            backgroundImage.top == backgroundImage.superview!.top
            backgroundImage.leading == backgroundImage.superview!.leading
            backgroundImage.trailing == backgroundImage.superview!.trailing
            backgroundImage.height == backgroundImage.width * 83 / 373
            
            eventView.edges == backgroundImage.edges
            
            bottomContainer.top == backgroundImage.bottom
            bottomContainer.leading == bottomContainer.superview!.leading
            bottomContainer.trailing == bottomContainer.superview!.trailing
            bottomContainer.height == 70
            bottomContainer.bottom == bottomContainer.superview!.bottom ~ UILayoutPriority(750)
        }
        
        constrain(ticketInfo, bottomSeparator) { ticketInfo, bottomSeparator in
            bottomSeparator.height == 9
            bottomSeparator.bottom == bottomSeparator.superview!.bottom
            bottomSeparator.leading == bottomSeparator.superview!.leading
            bottomSeparator.trailing == bottomSeparator.superview!.trailing
            
            ticketInfo.bottom == bottomSeparator.top
            ticketInfo.leading == ticketInfo.superview!.leading
            ticketInfo.trailing == ticketInfo.superview!.trailing - 10
            ticketInfo.height == 50
        }
    }
    
    
    override func applyStylings() {
        super.applyStylings()
        
        eventView.currentLabel.isHidden = true
        
        ticketInfo.isIconHidden = false
        
        bottomContainer.addBordersTo([.top, .left, .bottom],
                                     color: .fanatickWhite,
                                     thickness: 1,
                                     insets: .zero)
        
        bottomSeparator.addBordersTo([.right, .top],
                                     color: .fanatickWhite,
                                     thickness: 1,
                                     insets: .zero)
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? ListingDetailsViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        if let listing = viewModel.list.value {
            setSingleListData(listing: listing)
        }
        selectionStyle = .none
    }
    
    fileprivate func setSingleListData(listing: Listing) {
        
        ticketInfo.isHardCopy = false
        ticketInfo.isDigital = false
        ticketInfo.isQuickSell = false
        
        ticketInfo.section = listing.section
        ticketInfo.row = listing.row
        ticketInfo.seat = listing.seats?.joined(separator: ",")
        ticketInfo.quantity = "\(listing.quantity ?? 0)"
        
        ticketInfo.isHardCopy = listing.deliveryMethod == .hardcopy
        ticketInfo.isDigital = listing.deliveryMethod == .digital
        ticketInfo.isQuickSell = listing.quickBuy ?? false
        
        let event = listing.event
        if let startAt = event?.startAt, let date = Date.init(fromString: startAt, format: .isoDateTimeMilliSec) {
            eventView.weekdayLabel.text = date.toString(format: DateFormatType.custom("EEE")).uppercased()
            eventView.dateLabel.text = date.toString(format: DateFormatType.custom("MM/dd"))
            eventView.timeLabel.text = date.toString(format: DateFormatType.custom("HH:mm a"))
        } else {
            eventView.weekdayLabel.text = ""
            eventView.dateLabel.text = ""
            eventView.timeLabel.text = ""
        }
        
        eventView.eventTitleLabel.text = event?.name
        eventView.venueNameLabel.text = event?.venue?.name
        eventView.locationLabel.text = event?.location?.cityAndState
        eventView.priceLabel.text = String(format: LocalizedString("price_template"),
                                           Float(listing.unitPrice ?? 0) / 100)
    }
}
