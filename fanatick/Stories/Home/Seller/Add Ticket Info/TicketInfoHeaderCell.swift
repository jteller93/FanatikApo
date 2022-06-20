//
//  TicketInfoHeaderCell.swift
//  fanatick
//
//  Created by Yashesh on 01/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxSwift
import Cartography
import RxCocoa

class TicketInfoHeaderCell: CollectionHeaderFooterView {
    
    let labelTitle          = Label()
    let labelSectionTitle   = Label()
    let textFieldSection    = TextField()
    let labelRowTitle       = Label()
    let textFieldRow        = TextField()
    let stackViewForTitle   = UIStackView()
    let stackViewForTextfield = UIStackView()
    
    var toolBarForSectionTextfield               : InputAccessoryView!
    var toolBarForRowTextfield               : InputAccessoryView!
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(labelTitle)
        addSubview(stackViewForTitle)
        addSubview(stackViewForTextfield)
        stackViewForTitle.addArrangedSubview(labelSectionTitle)
        stackViewForTitle.addArrangedSubview(labelRowTitle)
        stackViewForTextfield.addArrangedSubview(textFieldSection)
        stackViewForTextfield.addArrangedSubview(textFieldRow)
        
        constrain(labelSectionTitle, labelTitle, stackViewForTitle, stackViewForTextfield) { (labelSectionTitle, labelTitle,stackViewForTitle, stackViewForTextfield) in
            
            labelTitle.leading == labelTitle.superview!.leading + 3
            labelTitle.trailing == labelTitle.superview!.trailing - 3
            labelTitle.top == labelTitle.superview!.top + 14
            
            stackViewForTitle.leading == labelTitle.leading
            stackViewForTitle.top == labelTitle.bottom + 27
            stackViewForTitle.trailing == labelTitle.trailing
            
            stackViewForTextfield.top == stackViewForTitle.bottom + 10
            stackViewForTextfield.leading == stackViewForTitle.leading
            stackViewForTextfield.trailing == stackViewForTitle.trailing
            stackViewForTextfield.height == K.Dimen.textFieldHeight
            
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        labelTitle.numberOfLines = 0
        labelTitle.text = LocalizedString("Seats must be in the same row and next to each other.", story: .ticketinfo)
        labelSectionTitle.text = LocalizedString("section", story: .ticketinfo).addColon()
        labelRowTitle.text = LocalizedString("row", story: .ticketinfo).addColon()
        
        labelTitle.textColor = .fanatickWhite
        labelSectionTitle.textColor = .fanatickWhite
        labelRowTitle.textColor = .fanatickWhite
        
        textFieldSection.tintColor = .fanatickWhite
        textFieldSection.textColor = .fanatickYellow
        textFieldSection.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        textFieldSection.addBorders(.fanatickWhite, thickness: 1)
        textFieldSection.cursorRectPoint = CGPoint(x: 16, y: 0)
        textFieldSection.keyboardAppearance = .dark
        
        textFieldRow.tintColor = .fanatickWhite
        textFieldRow.textColor = .fanatickYellow
        textFieldRow.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        textFieldRow.addBorders(.fanatickWhite, thickness: 1)
        textFieldRow.cursorRectPoint = CGPoint(x: 16, y: 0)
        textFieldRow.keyboardAppearance = .dark
        
        stackViewForTitle.spacing = 7
        stackViewForTitle.distribution = .fillEqually
        
        stackViewForTextfield.spacing = 7
        stackViewForTextfield.distribution = .fillEqually
        
        let accessoryViewFrame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: K.Dimen.toolBarHeight)
        
        toolBarForSectionTextfield = InputAccessoryView.init(frame: accessoryViewFrame)
        textFieldSection.inputAccessoryView = toolBarForSectionTextfield
        
        toolBarForRowTextfield = InputAccessoryView.init(frame: accessoryViewFrame)
        textFieldRow.inputAccessoryView = toolBarForRowTextfield
        toolBarForRowTextfield.hideCancelButton()
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? AddTicketInfoViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        addObservableFor(viewModel: viewModel)
    }
    
    func addObservableFor(viewModel: AddTicketInfoViewModel?) {
        
        textFieldSection.rx.text.orEmpty
            .bindBoth(viewModel!.sectionSelecion)
            .disposed(by: disposeBag)
        
        textFieldRow.rx.text.orEmpty
            .bindBoth(viewModel!.rowValue)
            .disposed(by: disposeBag)
        
        toolBarForSectionTextfield.buttonCancel.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.dismissKeyboard()
            }).disposed(by: disposeBag)
        
        toolBarForSectionTextfield.buttonDone.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.dismissKeyboard()
                viewModel?.sectionSelecion.accept(self.textFieldSection.text ?? "")
            }).disposed(by: disposeBag)
        
        toolBarForRowTextfield.buttonDone.rx.tap.subscribe(onNext:{ [weak self] (_) in
            self?.dismissKeyboard()
        }).disposed(by: disposeBag)
        
        textFieldRow.rx.text.orEmpty
            .subscribe(onNext: { [weak self] _ in
                viewModel?.rowValue.accept(self?.textFieldRow.text ?? "")
                viewModel?.listingAction.accept(viewModel?.ticketListing.value)
                viewModel?.isValid.accept(viewModel?.validateSectionRowAndTickets() ?? false)
            })
            .disposed(by: disposeBag)
        
        textFieldSection.rx.text.orEmpty
            .subscribe(onNext: { [weak self, viewModel] _ in
                viewModel?.sectionSelecion.accept(self?.textFieldSection.text ?? "")
                viewModel?.listingAction.accept(viewModel?.ticketListing.value)
                viewModel?.isValid.accept(viewModel?.validateSectionRowAndTickets() ?? false)
            })
            .disposed(by: disposeBag)
    }
    
    func dismissKeyboard() {
        endEditing(true)
    }
}
