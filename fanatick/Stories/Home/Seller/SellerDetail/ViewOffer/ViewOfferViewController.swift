//
//  ViewOfferViewController.swift
//  fanatick
//
//  Created by Yashesh on 13/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Cartography

class ViewOfferViewController: TableViewController {

    let viewModel = ViewOffersNegotationsViewModel()
    let header = ViewOfferHeaderCell()
    let stackViewForActionButtons = UIStackView()
    let buttonAccept = Button()
    let buttonCounter = Button()
    let buttonDecline = Button()
    let textFieldPrice = TextField()
    let viewForAskingPrice = AskingPriceInputView()
    let buttonGotoPayment = Button()
    
    override func setupSubviews() {
        super.setupSubviews()
        hasCloseButton = true
        navigationController?.navigationBar.isTranslucent = true
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
        
        view.addSubview(stackViewForActionButtons)
        stackViewForActionButtons.addArrangedSubview(buttonAccept)
        stackViewForActionButtons.addArrangedSubview(buttonCounter)
        stackViewForActionButtons.addArrangedSubview(buttonDecline)
        stackViewForActionButtons.spacing = 9
        stackViewForActionButtons.axis = .horizontal
        stackViewForActionButtons.distribution = .fillEqually
        view.addSubview(textFieldPrice)
        view.addSubview(buttonGotoPayment)
        
        constrain(tableView) { (tableView) in
            tableView.top == tableView.superview!.top
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.bottom == tableView.superview!.safeAreaLayoutGuide.bottom
        }
        
        constrain(stackViewForActionButtons, buttonGotoPayment) { (stackViewForActionButtons, buttonGotoPayment) in
            stackViewForActionButtons.leading == stackViewForActionButtons.superview!.leading + K.Dimen.smallMargin
            stackViewForActionButtons.trailing == stackViewForActionButtons.superview!.trailing - K.Dimen.smallMargin
            stackViewForActionButtons.bottom == stackViewForActionButtons.superview!.safeAreaLayoutGuide.bottom - 30
            stackViewForActionButtons.height == K.Dimen.button
            buttonGotoPayment.edges == stackViewForActionButtons.edges
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        if let listing = viewModel.list.value {
            header.setSingleListData(listing: listing)
        }
        
        buttonAccept.defaultYellowStyling(fontSize: 16,
                                          cornerRadius: K.Dimen.button / 2,
                                          borderColor: nil,
                                          cornersMask: [.layerMinXMinYCorner, .layerMinXMaxYCorner])
        
        buttonCounter.defaultWhiteStyling(fontSize: 16,
                                          borderColor: .fanatickGray_151_151_151)
        
        buttonDecline.defaultWhiteStyling(fontSize: 16,
                                          cornerRadius: K.Dimen.button / 2,
                                          borderColor: .fanatickGray_151_151_151,
                                          cornersMask: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        
        stackViewForActionButtons.isHidden = true
        
        viewForAskingPrice.frame = CGRect(x: 0,
                                          y: 0,
                                          width: view.frame.size.width,
                                          height: 185)
        textFieldPrice.inputAccessoryView = viewForAskingPrice
        textFieldPrice.keyboardType = .numberPad
        textFieldPrice.keyboardAppearance = .dark

        viewForAskingPrice.load(viewModel: viewModel)
        viewForAskingPrice.buttonUpdate.setTitle(LocalizedString("submit", story: .listingdetail), for: UIControl.State.normal)
        
        buttonGotoPayment.defaultYellowStyling(fontSize: 16,
                                               cornerRadius: K.Dimen.button / 2,
                                               borderColor: nil)
        buttonGotoPayment.setTitle(LocalizedString("go_to_payment", story: .listingdetail), for: UIControl.State.normal)
        buttonGotoPayment.isHidden = true
    }
    
    override func addObservables() {
        super.addObservables()

        viewModel.negotiationsChanged.subscribe(onNext:{ [weak self] changed in
            guard let self = self else { return }
            if changed { self.backButtonTapped() }
        }).disposed(by: disposeBag)

        viewModel.negotiationsID.map { [weak self] (_) -> String in
            return self?.viewModel.selectedNegotiation.value?.id ?? ""
        }.bind(to: viewModel.negotiationsEvent).disposed(by: disposeBag)
        
        viewModel.events.subscribe(onNext: { [weak self] _ in
            self?.setupAcceptCounterAndDeclineButtons()
        }).disposed(by: disposeBag)
    
        
        buttonCounter.rx.tap.subscribe(onNext:{ [weak self] _ in
            self?.askingPriceOrCounterNegotaition(counter: true)
        }).disposed(by: disposeBag)
        
        buttonAccept.rx.tap.subscribe(onNext: { [weak self] _ in
            if self?.buttonCounter.isHidden ?? false {
                self?.askingPriceOrCounterNegotaition(counter: false)
            } else {
                self?.negotiationAction(accept: true)
            }
        }).disposed(by: disposeBag)
        
        buttonDecline.rx.tap.subscribe(onNext:{ [weak self] _ in
            self?.negotiationAction(accept: false)
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
            }
            self?.dismissKeyboard()
        }).disposed(by: disposeBag)

        viewModel.negotiationResult.subscribe(onNext:{ [weak self] negotiationAccepted in
            if negotiationAccepted {
                let viewController = SellerConfirmationViewController()
                if let viewModel = self?.viewModel {
                    viewController.viewModel = viewModel
                }
                let navigationViewController = NavigationController(rootViewController: viewController)
                self?.navigationController?.present(navigationViewController, animated: true, completion: nil)
            } else {
                self?.dismissButtonTapped()
            }
        }).disposed(by: disposeBag)
        
        PushWooshObserver.shared.notificationReceiver.subscribe(onNext: { [weak self] notify in
            if notify == true {
                self?.updateNegotiation()
            }
        }).disposed(by: disposeBag)
    }
    
    func updateNegotiation() {
        viewModel.negotiationsID.map { [weak self] (_) -> String in
            return self?.viewModel.selectedNegotiation.value?.id ?? ""
            }.bind(to: viewModel.negotiationsEvent).disposed(by: disposeBag)
    }
    
    fileprivate func askingPriceOrCounterNegotaition(counter: Bool) {
        
        if let askingPrice = viewModel.events.value.first?.amount {
            textFieldPrice.text = counter ? "" : "\(askingPrice / 100)"
        } else {
            textFieldPrice.text = "0"
        }
        
        textFieldPrice.becomeFirstResponder()
    }
    
    fileprivate func setupAcceptCounterAndDeclineButtons() {
        
        
        if let lastEvent = viewModel.events.value.first, let type = lastEvent.type {
            
            var title = ""
            
            switch type {
            case .ask:
                title = LocalizedString("change_price", story: .listingdetail)
                buttonAccept.isDisabled = false
                buttonDecline.isDisabled = false
                buttonCounter.isHidden = true
                break
            case .offer:
                title = LocalizedString("accept", story: .listingdetail)
                buttonAccept.isDisabled = false
                buttonDecline.isDisabled = false
                buttonCounter.isHidden = false
                break
            case .exception:
                break
            case .decline:
                title = LocalizedString("accept", story: .listingdetail)
                buttonAccept.isDisabled = true
                buttonDecline.isDisabled = true
                buttonCounter.isHidden = false
                break
            case .accept:
                buttonGotoPayment.isHidden = false
                break
            }
            
            buttonAccept.setTitle(title,
                                  for: UIControl.State.normal)
            
            buttonCounter.setTitle(LocalizedString("counter", story: .listingdetail),
                                   for: UIControl.State.normal)
            
            buttonDecline.setTitle(LocalizedString("decline", story: .listingdetail),
                                   for: UIControl.State.normal)
//            if let quickBuy = viewModel.list.value?.quickBuy {
//                buttonCounter.isHidden = quickBuy
//            }
            stackViewForActionButtons.isHidden = false
        }
    }
    
    fileprivate func negotiationAction(accept: Bool) {
        viewModel.isAccept.accept(accept)
        viewModel.negotationAction.accept(viewModel.selectedNegotiation.value?.id ?? "")
    }
}

extension ViewOfferViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavigationBar = true
    }
}

extension ViewOfferViewController: UITableViewDataSource {
    
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

