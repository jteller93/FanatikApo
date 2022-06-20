//
//  MyTicketsCell.swift
//  fanatick
//
//  Created by Yashesh on 11/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class MyTicketsCell: TableViewHeaderFooterView {
    
    let backgroundImage = UIImageView()
    let eventView = EventView()
    let bottomContainer = View()
    let topSeparator = View()
    let ticketInfo = TicketInfoView()
    let bottomContainerHeight: CGFloat = 67
    let backgroundImageBottomMargin: CGFloat = 0
    let buttonDownArrow = Button()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        contentView.addSubview(backgroundImage)
        contentView.addSubview(eventView)
        contentView.addSubview(bottomContainer)
        contentView.addSubview(topSeparator)
        bottomContainer.addSubview(ticketInfo)
        
        constrain(topSeparator, backgroundImage, eventView, bottomContainer) {topSeparator, backgroundImage, eventView, bottomContainer in
            
            topSeparator.top == topSeparator.superview!.top
            topSeparator.leading == topSeparator.superview!.leading
            topSeparator.trailing == topSeparator.superview!.trailing
            topSeparator.height == 9
            
            
            backgroundImage.top == topSeparator.bottom
            backgroundImage.leading == backgroundImage.superview!.leading
            backgroundImage.trailing == backgroundImage.superview!.trailing
            backgroundImage.height == (K.Dimen.screenSize.width * 83 / 373)
            backgroundImage.bottom == backgroundImage.superview!.bottom - bottomContainerHeight - backgroundImageBottomMargin
            
            eventView.top == backgroundImage.top
            eventView.leading == backgroundImage.leading
            eventView.trailing == backgroundImage.trailing
            eventView.bottom == backgroundImage.bottom
            
            bottomContainer.leading == bottomContainer.superview!.leading
            bottomContainer.trailing == bottomContainer.superview!.trailing
            bottomContainer.height == bottomContainerHeight
            bottomContainer.bottom == bottomContainer.superview!.bottom - backgroundImageBottomMargin
        }
        
        constrain(ticketInfo, bottomContainer) { ticketInfo, bottomContainer in
            ticketInfo.bottom == bottomContainer.bottom
            ticketInfo.leading == ticketInfo.superview!.leading
            ticketInfo.trailing == ticketInfo.superview!.trailing - 10
            ticketInfo.height == 50
        }
    }
    
    
    override func applyStyling() {
        super.applyStyling()
        
        eventView.buttonDownArrow.setImage(UIImage.init(named: "chevron_down"), for: .normal)
        
        backgroundImage.clipsToBounds = true
        eventView.currentLabel.isHidden = true
        
        ticketInfo.isIconHidden = false
        
        bottomContainer.addBordersTo([.top, .left, .bottom],
                                     color: .fanatickWhite,
                                     thickness: 1,
                                     insets: .zero)
        
        topSeparator.addBordersTo([.right, .left, .top, .bottom],
                                  color: .fanatickWhite,
                                  thickness: 1,
                                  insets: .zero)
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, section: Int) {
        guard let viewModel = viewModel as? MyTicketsViewModel else { return }
        super.load(viewModel: viewModel, section: section)
        
        let myTicketType = viewModel.selectedSegment.value
        switch myTicketType {
        case .openNegotiations:
            let listing = viewModel.openNegotiations.value.0[section]
                
            setOpenNegotiation(listing: listing)
            eventView.buttonDownArrow.isHidden = viewModel.selectedSegment.value == .openNegotiations && viewModel.role.value == .seller
            
            eventView.buttonDownArrow.rx.tap.subscribe(onNext: { [weak viewModel] _ in
                viewModel?.expanded.accept(section)
            }).disposed(by: disposeBag)
            break
        case .transactions:
            if let listing = viewModel.transactions.value[section].listing {
                setSingleListData(listing: listing)
            }
            break
        }
        
        eventView.buttonDownArrow.isHidden = !((viewModel.selectedSegment.value == .openNegotiations) && viewModel.role.value == .seller)
    }
    
    func setSingleListData(listing: Listing) {
        
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
        eventView.locationLabel.text = "\(event?.venue?.location?.city ?? ""), \(event?.venue?.location?.state ?? "")"
        eventView.priceLabel.text = String(format: LocalizedString("price_template"),
                                           Float(listing.unitPrice ?? 0) / 100)
    }
    
    func setOpenNegotiation(listing: OpenNegotiations) {
        
        ticketInfo.isHardCopy = false
        ticketInfo.isDigital = false
        ticketInfo.isQuickSell = false
        
        ticketInfo.section = listing.section
        ticketInfo.row = listing.row
        ticketInfo.seat = listing.seats?.joined(separator: ",")
        ticketInfo.quantity = "\(listing.seats?.count ?? 0)"
        
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
        eventView.locationLabel.text = "\(event?.venue?.location?.city ?? ""), \(event?.venue?.location?.state ?? "")"
        eventView.priceLabel.text = String(format: LocalizedString("price_template"),
                                           Float(listing.unitPrice ?? 0) / 100)
    }
    
}
