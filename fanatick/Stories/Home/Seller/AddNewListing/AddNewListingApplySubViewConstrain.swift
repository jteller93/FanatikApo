//
//  AddNewListingApplySubViewConstrain.swift
//  fanatick
//
//  Created by Yashesh on 30/05/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import RxCocoa
import RxSwift

//MARK: Apply constraint for All Subviews

extension AddNewListingViewController {
    
    func setupCitySubview() {
        
        constrain(scrollView, containerView, labelEventName, labelCityTitle, labelCityName, underLineForCity) { (scrollView, containerView, labelEventName, labelCityTitle, labelCityName, underLineForCity) in
            
            scrollView.top == scrollView.superview!.safeAreaLayoutGuide.top
            scrollView.bottom == scrollView.superview!.safeAreaLayoutGuide.bottom
            scrollView.leading == scrollView.superview!.leading
            scrollView.trailing == scrollView.superview!.trailing
            
            containerView.top == scrollView.top
            containerView.bottom == scrollView.bottom
            containerView.width == scrollView.width
            containerView.centerX == scrollView.centerX
            
            labelEventName.top == containerView.top + 20
            labelEventName.leading == containerView.leading + 10
            labelEventName.trailing == containerView.trailing - 10
            
            labelCityTitle.top == labelEventName.bottom + 21
            labelCityTitle.leading == labelEventName.leading
            labelCityTitle.trailing == labelEventName.trailing
            
            labelCityName.top == labelCityTitle.bottom + 26
            labelCityName.leading == labelCityTitle.leading + K.Dimen.defaultMargin
            labelCityName.trailing == labelCityTitle.trailing
            
            underLineForCity.leading == labelCityTitle.leading
            underLineForCity.trailing == labelCityTitle.trailing
            underLineForCity.top == labelCityName.bottom + 17
            underLineForCity.height == 1
        }
    }
    
    func setupDateAndTimeSubviews() {
        
        constrain(labelDateAndTimeTitle, underLineForCity, labelDateAndTime, underLineForDateAndTime) { (labelDateAndTimeTitle, underLineForCity, labelDateAndTime, underLineForDateAndTime) in
            
            labelDateAndTimeTitle.top == underLineForCity.bottom + 14
            labelDateAndTimeTitle.leading == underLineForCity.leading
            labelDateAndTimeTitle.trailing == underLineForCity.trailing
            
            labelDateAndTime.top == labelDateAndTimeTitle.bottom + 26
            labelDateAndTime.leading == labelDateAndTimeTitle.leading + K.Dimen.defaultMargin
            labelDateAndTime.trailing == labelDateAndTimeTitle.trailing
            
            underLineForDateAndTime.top == labelDateAndTime.bottom + 16
            underLineForDateAndTime.leading == labelDateAndTimeTitle.leading
            underLineForDateAndTime.trailing == labelDateAndTimeTitle.trailing
            underLineForDateAndTime.height == 1
        }
    }
    
    func setupQtyAndPriceSubViews() {
        
        constrain(underLineForDateAndTime, stackViewForQtyAndPriceTitle, stackViewForQtyAndPriceTextField, buttonQtyDownArrow, labelDollarSign) { (underLineForDateAndTime, stackViewForQtyAndPriceTitle, stackViewForQtyAndPriceTextField, buttonQtyDownArrow, labelDollarSign) in
            
            stackViewForQtyAndPriceTitle.top == underLineForDateAndTime.bottom + 14
            stackViewForQtyAndPriceTitle.leading == underLineForDateAndTime.leading
            stackViewForQtyAndPriceTitle.trailing == underLineForDateAndTime.trailing
            
            stackViewForQtyAndPriceTextField.top == stackViewForQtyAndPriceTitle.bottom + 10
            stackViewForQtyAndPriceTextField.leading == stackViewForQtyAndPriceTitle.leading
            stackViewForQtyAndPriceTextField.trailing == stackViewForQtyAndPriceTitle.trailing
            stackViewForQtyAndPriceTextField.height == K.Dimen.textFieldHeight
            
            buttonQtyDownArrow.width == 40
            buttonQtyDownArrow.height == K.Dimen.textFieldHeight
            
            labelDollarSign.height == K.Dimen.textFieldHeight
            labelDollarSign.width == 35
        }
    }
    
    func setupDeliveryMethodSubViews() {
        
        constrain(stackViewForQtyAndPriceTextField, labelDeliveryMethod, textFieldDeliveryMethod,buttonDeliveryMethodDownArrow) { (stackViewForQtyAndPriceTextField, labelDeliveryMethod, textFieldDeliveryMethod, buttonDeliveryMethodDownArrow) in
            
            labelDeliveryMethod.top == stackViewForQtyAndPriceTextField.bottom + 15
            labelDeliveryMethod.leading == stackViewForQtyAndPriceTextField.leading
            labelDeliveryMethod.trailing == stackViewForQtyAndPriceTextField.trailing
            
            textFieldDeliveryMethod.top == labelDeliveryMethod.bottom + 10
            textFieldDeliveryMethod.leading == labelDeliveryMethod.leading
            textFieldDeliveryMethod.trailing == labelDeliveryMethod.trailing
            textFieldDeliveryMethod.height == K.Dimen.textFieldHeight
            
            buttonDeliveryMethodDownArrow.width == 40
            buttonDeliveryMethodDownArrow.height == K.Dimen.textFieldHeight
        }
    }
    
    func setupPickUPLocationSubViews() {
        
        constrain(textFieldDeliveryMethod, containerPickUpLocation, labelPickUpLocationTitle, textFieldPickUpLocation) { (textFieldDeliveryMethod, containerPickUpLocation, labelPickUpLocationTitle, textFieldPickUpLocation) in
            
            containerPickUpLocation.top == textFieldDeliveryMethod.bottom
            containerPickUpLocation.leading == textFieldDeliveryMethod.leading
            containerPickUpLocation.trailing == textFieldDeliveryMethod.trailing
            
            labelPickUpLocationTitle.leading == containerPickUpLocation.leading
            labelPickUpLocationTitle.top == containerPickUpLocation.topMargin + 6
            
            textFieldPickUpLocation.height == K.Dimen.textFieldHeight
            textFieldPickUpLocation.leading == containerPickUpLocation.leading
            textFieldPickUpLocation.trailing == containerPickUpLocation.trailing
            textFieldPickUpLocation.top == labelPickUpLocationTitle.bottom + 10
        }
        
        constrintForContainerPickUpLocationHeight = NSLayoutConstraint(item: containerPickUpLocation, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([constrintForContainerPickUpLocationHeight])
    }
    
    func setupActionButtonsStyling() {
        
        constrain(containerView, containerPickUpLocation, buttonQuickSell, continueButton) { (containerView, containerPickUpLocation, buttonQuickSell, continueButton) in
            
            buttonQuickSell.top == containerPickUpLocation.bottom + 20
            buttonQuickSell.leading == containerPickUpLocation.leading
            buttonQuickSell.trailing == containerPickUpLocation.trailing
            buttonQuickSell.height == 21
                        
            continueButton.top == buttonQuickSell.bottom + 37
            continueButton.leading == continueButton.superview!.leading + K.Dimen.smallMargin
            continueButton.trailing == continueButton.superview!.trailing - K.Dimen.smallMargin
            continueButton.height == K.Dimen.button
            
            containerView.bottom == continueButton.bottom + 30
        }
    }
    
    func isExpandPickUpLocation(expand: Bool = false) {
        textFieldPickUpLocation.text = nil
        constrintForContainerPickUpLocationHeight.constant = (expand) ? 93 : 0
    }
}
