//
//  TicketInfoCell.swift
//  fanatick
//
//  Created by Yashesh on 01/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import RxSwift
import RxCocoa

class TicketInfoCell: CollectionViewCell {
    
    let labelTitle = Label()
    let textField = TextField()
    var inputAccessoryViewForTextField: InputAccessoryView!
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(labelTitle)
        addSubview(textField)
        
        constrain(labelTitle, textField) { (labelTitle, textField) in
            
            labelTitle.top == labelTitle.superview!.top + 14
            labelTitle.leading == labelTitle.superview!.leading + 3
            labelTitle.trailing == labelTitle.superview!.trailing - 3
            
            textField.top == labelTitle.bottom + 14
            textField.leading == labelTitle.leading
            textField.trailing == labelTitle.trailing
            textField.height == K.Dimen.textFieldHeight
            textField.bottom == textField.superview!.bottom
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        textField.addBorders(.fanatickWhite, thickness: 1.0)
        textField.tintColor = .fanatickWhite
        textField.textColor = .fanatickYellow
        textField.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        textField.keyboardAppearance = .dark
        
        let accessoryViewFrame = CGRect.init(x: 0, y: 0, width: frame.width, height: K.Dimen.toolBarHeight)
        inputAccessoryViewForTextField = InputAccessoryView.init(frame: accessoryViewFrame)
        inputAccessoryViewForTextField.hideCancelButton()
        textField.inputAccessoryView = inputAccessoryViewForTextField
        labelTitle.textColor = .fanatickWhite
        labelTitle.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? AddTicketInfoViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        labelTitle.text = "\(LocalizedString("seat_ticket", story: .ticketinfo)) \(indexPath.item + 1)".addColon()
        textField.text = viewModel.ticketListing.value?.tickets?[indexPath.row].seat ?? ""
        addObservableFor(viewModel: viewModel, indexPath: indexPath)
    }
    
    func addObservableFor(viewModel: AddTicketInfoViewModel?, indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        
        inputAccessoryViewForTextField.buttonDone.rx.tap.subscribe(onNext: { [weak self] () in
            self?.endEditing(true)
        }).disposed(by: disposeBag)
        
        textField.rx.text
            .orEmpty
            .map{ [weak viewModel] text -> Listing? in
                guard let viewModel = viewModel else { return nil }
                var listing = viewModel.ticketListing.value
                if listing == nil, listing?.tickets == nil { return nil }
                var ticket = listing!.tickets![indexPath.row]
                ticket.seat = text
                listing!.seats![indexPath.row] = text
                listing!.tickets![indexPath.row] = ticket
                return listing
            }.filter{ $0 != nil }.bind(to: viewModel.ticketListing)
            .disposed(by: disposeBag)
                
        textField.rx.text.orEmpty.map { _ -> Bool in
            return viewModel.validateSectionRowAndTickets()
            }.bind(to: viewModel.isValid).disposed(by: disposeBag)
    }
}
