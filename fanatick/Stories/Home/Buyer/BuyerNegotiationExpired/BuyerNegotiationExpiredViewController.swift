//
//  BuyerNegotiationExpiredViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 1/3/20.
//  Copyright © 2020 Fanatick. All rights reserved.
//

import Foundation
import Cartography

class BuyerNegotiationExpiredViewController: ViewController {

    let imageView = UIImageView()
    let labelDescription = Label()
    
    let buttonCancel = Button()
    let stackViewForButton = UIStackView()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(imageView)
        view.addSubview(labelDescription)
        
        view.addSubview(stackViewForButton)
        stackViewForButton.axis = .horizontal
        stackViewForButton.spacing = 9
        stackViewForButton.distribution = .fillEqually
        stackViewForButton.addArrangedSubview(buttonCancel)
        
        constrain(imageView, labelDescription) { (imageView, labelDescription) in
            imageView.height == 98
            imageView.width == 74
            imageView.centerX == imageView.superview!.centerX
            imageView.bottom == imageView.superview!.centerY - 86.4
            
            labelDescription.top == labelDescription.superview!.centerY - 42
            labelDescription.leading == labelDescription.superview!.leading + 42
            labelDescription.trailing == labelDescription.superview!.trailing - 42
        }
        
        constrain(stackViewForButton) { (stackViewForButton) in
            (stackViewForButton).leading == (stackViewForButton).superview!.leading + K.Dimen.smallMargin
            (stackViewForButton).trailing == (stackViewForButton).superview!.trailing - K.Dimen.smallMargin
            (stackViewForButton).height == K.Dimen.button
            (stackViewForButton).bottom == (stackViewForButton).superview!.safeAreaLayoutGuide.bottom - K.Dimen.largeMargin
        }
        
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        imageView.image = UIImage.init(named: "icon_thunder")
        
        labelDescription.numberOfLines = 0
        labelDescription.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        labelDescription.textColor = .fanatickWhite
        labelDescription.textAlignment = .center
        labelDescription.text = LocalizedString("offer_expired", story: .negotiation)
        
        buttonCancel.setTitle(LocalizedString("buttonTitle_ok"), for: UIControl.State.normal)
        
        buttonCancel.defaultYellowStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2, borderColor: nil, cornersMask: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner])
    }
    
    override func addObservables() {
        super.addObservables()
        
        buttonCancel.rx.tap.subscribe(onNext:{ [weak self] _ in
            self?.navigationController?
                .dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}
