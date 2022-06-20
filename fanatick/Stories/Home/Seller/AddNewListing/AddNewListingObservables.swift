//
//  AddNewListingObservables.swift
//  fanatick
//
//  Created by Yashesh on 31/05/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import RxCocoa
import RxSwift

extension AddNewListingViewController {
    
    func observablesForPickerViewQty() {
        
        Observable.just(qtyArray)
            .bind(to: pickerViewQty.rx.itemAttributedTitles) { _, item in
                return NSAttributedString(string: "\(item)",
                    attributes: [
                        NSAttributedString.Key.foregroundColor: (self.selectedQtyRow == item) ? UIColor.fanatickYellow : UIColor.fanatickLighterGrey,
                        NSAttributedString.Key.font: UIFont.shFont(size: 23.5, fontType: .sfProDisplay, weight: .regular)
                    ])
            }
            .disposed(by: disposeBag)
        
        pickerViewQty.rx.modelSelected(Int.self)
            .subscribe(onNext: { [weak self] models in
                self?.selectedQtyRow = models.first!
                self?.pickerViewQty.reloadAllComponents()
                self?.setTextSelectedQty()
            })
            .disposed(by: disposeBag)
    }
    
    func observablesForPickerViewDeliveryMethod() {
        
        Observable.just(deliveryMethodsArray)
            .bind(to: pickerViewDeliveryMethod.rx.itemAttributedTitles) {  index, item in
                return NSAttributedString(string: "\(self.deliveryMethodsArray[index].value)",
                    attributes: [
                        NSAttributedString.Key.foregroundColor: item == self.selectedDeliveryMethod ? UIColor.fanatickYellow : UIColor.fanatickLighterGrey,
                        NSAttributedString.Key.font: UIFont.shFont(size: 23.5, fontType: .sfProDisplay, weight: .regular),
                    ])
            }
            .disposed(by: disposeBag)
        
        pickerViewDeliveryMethod.rx.modelSelected(DeliveryMethod.self)
            .subscribe(onNext: { [weak self] models in
                self?.selectedDeliveryMethod = models.first!
                self?.pickerViewDeliveryMethod.reloadAllComponents()
                self?.isExpandPickUpLocation(expand: models.first! == .hardcopy)
                self?.setTextDeliveryMethod()
                self?.viewModel.selectedDeliveryMethod.accept(models.first)
            })
            .disposed(by: disposeBag)
    }
    
    func observablesForToolBar() {
        
        toolBarForQtyTextfield.buttonCancel.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.dismissKeyboard()
            }).disposed(by: disposeBag)
        
        toolBarForPricePerTktTextField.buttonCancel.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.dismissKeyboard()
            }).disposed(by: disposeBag)
        
        toolBarForDeliveryMethodTextField.buttonCancel.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.dismissKeyboard()
            }).disposed(by: disposeBag)
        
        toolBarForQtyTextfield.buttonDone.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.dismissKeyboard()
                self.setTextSelectedQty()
            }).disposed(by: disposeBag)
        
        toolBarForPricePerTktTextField.buttonDone.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.dismissKeyboard()
            }).disposed(by: disposeBag)
        
        toolBarForDeliveryMethodTextField.buttonDone.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.dismissKeyboard()
                self?.setTextDeliveryMethod()
            }).disposed(by: disposeBag)

    }
    
    func ovservablesForQuickSellAndDoNotLeaveWithSignleTicket() {
        
        buttonQuickSell.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let `self` = self else { return }
            self.buttonQuickSell.isSelected = !self.buttonQuickSell.isSelected
        }).disposed(by: disposeBag)
    }
    
    func observablesForContinueButton() {
        viewModel.error
            .filter{ $0 != nil }
            .subscribe(onNext: { [weak self] (error) in
                self?.handleError(error: error!.runtimeError)
            }).disposed(by: disposeBag)
        
        textFieldQty.rx.text.orEmpty
            .bindBoth(viewModel.ticketQty)
            .disposed(by: disposeBag)
        
        textFieldPrice.rx.text.orEmpty
            .bindBoth(viewModel.ticketPrice)
            .disposed(by: disposeBag)
        
        textFieldDeliveryMethod.rx.text.orEmpty
            .bindBoth(viewModel.ticketMethod)
            .disposed(by: disposeBag)
        
        textFieldPickUpLocation.rx.text.orEmpty
            .bindBoth(viewModel.pickupLocation)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: continueButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        continueButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            self?.dismissKeyboard()
            let viewController = AddTicketInfoViewController()
            
            guard let userID = FirebaseSession.shared.user.value?.userId else {
                return
            }
            
            guard let eventID = self?.viewModel.event.value?.id else  {
                return
            }
            
            let unitPrices = (Int(self?.textFieldPrice.text ?? "") ?? 0) * 100
            let qty = Int(self?.textFieldQty.text ?? "") ?? 0
            let tickets = [Ticket](repeating: Ticket(), count: qty)
            let seats = [String](repeating: "", count: qty)
            let pickupLocation = self?.textFieldPickUpLocation.text ?? ""
            let listing = Listing(deliveryMethod: self?.selectedDeliveryMethod,
                                  eventId: eventID,
                                  event: nil,
                                  id: nil,
                                  quickBuy: self?.buttonQuickSell.isSelected,
                                  seller: nil,
                                  tickets: tickets,
                                  unitPrice: unitPrices,
                                  sellerID: userID,
                                  section: nil,
                                  row: nil,
                                  seats: seats,
                                  quantity: qty,
                                  pickupLocation: pickupLocation)
            
            viewController.viewModel.setTicketDatatoModel(listing: listing)
            let navigationController = NavigationController(rootViewController: viewController)
            self?.navigationController?.present(navigationController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    func obeservablesForDropDownArrow() {
        
        buttonQtyDownArrow.rx.tap.subscribe(onNext: { [weak self] (_) in
            self?.textFieldQty.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        buttonDeliveryMethodDownArrow.rx.tap.subscribe(onNext: { [weak self] (_) in
            self?.textFieldDeliveryMethod.becomeFirstResponder()
        }).disposed(by: disposeBag)
    }
}
