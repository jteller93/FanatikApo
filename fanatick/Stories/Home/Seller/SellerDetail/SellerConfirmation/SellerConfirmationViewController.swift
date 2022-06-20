//
//  SellerConfirmationViewController.swift
//  fanatick
//
//  Created by Yashesh on 18/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography

class SellerConfirmationViewController: ViewController, GeolocationServiceDelegate {
  
  let imageView = UIImageView()
  let buttonGotit = Button()
  let labelDescription = Label()
  let labelDescriptionForQrCode = Label()
  let stackView = UIStackView()
  var viewModel = ViewOffersNegotationsViewModel()
  var locationService = GeolocationService.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationService.delegate = self
  }
  
  override func setupSubviews() {
    super.setupSubviews()
    
    view.addSubview(imageView)
    view.addSubview(buttonGotit)
    view.addSubview(stackView)
    stackView.addArrangedSubview(labelDescription)
    stackView.addArrangedSubview(labelDescriptionForQrCode)
    
    stackView.axis = .vertical
    stackView.spacing = 25
    
    constrain(imageView, stackView) { (imageView, stackView) in
      imageView.height == 86.4
      imageView.width == 109
      imageView.centerX == imageView.superview!.centerX
      imageView.bottom == imageView.superview!.centerY - 86.4
      
      stackView.top == stackView.superview!.centerY - 42
      stackView.leading == stackView.superview!.leading + 42
      stackView.trailing == stackView.superview!.trailing - 42
    }
    
    constrain(buttonGotit) { (buttonGotit) in
      buttonGotit.leading == buttonGotit.superview!.leading + K.Dimen.smallMargin
      buttonGotit.trailing == buttonGotit.superview!.trailing - K.Dimen.smallMargin
      buttonGotit.height == K.Dimen.button
      buttonGotit.bottom == buttonGotit.superview!.safeAreaLayoutGuide.bottom - K.Dimen.largeMargin
    }
    
  }
  
  override func applyStyling() {
    super.applyStyling()
    
    imageView.image = UIImage.init(named: "checkIconYellow")
    
    labelDescription.numberOfLines = 0
    labelDescription.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
    labelDescription.textColor = .fanatickWhite
    labelDescription.textAlignment = .center
    labelDescriptionForQrCode.numberOfLines = 0
    labelDescriptionForQrCode.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
    labelDescriptionForQrCode.textColor = .fanatickWhite
    labelDescriptionForQrCode.textAlignment = .center
    
    buttonGotit.setTitle(LocalizedString("got_it", story: .listingdetail), for: UIControl.State.normal)
    buttonGotit.titleLabel?.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
    buttonGotit.defaultYellowStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2)
    
    setupConfirmationMessage()
  }
  
  override func addObservables() {
    super.addObservables()
    
    buttonGotit.rx.tap.subscribe(onNext:{ [weak self] _ in
      if let vc = self?.presentingViewController?.presentingViewController {
        vc.dismiss(animated: true, completion: nil)
      } else if let vc = self?.presentingViewController {
        vc.dismiss(animated: true, completion: nil)
      } else {
        self?.dismiss(animated: true, completion: nil)
      }
    }).disposed(by: disposeBag)
  }
  
  fileprivate func setupConfirmationMessage() {
    
    if let listing = viewModel.list.value, let negotiations = viewModel.selectedNegotiation.value {
      
      let buyer = negotiations.buyer
      let buyerName = " \(buyer?.firstName ?? "") \(buyer?.lastName ?? "") "
      
      if listing.deliveryMethod == .digital {
        
        labelDescription.text = LocalizedString("you_have_accepted", story: .listingdetail) + buyerName + LocalizedString("offer_once_payment_is_complete_your_buyer_will_receive_a_digital_copy_of_the_tickets", story: .listingdetail)
        
      } else {
        
        labelDescription.text = LocalizedString("you_have_accepted", story: .listingdetail) + buyerName + LocalizedString("offer_Once_payment_is_complete_your_buyer_will_be_shown_a_map_of_your_current_location", story: .listingdetail)
        
        labelDescriptionForQrCode.text = LocalizedString("Scan_your_buyers_qr_Code_upon_pick_up_to_complete_the_transaction", story: .listingdetail)
      }
    }
  }
  
}
