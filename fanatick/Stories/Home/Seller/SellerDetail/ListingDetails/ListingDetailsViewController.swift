//
//  SellerDetailsViewController.swift
//  fanatick
//
//  Created by Yashesh on 10/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class ListingDetailsViewController: TableViewController {
    
    let viewModel = ListingDetailsViewModel()
    let stackView = UIStackView()
    let buttonChangePrice = Button()
    let buttonMarkAsSold = Button()
    let viewForAskingPrice = AskingPriceInputView()
    let textFieldPrice = TextField()
    var listingStatus: ListingStatus!
    
    override func setupSubviews() {
        super.setupSubviews()
        hasYellowNavigation = true
        
        ListingBuyerCell.registerCell(tableView: tableView)
        ListingHeaderCell.registerCell(tableView: tableView)
        MessageCell.registerCell(tableView: tableView)

        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(buttonChangePrice)
        stackView.addArrangedSubview(buttonMarkAsSold)
        stackView.spacing = 9
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        view.addSubview(textFieldPrice)
        
        constrain(tableView, customNavigationBar, stackView) { tableView, customNavigationBar, stackView in
            
            tableView.top == customNavigationBar.bottom
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.bottom == tableView.superview!.safeAreaLayoutGuide.bottom - 100
            
            stackView.leading == tableView.leading + K.Dimen.smallMargin
            stackView.trailing == tableView.trailing - K.Dimen.smallMargin
            stackView.bottom == stackView.superview!.safeAreaLayoutGuide.bottom - 30
            stackView.height == K.Dimen.button
        }
    }
    
    override func applyStyling() {
        super.applyStyling()

        tableView.separatorColor = .fanatickGray_90_90_90
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = defaultSeparatorInset
        
        customNavigationBar.set(title: nil, subtitle: LocalizedString("listing_details", story: .listingdetail).addColon())
        
        buttonChangePrice.setTitle(LocalizedString("change_price", story: .listingdetail), for: UIControl.State.normal)
        buttonChangePrice.defaultYellowStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2, cornersMask: [.layerMinXMinYCorner, .layerMinXMaxYCorner])
        buttonMarkAsSold.setTitle(LocalizedString("mark_as_sold", story: .listingdetail), for: UIControl.State.normal)
        
        buttonMarkAsSold.defaultWhiteStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2, borderColor: .fanatickGray_151_151_151, cornersMask: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        
        viewForAskingPrice.frame = CGRect(x: 0,
                                          y: 0,
                                          width: view.frame.size.width,
                                          height: 185)
        textFieldPrice.inputAccessoryView = viewForAskingPrice
        textFieldPrice.keyboardType = .numberPad
        textFieldPrice.keyboardAppearance = .dark
        
        viewForAskingPrice.load(viewModel: viewModel)
    }

    override func addObservables() {
        super.addObservables()
        
        viewModel.listingId.map{ [weak viewModel] _ -> String? in
            return viewModel?.list.value?.id
        }.bind(to: viewModel.negotiationsAction).disposed(by: disposeBag)
        
        viewModel.negotiations
            .subscribe(onNext: { [weak self] negotiations in
                
                if var recentNegotiation = negotiations.first {
                    if recentNegotiation.transaction == nil {
                        recentNegotiation.transaction = self?.viewModel.list.value?.transaction
                    }
                    self?.ifOfferAccpeted(negotiations: [recentNegotiation])
                }
            }).disposed(by: disposeBag)
        
        viewModel.selectedViewOffer.subscribe(onNext: { [weak self] (indexPath) in
            guard let indexPath = indexPath else {return }
            let viewController = ViewOfferViewController()
            viewController.viewModel.list.accept(self?.viewModel.list.value)
            viewController.viewModel.selectedNegotiation.accept(self?.viewModel.negotiations.value[indexPath.row])
            self?.navigationController?.pushViewController(viewController, animated: true)
            
        }).disposed(by: disposeBag)
        //TODO: Will be used if require
//        viewModel.buyerSelected.subscribe(onNext: { [weak self] indexPath in
//            guard let indexPath = indexPath else { return }
//            let viewController = SellerListingBuyerStatusViewController()
//            viewController.viewModel.list.accept(self?.viewModel.list.value)
//            viewController.viewModel.selectedNegotiation.accept(self?.viewModel.negotiations.value[indexPath.row])
//            let navigationController = NavigationController(rootViewController: viewController)
//            self?.navigationController?.present(navigationController, animated: true, completion: nil)
//        }).disposed(by: disposeBag)
        
        viewModel.list.subscribe(onNext:{ [weak self] _ in
            let isSold = self?.getListingStatusSold() ?? false
            self?.buttonChangePrice.isDisabled = isSold
            self?.listingStatus = isSold ? .unsold : .sold
            self?.buttonMarkAsSold.setTitle(LocalizedString(isSold ? "mark_as_avaliable" : "mark_as_sold", story: .listingdetail), for: UIControl.State.normal)
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        buttonChangePrice.rx.tap.subscribe(onNext: { [weak self] _ in
            if let unitPrice = self?.viewModel.list.value?.unitPrice {
                self?.textFieldPrice.text = "\(unitPrice / 100)"
            } else {
                self?.textFieldPrice.text = "0"
            }
            self?.textFieldPrice.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        buttonMarkAsSold.rx.tap.subscribe(onNext: { [weak self] _ in
            
            if self?.getListingStatusSold() ?? false {
                self?.markAsSoldAndAvaliable()
                return
            }
            
            let alert = UIAlertController(title: nil, message: LocalizedString("mark_as_sold_any_offer_will_be_automatically_declined", story: .listingdetail), preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: LocalizedString("cancel"),
                              style: .default,
                              handler: { (_) in
                })
            )
            alert.addAction(
                UIAlertAction(title: LocalizedString("proceed"),
                              style: .default,
                              handler: { (_) in
                                    self?.markAsSoldAndAvaliable()
                })
            )
            
            self?.navigationController?.present(alert,
                                                animated: true,
                                                completion: nil)
            
            
        }).disposed(by: disposeBag)
        
        textFieldPrice.rx.text.orEmpty.map { [weak self] _ -> String in
            return self?.textFieldPrice.text ?? ""
            }.bind(to: viewModel.priceText).disposed(by: disposeBag)
        
        viewForAskingPrice.buttonCancel.rx.tap.subscribe(onNext:{ [weak self] _ in
            self?.dismissKeyboard()
        }).disposed(by: disposeBag)
        
        viewForAskingPrice.buttonUpdate.rx.tap.subscribe(onNext:{ [weak self] _ in
            self?.dismissKeyboard()
            let alert = UIAlertController(title: nil, message: LocalizedString("update_price_any_offers_above_new_asking_price_will_be_automatically_declined", story: .listingdetail), preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: LocalizedString("cancel"),
                              style: .default,
                              handler: { (_) in
                })
            )
            alert.addAction(
                UIAlertAction(title: LocalizedString("update"),
                              style: .default,
                              handler: { (_) in
                                if let listingID = self?.viewModel.list.value?.id, let price = self?.viewModel.priceText.value {
                                    let updateTicketModel = UpdateTicketListing.init(quickBuy: nil,
                                                                                     status: nil,
                                                                                     unitPrice: Int(price)! * 100)
                                    self?.viewModel.changePriceAction.accept((listingID, updateTicketModel))
                                }
                })
            )
            
            self?.navigationController?.present(alert,
                                                animated: true,
                                                completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.listingWithoutNegotiation.subscribe(onNext: { [weak self] list in
            guard let list = list, list.transaction != nil else {return}
            let viewController = SellerListingBuyerStatusViewController()
            if let viewModel = self?.viewModel {
                viewController.viewModel = viewModel
                var negotiaiton = Negotiations()
                negotiaiton.transaction = list.transaction
                viewController.viewModel.selectedNegotiation.accept(negotiaiton)
            }
            let navigationController = NavigationController(rootViewController: viewController)
            self?.navigationController?.present(navigationController, animated: false, completion: nil)
        }).disposed(by: disposeBag)
        
    }
    
    fileprivate func markAsSoldAndAvaliable() {
        if let listingID = viewModel.list.value?.id, let listingStatus = listingStatus {
            let updateTicketModel = UpdateTicketListing.init(quickBuy: nil,
                                                             status: listingStatus.rawValue,
                                                             unitPrice: nil)
            viewModel.changePriceAction.accept((listingID, updateTicketModel))
            
        }
    }
    
    fileprivate func getListingStatusSold() -> Bool {
        return viewModel.list.value?.status ?? .unsold == .sold
    }
}


extension ListingDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            return getListingStatusSold() ? 1 : viewModel.negotiations.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if let cell = ListingHeaderCell.dequeueCell(tableView: tableView) as? ListingHeaderCell {
                cell.load(viewModel: viewModel, indexPath: indexPath)
                return cell
            }
        } else {
            
            if getListingStatusSold() {
                if let cell = MessageCell.dequeueCell(tableView: tableView) {
                    cell.load(viewModel: viewModel, indexPath: indexPath)
                    return cell
                }
            } else {
                if let cell = ListingBuyerCell.dequeueCell(tableView: tableView) as? ListingBuyerCell {
                    cell.load(viewModel: viewModel, indexPath: indexPath)
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if indexPath.section == 0 {
            return
        }
        //TODO: Will be used if require
//        viewModel.buyerSelected.accept(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 || !getListingStatusSold() {
            return UITableView.automaticDimension
        } else  {
            return getStatusCellHeight()
        }

    }
    
    fileprivate func getStatusCellHeight() -> CGFloat {
        
        let tableViewHeight = tableView.frame.size.height
        // Calculat Height of row at section and row 0
        let firstCellHeight = tableView.rectForRow(at: IndexPath.init(row: 0, section: 0)).size.height
        return tableViewHeight - firstCellHeight
    }
}

extension ListingDetailsViewController {
    
    fileprivate func ifOfferAccpeted(negotiations: [Negotiations]) {
        
        
        if let acceptedNegotiation = negotiations.first(where: { (negotiation) -> Bool in
            return negotiation.status == NegotiationStatus.accepted || negotiation.status == NegotiationStatus.active && negotiation.transaction != nil && negotiation.transaction?.state != .expired
        }) {
            let viewController = SellerListingBuyerStatusViewController()
            viewController.viewModel = viewModel
            viewController.viewModel.selectedNegotiation.accept(acceptedNegotiation)
            let navigationController = NavigationController(rootViewController: viewController)
            self.navigationController?.present(navigationController, animated: false, completion: nil)
        } else {
            tableView.reloadData()
        }
    }
}
