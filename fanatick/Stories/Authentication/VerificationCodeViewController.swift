//
//  VerificationCodeViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/15/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class VerificationCodeViewController: ViewController {
    var viewModel = VerificationCodeViewModel()
    let verifyButton = Button()
    let verificationCode = VerificationField()
    let titleLabel = Label()
    let resendButton = Button()
    let enterCodeLabel = Label()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(titleLabel)
        view.addSubview(enterCodeLabel)
        view.addSubview(resendButton)
        view.addSubview(verificationCode)
        view.addSubview(verifyButton)
        
        constrain(titleLabel, enterCodeLabel, resendButton, car_topLayoutGuide) { titleLabel, enterCodeLabel, resendButton, top in
            titleLabel.top == top.bottom + K.Dimen.largeMargin
            titleLabel.leading == titleLabel.superview!.leading + K.Dimen.smallMargin
            titleLabel.trailing == titleLabel.superview!.trailing - K.Dimen.smallMargin
            
            enterCodeLabel.top == titleLabel.bottom + K.Dimen.largeMargin
            enterCodeLabel.leading == titleLabel.leading
            enterCodeLabel.trailing <= resendButton.leading
            
            resendButton.centerY == enterCodeLabel.centerY
            resendButton.trailing == titleLabel.trailing
        }
        
        constrain(enterCodeLabel, verificationCode, verifyButton) { enterCodeLabel, verificationCode, verifyButton in
            verificationCode.top == enterCodeLabel.bottom + 10
            verificationCode.leading == verificationCode.superview!.leading + K.Dimen.smallMargin
            verificationCode.trailing == verificationCode.superview!.trailing - K.Dimen.smallMargin
            verificationCode.height == 80
            
            verifyButton.top == verificationCode.bottom + 50
            verifyButton.leading == verificationCode.leading
            verifyButton.trailing == verificationCode.trailing
            verifyButton.height == K.Dimen.button
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light)
        titleLabel.textColor = .fanatickWhite
        titleLabel.text = String(format: LocalizedString("verification_code_title", story: .authentication), FirebaseSession.shared.displayedPhoneNumber)
        
        verificationCode.count = 6
        
        enterCodeLabel.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light)
        enterCodeLabel.textColor = .fanatickYellow
        enterCodeLabel.text = LocalizedString("enter_verification_code", story: .authentication)
        
        resendButton.setTitleColor(.fanatickYellow, for: .normal)
        
        let attrs : [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light),
            NSAttributedString.Key.foregroundColor : UIColor.fanatickYellow,
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
        let buttonTitle = NSMutableAttributedString(string: LocalizedString("resend_code", story: .authentication), attributes: attrs)
        resendButton.setAttributedTitle(buttonTitle, for: .normal)
        
        verifyButton.setTitle(LocalizedString("verify", story: .authentication), for: .normal)
        verifyButton.defaultYellowStyling(cornerRadius: K.Dimen.button / 2, borderColor: UIColor.fanatickLightGrey)
    }
    
    override func addObservables() {
        super.addObservables()
        
        verifyButton.rx.tap.bind(to: viewModel.verifyAction)
            .disposed(by: disposeBag)
        
        resendButton.rx.tap
            .bind(to: viewModel.resendAction)
            .disposed(by: disposeBag)
        
        verificationCode.rx.verificationCode
            .bind(to:  viewModel.verificationCode)
            .disposed(by: disposeBag)
        
        verificationCode.rx.isValid
            .bind(to: verifyButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.resendSuccess.subscribe(onNext: { [weak self] (_) in
            self?.showMessage(title: "",
                             message: String(format: LocalizedString("verification_code_resend",
                                                                     story: .authentication),
                                             FirebaseSession.shared.displayedPhoneNumber))
        }).disposed(by: disposeBag)
        
        viewModel.success.subscribe(onNext: { [weak self] (_) in
            self?.pushNextScreen()
        }).disposed(by: disposeBag)
        
        viewModel.error.filter{ $0 != nil }
            .subscribe(onNext: { [weak self] (error) in
                self?.handleError(error: error!)
            }).disposed(by: disposeBag)
    }
    
    
    private func pushNextScreen() {
        if FirebaseSession.shared.user.value == nil {
            navigationController?.pushViewController(SignUpNameViewController(), animated: true)
        } else {
            navigationController?.pushViewController(StartAsViewController(), animated: true)
        }
    }
}
