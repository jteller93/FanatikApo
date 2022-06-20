//
//  AuthenticationViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/12/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class AuthenticationViewController: ViewController {
    
    private struct Constant {
        static let logoTopMargin: CGFloat = 60
        static let inputViewTopMargin: CGFloat = 120
    }
    
    var viewModel: AuthenticationViewModel = AuthenticationViewModel()
    let logo = UIImageView()
    let inputViews = View()
    var logoCenterConstraint: NSLayoutConstraint? = nil
    let titleLabel = Label()
    let phoneTextField = PhoneNumberField()
    let signInButton = Button()
    let createButton = Button()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(logo)
        view.addSubview(inputViews)
        
        inputViews.addSubview(titleLabel)
        inputViews.addSubview(phoneTextField)
        inputViews.addSubview(signInButton)
        inputViews.addSubview(createButton)
        
        inputViews.isHidden = true
        
        constrain(logo, inputViews, car_topLayoutGuide, car_bottomLayoutGuide) { logos, inputViews, top, bottom in
            logoCenterConstraint = logos.centerY == logos.superview!.centerY
            logos.centerX == logos.superview!.centerX
            
            inputViews.top == top.bottom + Constant.inputViewTopMargin
            inputViews.leading == inputViews.superview!.leading + K.Dimen.smallMargin
            inputViews.trailing == inputViews.superview!.trailing - K.Dimen.smallMargin
            inputViews.bottom == bottom.top - K.Dimen.smallMargin
        }
        
        constrain(titleLabel, phoneTextField, signInButton, createButton) { titleLabel, phoneTextField, signInButton, createButton in
            titleLabel.top == titleLabel.superview!.top
            titleLabel.leading == titleLabel.superview!.leading
            titleLabel.trailing == titleLabel.superview!.trailing
            
            align(left: titleLabel, phoneTextField, signInButton, createButton)
            align(right: titleLabel, phoneTextField, signInButton, createButton)
            
            phoneTextField.top == titleLabel.bottom + 50
            phoneTextField.height == K.Dimen.textFieldHeight
            
            signInButton.top == phoneTextField.bottom + 30
            signInButton.height == K.Dimen.button
            
            createButton.top == signInButton.bottom + 30
            createButton.height == K.Dimen.button
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        navigationController?.navigationBar.isTranslucent = true
        
        logo.image = UIImage(named: "icon_logo")
        
        phoneTextField.defaultGrayBorderStyling()
        
        titleLabel.text = LocalizedString("enter_your_number")
        titleLabel.font = UIFont.shFont(size: 20, fontType: .sfProDisplay, weight: .medium)
        titleLabel.textColor = .fanatickYellow
        
        signInButton.defaultWhiteStyling(cornerRadius: K.Dimen.button / 2, borderColor: .fanatickLightGrey)
        signInButton.setTitle(LocalizedString("sign_in", story: .general), for: .normal)
        signInButton.isEnabled = false
        
        createButton.defaultYellowStyling(cornerRadius: K.Dimen.button / 2, borderColor: .fanatickLightGrey)
        createButton.setTitle(LocalizedString("create_new_account", story: .general), for: .normal)
    }
    
    override func addObservables() {
        super.addObservables()
        
        phoneTextField.rx.isValid
            .bind(to: signInButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        phoneTextField.rx.text.orEmpty
            .bind(to: viewModel.phoneNumber)
            .disposed(by: disposeBag)
        
        signInButton.rx.tap
            .bind(to: viewModel.validateAction)
            .disposed(by: disposeBag)
        
        viewModel.error.filter{ $0 != nil }.subscribe(onNext: { [weak self] (error) in
            self?.handleError(error: error!)
        }).disposed(by: disposeBag)
        
        viewModel.success.subscribe(onNext: { [weak self] (_) in
            self?.navigationController?.pushViewController(VerificationCodeViewController(), animated: true)
        }).disposed(by: disposeBag)
        
        createButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            self?.navigationController?.pushViewController(SignUpPhoneViewController(), animated: true)
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TutorialViewController.showIfNeeded(sender: self)
    }
    
    // MARK: Animation
    var didLayoutSubview = false
    var showDelayedAnimation = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubview {
            didLayoutSubview = true
            
            if showDelayedAnimation {
                animate()
                showDelayedAnimation = false
            }
        }
    }
    
    func animate() {
        if didLayoutSubview {
            inputViews.alpha = 0
            inputViews.isHidden = false
            logoCenterConstraint?.constant = Constant.logoTopMargin - (UIScreen.main.bounds.height - logo.frame.height) / 2
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                UIView.animate(withDuration: 0.3, animations: {
                    self.inputViews.alpha = 1
                })
            }
        } else {
            showDelayedAnimation = true
        }
    }
}

// Mark: Static func
extension AuthenticationViewController {
    
    class func show(sender: ViewController, animated: Bool) {
        let viewController = AuthenticationViewController()
        let navigationController = NavigationController(rootViewController: viewController)
        navigationController.modalTransitionStyle = .crossDissolve
        sender.present(navigationController, animated: true) {
            if animated {
                viewController.animate()
            }
        }
    }
    
    class func makeRoot() {
        let authVC = AuthenticationViewController()
        let navigationController = NavigationController(rootViewController: authVC)
        UIApplication.shared.appDelegate().makeRoot(viewController: navigationController)
        authVC.animate()
    }
}
