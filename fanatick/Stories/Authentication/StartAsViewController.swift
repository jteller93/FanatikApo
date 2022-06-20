//
//  StartAsViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/15/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class StartAsViewController: ViewController {
    private struct Constant {
        static let inputViewTopMargin: CGFloat = 120
    }
    var viewModel = StartAsViewModel()
    let titleLabel = Label()
    let segmentedControl = SegmentedControl()
    let descriptionLabel = Label()
    let finishButton = Button()
    
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(titleLabel)
        view.addSubview(segmentedControl)
        view.addSubview(descriptionLabel)
        view.addSubview(finishButton)
        
        constrain(titleLabel, segmentedControl, descriptionLabel, finishButton, car_topLayoutGuide) { titleLabel, segmentedControl, descriptionLabel, finishButton, top in
            titleLabel.top == top.bottom + Constant.inputViewTopMargin
            titleLabel.leading == titleLabel.superview!.leading + K.Dimen.smallMargin
            titleLabel.trailing == titleLabel.superview!.trailing - K.Dimen.smallMargin
            
            segmentedControl.top == titleLabel.bottom + 30
            segmentedControl.leading == segmentedControl.superview!.leading + 50
            segmentedControl.trailing == segmentedControl.superview!.trailing - 50
            segmentedControl.height == 30
            
            descriptionLabel.top == segmentedControl.bottom + 30
            descriptionLabel.leading == titleLabel.leading
            descriptionLabel.trailing == titleLabel.trailing
            
            finishButton.top == descriptionLabel.bottom + 70
            finishButton.leading == titleLabel.leading
            finishButton.trailing == titleLabel.trailing
            finishButton.height == K.Dimen.button
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        segmentedControl.insertSegment(withTitle: LocalizedString("buyer", story: .authentication), at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: LocalizedString("seller", story: .authentication), at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.updateCorner(cornerRadius: 30 / 2)
        
        titleLabel.text = LocalizedString("start_as_title", story: .authentication)
        titleLabel.textColor = .fanatickYellow
        titleLabel.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light)
        
        descriptionLabel.text = LocalizedString("start_as_description", story: .authentication)
        descriptionLabel.textColor = .fanatickWhite
        descriptionLabel.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .center
        
        finishButton.defaultYellowStyling(cornerRadius: K.Dimen.button / 2 , borderColor: .fanatickLightGrey)
        finishButton.setTitle(LocalizedString("finish"), for: .normal)
    }
    
    override func addObservables() {
        super.addObservables()
        
        finishButton.rx.tap.subscribe(onNext: { (_) in
            FirebaseSession.shared.isSignIn = true
            RootNavigationController.makeRoot()
        }).disposed(by: disposeBag)
        
        segmentedControl.rx.value.subscribe(onNext: { (index) in
            FirebaseSession.shared.role = index == 0 ? .buyer : .seller
        }).disposed(by: disposeBag)
    }
}
