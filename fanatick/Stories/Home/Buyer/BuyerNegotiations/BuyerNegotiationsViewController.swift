//
//  BuyerNegotiationsViewController.swift
//  fanatick
//
//  Created by Yashesh on 23/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Cartography
import Stripe

class BuyerNegotiationsViewController: TableViewController {
    
    let viewModel = ViewOffersNegotationsViewModel()
    let header = ViewOfferHeaderCell()
    let stackViewForActionButtons = UIStackView()
    let buttonBuyNow = Button()
    let buttonMakeOffer = Button()
    
    let textFieldPrice = TextField()
    let viewForAskingPrice = AskingPriceInputView()
    var stripePaymentAddCard: STPAddCard?

    override func setupSubviews() {
        super.setupSubviews()
        hasCloseButton = true
        ViewOfferHeaderCell.registerCell(tableView: tableView)
        ViewOfferNagotiationsCell.registerCell(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = header
        tableView.tableFooterView = UIView.init(frame: .zero)
        header.setNeedsLayout()
        header.layoutIfNeeded()
        navigationController?.navigationBar.isTranslucent = true
        
        view.addSubview(stackViewForActionButtons)
        stackViewForActionButtons.addArrangedSubview(buttonBuyNow)
        stackViewForActionButtons.addArrangedSubview(buttonMakeOffer)
        stackViewForActionButtons.spacing = 9
        stackViewForActionButtons.axis = .horizontal
        stackViewForActionButtons.distribution = .fillEqually
        view.addSubview(textFieldPrice)
        
        constrain(tableView) { (tableView) in
            tableView.top == tableView.superview!.top
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.bottom == tableView.superview!.safeAreaLayoutGuide.bottom
        }
        
        constrain(stackViewForActionButtons) { (stackViewForActionButtons) in
            stackViewForActionButtons.leading == stackViewForActionButtons.superview!.leading + K.Dimen.smallMargin
            stackViewForActionButtons.trailing == stackViewForActionButtons.superview!.trailing - K.Dimen.smallMargin
            stackViewForActionButtons.bottom == stackViewForActionButtons.superview!.safeAreaLayoutGuide.bottom - 30
            stackViewForActionButtons.height == K.Dimen.button
        }
        
        // assign self to open STPAddCardViewController click on buy now.
        stripePaymentAddCard = STPAddCard.init(vc: self)
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        if let listing = viewModel.list.value {
            header.setSingleListData(listing: listing)
        }
        
        stackViewForActionButtons.isHidden = true
        
        viewForAskingPrice.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 185)
        textFieldPrice.inputAccessoryView = viewForAskingPrice
        textFieldPrice.keyboardType = .numberPad
        textFieldPrice.keyboardAppearance = .dark
        
        viewForAskingPrice.load(viewModel: viewModel)
        viewForAskingPrice.buttonUpdate.setTitle(LocalizedString("submit", story: .listingdetail), for: UIControl.State.normal)
        
        buttonMakeOffer.defaultWhiteStyling(fontSize: 16,
                                            cornerRadius: K.Dimen.button / 2,
                                            borderColor: .fanatickGray_151_151_151, cornersMask: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        
        buttonMakeOffer.isHidden = viewModel.list.value?.quickBuy ?? false
    }
    
    override func addObservables() {
        super.addObservables()
        
        viewModel.negotiationsChanged.subscribe(onNext:{ [weak self] changed in
            guard let self = self else { return }
            if changed { self.dismissButtonTapped() }
        }).disposed(by: disposeBag)

        
        if viewModel.list.value?.status ?? .unsold == .sold {
            if viewModel.list.value?.transaction?.state ?? .exception == .pickupPending {
                openDigitalOrHardcopyPickup(transaction: viewModel.list.value?.transaction)
            }
            return
        }
        
        if viewModel.list.value?.quickBuy ?? false == false {

            viewModel.listingID.map { [weak viewModel] (_) -> String in
                return viewModel?.list.value?.id ?? ""
                }.bind(to: viewModel.negotiations).disposed(by: disposeBag)
            
            viewModel.selectedNegotiation.subscribe(onNext:{ [weak self] negotiation in
                guard let negotiationid = negotiation?.id else { return }
                self?.viewModel.negotiationsEvent.accept(negotiationid)
            }).disposed(by: disposeBag)
            
            viewModel.negotiationsID.subscribe(onNext:{ [weak self] negotiationID in
                let negotiationsID = self?.viewModel.selectedNegotiation.value?.id ?? negotiationID ?? ""
                if negotiationsID.isNotEmpty() {
                    self?.viewModel.negotiationsEvent.accept(negotiationsID)
                }
            }).disposed(by: disposeBag)
            
            viewModel.events.subscribe(onNext: { [weak self] events in
                self?.setupAcceptCounterAndDeclineButtons()
            }).disposed(by: disposeBag)
            
            
            buttonMakeOffer.rx.tap.subscribe(onNext:{ [weak self] _ in
                self?.askingPriceOrCounterNegotaition(counter: true)
            }).disposed(by: disposeBag)
            
            textFieldPrice.rx.text.orEmpty.map { [weak self] _ -> String in
                return self?.textFieldPrice.text ?? ""
                }.bind(to: viewModel.priceText).disposed(by: disposeBag)
            
            viewForAskingPrice.buttonCancel.rx.tap.subscribe(onNext:{ [weak self] _ in
                self?.dismissKeyboard()
            }).disposed(by: disposeBag)
            
            viewForAskingPrice.buttonUpdate.rx.tap.subscribe(onNext:{ [weak self] _ in
                if let negotiationID = self?.viewModel.selectedNegotiation.value?.id, let price = self?.viewModel.priceText.value {
                    let updatePriceModel = NegotiationPrice.init(price: Int(price)! * 100)
                    self?.viewModel.changePriceAction.accept((negotiationID, updatePriceModel))
                } else if let price = self?.viewModel.priceText.value, let listingID = self?.viewModel.list.value?.id, let userID = FirebaseSession.shared.user.value?.id {
                    let startNegotiation = StartNegotiation.init(listingId: listingID, offerPrice: Int(price)! * 100, userId: userID)
                    self?.viewModel.createNegotiation.accept(startNegotiation)
                }
                self?.dismissKeyboard()
            }).disposed(by: disposeBag)
            
            viewModel.negotiationResult.subscribe(onNext:{ [weak self] negotiationAccepted in
                if negotiationAccepted {
                    self?.openBuyerConfirmation()
                } else {
                    self?.dismissButtonTapped()
                }
            }).disposed(by: disposeBag)
        } else {
            setupBuyNowButtonForQuickSell()
        }
        
        buttonBuyNow.rx.tap.subscribe(onNext: { [weak self] _ in
            if self?.viewModel.events.value.first?.type == .offer {
                self?.dismissButtonTapped()
            } else {
                if !(FirebaseSession.shared.user.value?.membership?.proSubscriptionActive ?? false) {
                    self?.showAlertForNoProMember()
                } else {
                    if let stripePayment = self?.stripePaymentAddCard {
                        stripePayment.handleAddPaymentOptionButtonTapped()
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        viewModel.completedTransaction.subscribe(onNext: { [weak self] transaction in
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
        
        stripePaymentAddCard?.stripeToken.subscribe(onNext: { [weak viewModel] tokenId in
            guard let token = tokenId else { return }
            
            if (viewModel?.selectedNegotiation.value?.listing?.quickBuy ?? true) {
                viewModel?.buyNowTickets.accept(token)
            } else {
                viewModel?.buyNowTicketsOffers.accept(token)
            }
        }).disposed(by: disposeBag)
        
        PushWooshObserver.shared.notificationReceiver.subscribe(onNext: { [weak self] notify in
            if notify == true {
                self?.pushNotificationObserver()
            }
        }).disposed(by: disposeBag)
        
        viewModel.transactionCanceled.subscribe(onNext: { [weak self] success in
            if success == true {
                self?.dismissButtonTapped()
            }
        }).disposed(by: disposeBag)
        
        viewModel.errorMessage.subscribe(onNext: { [weak self] errorMessage in
            guard let errorMessage = errorMessage else { return }
            self?.showMessage(title: "", message: errorMessage ?? "")
        }).disposed(by: disposeBag)
    }
    
    func pushNotificationObserver() {
        
        if viewModel.list.value?.status ?? .unsold == .sold {
            if viewModel.list.value?.transaction?.state ?? .exception == .pickupPending {
                openDigitalOrHardcopyPickup(transaction: viewModel.list.value?.transaction)
            }
            return
        }
        
        if viewModel.list.value?.quickBuy ?? false == false {
            
            viewModel.listingID.map { [weak viewModel] (_) -> String in
                return viewModel?.list.value?.id ?? ""
                }.bind(to: viewModel.negotiations).disposed(by: disposeBag)
        }        
    }
    
    fileprivate func askingPriceOrCounterNegotaition(counter: Bool) {
        
        if let askingPrice = viewModel.events.value.first?.amount {
            textFieldPrice.text = counter ? "" : "\(askingPrice / 100)"
        } else {
            textFieldPrice.text = ""
        }
        
        textFieldPrice.becomeFirstResponder()
    }
    
    fileprivate func setupAcceptCounterAndDeclineButtons() {
        
        setupActionButtons()
        
        var title = ""
        
        if let lastEvent = viewModel.events.value.first, let type = lastEvent.type {
            
            switch type {
            case .ask:
                setupBuyNowButtonForQuickSell()
                title = LocalizedString("make_an_offer", story: .listingdetail)
                break
            case .offer:
                buttonBuyNow.defaultWhiteStyling(fontSize: 16,
                                                  cornerRadius: K.Dimen.button / 2,
                                                  borderColor: nil,
                                                  cornersMask: [.layerMinXMinYCorner, .layerMinXMaxYCorner])
                buttonBuyNow.setTitle(LocalizedString("cancel_offer", story: .listingdetail), for: UIControl.State.normal)
                title = LocalizedString("change_offer", story: .listingdetail)
                break
            case .exception:
                break
            case .decline:
                stackViewForActionButtons.isHidden = true
                break
            case .accept:
                openBuyerConfirmation()
                return
            }
        } else {
            title = LocalizedString("make_an_offer", story: .listingdetail)
            
            buttonBuyNow.defaultYellowStyling(fontSize: 16,
                                              cornerRadius: K.Dimen.button / 2,
                                              borderColor: nil,
                                              cornersMask: buttonMakeOffer.isHidden == true ? nil : [.layerMinXMinYCorner, .layerMinXMaxYCorner])
            buttonBuyNow.setTitle(LocalizedString("buy_now", story: .listingdetail), for: UIControl.State.normal)
        }
        
        buttonMakeOffer.setTitle(title,
                                 for: UIControl.State.normal)
        buttonMakeOffer.defaultWhiteStyling(fontSize: 16,
                                            cornerRadius: K.Dimen.button / 2,
                                            borderColor: nil,
                                            cornersMask: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        tableView.reloadData()
        
    }
    
    fileprivate func setupActionButtons() {
        if let status = viewModel.list.value?.status {
            stackViewForActionButtons.isHidden = status == .sold
        }
    }
    
    fileprivate func negotiationAction(accept: Bool) {
        viewModel.isAccept.accept(accept)
        viewModel.negotationAction.accept(viewModel.selectedNegotiation.value?.id ?? "")
    }
    
    fileprivate func openBuyerConfirmation() {
        let selectedNegotiation = viewModel.selectedNegotiation.value
        let lastDate = Date.init(fromString: selectedNegotiation?.updatedAt ?? "", format: .isoDateTimeMilliSec) ?? Date()
        
        if selectedNegotiation?.transaction?.state ?? .exception == .pickupPending {
            openDigitalOrHardcopyPickup()
        } else if viewModel.events.value.first?.userID == viewModel.selectedNegotiation.value?.buyer?.userId {
            // do nothing if buyer accepted offer
        } else if Date().timeIntervalSince(lastDate) < K.maxPaidTime  {
            let viewController = BuyerNegotiationConfirmationViewController()
            viewController.viewModel = viewModel
            let navigationViewController = NavigationController(rootViewController: viewController)
            self.navigationController?.present(navigationViewController, animated: true, completion: nil)
        } else {
            let viewController = BuyerNegotiationExpiredViewController()
            let navigationViewController = NavigationController(rootViewController: viewController)
            self.navigationController?.present(navigationViewController, animated: true, completion: nil)
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

    
    fileprivate func setupBuyNowButtonForQuickSell() {
        tableView.reloadData()
        stackViewForActionButtons.isHidden = false
        buttonBuyNow.defaultYellowStyling(fontSize: 16,
                                          cornerRadius: K.Dimen.button / 2,
                                          borderColor: nil,
                                          cornersMask: buttonMakeOffer.isHidden == true ? nil : [.layerMinXMinYCorner, .layerMinXMaxYCorner])
        buttonBuyNow.setTitle(LocalizedString("buy_now", story: .listingdetail), for: UIControl.State.normal)
        
    }
    
    fileprivate func openDigitalOrHardcopyPickup(transaction: Transaction?) {
        guard let _ = transaction, var listing = viewModel.list.value else {
            return
        }
        
        listing.transaction = transaction
        
        if let deliveryMethod = listing.deliveryMethod {
            switch deliveryMethod{
            case .digital:
                let viewController = GetDigitalTicketsViewController()
                viewController.viewModel.listing.accept(listing)
                let controller = NavigationController(rootViewController: viewController)
                self.navigationController?.present(controller,
                                                   animated: true,
                                                   completion: nil)
                break
            case .hardcopy:
                let viewController = GetHardCopyTicketsViewController()
                viewController.viewModel.listing.accept(listing)
                let controller = NavigationController(rootViewController: viewController)
                self.navigationController?.present(controller,
                                                   animated: true,
                                                   completion: nil)
                break
            }
        }
    }
}

extension BuyerNegotiationsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = ViewOfferNagotiationsCell.dequeueCell(tableView: tableView) as? ViewOfferNagotiationsCell {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getStatusCellHeight()
    }
    
    fileprivate func getStatusCellHeight() -> CGFloat {
        
        let tableViewHeight = tableView.frame.size.height
        // Calculat Height of row at section and row 0
        let firstCellHeight = header.frame.size.height
        return tableViewHeight - firstCellHeight
    }
}

extension BuyerNegotiationsViewController: SavingViewControllerDelegate {
    func viewControllerDidComplete(_ viewController: SavingViewController, transaction: Transaction?) {
        viewController.dismiss(animated: true) {
           self.openDigitalOrHardcopyPickup(transaction: transaction)
        }
    }
}
