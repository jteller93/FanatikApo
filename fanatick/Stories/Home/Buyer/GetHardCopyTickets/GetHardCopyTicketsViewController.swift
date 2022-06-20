//
//  GetHardCopyTicketsViewController.swift
//  fanatick
//
//  Created by Yashesh on 01/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography

class GetHardCopyTicketsViewController: ViewController {
    
    let stackView = UIStackView()
    let labelTitle = Label()
    let labelDescription = Label()
    let buttonViewSellerLocation = Button()
    let viewScreenShotFirst = View()
    let viewScreenShotSecond = View()
    let viewModel = GetHardCopyViewModel()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        stackView.axis = .vertical
        stackView.spacing = 15
        view.addSubview(stackView)
        stackView.addArrangedSubview(labelTitle)
        stackView.addArrangedSubview(labelDescription)
        view.addSubview(buttonViewSellerLocation)
        
        constrain(stackView, buttonViewSellerLocation) { (stackView, buttonViewSellerLocation) in
            stackView.leading == stackView.superview!.leading + 34
            stackView.trailing == stackView.superview!.trailing - 34
            stackView.top == stackView.superview!.safeAreaLayoutGuide.top + 30
            
            buttonViewSellerLocation.leading == buttonViewSellerLocation.superview!.leading + 16
            buttonViewSellerLocation.trailing == buttonViewSellerLocation.superview!.trailing - 16
            buttonViewSellerLocation.height == K.Dimen.button
            buttonViewSellerLocation.bottom == buttonViewSellerLocation.superview!.safeAreaLayoutGuide.bottom - 30
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        hasCloseButton = true
        
        labelTitle.text = LocalizedString("you_have_1_hour_to_pick_up_your_tickets", story: .general)
        labelDescription.text = LocalizedString("Tap_the_button_below_to_view_your_seller’s_location_Dont_forget_to_show_your_QR_code_to_the_seller_to_confirm_pickup", story: .general)
        
        labelTitle.textColor = .fanatickWhite
        labelTitle.font = UIFont.shFont(size: 16.0, fontType: .helveticaNeue, weight: .bold)
        
        labelDescription.textColor = .fanatickWhite
        labelDescription.font = UIFont.shFont(size: 16.0, fontType: .helveticaNeue, weight: .regular)
        
        labelTitle.numberOfLines = 0
        labelDescription.numberOfLines = 0
        
        labelTitle.textAlignment = .center
        labelDescription.textAlignment = .center
        
        buttonViewSellerLocation.defaultYellowStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2)
        buttonViewSellerLocation.setTitle(LocalizedString("view_seller_location", story: .general), for: .normal)
    }

    override func addObservables() {
        super.addObservables()
        
        buttonViewSellerLocation.rx.tap.subscribe(onNext:{ [weak self] _ in
            let viewController = SellerLocationViewController()
            viewController.viewModel.listing.accept(self?.viewModel.listing.value)
            let controller = NavigationController(rootViewController: viewController)
            self?.navigationController?.present(controller, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    override func dismissButtonTapped() {
        if viewModel.transactions.value?.rating == nil {
            let viewController = RateSellerViewController()
            viewController.viewModel.listing.accept(self.viewModel.listing.value)
            let controller = NavigationController(rootViewController: viewController)
            navigationController?.present(controller, animated: true, completion: nil)
        } else {
            super.dismissButtonTapped()
        }
    }
}
