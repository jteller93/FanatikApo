//
//  BuyerCell.swift
//  fanatick
//
//  Created by Yashesh on 10/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class ListingBuyerCell: TableViewCell {

    let stackView = UIStackView()
    let labelName = Label()
    let labeldetail = Label()
    let buttonViewOffer = Button()
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(stackView)
        addSubview(buttonViewOffer)
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.addArrangedSubview(labelName)
        stackView.addArrangedSubview(labeldetail)
        
        constrain(stackView, buttonViewOffer) { (stackView, buttonViewOffer) in
            
            stackView.leading == stackView.superview!.leading + 13
            stackView.top == stackView.superview!.top + 13
            stackView.bottom == stackView.superview!.bottom - 17.5
            
            buttonViewOffer.trailing == buttonViewOffer.superview!.trailing - 8
            buttonViewOffer.height == 30
            buttonViewOffer.width == 122
            buttonViewOffer.centerY == stackView.centerY
        }
    }

    override func applyStylings() {
        super.applyStylings()
        
        labelName.font = UIFont.shFont(size: 18, fontType: .helveticaNeue, weight: .bold)
        labelName.textColor = .fanatickYellow
        labeldetail.textColor = .fanatickWhite
        buttonViewOffer.defaultYellowStyling(fontSize: 15, cornerRadius: 15)
        buttonViewOffer.setTitle(LocalizedString("view_offer", story: .listingdetail), for: UIControl.State.normal)
        
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? ListingDetailsViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        addObserver(viewModel: viewModel)
        
        let negotiations = viewModel.negotiations.value[indexPath.row]
        let buyer = negotiations.buyer
        labelName.text = "\(buyer?.firstName ?? "") \(buyer?.lastName ?? "")"
        let price = String(format: LocalizedString("price_template"),
                           Float(negotiations.offerPrice ?? 0) / 100)
        
        var pricePerTicket = ""
        if (negotiations.transaction?.state == .expired) {
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

    }
    
    
    func addObserver(viewModel: ListingDetailsViewModel) {
        
        buttonViewOffer.rx.tap.subscribe(onNext:{ [weak self] _ in
            viewModel.selectedViewOffer.accept(self?.indexPath)
        }).disposed(by: disposeBag)
    }
}
