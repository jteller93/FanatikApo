//
//  EventCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/6/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cosmos
import Cartography
import UIKit
import RxCocoa
import RxSwift

class EventDetailCell: TableViewCell {
    let starRating = CosmosView()
    let nameLabel = Label()
    let ticketInfo = TicketInfoView()
    let bottomSeparator = View()
    let verticalSeparator = View()
    let rightArrow = UIImageView()
    let priceLabel = Label()
    let currencyLabel = Label()
    let iconView = TicketIcons()
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(ticketInfo)
        contentView.addSubview(bottomSeparator)
        contentView.addSubview(verticalSeparator)
        contentView.addSubview(starRating)
        
        constrain(nameLabel, starRating, ticketInfo, bottomSeparator, verticalSeparator) { nameLabel, starRating, ticketInfo, bottomSeparator, verticalSeparator in
            nameLabel.leading == nameLabel.superview!.leading + 10
            nameLabel.trailing <= starRating.leading - 10
            nameLabel.top == nameLabel.superview!.top
            nameLabel.height == ticketInfo.height
            
            starRating.centerY == nameLabel.centerY
            starRating.trailing == verticalSeparator.leading - 12
            
            ticketInfo.height == 50
            ticketInfo.top == nameLabel.bottom
            ticketInfo.leading == ticketInfo.superview!.leading
            ticketInfo.trailing == verticalSeparator.leading
            ticketInfo.bottom == bottomSeparator.top
            
            verticalSeparator.top == verticalSeparator.superview!.top
            verticalSeparator.leading == verticalSeparator.superview!.trailing - 100
            verticalSeparator.width == 1
            verticalSeparator.bottom == bottomSeparator.top
            
            bottomSeparator.height == 9
            bottomSeparator.bottom == bottomSeparator.superview!.bottom - 1 ~ UILayoutPriority(750)
            bottomSeparator.leading == bottomSeparator.superview!.leading + 1
            bottomSeparator.trailing == bottomSeparator.superview!.trailing - 1
        }
        
        contentView.addSubview(priceLabel)
        contentView.addSubview(currencyLabel)
        contentView.addSubview(rightArrow)
        contentView.addSubview(iconView)
        
        constrain(priceLabel, currencyLabel, rightArrow, iconView, bottomSeparator) { priceLabel, currencyLabel, rightArrow, iconView, bottomSeparator in
            rightArrow.height == 20
            rightArrow.width == 11
            rightArrow.trailing == rightArrow.superview!.trailing - 10
            rightArrow.top == rightArrow.superview!.top + 30
            
            priceLabel.leading == priceLabel.superview!.trailing - 95
            priceLabel.trailing == rightArrow.leading - 5
            priceLabel.top == rightArrow.top
            
            currencyLabel.leading == priceLabel.leading
            currencyLabel.trailing == priceLabel.trailing
            currencyLabel.top == priceLabel.bottom
            
            iconView.centerX == priceLabel.centerX
            iconView.top == currencyLabel.bottom + 5
            iconView.bottom <= bottomSeparator.top - 5
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        backgroundColor = .clear
        
        starRating.settings.fillMode = .precise
        starRating.settings.starSize = 14
        starRating.settings.emptyBorderColor = .fanatickWhite
        starRating.settings.filledColor = .fanatickYellow
        starRating.settings.emptyBorderWidth = 1
        starRating.settings.updateOnTouch = true
        starRating.rating = 0
        
        bottomSeparator.addBorders(.fanatickWhite)
        verticalSeparator.backgroundColor = .fanatickWhite
        nameLabel.textColor = .fanatickYellow
        nameLabel.font = UIFont.shFont(size: 18, fontType: .sfProDisplay, weight: .bold)
        
        priceLabel.textColor = .fanatickWhite
        priceLabel.font = UIFont.shFont(size: 14, fontType: .sfProDisplay, weight: .medium)
        priceLabel.textAlignment = .center
        
        currencyLabel.text = LocalizedString("usd")
        currencyLabel.textColor = .fanatickWhite
        currencyLabel.font = UIFont.shFont(size: 10, fontType: .sfProDisplay, weight: .medium)
        currencyLabel.textAlignment = .center
        
        rightArrow.image = UIImage(named: "chevron_right")
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? EventDetailViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        iconView.isHardCopy = false
        iconView.isDigital = false
        iconView.isQuickSell = false
        
        let listing = viewModel.listings.value[indexPath.row]
        
        let seller = listing.seller
        nameLabel.text = "\(seller?.firstName ?? "") \(seller?.lastName ?? "")"
        
        if let ratingString = seller?.ratings, let ratings = Double(ratingString) {
            starRating.isHidden = false
            starRating.rating = ratings
        } else {
            starRating.isHidden = true
        }
        
        ticketInfo.section = listing.section
        ticketInfo.row = listing.row
        ticketInfo.seat = listing.seats?.joined(separator: ", ")
        ticketInfo.quantity = "\(listing.quantity ?? 0)"
        
        priceLabel.text = String(format: LocalizedString("price_template"),
                                 Float(listing.unitPrice ?? 0) / 100)
        iconView.isHardCopy = listing.deliveryMethod == .hardcopy
        iconView.isDigital = listing.deliveryMethod == .digital
        iconView.isQuickSell = listing.quickBuy ?? false
    }
}
