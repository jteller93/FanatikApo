//
//  SavingViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 12/11/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cosmos
import Cartography
import UIKit
import RxCocoa
import RxSwift

protocol SavingViewControllerDelegate: class {
    func viewControllerDidComplete(_ viewController: SavingViewController, transaction: Transaction?)
}

class SavingViewController: ViewController {
    var transaction: Transaction? = nil
    var quantity: Int? = nil
    weak var delegate: SavingViewControllerDelegate?
    let checkmark = UIImageView()
    let saveYou = Label()
    let saving = Label()
    let perTicket = Label()
    let industryStandard = Label()
    let button = Button()
    
    override func applyStyling() {
        super.applyStyling()
        
        checkmark.image = UIImage(named: "checkIconYellow")
        
        saveYou.text = LocalizedString("saving_title")
        saveYou.font = UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .regular)
        saveYou.textColor = .fanatickWhite
        
        saving.font = UIFont.shFont(size: 40, fontType: .sfProDisplay, weight: .regular)
        saving.textColor = .fanatickYellow
        
        perTicket.text = LocalizedString("saving_per_ticket")
        perTicket.font = UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .regular)
        perTicket.textColor = .fanatickWhite
        
        industryStandard.text = LocalizedString("saving_industry_standard")
        industryStandard.font = UIFont.shFont(size: 12, fontType: .sfProDisplay, weight: .regular)
        industryStandard.textColor = .fanatickWhite
        
        button.defaultYellowStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2)
        button.setTitle(LocalizedString("got_it", story: .general), for: .normal)
    }
    
    override func reapplyStyling() {
        super.reapplyStyling()
        
        if let fee = transaction?.fee, let amount = transaction?.payment?.amount {
            saving.text = String(format: LocalizedString("saving_amount"), (Float(amount - fee) / (1.0 - 0.27) - Float(amount - fee)) / 100.0 / Float(quantity ?? 1))
        }
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(checkmark)
        view.addSubview(saveYou)
        view.addSubview(saving)
        view.addSubview(perTicket)
        view.addSubview(industryStandard)
        view.addSubview(button)
        
        constrain(checkmark, car_topLayoutGuide) { checkmark, top in
            checkmark.top == top.bottom + 100
            checkmark.centerX == checkmark.superview!.centerX
        }
        
        constrain(checkmark, saveYou, saving, perTicket, industryStandard) { checkmark, saveYou, saving, perTicket, industryStandard in
            saveYou.top == checkmark.bottom + 45
            saveYou.centerX == saveYou.superview!.centerX
            
            saving.top == saveYou.bottom + 11
            saving.centerX == saving.superview!.centerX
            
            perTicket.top == saving.bottom + 11
            perTicket.centerX == perTicket.superview!.centerX
            
            industryStandard.top == perTicket.bottom + 11
            industryStandard.centerX == industryStandard.superview!.centerX
        }
        
        constrain(button, car_bottomLayoutGuide) { button, bottom in
            button.leading == button.superview!.leading + K.Dimen.smallMargin
            button.trailing == button.superview!.trailing - K.Dimen.smallMargin
            button.height == K.Dimen.button
            button.bottom == bottom.top - 30
        }
    }
    
    override func addObservables() {
        super.addObservables()
        
        button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.delegate?.viewControllerDidComplete(self, transaction: self.transaction)
            }).disposed(by: disposeBag)
    }
}
