//
//  AddNewListingViewController.swift
//  fanatick
//
//  Created by Yashesh on 29/05/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import RxCocoa
import RxSwift

class AddNewListingViewController: ViewController {
    let viewModel             = AddTicketInfoViewModel()
    let scrollView                  = UIScrollView()
    let containerView               = View()
    let labelEventName              = Label()
    let labelCityTitle              = Label()
    let labelCityName               = Label()
    let underLineForCity            = View()
    let labelDateAndTimeTitle       = Label()
    let labelDateAndTime            = Label()
    let underLineForDateAndTime     = View()
    let stackViewForQtyAndPriceTitle = UIStackView()
    let labelQty                    = Label()
    let labelPricePerTicket         = Label()
    let stackViewForQtyAndPriceTextField = UIStackView()
    let textFieldQty                = TextField()
    let textFieldPrice              = TextField()
    let buttonQtyDownArrow          = Button()
    let labelDollarSign             = Label()
    let labelDeliveryMethod         = Label()
    let textFieldDeliveryMethod     = TextField()
    let buttonDeliveryMethodDownArrow = Button()
    let containerPickUpLocation     = View()
    let labelPickUpLocationTitle    = Label()
    let textFieldPickUpLocation     = TextField()
    let buttonQuickSell             = Button()
    let continueButton              = Button()
    let pickerViewQty               = PickerView()
    let pickerViewDeliveryMethod    = PickerView()
    
    let imgChevron_down = UIImage.init(named: "chevron_down")
    var constrintForContainerPickUpLocationHeight = NSLayoutConstraint()
    
    var toolBarForQtyTextfield               : InputAccessoryView!
    var toolBarForPricePerTktTextField       : InputAccessoryView!
    var toolBarForDeliveryMethodTextField    : InputAccessoryView!

    let qtyArray : [Int] = Array(1...25)
    var selectedQtyRow: Int?
    var deliveryMethodsArray: [DeliveryMethod] = [.digital, .hardcopy]
    var selectedDeliveryMethod: DeliveryMethod? = .digital
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(labelEventName)
        containerView.addSubview(labelCityTitle)
        containerView.addSubview(labelCityName)
        containerView.addSubview(underLineForCity)
        containerView.addSubview(labelDateAndTimeTitle)
        containerView.addSubview(labelDateAndTime)
        containerView.addSubview(underLineForDateAndTime)
        containerView.addSubview(stackViewForQtyAndPriceTitle)
        stackViewForQtyAndPriceTitle.addArrangedSubview(labelQty)
        stackViewForQtyAndPriceTitle.addArrangedSubview(labelPricePerTicket)
        containerView.addSubview(stackViewForQtyAndPriceTextField)
        stackViewForQtyAndPriceTextField.addArrangedSubview(textFieldQty)
        stackViewForQtyAndPriceTextField.addArrangedSubview(textFieldPrice)
        containerView.addSubview(labelDeliveryMethod)
        containerView.addSubview(textFieldDeliveryMethod)
        containerView.addSubview(containerPickUpLocation)
        containerPickUpLocation.addSubview(labelPickUpLocationTitle)
        containerPickUpLocation.addSubview(textFieldPickUpLocation)
        containerView.addSubview(buttonQuickSell)
        containerView.addSubview(continueButton)
        
        //Setup DownArrow Button to TextField Qty
        textFieldQty.rightViewMode = .always
        textFieldQty.rightView = buttonQtyDownArrow
        
        //Setup Dollar Label for TextField Price
        textFieldPrice.leftViewMode = .always
        textFieldPrice.leftView = labelDollarSign
        
        //Setup DownArroe Button to Textfield Delivery Methods
        textFieldDeliveryMethod.rightViewMode = .always
        textFieldDeliveryMethod.rightView = buttonDeliveryMethodDownArrow
        
        //Setup all constraint
        setupCitySubview()
        setupDateAndTimeSubviews()
        setupQtyAndPriceSubViews()
        setupDeliveryMethodSubViews()
        setupPickUPLocationSubViews()
        setupActionButtonsStyling()
        obeservablesForDropDownArrow()
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        hasCloseButton = true
        navigationController?.navigationBar.isTranslucent = true
        title = LocalizedString("add_new_listing", story: .home)
        
        stylingForEventName()
        stylingForCity()
        staylingForDateAndTime()
        stylingForQtyAndPrice()
        stylingForDeliveryMethod()
        stylingForPickUpLocation()
        stylingForActionButtons()
        stylingForPickerView()
        
        // setup input AccessaryView for Ticket Qty, price and delivery method
        setInputAccesaryView()
    }
    
    override func addObservables() {
        super.addObservables()
        
        observablesForPickerViewQty()
        observablesForPickerViewDeliveryMethod()
        observablesForToolBar()
        observablesForContinueButton()
        ovservablesForQuickSellAndDoNotLeaveWithSignleTicket()
    }
    
    func setTitleLabelStyling(label: UILabel, title: String) {
        label.text = title
        label.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        label.textColor = .fanatickWhite
    }
    
    func setTextfieldStyle(textField: TextField) {
        textField.tintColor = .fanatickWhite
        textField.textColor = .fanatickYellow
        textField.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        textField.addBorders(.fanatickWhite, thickness: 1, insets: UIEdgeInsets.zero)
    }
}
