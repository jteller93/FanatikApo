//
//  MembershipViewController.swift
//  fanatick
//
//  Created by Essam on 1/6/20.
//  Copyright © 2020 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import RxCocoa
import RxSwift

class MembershipViewController: ViewController {

    private struct Constant {
        static let logoTopMargin: CGFloat = 60
        static let inputViewTopMargin: CGFloat = 120
    }
    
    let viewModel = MembershipViewModel()
    let logo = UIImageView()
    let memberShipButton   = Button()
    let memberShipTitle = Label()
    let memberShipDescription = Label()
    let memberShipTerm = Label()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(logo)
        view.addSubview(memberShipButton)
        view.addSubview(memberShipTitle)
        view.addSubview(memberShipDescription)
        view.addSubview(memberShipTerm)

        constrain(logo, memberShipTitle, memberShipDescription, car_topLayoutGuide) {
                  logo, memberShipTitle, memberShipDescription, top in
            logo.top == logo.superview!.top + 27
            logo.centerX == logo.superview!.centerX
            
            memberShipTitle.top == logo.bottom + 16
            memberShipTitle.leading == memberShipTitle.superview!.leading + 16
            memberShipTitle.trailing == memberShipTitle.superview!.trailing - 16

            memberShipDescription.top == memberShipTitle.bottom + 30
            memberShipDescription.leading == memberShipDescription.superview!.leading + 16
        }
        
        constrain(memberShipTerm, memberShipButton, car_bottomLayoutGuide) { memberShipTerm, memberShipButton, bottom in
            
            memberShipTerm.bottom == memberShipButton.top - 30
            memberShipTerm.leading == memberShipButton.superview!.leading + 16
            memberShipTerm.trailing == memberShipButton.superview!.trailing - 16
            
            memberShipButton.bottom == bottom.top - 30
            memberShipButton.leading == memberShipButton.superview!.leading + 16
            memberShipButton.trailing == memberShipButton.superview!.trailing - 16
            memberShipButton.height == K.Dimen.button
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        logo.image = UIImage(named: "icon_logo")
        
        memberShipTitle.text = LocalizedString("pro_features", story: .settings)
        memberShipTitle.textColor = .fanatickWhite
        memberShipTitle.font = UIFont.shFont(size: 14, fontType: .sfProDisplay, weight: .regular)
        memberShipTitle.numberOfLines = 0
        
        memberShipTerm.numberOfLines = 0
        memberShipTerm.text = LocalizedString("pro_terms", story: .settings)
        memberShipTerm.textColor = .fanatickWhite
        memberShipTerm.font = UIFont.shFont(size: 14, fontType: .sfProDisplay, weight: .regular)
        
        memberShipDescription.numberOfLines = 0
    }

    override func addObservables() {
        super.addObservables()
        
        viewModel.user.subscribe(onNext: { [weak self] (user) in
            guard let self = self else { return }
            self.applyMembershipStyling(subscriber: user?.membership?.proSubscriptionActive ?? false)
        }).disposed(by: disposeBag)
        
        self.memberShipButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            if !(self?.viewModel.user.value?.membership?.proSubscriptionActive ?? false) {
                self?.viewModel.subscribeAction.accept(())
            } else {
                self?.viewModel.unsubscribeAction.accept(())
            }
        }).disposed(by: self.disposeBag)
        
        viewModel.error.filter{ $0 != nil }
        .subscribe(onNext: { [weak self] (error) in
            self?.handleError(error: error!)
        }).disposed(by: disposeBag)
    }
    
    func applyMembershipStyling(subscriber: Bool) {
        if subscriber {
            memberShipButton.defaultWhiteStyling(cornerRadius: K.Dimen.button / 2, borderColor: .fanatickYellow)
            memberShipButton.setTitle(LocalizedString("pro_cancel", story: .settings), for: .normal)
            
            let str = LocalizedString("pro_member", story: .settings)
//            str += "\n(\(LocalizedString("renews", story: .settings)) \("04/15/2019"))"
            let attributedString = NSMutableAttributedString(string: str, attributes: [
                .font: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .light),
                .foregroundColor: UIColor.fanatickYellow
            ])
            attributedString.addAttribute(.font, value: UIFont.shFont(size: 20, fontType: .helveticaNeue, weight: .light), range: NSRange(location: 0, length: LocalizedString("pro_member", story: .settings).count))
            
            memberShipDescription.attributedText = attributedString
        } else {
            memberShipDescription.text = ""
            memberShipButton.setTitle(LocalizedString("upgrade_to_pro", story: .settings), for: .normal)
            memberShipButton.defaultYellowStyling(cornerRadius: K.Dimen.button / 2, borderColor: .fanatickGrey)
        }
    }
    
    override func backButtonTapped() {
        super.backButtonTapped()
        ActivityIndicator.shared.stop()
    }
    
    override func dismissButtonTapped() {
        super.dismissButtonTapped()
        ActivityIndicator.shared.stop()
    }
}
