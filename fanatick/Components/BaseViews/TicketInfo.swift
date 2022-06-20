//
//  TicketInfoLabel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/6/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import NutsAndBolts

class TicketInfoLabel: View {
    let titleLabel = Label()
    let descriptionLabel = Label()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        constrain(titleLabel, descriptionLabel) { titleLabel, descriptionLabel in
            titleLabel.leading == titleLabel.superview!.leading + 5
            titleLabel.trailing == titleLabel.superview!.trailing - 5
            titleLabel.top == titleLabel.superview!.top
            
            descriptionLabel.top == titleLabel.bottom
            descriptionLabel.leading == titleLabel.leading
            descriptionLabel.trailing == titleLabel.trailing
            descriptionLabel.bottom <= descriptionLabel.superview!.bottom ~ UILayoutPriority(750)
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        titleLabel.font = UIFont.shFont(size: 13, fontType: .sfProDisplay, weight: .regular)
        titleLabel.textColor = .fanatickWhite
        titleLabel.textAlignment = .center
        
        descriptionLabel.font = UIFont.shFont(size: 13, fontType: .sfProDisplay, weight: .medium)
        descriptionLabel.textColor = .fanatickWhite
        descriptionLabel.textAlignment = .center
    }
}

class TicketIcons: View {
    fileprivate let stackView = UIStackView()
    fileprivate let digitalIcon = UIImageView()
    fileprivate let quickSellIcon = UIImageView()
    fileprivate let hardCopyIcon = UIImageView()
    
    var isDigital: Bool = false {
        didSet {
            digitalIcon.isHidden = !isDigital
        }
    }
    
    var isQuickSell: Bool = false {
        didSet {
            quickSellIcon.isHidden = !isQuickSell
        }
    }
    
    var isHardCopy: Bool = false {
        didSet {
            hardCopyIcon.isHidden = !isHardCopy
        }
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(stackView)
        
        constrain(stackView) { stackView in
            stackView.edges == inset(stackView.superview!.edges, 4)
        }
        
        constrain(digitalIcon, quickSellIcon, hardCopyIcon) { digitalIcon, quickSellIcon, hardCopyIcon in
            digitalIcon.width == 11
            digitalIcon.height == 23
            
            quickSellIcon.width == 9
            quickSellIcon.height == 23
            
            hardCopyIcon.width == 18
            hardCopyIcon.height == 23
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 4
        
        digitalIcon.image = UIImage(named: "icon_phone")
        digitalIcon.contentMode = .scaleAspectFit
        quickSellIcon.image = UIImage(named: "icon_quick_buy")
        quickSellIcon.contentMode = .scaleAspectFit
        hardCopyIcon.image = UIImage(named: "icon_ticket")
        hardCopyIcon.contentMode = .scaleAspectFit
        
        stackView.addArrangedSubview(hardCopyIcon)
        stackView.addArrangedSubview(digitalIcon)
        stackView.addArrangedSubview(quickSellIcon)
        
        isQuickSell = false
        isDigital = false
        isHardCopy = false
    }
}

class TicketInfoView: View {
    fileprivate let ticketInfoStackView = UIStackView()
    fileprivate let sectionLabel = TicketInfoLabel()
    fileprivate let rowLabel = TicketInfoLabel()
    fileprivate let seatLabel = TicketInfoLabel()
    fileprivate let qtyLabel = TicketInfoLabel()
    fileprivate let iconViewHolder = View()
    fileprivate let iconView = TicketIcons()
    
    var section: String? {
        set {
            sectionLabel.descriptionLabel.text = newValue
        }
        
        get {
            return sectionLabel.descriptionLabel.text
        }
    }
    
    var row: String? {
        set {
            rowLabel.descriptionLabel.text = newValue
        }
        
        get {
            return rowLabel.descriptionLabel.text
        }
    }
    
    var seat: String? {
        set {
            seatLabel.descriptionLabel.text = newValue
        }
        
        get {
            return seatLabel.descriptionLabel.text
        }
    }
    
    var quantity: String? {
        set {
            qtyLabel.descriptionLabel.text = newValue
        }
        
        get {
            return qtyLabel.descriptionLabel.text
        }
    }
    
    
    var isDigital: Bool {
        set {
            iconView.isDigital = newValue
        }
        
        get {
            return iconView.isDigital
        }
    }
    
    var isQuickSell: Bool {
        set {
            iconView.isQuickSell = newValue
        }
        
        get {
            return iconView.isQuickSell
        }
    }
    
    var isHardCopy: Bool {
        set {
            iconView.isHardCopy = newValue
        }
        
        get {
            return iconView.isHardCopy
        }
    }
    
    var isIconHidden: Bool = true {
        didSet {
            iconViewHolder.isHidden = isIconHidden
            iconView.isHidden = isIconHidden
        }
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(ticketInfoStackView)
        
        ticketInfoStackView.addArrangedSubview(sectionLabel)
        ticketInfoStackView.addArrangedSubview(rowLabel)
        ticketInfoStackView.addArrangedSubview(seatLabel)
        ticketInfoStackView.addArrangedSubview(qtyLabel)
        ticketInfoStackView.addArrangedSubview(iconViewHolder)
        
        iconViewHolder.addSubview(iconView)
        
        constrain(ticketInfoStackView, iconView) { stack, iconView in
            stack.edges == stack.superview!.edges
            
            iconView.center == iconView.superview!.center
            iconView.leading >= iconView.superview!.leading
            iconView.trailing <= iconView.superview!.trailing
            iconView.height == 23
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        ticketInfoStackView.axis = .horizontal
        ticketInfoStackView.distribution = .fillEqually
        
        sectionLabel.titleLabel.text = LocalizedString("sec")
        rowLabel.titleLabel.text = LocalizedString("row")
        rowLabel.addBorderTo(UIRectEdge.left, color: .white, thickness: 1, insets: .zero)
        seatLabel.titleLabel.text = LocalizedString("seat")
        seatLabel.addBorderTo(UIRectEdge.left, color: .white, thickness: 1, insets: .zero)
        qtyLabel.titleLabel.text = LocalizedString("qty")
        qtyLabel.addBorderTo(UIRectEdge.left, color: .white, thickness: 1, insets: .zero)
        iconViewHolder.addBorderTo(UIRectEdge.left, color: .white, thickness: 1, insets: .zero)
    
        isIconHidden = true
    }
}

