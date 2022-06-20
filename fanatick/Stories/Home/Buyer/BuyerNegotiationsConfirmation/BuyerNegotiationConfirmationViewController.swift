//
//  BuyerNegotiationConfirmationViewController.swift
//  fanatick
//
//  Created by Yashesh on 22/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import Stripe

class BuyerNegotiationConfirmationViewController: ViewController {

    var viewModel = ViewOffersNegotationsViewModel()
    let imageView = UIImageView()
    let labelDescription = Label()
    let labelDescriptionForQrCode = Label()
    let stackView = UIStackView()
    
    let buttonCancel = Button()
    let buttonContinue = Button()
    let stackViewForButton = UIStackView()
    var stripePaymentAddCard: STPAddCard?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(imageView)
        view.addSubview(stackView)
        stackView.addArrangedSubview(labelDescription)
        stackView.addArrangedSubview(labelDescriptionForQrCode)
        
        stackView.axis = .vertical
        stackView.spacing = 25
        
        view.addSubview(stackViewForButton)
        stackViewForButton.axis = .horizontal
        stackViewForButton.spacing = 9
        stackViewForButton.distribution = .fillEqually
        stackViewForButton.addArrangedSubview(buttonCancel)
        stackViewForButton.addArrangedSubview(buttonContinue)
        
        constrain(imageView, stackView) { (imageView, stackView) in
            imageView.height == 98
            imageView.width == 74
            imageView.centerX == imageView.superview!.centerX
            imageView.bottom == imageView.superview!.centerY - 86.4
            
            stackView.top == stackView.superview!.centerY - 42
            stackView.leading == stackView.superview!.leading + 42
            stackView.trailing == stackView.superview!.trailing - 42
        }
        
        constrain(stackViewForButton) { (stackViewForButton) in
            (stackViewForButton).leading == (stackViewForButton).superview!.leading + K.Dimen.smallMargin
            (stackViewForButton).trailing == (stackViewForButton).superview!.trailing - K.Dimen.smallMargin
            (stackViewForButton).height == K.Dimen.button
            (stackViewForButton).bottom == (stackViewForButton).superview!.safeAreaLayoutGuide.bottom - K.Dimen.largeMargin
        }
        
        // assign self to open STPAddCardViewController click on buy now.
        stripePaymentAddCard = STPAddCard.init(vc: self)
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        labelDescription.numberOfLines = 0
        labelDescription.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        labelDescription.textColor = .fanatickWhite
        labelDescription.textAlignment = .center
        labelDescriptionForQrCode.numberOfLines = 0
        labelDescriptionForQrCode.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        labelDescriptionForQrCode.textColor = .fanatickWhite
        labelDescriptionForQrCode.textAlignment = .center
        
        buttonCancel.setTitle(LocalizedString("cancel"), for: UIControl.State.normal)
        buttonContinue.setTitle(LocalizedString("continue"), for: UIControl.State.normal)
        
        buttonCancel.defaultWhiteStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2, borderColor: nil, cornersMask: [.layerMinXMinYCorner, .layerMinXMaxYCorner])
        
        buttonContinue.defaultYellowStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2, borderColor: nil, cornersMask: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        
        setupConfirmationMessage()
    }
    
    override func addObservables() {
        super.addObservables()
        
        buttonCancel.rx.tap.subscribe(onNext:{ [weak self] _ in
            self?.presentingViewController?
                .presentingViewController?
                .dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        buttonContinue.rx.tap.subscribe({ [weak self] _ in
            let selectedNegotiation = self?.viewModel.selectedNegotiation.value
            let lastDate = Date.init(fromString: selectedNegotiation?.updatedAt ?? "", format: .isoDateTimeMilliSec) ?? Date()
            
            if Date().timeIntervalSince(lastDate) < K.maxPaidTime  {
                if !(FirebaseSession.shared.user.value?.membership?.proSubscriptionActive ?? false) {
                    self?.showAlertForNoProMember()
                } else {
                    if let stripePayment = self?.stripePaymentAddCard {
                        stripePayment.handleAddPaymentOptionButtonTapped()
                    }
                }
            } else {
                let viewController = BuyerNegotiationExpiredViewController()
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }).disposed(by: disposeBag)
        
        stripePaymentAddCard?.stripeToken.subscribe(onNext: { [weak viewModel] tokenId in
            guard let token = tokenId else { return }
            
            viewModel?.buyNowTicketsOffers.accept(token)
        }).disposed(by: disposeBag)

        viewModel.completedTransaction.subscribe(onNext:{ [weak self] transaction in
            guard let transaction = transaction else { return }
            let viewController = SavingViewController()
            viewController.transaction = transaction
            viewController.quantity = self?.viewModel.list.value?.quantity
            viewController.delegate = self
            let controller = NavigationController(rootViewController: viewController)
            self?.navigationController?.present(controller,
                                               animated: true,
                                               completion: nil)
        }).disposed(by: disposeBag)
    }
    
    fileprivate func setupConfirmationMessage() {
        
        if let listing = viewModel.list.value, let negotiations = viewModel.selectedNegotiation.value {

            let seller = listing.seller
            let sellerName = "\(seller?.firstName ?? "") \(seller?.lastName ?? "") "
            let fees = String(format: LocalizedString("price_template"),
                   Float(negotiations.finalPrice ?? 0) / 100)

            labelDescription.text = sellerName + LocalizedString("accept_your_offer_of", story: .negotiation) + fees + "!\n" + LocalizedString("you_have_15_minutes_to_complete_payment_for_your_tickets", story: .listingdetail)
            
            imageView.contentMode = .scaleAspectFill
            
            if listing.deliveryMethod == .digital {
                imageView.image = UIImage.init(named: "icon_digital_ticket")
                labelDescriptionForQrCode.text = LocalizedString("once_payment_is_complete_you_will_receive_a_digital_copy_of_the_tickets", story: .listingdetail)
                
            } else {
                imageView.image = UIImage.init(named: "icon_hardcopy_ticket")
                labelDescriptionForQrCode.text = LocalizedString("once_payment_is_complete_you_will_be_shown_a_map_of_the_sellers_location", story: .listingdetail)
            }
        }
    }
    
    fileprivate func openDigitalOrHardcopyPickup() {
        
        guard let list = viewModel.list.value else {
            return
        }
        
        if let deliveryMethod = list.deliveryMethod {
            switch deliveryMethod{
            case .digital:
                let viewController = GetDigitalTicketsViewController()
                viewController.viewModel.listing.accept(viewModel.list.value)
                let controller = NavigationController(rootViewController: viewController)
                self.navigationController?.present(controller,
                                                   animated: true,
                                                   completion: nil)
                break
            case .hardcopy:
                let viewController = GetHardCopyTicketsViewController()
                viewController.viewModel.listing.accept(viewModel.list.value)
                let controller = NavigationController(rootViewController: viewController)
                self.navigationController?.present(controller,
                                                   animated: true,
                                                   completion: nil)
                break
            }
        }
    }
}

extension BuyerNegotiationConfirmationViewController: SavingViewControllerDelegate {
    func viewControllerDidComplete(_ viewController: SavingViewController, transaction: Transaction?) {
        viewController.dismiss(animated: true) {
            self.openDigitalOrHardcopyPickup()
        }
    }
}
