//
//  RateSellerViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 11/18/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cosmos
import Cartography
import UIKit
import RxCocoa
import RxSwift

class RateSellerViewController: ViewController {
    let viewModel = RateSellerViewModel()
    
    let titleLabel = Label()
    let starRating = CosmosView()
    let ratingLabel = Label()
    let submitButton = Button()
    let fairPriceButton = Button()
    let friendlyButton = Button()
    let quickResponseButton = Button()
    let easyToLocateButton = Button()
    let buttonContainer = View()
    
    override func setupSubviews() {
        super.setupSubviews()
        view.addSubview(titleLabel)
        view.addSubview(starRating)
        view.addSubview(ratingLabel)
        view.addSubview(submitButton)
        view.addSubview(buttonContainer)
        buttonContainer.addSubview(fairPriceButton)
        buttonContainer.addSubview(friendlyButton)
        buttonContainer.addSubview(quickResponseButton)
        buttonContainer.addSubview(easyToLocateButton)
        
        constrain(titleLabel, starRating, ratingLabel, car_topLayoutGuide) { titleLabel, starRating, ratingLabel, top in
            titleLabel.top == top.bottom + 100
            titleLabel.centerX == titleLabel.superview!.centerX
            titleLabel.leading == titleLabel.superview!.leading + 30
            titleLabel.trailing == titleLabel.superview!.trailing - 30
            
            starRating.top == titleLabel.bottom + 50
            starRating.centerX == starRating.superview!.centerX
            
            ratingLabel.top == starRating.bottom + 30
            ratingLabel.centerX == ratingLabel.superview!.centerX
        }
        
        constrain(ratingLabel, buttonContainer, submitButton) { ratingLabel, buttonContainer, submitButton in
            buttonContainer.leading == buttonContainer.superview!.leading + K.Dimen.smallMargin
            buttonContainer.trailing == buttonContainer.superview!.trailing - K.Dimen.smallMargin
            buttonContainer.top == ratingLabel.bottom + 30
            buttonContainer.bottom == submitButton.top - 30
        }
        
        constrain(fairPriceButton, friendlyButton, quickResponseButton, easyToLocateButton) { fairPriceButton, friendlyButton, quickResponseButton, easyToLocateButton in
            fairPriceButton.height == 70
            fairPriceButton.width == friendlyButton.width
            fairPriceButton.trailing == friendlyButton.leading - 30
            fairPriceButton.leading == fairPriceButton.superview!.leading + 30
            
            friendlyButton.height == 70
            friendlyButton.top == fairPriceButton.top
            friendlyButton.trailing == friendlyButton.superview!.trailing - 30
            
            quickResponseButton.height == 70
            quickResponseButton.width == easyToLocateButton.width
            quickResponseButton.trailing == easyToLocateButton.leading - 30
            quickResponseButton.leading == fairPriceButton.leading
            quickResponseButton.top == fairPriceButton.bottom + 30
            
            easyToLocateButton.height == 70
            easyToLocateButton.top == quickResponseButton.top
            easyToLocateButton.trailing == friendlyButton.trailing
            
        }
        
        constrain(submitButton, car_bottomLayoutGuide) { submitButton, bottom in
            submitButton.leading == submitButton.superview!.leading + K.Dimen.smallMargin
            submitButton.trailing == submitButton.superview!.trailing - K.Dimen.smallMargin
            submitButton.height == K.Dimen.button
            submitButton.bottom == bottom.top - 30
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        hasCloseButton = true
        titleLabel.text = String(format: LocalizedString("rating_seller_title"), "")
        titleLabel.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        titleLabel.textColor = .fanatickWhite
        titleLabel.textAlignment = .center
        
        starRating.settings.fillMode = .full
        starRating.settings.starSize = 40
        starRating.settings.emptyBorderColor = .fanatickWhite
        starRating.settings.filledColor = .fanatickYellow
        starRating.settings.emptyBorderWidth = 2
        starRating.settings.updateOnTouch = true
        starRating.rating = 0
    
        ratingLabel.font = UIFont.shFont(size: 14, fontType: .sfProDisplay, weight: .medium)
        ratingLabel.textColor = .fanatickWhite
        ratingLabel.textAlignment = .center
        
        submitButton.defaultYellowStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2)
        submitButton    .setTitle(LocalizedString("rating_seller_submit", story: .general), for: .normal)
        
        fairPriceButton.applySelectorStyling()
        fairPriceButton    .setTitle(LocalizedString("fair_price", story: .general), for: .normal)
        
        friendlyButton.applySelectorStyling()
        friendlyButton    .setTitle(LocalizedString("friendly_seller", story: .general), for: .normal)
        
        quickResponseButton.applySelectorStyling()
        quickResponseButton    .setTitle(LocalizedString("quick_response", story: .general), for: .normal)
        
        easyToLocateButton.applySelectorStyling()
        easyToLocateButton    .setTitle(LocalizedString("easy_to_locate", story: .general), for: .normal)
    }
    
    override func addObservables() {
        super.addObservables()
        
        viewModel.listing.subscribe(onNext: { [weak self] (listing) in
            if let listing = listing {
                self?.titleLabel.text = String(format: LocalizedString("rating_seller_title"), "\(listing.seller?.firstName ?? "") \(listing.seller?.lastName ?? "")")
            }
            }).disposed(by: disposeBag)
        
        starRating.didTouchCosmos = { rating in
            self.viewModel.rating.accept(Int(rating))
            switch rating {
            case 1:
                self.ratingLabel.text = LocalizedString("rating_1")
            case 2:
                self.ratingLabel.text = LocalizedString("rating_2")
            case 3:
                self.ratingLabel.text = LocalizedString("rating_3")
            case 4:
                self.ratingLabel.text = LocalizedString("rating_4")
            case 5:
                self.ratingLabel.text = LocalizedString("rating_5")
            default:
                break
            }
        }
        
        fairPriceButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                var ratings = self?.viewModel.ratingOptions.value ?? []
                if ratings.contains(.fair) {
                    ratings.remove(.fair)
                } else {
                    ratings.append(.fair)
                }
                self?.viewModel.ratingOptions.accept(ratings)
                self?.fairPriceButton.isSelected = ratings.contains(.fair)
            }).disposed(by: disposeBag)
        
        friendlyButton.rx.tap
        .subscribe(onNext: { [weak self] (_) in
            var ratings = self?.viewModel.ratingOptions.value ?? []
            if ratings.contains(.friendly) {
                ratings.remove(.friendly)
            } else {
                ratings.append(.friendly)
            }
            self?.viewModel.ratingOptions.accept(ratings)
            self?.friendlyButton.isSelected = ratings.contains(.friendly)
        }).disposed(by: disposeBag)
        
        quickResponseButton.rx.tap
        .subscribe(onNext: { [weak self] (_) in
            var ratings = self?.viewModel.ratingOptions.value ?? []
            if ratings.contains(.quick) {
                ratings.remove(.quick)
            } else {
                ratings.append(.quick)
            }
            self?.viewModel.ratingOptions.accept(ratings)
            self?.quickResponseButton.isSelected = ratings.contains(.quick)
        }).disposed(by: disposeBag)
        
        easyToLocateButton.rx.tap
        .subscribe(onNext: { [weak self] (_) in
            var ratings = self?.viewModel.ratingOptions.value ?? []
            if ratings.contains(.easyToLocate) {
                ratings.remove(.easyToLocate)
            } else {
                ratings.append(.easyToLocate)
            }
            self?.viewModel.ratingOptions.accept(ratings)
            self?.easyToLocateButton.isSelected = ratings.contains(.easyToLocate)
        }).disposed(by: disposeBag)
        
        submitButton.rx.tap
            .bind(to: viewModel.submitButtonAction)
            .disposed(by: disposeBag)
        
        viewModel.rating
            .map { (value) -> Bool in
                return value != nil
            }.bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.successAction
            .subscribe(onNext: {[weak self] (_) in
                self?.dismissButtonTapped()
            }).disposed(by: disposeBag)
    }
    
    override func dismissButtonTapped() {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

extension UIButton {
    fileprivate func applySelectorStyling() {
        layer.cornerRadius = 35
        layer.masksToBounds = true
        
        layer.borderColor = UIColor.fanatickWhite.cgColor
        layer.borderWidth = 1
        
        titleLabel?.font = UIFont.shFont(size: 14, fontType: .sfProDisplay, weight: .medium)
        setBackgroundImage(UIImage.image(color: .clear), for: .normal)
        setBackgroundImage(UIImage.image(color: .fanatickYellow), for: .selected)
        setBackgroundImage(UIImage.image(color: .clear), for: .disabled)
        setTitleColor(.fanatickWhite, for: .normal)
        setTitleColor(.fanatickBlack, for: .selected)
    }
}

