//
//  SignUpPhoneViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/15/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class SignUpPhoneViewController: ViewController {
    private struct Constant {
        static let inputViewTopMargin: CGFloat = 120
    }
    
    var viewModel = SignUpViewModel()
    let titleLabel = Label()
    let phoneTextField = PhoneNumberField()
    let continueButton = Button()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(titleLabel)
        view.addSubview(phoneTextField)
        view.addSubview(continueButton)
        
        constrain(titleLabel, phoneTextField, continueButton, car_topLayoutGuide) { titleLabel, phoneTextField, continueButton, top in
            titleLabel.top == top.bottom + Constant.inputViewTopMargin
            titleLabel.leading == titleLabel.superview!.leading + K.Dimen.smallMargin
            titleLabel.trailing == titleLabel.superview!.trailing - K.Dimen.smallMargin
            
            phoneTextField.leading == titleLabel.leading
            phoneTextField.trailing == titleLabel.trailing
            phoneTextField.height == K.Dimen.textFieldHeight
            phoneTextField.top == titleLabel.bottom + 50
            
            continueButton.top == phoneTextField.bottom + 100
            continueButton.leading == titleLabel.leading
            continueButton.trailing == titleLabel.trailing
            continueButton.height == K.Dimen.button
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        titleLabel.text = LocalizedString("enter_your_number")
        titleLabel.textColor = .fanatickYellow
        titleLabel.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light)
        
        phoneTextField.defaultGrayBorderStyling()
        
        continueButton.defaultYellowStyling(cornerRadius: K.Dimen.button / 2, borderColor: .fanatickLightGrey)
        continueButton.setTitle(LocalizedString("continue"), for: .normal)
    }
    
    override func addObservables() {
        super.addObservables()
        
        phoneTextField.rx.isValid
            .bind(to: continueButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        phoneTextField.rx.text.orEmpty
            .bind(to: viewModel.phoneNumber)
            .disposed(by: disposeBag)
        
        continueButton.rx.tap
            .bind(to: viewModel.validateAction)
            .disposed(by: disposeBag)
        
        viewModel.error.filter{ $0 != nil }.subscribe(onNext: { [weak self] (error) in
            self?.handleError(error: error!)
        }).disposed(by: disposeBag)
        
        viewModel.success.subscribe(onNext: { [weak self] (_) in
            self?.navigationController?.pushViewController(VerificationCodeViewController(), animated: true)
        }).disposed(by: disposeBag)
    }
}
