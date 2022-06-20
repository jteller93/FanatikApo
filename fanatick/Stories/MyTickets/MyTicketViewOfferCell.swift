//
//  MyTicketViewOfferCell.swift
//  fanatick
//
//  Created by Yashesh on 15/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class MyTicketViewOfferCell: TableViewCell {
    
    let stackView = UIStackView()
    let labelName = Label()
    let labeldetail = Label()
    let buttonViewOffer = Button()
    let labelOfferStatus = Label()
    let imageViewQr = UIImageView()
    let imageViewSize = CGSize.init(width: 14, height: 14)
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(stackView)
        addSubview(buttonViewOffer)
        addSubview(labelOfferStatus)
        addSubview(imageViewQr)
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.addArrangedSubview(labelName)
        stackView.addArrangedSubview(labeldetail)
        
        constrain(stackView, buttonViewOffer, labelOfferStatus, imageViewQr) { (stackView, buttonViewOffer, labelOfferStatus, imageViewQr) in
            
            stackView.leading == stackView.superview!.leading + 13
            stackView.top == stackView.superview!.top + 11
            stackView.bottom == stackView.superview!.bottom - 17
        
            buttonViewOffer.trailing == buttonViewOffer.superview!.trailing - 8
            buttonViewOffer.height == 30
            buttonViewOffer.width == 122
            buttonViewOffer.bottom == labelOfferStatus.top - 7
            
            labelOfferStatus.trailing == buttonViewOffer.trailing
            labelOfferStatus.bottom == stackView.bottom
            
            imageViewQr.height == imageViewSize.height
            imageViewQr.width == imageViewSize.width
            
            imageViewQr.trailing == labelOfferStatus.leading - 5
            imageViewQr.centerY == labelOfferStatus.centerY
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        labelName.font = UIFont.shFont(size: 18, fontType: .helveticaNeue, weight: .bold)
        labelName.textColor = .fanatickYellow
        labeldetail.textColor = .fanatickWhite
        buttonViewOffer.defaultYellowStyling(fontSize: 15, cornerRadius: 15)
        labelOfferStatus.font = UIFont.shFont(size: 11, fontType: .helveticaNeue, weight: .regular)
        labelOfferStatus.textColor = .fanatickWhite
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? MyTicketsViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        switch viewModel.selectedSegment.value {
        case .transactions:
            transactionListing(viewModel: viewModel, indexPath: indexPath)
            break
        case .openNegotiations:
            openNegotiationsListing(viewModel: viewModel, indexPath: indexPath)
            break
        }
    }
    
    
    func addObserverForViewTickets(viewModel: MyTicketsViewModel?, indexPath: IndexPath) {
        
        buttonViewOffer.rx.tap.subscribe(onNext:{ [weak viewModel] _ in
            viewModel?.viewTickets.accept(viewModel?.transactions.value[indexPath.section])
        }).disposed(by: disposeBag)
    }
    
    func addObserverForViewOffers(viewModel: MyTicketsViewModel?, indexPath: IndexPath) {
        
        buttonViewOffer.rx.tap.subscribe(onNext:{ [weak viewModel] _ in
            viewModel?.viewOffers.accept(viewModel?.transactions.value[indexPath.section])
        }).disposed(by: disposeBag)
    }
    
    func addObserverForViewHardcopyTickets (viewModel: MyTicketsViewModel?, indexPath: IndexPath) {
        
        buttonViewOffer.rx.tap.subscribe(onNext:{ [weak viewModel] _ in
            viewModel?.viewHardcopyTickets.accept(viewModel?.transactions.value[indexPath.section])
        }).disposed(by: disposeBag)
    }
    
    func addObserverForOpenNegotiationsViewOffers(viewModel: MyTicketsViewModel?, indexPath: IndexPath) {
        
        buttonViewOffer.rx.tap.subscribe(onNext:{ [weak viewModel] _ in
            viewModel?.openNegotiationsViewOffer.accept(viewModel?.openNegotiations.value.0[indexPath.section].negotiations?[indexPath.row])
        }).disposed(by: disposeBag)
    }
    
    func addObserverForPickupMap(viewModel: MyTicketsViewModel?, indexPath: IndexPath) {
        
        buttonViewOffer.rx.tap.subscribe(onNext: { [weak viewModel] _ in
            if let negotiations = viewModel?.openNegotiations.value.0[indexPath.section], var listing = negotiations.negotiations?[indexPath.row].listing {
                listing.transaction = negotiations.transaction
                viewModel?.pickupMap.accept(listing)
            }
        }).disposed(by: disposeBag)
    }
    
    func transactionListing(viewModel: MyTicketsViewModel?, indexPath: IndexPath) {
        labelOfferStatus.text = ""
        imageViewQr.image = nil
        
        if let negotiations = viewModel?.transactions.value[indexPath.section] {
            
            let buyer = negotiations.buyer
            
            labelName.text = "\(buyer?.firstName ?? "") \(buyer?.lastName ?? "")"
            
            let price = String(format: LocalizedString("price_template"),
                               Float(negotiations.payment?.amount ?? 0) / 100)
            
            var pricePerTicket = ""
            if (negotiations.state == .expired) {
                pricePerTicket = "\(price)/ticket (expired due to non-pickup)"
            } else {
                pricePerTicket = "\(price)/ticket"
            }
            
            let attributedString = NSMutableAttributedString(string: pricePerTicket, attributes: [
                .font: UIFont.shFont(size: 11, fontType: .helveticaNeue, weight: .regular),
                .foregroundColor: UIColor(white: 1.0, alpha: 1.0),
                .kern: 0.0
                ])
            
            attributedString.addAttribute(.font, value: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .bold), range: (pricePerTicket as NSString).range(of: price))
            
            labeldetail.attributedText = attributedString
            
            if viewModel?.role.value == .buyer && viewModel?.selectedSegment.value == .transactions {
                if (negotiations.listing?.deliveryMethod == .hardcopy) {
                    buttonViewOffer.setTitle(LocalizedString("view_purchase", story: .listingdetail), for: UIControl.State.normal)
                    addObserverForViewHardcopyTickets(viewModel: viewModel, indexPath: indexPath)
                } else {
                    buttonViewOffer.setTitle(LocalizedString("view_tickets", story: .myTickets), for: UIControl.State.normal)
                    addObserverForViewTickets(viewModel: viewModel, indexPath: indexPath)
                }
            } else if viewModel?.role.value == .seller && viewModel?.selectedSegment.value == .transactions {
                buttonViewOffer.setTitle(LocalizedString("view_purchase", story: .listingdetail), for: UIControl.State.normal)
                addObserverForViewOffers(viewModel: viewModel, indexPath: indexPath)
            }
            
            if let startAt = negotiations.payment?.updatedAt, let date = Date.init(fromString: startAt, format: .isoDateTimeMilliSec), negotiations.payment?.state == .succeeded {
                labelOfferStatus.text = "\(LocalizedString("completed", story: .myTickets)) \(date.toString(format: DateFormatType.custom("MM/dd - HH:mm a")))"
            }
            
            if negotiations.state == .pickupPending && viewModel?.role.value == .seller{
                imageViewQr.image = UIImage.init(named: "icon_qr")
                labelOfferStatus.text = LocalizedString("pending_pickup", story: .myTickets)
            }
        }
    }
    
    func openNegotiationsListing(viewModel: MyTicketsViewModel?,indexPath: IndexPath) {
        
        buttonViewOffer.isHidden = false
        labelOfferStatus.text = ""
        imageViewQr.image = nil
        
        if let openNegotiations = viewModel?.openNegotiations.value.0[indexPath.section], let negotiations = openNegotiations.negotiations?[indexPath.row] {
            
            let buyer = (viewModel?.role.value ?? .seller) == .buyer ? viewModel?.openNegotiations.value.0[indexPath.section].seller : negotiations.buyer
            
            labelName.text = "\(buyer?.firstName ?? "") \(buyer?.lastName ?? "")"
            
            let price = String(format: LocalizedString("price_template"),
                               Float(negotiations.finalPrice ?? negotiations.offerPrice ?? 0) / 100)
            
            let pricePerTicket = "\(price)/ticket"
            
            let attributedString = NSMutableAttributedString(string: pricePerTicket, attributes: [
                .font: UIFont.shFont(size: 11, fontType: .helveticaNeue, weight: .regular),
                .foregroundColor: UIColor(white: 1.0, alpha: 1.0),
                .kern: 0.0
                ])
            
            attributedString.addAttribute(.font, value: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .bold), range: (pricePerTicket as NSString).range(of: price))
            
            labeldetail.attributedText = attributedString
            buttonViewOffer.setTitle(LocalizedString("view_offer", story: .listingdetail), for: UIControl.State.normal)
            addObserverForOpenNegotiationsViewOffers(viewModel: viewModel, indexPath: indexPath)
        }
    }
}
