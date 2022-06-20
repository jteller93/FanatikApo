//
//  ListingDetailBuyerStatusCell.swift
//  fanatick
//
//  Created by Yashesh on 12/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography

class ViewOfferNagotiationsCell: TableViewCell {

    let viewForNameAndPrice = View()
    let viewForStatus = View()
    let stackView = UIStackView()
    let labelName = Label()
    let labelSellingPriceTitle = Label()
    let labelSellingPrice = Label()
    let stackViewForSellingPrice = UIStackView()
    let labelOriginalPriceTitle = Label()
    let labelOriginalPrice = Label()
    let tableView = UITableView()
    let userRole = MenuViewModel.shared.role.value
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(stackView)
        stackView.addArrangedSubview(viewForNameAndPrice)
        stackView.addArrangedSubview(viewForStatus)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        
        viewForNameAndPrice.addSubview(labelName)
        viewForNameAndPrice.addSubview(labelOriginalPriceTitle)
        viewForNameAndPrice.addSubview(labelOriginalPrice)
        
        viewForNameAndPrice.addSubview(stackViewForSellingPrice)
        stackViewForSellingPrice.axis = .vertical
        stackViewForSellingPrice.addArrangedSubview(labelSellingPriceTitle)
        stackViewForSellingPrice.addArrangedSubview(labelSellingPrice)
        stackViewForSellingPrice.spacing = 12
    
        viewForStatus.addSubview(tableView)
        
        constrain(labelName, stackView, stackViewForSellingPrice) { (labelName, stackView, stackViewForSellingPrice) in
            
            stackView.top == stackView.superview!.top
            stackView.leading == stackView.superview!.leading
            stackView.trailing == stackView.superview!.trailing
            stackView.bottom == stackView.superview!.bottom
            
            labelName.leading == labelName.superview!.leading + K.Dimen.smallMargin
            labelName.top == labelName.superview!.top + 22
            
            stackViewForSellingPrice.centerX == stackViewForSellingPrice.superview!.centerX
            stackViewForSellingPrice.centerY == stackViewForSellingPrice.superview!.centerY + 10
        }
        
        NegotiationOffersCell.registerCell(tableView: tableView)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        
        constrain(tableView) { (tableView) in
            tableView.top == tableView.superview!.top
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.bottom == tableView.superview!.bottom - 100
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        labelName.font = UIFont.shFont(size: 24,
                                       fontType: .helveticaNeue,
                                       weight: .bold)
        
        labelName.textColor = .fanatickYellow
        
        labelSellingPriceTitle.textAlignment = .center
        labelSellingPrice.textAlignment = .center
    }
    
    fileprivate func setLabelStyling(label:Label, text: String, fontSize: CGFloat = 16, textColor: UIColor = .fanatickWhite) {
        label.text = text
        label.font = UIFont.shFont(size: fontSize, fontType: .helveticaNeue, weight: .regular)
        label.textColor = textColor
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? ViewOffersNegotationsViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        if let negotiations = viewModel.selectedNegotiation.value {
            
            let buyer = userRole == .buyer ? viewModel.list.value?.seller : negotiations.buyer
            labelName.text = "\(buyer?.firstName ?? "") \(buyer?.lastName ?? "")"
            
            viewModel.events.subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
                self?.setupOfferAndAskingPrice(viewModel: viewModel)
            }).disposed(by: disposeBag)
        } else if userRole == .buyer {
            if viewModel.list.value?.status ?? .unsold == .sold {
                setLabelStyling(label: labelSellingPrice,
                                text: LocalizedString("transaction_completed", story: .home),
                                fontSize: 30,
                                textColor: .fanatickWhite)
            } else {
                let seller = viewModel.list.value?.seller
                labelName.text = "\(seller?.firstName ?? "") \(seller?.lastName ?? "")"
                setupOfferAndAskingPrice(viewModel: viewModel)
                tableView.reloadData()
            }
        }
    }
    
    fileprivate func setupOfferAndAskingPrice(viewModel: ViewOffersNegotationsViewModel?) {
        
        var title = ""
        var price = ""
        
        if let lastEvent = viewModel?.events.value.first, let type = lastEvent.type {
            
            switch type {
            case .ask:
                title = userRole == .seller ? LocalizedString("you_asked_for", story: .listingdetail) : LocalizedString("current_asking_price_per_ticket", story: .listingdetail)
                break
            case .offer://you_offered
                title = userRole == .seller ? LocalizedString("current_offer", story: .listingdetail) : LocalizedString("you_offered", story: .listingdetail)
                break
            case .exception:
                break
            case .decline:
                title = LocalizedString("you_declined", story: .listingdetail)
                break
            case .accept:
                title = LocalizedString("accepted_offer", story: .listingdetail)
                break
            }
            price = String(format: LocalizedString("price_template"),
                           Float(lastEvent.amount ?? 0) / 100)
        } else if userRole == .buyer {
            title = LocalizedString("current_asking_price_per_ticket", story: .listingdetail)
            price = String(format: LocalizedString("price_template"),
                   Float(viewModel?.list.value?.unitPrice ?? 0) / 100)
        }
        
        setLabelStyling(label: labelSellingPriceTitle,
                        text: title,
                        textColor: .fanatickWhite)
        
        setLabelStyling(label: labelSellingPrice,
                        text: price,
                        fontSize: 40,
                        textColor: .fanatickWhite)
    }
}

extension ViewOfferNagotiationsCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (viewModel as? ViewOffersNegotationsViewModel)?.list.value?.status ?? .unsold == .sold ? 0 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? ((viewModel as? ViewOffersNegotationsViewModel)?.events.value.count ?? 0) : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = NegotiationOffersCell.dequeueCell(tableView: tableView) as? NegotiationOffersCell {
            guard let viewModel = viewModel as? ViewOffersNegotationsViewModel else {
                return cell
            }
            if indexPath.section == 0 {
                cell.load(viewModel: viewModel, indexPath: indexPath)
            } else {
                cell.loadOriginalPrice(viewModel: viewModel)
            }
            return cell
        }
        return UITableViewCell()
    }
}

class NegotiationOffersCell: TableViewCell {
    
    let labelTitle = Label()
    let labelPrice = Label()
    let stackView = UIStackView()
    let userRole = MenuViewModel.shared.role.value
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        
        stackView.addArrangedSubview(labelTitle)
        stackView.addArrangedSubview(labelPrice)
        
        constrain(stackView) { (stackView) in
            stackView.top == stackView.superview!.top + 6
            stackView.bottom == stackView.superview!.bottom - 6
            stackView.leading == stackView.superview!.leading + K.Dimen.smallMargin
            stackView.trailing == stackView.superview!.trailing - K.Dimen.smallMargin
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        labelTitle.textAlignment = .left
        labelPrice.textAlignment = .right
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? ViewOffersNegotationsViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        let event = viewModel.events.value[indexPath.row]
        let type = event.type
        
        let buyer = userRole == .buyer ? viewModel.list.value?.seller : viewModel.selectedNegotiation.value?.buyer
        let name = "\(buyer?.firstName ?? "") \(buyer?.lastName ?? "")"
        
        var title = ""
        
        switch type {
        case .ask:
            title = userRole == .buyer ? "\(name) \(LocalizedString("asked_for", story: .listingdetail))" : LocalizedString("you_asked_for", story: .listingdetail)
            break
        case .offer, .decline, .accept:
            title = userRole == .buyer ? LocalizedString("you_asked_for", story: .listingdetail) : "\(name) \(LocalizedString("asked_for", story: .listingdetail))"
            break
        case .exception:
            break
        default:
            break
        }
        
        setLabelStyling(label: labelTitle,
                        text: title,
                        textColor: .fanatickGray_74_74_74)
        
        if let amount = event.amount {
            let offerPrice = amount / 100
            setLabelStyling(label: labelPrice,
                            text: String(format: LocalizedString("price_template"),
                                         Float(offerPrice)),
                            textColor: .fanatickGray_74_74_74)
        }
    }
    
    fileprivate func setLabelStyling(label:Label, text: String, fontSize: CGFloat = 16, textColor: UIColor = .fanatickWhite) {
        label.text = text
        label.font = UIFont.shFont(size: fontSize, fontType: .helveticaNeue, weight: .regular)
        label.textColor = textColor
    }
    
    func loadOriginalPrice(viewModel: ViewOffersNegotationsViewModel?) {
        
        if let unitPrice = viewModel?.list.value?.unitPrice, let seats = viewModel?.list.value?.seats?.count {
            
            let isSellerQuickSell = (userRole == .buyer)
            
            let title = (isSellerQuickSell ?
                LocalizedString("total", story: .negotiation) + " (\(seats) \(seats == 1 ? "Ticket" : "Tickets"))" :
                LocalizedString("original_price", story: .listingdetail))
            
            let textColor: UIColor = isSellerQuickSell ? .fanatickGray_142_142_142 : .fanatickGray_74_74_74
            
            setLabelStyling(label: labelTitle,
                            text: title,
                            textColor: textColor)
            
            let originalPrice = (unitPrice * seats) / 100
            
            setLabelStyling(label: labelPrice,
                            text: String(format: LocalizedString("price_template"),
                                         Float(originalPrice)),
                            textColor: textColor)
        }
    }
}
