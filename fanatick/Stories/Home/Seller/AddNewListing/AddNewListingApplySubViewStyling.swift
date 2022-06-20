//
//  AddNewListingApplySubViewStyling.swift
//  fanatick
//
//  Created by Yashesh on 30/05/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import RxCocoa
import RxSwift

//MARK: Apply Styling for all subviews

extension AddNewListingViewController {
    
    func stylingForEventName() {
        
        if let event = viewModel.event.value {
            labelEventName.numberOfLines = 0
            labelEventName.textColor = .fanatickWhite
            labelEventName.font = UIFont.shFont(size: 18, fontType: .sfProDisplay, weight: .medium)
            labelEventName.text = event.name ?? ""
        }
    }
    
    func stylingForCity() {
        
        setTitleLabelStyling(label: labelCityTitle, title: LocalizedString("city", story: .newList).addColon())
        
        if let city = viewModel.event.value?.venue?.location?.city, let state = viewModel.event.value?.venue?.location?.state {
            labelCityName.text = "\(city), \(state)"
            labelCityName.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
            labelCityName.textColor = .fanatickWhite
        }
        underLineForCity.backgroundColor = .fanatickWhite
    }
    
    func staylingForDateAndTime() {
        
        setTitleLabelStyling(label: labelDateAndTimeTitle, title: LocalizedString("date_and_time", story: .newList).addColon())
        if let startAt = viewModel.event.value?.startAt, let date = Date.init(fromString: startAt, format: .isoDateTimeMilliSec) {
            let dateString = date.toString(format: DateFormatType.custom("EEEE MMMM dd HH:mm a"))
            setTitleLabelStyling(label: labelDateAndTime, title: dateString)
        } else {
            
        }
        
        underLineForDateAndTime.backgroundColor = .fanatickWhite
    }
    
    func stylingForQtyAndPrice() {
        
        stackViewForQtyAndPriceTitle.spacing = 7.0
        stackViewForQtyAndPriceTitle.distribution = .fillEqually
        
        setTitleLabelStyling(label: labelQty, title: LocalizedString("qty", story: .newList).addColon())
        setTitleLabelStyling(label: labelPricePerTicket, title: LocalizedString("price_per_ticket", story: .newList).addColon())
        
        stackViewForQtyAndPriceTextField.spacing = 7.0
        stackViewForQtyAndPriceTextField.distribution = .fillEqually
        
        setTextfieldStyle(textField: textFieldQty)
        textFieldQty.inputView = pickerViewQty
        buttonQtyDownArrow.setImage(imgChevron_down, for: UIControl.State.normal)
        
        setTextfieldStyle(textField: textFieldPrice)
        setTitleLabelStyling(label: labelDollarSign, title: "$")
        
        textFieldPrice.cursorRectPoint      = CGPoint.init(x: 35, y: 0)
        labelDollarSign.textAlignment       = .center
        textFieldPrice.keyboardType         = .numberPad
        textFieldPrice.keyboardAppearance   = .dark
    }
    
    func stylingForDeliveryMethod() {
        setTitleLabelStyling(label: labelDeliveryMethod, title: LocalizedString("delivery_method", story: .newList).addColon())
        setTextfieldStyle(textField: textFieldDeliveryMethod)
        buttonDeliveryMethodDownArrow.setImage(imgChevron_down, for: UIControl.State.normal)
        textFieldDeliveryMethod.inputView = pickerViewDeliveryMethod
        textFieldDeliveryMethod.adjustsFontSizeToFitWidth = true
        textFieldDeliveryMethod.minimumFontSize = 5
    }
    
    func stylingForPickUpLocation() {
        containerPickUpLocation.clipsToBounds = true
        setTitleLabelStyling(label: labelPickUpLocationTitle, title: LocalizedString("pick_up_location", story: .newList).addColon())
        containerPickUpLocation.addBordersTo([UIRectEdge.bottom], color: .fanatickWhite, thickness: 1)
        textFieldPickUpLocation.placeholder = LocalizedString("pickup_location_placeholder", story: .general)
        textFieldPickUpLocation.placeholderColor = .fanatickLightGrey
        textFieldPickUpLocation.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        textFieldPickUpLocation.tintColor = .fanatickWhite
        textFieldPickUpLocation.textColor = .fanatickWhite
        textFieldPickUpLocation.keyboardAppearance = .dark
        textFieldPickUpLocation.cursorRectPoint = CGPoint.init(x: 16, y: 0)
    }
    
    func stylingForActionButtons() {
        
        buttonQuickSell.setTitle(LocalizedString("quicksell", story: .newList), for: UIControl.State.normal)
        buttonQuickSell.setImage(UIImage.init(named: "checkedBox"), for: UIControl.State.selected)
        buttonQuickSell.setImage(UIImage.init(named: "uncheckedBox"), for: UIControl.State.normal)
        buttonQuickSell.setTitleColor(.fanatickWhite, for: UIControl.State.normal)
        buttonQuickSell.contentHorizontalAlignment = .left
        buttonQuickSell.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 11, bottom: 0, right: 0)
        
        continueButton.defaultYellowStyling(cornerRadius: K.Dimen.button / 2, borderColor: .fanatickLightGrey)
        continueButton.setTitle(LocalizedString("continue"), for: .normal)
    }
    
    func stylingForPickerView() {
        pickerViewQty.backgroundColor = .fanatickGrey
        pickerViewDeliveryMethod.backgroundColor = .fanatickGrey
    }
    
    func setInputAccesaryView() {
        
        let accessoryViewFrame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: K.Dimen.toolBarHeight)
        
        toolBarForQtyTextfield = InputAccessoryView.init(frame: accessoryViewFrame)
        toolBarForPricePerTktTextField = InputAccessoryView.init(frame: accessoryViewFrame)
        toolBarForDeliveryMethodTextField = InputAccessoryView.init(frame: accessoryViewFrame)
        
        textFieldQty.inputAccessoryView = toolBarForQtyTextfield
        textFieldPrice.inputAccessoryView = toolBarForPricePerTktTextField
        textFieldDeliveryMethod.inputAccessoryView = toolBarForDeliveryMethodTextField
    }
    
    func setTextSelectedQty() {
        textFieldQty.text = "\(qtyArray[pickerViewQty.selectedRow(inComponent: 0)])"
        viewModel.ticketQty.accept(textFieldQty.text ?? "")
    }
    
    func setTextDeliveryMethod() {
        textFieldDeliveryMethod.text = "\(deliveryMethodsArray[pickerViewDeliveryMethod.selectedRow(inComponent: 0)].value)"
        viewModel.ticketMethod.accept(textFieldDeliveryMethod.text ?? "")
    }
}
