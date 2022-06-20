//
//  AskingPriceInputView.swift
//  fanatick
//
//  Created by Yashesh on 17/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import RxCocoa
import RxSwift

class AskingPriceInputView: View {

    let buttonCancel = Button()
    let buttonUpdate = Button()
    let labelTitle = Label()
    let labelDollarSign = Label()
    let labelPrice = Label()
    let labelPerTicket = Label()
    let stackView = UIStackView()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(buttonCancel)
        addSubview(buttonUpdate)
        addSubview(labelTitle)
        addSubview(labelPerTicket)
        addSubview(stackView)
        stackView.addArrangedSubview(labelDollarSign)
        stackView.addArrangedSubview(labelPrice)
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        stackView.axis = .horizontal
        
        constrain(buttonCancel, labelTitle, buttonUpdate) { (buttonCancel, labelTitle, buttonUpdate) in
            
            buttonCancel.leading == buttonCancel.superview!.leading + K.Dimen.smallMargin
            buttonCancel.top == buttonCancel.superview!.top
            buttonCancel.height == K.Dimen.button
            buttonUpdate.trailing == buttonUpdate.superview!.trailing - K.Dimen.smallMargin
            buttonUpdate.top == buttonCancel.top
            buttonUpdate.height == buttonCancel.height
            
            labelTitle.centerX == labelTitle.superview!.centerX
            labelTitle.top == labelTitle.superview!.top + 10
        }
        
        constrain(stackView, labelPerTicket) { (stackView, labelPerTicket) in
            
            stackView.top == stackView.superview!.top + 50
            stackView.height == 86
            stackView.centerX == stackView.superview!.centerX
            
            labelPerTicket.centerX == stackView.centerX
            labelPerTicket.top == stackView.bottom + 10
            labelPerTicket.bottom == labelPerTicket.bottom - 20
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        
        buttonCancel.setTitle(LocalizedString("cancel"), for: UIControl.State.normal)
        buttonCancel.titleLabel?.font = UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium)
        buttonCancel.setTitleColor(.fanatickWhite, for: UIControl.State.normal)
        
        buttonUpdate.setTitle(LocalizedString("update"), for: UIControl.State.normal)
        buttonUpdate.titleLabel?.font = UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium)
        buttonUpdate.setTitleColor(.fanatickWhite, for: UIControl.State.normal)
        buttonUpdate.setTitleColor(.fanatickGray_74_74_74, for: UIControl.State.disabled)
        
        labelTitle.text = LocalizedString("asking_price", story: .listingdetail)
        labelTitle.textColor = .fanatickWhite
        labelTitle.font = UIFont.shFont(size: 24, fontType: .sfProDisplay, weight: .light)
        
        labelPerTicket.text = LocalizedString("per_ticket", story: .listingdetail)
        labelPerTicket.textColor = .fanatickWhite
        labelPerTicket.font = UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .light)
        
        backgroundColor = .fanaticLightGray_66_66_66
        
        labelPrice.font = UIFont.shFont(size: 72, fontType: .sfProDisplay, weight: .ultralight)
        labelPrice.textColor = .fanatickWhite
        
        labelDollarSign.text = "$"
        labelDollarSign.font = UIFont.shFont(size: 48, fontType: .sfProDisplay, weight: .ultralight)
        labelDollarSign.textColor = .fanatickWhite
    }
    
    func load<VM>(viewModel: VM?) where VM : ListingDetailsViewModel {
        if let viewModel = viewModel {
            viewModel.priceText.subscribe(onNext: { [weak self] text in
                self?.labelPrice.text = text
            }).disposed(by: disposeBag)
            
            viewModel.priceText.map { (text) -> Bool in
                return text.isNotEmpty() && Int(text) ?? 0 > 0
                }.bind(to: viewModel.isValid).disposed(by: disposeBag)
            
            viewModel.isValid.subscribe(onNext:{ [weak self] enable in
                self?.buttonUpdate.isEnabled = enable
            }).disposed(by: disposeBag)
            
        }
    }
    
    func load<VM>(viewModel: VM?) where VM : ViewOffersNegotationsViewModel {
        if let viewModel = viewModel {
            viewModel.priceText.subscribe(onNext: { [weak self] text in
                self?.labelPrice.text = text
            }).disposed(by: disposeBag)
            
            viewModel.priceText.map { (text) -> Bool in
                return text.isNotEmpty() && Int(text) ?? 0 > 0
                }.bind(to: viewModel.isValid).disposed(by: disposeBag)
            
            viewModel.isValid.subscribe(onNext:{ [weak self] enable in
                self?.buttonUpdate.isEnabled = enable
            }).disposed(by: disposeBag)
        }
    }
}
