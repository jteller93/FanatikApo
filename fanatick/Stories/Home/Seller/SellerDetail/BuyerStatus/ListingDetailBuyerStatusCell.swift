//
//  ListingDetailBuyerStatusCell.swift
//  fanatick
//
//  Created by Yashesh on 12/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography

class ListingDetailBuyerStatusCell: TableViewCell {

    let viewForNameAndPrice = View()
    let viewForStatus = View()
    let stackView = UIStackView()
    let labelName = Label()
    let labelOriginalPriceTitle = Label()
    let labelOriginalPrice = Label()
    let labelSellingPriceTitle = Label()
    let labelSellingPrice = Label()
    let stackViewForSellingPrice = UIStackView()
    let labelStatusDetail = Label()
    let stackViewForActionButtons = UIStackView()
    let buttonScanQRCode = Button()
    let buttonCancel = Button()
    
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
        
        viewForStatus.addSubview(stackViewForActionButtons)
        stackViewForActionButtons.addArrangedSubview(buttonScanQRCode)
        stackViewForActionButtons.addArrangedSubview(buttonCancel)
        stackViewForActionButtons.spacing = 9
        stackViewForActionButtons.axis = .horizontal
        stackViewForActionButtons.distribution = .fillEqually
        
        viewForStatus.addSubview(labelStatusDetail)
        
        constrain(labelName, stackView, labelOriginalPriceTitle, labelOriginalPrice, stackViewForSellingPrice, stackViewForActionButtons, labelStatusDetail) { (labelName, stackView, labelOriginalPriceTitle, labelOriginalPrice, stackViewForSellingPrice, stackViewForActionButtons, labelStatusDetail) in
            
            stackView.top == stackView.superview!.top
            stackView.leading == stackView.superview!.leading
            stackView.trailing == stackView.superview!.trailing
            stackView.bottom == stackView.superview!.bottom
            
            labelName.leading == labelName.superview!.leading + K.Dimen.smallMargin
            labelName.top == labelName.superview!.top + K.Dimen.smallMargin
            
            labelOriginalPriceTitle.leading == labelName.leading
            labelOriginalPriceTitle.bottom == labelOriginalPriceTitle.superview!.bottom
            
            labelOriginalPrice.trailing == labelOriginalPriceTitle.superview!.trailing - K.Dimen.smallMargin
            labelOriginalPrice.bottom == labelOriginalPriceTitle.bottom
            
            stackViewForSellingPrice.centerX == stackViewForSellingPrice.superview!.centerX
            stackViewForSellingPrice.centerY == stackViewForSellingPrice.superview!.centerY + 10
            
            stackViewForActionButtons.leading == stackViewForActionButtons.superview!.leading + K.Dimen.smallMargin
            stackViewForActionButtons.trailing == stackViewForActionButtons.superview!.trailing - K.Dimen.smallMargin
            stackViewForActionButtons.bottom == stackViewForActionButtons.superview!.bottom - 30
            stackViewForActionButtons.height == K.Dimen.button
            
            labelStatusDetail.top == labelStatusDetail.superview!.top
            labelStatusDetail.bottom == stackViewForActionButtons.top
            labelStatusDetail.centerX == stackViewForActionButtons.centerX
            labelStatusDetail.width == stackViewForActionButtons.width
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        labelName.font = UIFont.shFont(size: 24,
                                       fontType: .helveticaNeue,
                                       weight: .bold)
        
        labelName.textColor = .fanatickYellow
        
        
        setLabelStyling(label: labelOriginalPriceTitle,
                              text: LocalizedString("original_price", story: .listingdetail),
                              textColor: .fanatickGray_74_74_74)
        
        labelSellingPriceTitle.textAlignment = .center
        
        setLabelStyling(label: labelSellingPriceTitle,
                        text: LocalizedString("selling_price", story: .listingdetail),
                        textColor: .fanatickWhite)
        
        buttonScanQRCode.setTitle(LocalizedString("scan_qr_code",
                                                  story: .listingdetail),
                                  for: UIControl.State.normal)
        
        buttonScanQRCode.defaultYellowStyling(fontSize: 16,
                                              cornerRadius: K.Dimen.button / 2,
                                              borderColor: nil,
                                              cornersMask: [.layerMinXMinYCorner, .layerMinXMaxYCorner])
        
        buttonCancel.setTitle(LocalizedString("cancel"),
                              for: UIControl.State.normal)
        
        buttonCancel.defaultWhiteStyling(fontSize: 16,
                                         cornerRadius: K.Dimen.button / 2,
                                         borderColor: .fanatickGray_151_151_151,
                                         cornersMask: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        
        labelStatusDetail.textAlignment = .center
        labelStatusDetail.numberOfLines = 0
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? ListingDetailsViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        if let negotiations = viewModel.selectedNegotiation.value, let transection = viewModel.selectedNegotiation.value?.transaction {
            
            let buyer = negotiations.buyer
            labelName.text = "\(buyer?.firstName ?? "") \(buyer?.lastName ?? "")"
            
            setLabelStyling(label: labelSellingPrice,
                            text: String(format: LocalizedString("price_template"),
                                         Float(transection.payment?.amount ?? negotiations.finalPrice ?? 00) / 100),
                            fontSize: 40,
                            textColor: .fanatickWhite)
            
            if let unitPrice = negotiations.listing?.unitPrice, let numberOfSeat = negotiations.listing?.seats?.count {
                setLabelStyling(label: labelOriginalPrice,
                                text: String(format: LocalizedString("price_template"),
                                             (Float(unitPrice) * Float(numberOfSeat)) / 100),
                                textColor: .fanatickGray_74_74_74)
            }
            setupTransactionDetails(viewModel: viewModel)
        }
        
    }
    
    fileprivate func setLabelStyling(label:Label, text: String, fontSize: CGFloat = 16, textColor: UIColor = .fanatickWhite) {
        label.text = text
        label.font = UIFont.shFont(size: fontSize, fontType: .helveticaNeue, weight: .regular)
        label.textColor = textColor
    }
    
    fileprivate func setupTransactionDetails(viewModel: ListingDetailsViewModel?) {
        
        if let transaction = viewModel?.selectedNegotiation.value?.transaction?.state {
            if let deliveryMethod = viewModel?.list.value?.deliveryMethod {
                switch deliveryMethod {
                case .digital:
                    stackViewForActionButtons.isHidden = true
                    break
                case .hardcopy:
                    stackViewForActionButtons.isHidden = false
                    buttonScanQRCode.isDisabled = true
                    buttonCancel.isDisabled = false
                    addObserverForCancelButton(viewModel: viewModel)
                    break
                }
                
                switch transaction {
                case .pending:
                    setStatusLabel(text: LocalizedString(deliveryMethod == .hardcopy ? "offer_Once_payment_is_complete_your_buyer_will_be_shown_a_map_of_your_current_location" : "once_payment_is_complete_your_buyer_will_receive_a_digital_copy_of_the_tickets", story: .listingdetail))
                    break
                case .charged, .pickupPending:
                    setStatusLabel(text: LocalizedString("payment_has_been_processed_scan_your_buyers_qr_code_upon_pick_up_to_complete_the_transaction", story: .listingdetail))
                    buttonCancel.isHidden = true
                    buttonScanQRCode.defaultYellowStyling(fontSize: 16,
                                                          cornerRadius: K.Dimen.button / 2, cornersMask: [.layerMinXMinYCorner, .layerMinXMaxYCorner,.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
                    buttonScanQRCode.isDisabled = false
                    addObservablesForScanner(viewModel: viewModel)
                    break
                case .succeeded:
                    setStatusLabel(text: LocalizedString("transaction_complete", story: .listingdetail))
                    stackViewForActionButtons.isHidden = true
                    break
                case .failed:
                    setStatusLabel(text: LocalizedString("transaction_failed", story: .listingdetail))
                    break
                case .expired:
                    buttonScanQRCode.isHidden = true
                    buttonCancel.isHidden = true
                    setStatusLabel(text: LocalizedString("transaction_expired", story: .listingdetail))
                    break
                case .canceled:
                    setStatusLabel(text: LocalizedString("transaction_cancel", story: .listingdetail))
                    break
                case .exception:
                    //TODO: in case of status blank..
                    break
                case .scanSuccess:
                    if let buyer = viewModel?.selectedNegotiation.value?.buyer {
                        setStatusLabel(text:
                            LocalizedString("i_have_provided", story: .listingdetail) +
                                " \("\(buyer.firstName ?? "") \(buyer.lastName ?? "")") " +
                                LocalizedString("with_the_tickets", story: .listingdetail)
                        )
                        buttonScanQRCode.setTitle(LocalizedString("confirm",
                                                                  story: .listingdetail),
                                                  for: UIControl.State.normal)
                        buttonScanQRCode.isDisabled = false
                        addObservablesForScanner(viewModel: viewModel)
                    }
                    break
                }
            }
        }
    }
    
    fileprivate func setStatusLabel(text: String) {
        setLabelStyling(label: labelStatusDetail, text: text)
    }
    
    fileprivate func addObservablesForScanner(viewModel: ListingDetailsViewModel?) {
        guard let viewModel = viewModel else { return }
        
        buttonScanQRCode.rx.tap.subscribe(onNext: { [weak self] _ in
            if self?.buttonScanQRCode.titleLabel?.text ?? "" == LocalizedString("confirm", story: .listingdetail) {
                if let transactionId = viewModel.qrcodeDetails.value.0, let qrCode = viewModel.qrcodeDetails.value.1 {
                    viewModel.verifyPayment.accept((transactionId, qrCode))
                }
            } else {
                viewModel.startScanner.accept(true)
            }
        }).disposed(by: disposeBag)
    }
    
    fileprivate func addObserverForCancelButton(viewModel: ListingDetailsViewModel?) {
        guard let viewModel = viewModel else { return }
        
        buttonCancel.rx.tap.subscribe(onNext: { [weak viewModel] _ in
            viewModel?.cancelNegotiation.accept(())
        }).disposed(by: disposeBag)
    }
}
