//
//  SignUpNameViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/15/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class SignUpNameViewController: ViewController {
    private struct Constant {
        static let inputViewTopMargin: CGFloat = 120
    }
    var viewModel = SignUpNameViewModel()
    let firstNameTitle = Label()
    let firstNameTextField = TextField()
    let lastNameTitle = Label()
    let lastNameTextField = TextField()
    let continueButton = Button()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(firstNameTitle)
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameTitle)
        view.addSubview(lastNameTextField)
        view.addSubview(continueButton)
        
        constrain(firstNameTitle, firstNameTextField, lastNameTitle, lastNameTextField, continueButton, car_topLayoutGuide) { firstNameTitle, firstNameTextField, lastNameTitle, lastNameTextField, continueButton, top in
            
            firstNameTitle.top == top.bottom + Constant.inputViewTopMargin
            firstNameTitle.leading == firstNameTitle.superview!.leading + K.Dimen.smallMargin
            firstNameTitle.trailing == firstNameTitle.superview!.trailing - K.Dimen.smallMargin
            
            firstNameTextField.top == firstNameTitle.bottom + 10
            firstNameTextField.height == K.Dimen.textFieldHeight
            
            lastNameTitle.top == firstNameTextField.bottom + 15
            
            lastNameTextField.top == lastNameTitle.bottom + 10
            lastNameTextField.height == K.Dimen.textFieldHeight
            
            continueButton.top == lastNameTextField.bottom + 50
            continueButton.height == K.Dimen.button
            
            align(left: firstNameTitle, firstNameTextField, lastNameTitle, lastNameTextField, continueButton)
            align(right: firstNameTitle, firstNameTextField, lastNameTitle, lastNameTextField, continueButton)
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        firstNameTitle.text = LocalizedString("enter_your_first_name", story: .authentication)
        firstNameTitle.textColor = .fanatickYellow
        firstNameTitle.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light)
        
        firstNameTextField.defaultGrayBorderStyling()
        
        lastNameTitle.text = LocalizedString("enter_your_last_name", story: .authentication)
        lastNameTitle.textColor = .fanatickYellow
        lastNameTitle.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light)
        
        lastNameTextField.defaultGrayBorderStyling()
        
        continueButton.defaultYellowStyling(cornerRadius: K.Dimen.button / 2, borderColor: .fanatickLightGrey)
        continueButton.setTitle(LocalizedString("continue"), for: .normal)
    }
    
    override func addObservables() {
        super.addObservables()
        
        continueButton.rx.tap.bind(to: viewModel.continueAction)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: continueButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.success.subscribe(onNext: { [weak self] _ in
            self?.navigationController?.pushViewController(StartAsViewController(), animated: true)
        }).disposed(by: disposeBag)
        
        viewModel.error.filter{ $0 != nil }
            .subscribe(onNext: { [weak self] (error) in
                self?.handleError(error: error!)
            }).disposed(by: disposeBag)
        
        firstNameTextField.rx.text.orEmpty
            .scan("") { (previous, new) -> String in
                if new.count > 15 {
                    return previous ?? String(new.prefix(15))
                } else {
                    return new
                }
            }
            .subscribe(firstNameTextField.rx.text)
            .disposed(by: disposeBag)
        
        lastNameTextField.rx.text.orEmpty
            .scan("") { (previous, new) -> String in
                if new.count > 15 {
                    return previous ?? String(new.prefix(15))
                } else {
                    return new
                }
            }
            .subscribe(lastNameTextField.rx.text)
            .disposed(by: disposeBag)

        firstNameTextField.rx.text.orEmpty
            .bind(to: viewModel.firstName)
            .disposed(by: disposeBag)
        
        lastNameTextField.rx.text.orEmpty
            .bind(to: viewModel.lastName)
            .disposed(by: disposeBag)
    }
}
