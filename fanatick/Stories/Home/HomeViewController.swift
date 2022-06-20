//
//  HomeViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/7/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import NutsAndBolts
import RxCocoa
import RxSwift

class HomeViewController: ViewController, ChildViewControllerHolder {
    let viewModel = HomeViewModel()
    var containerView: ContainerView = ContainerView()
    let buyerViewController = BuyerHomeViewController()
    let sellerViewController = SellerHomeViewController()
    
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(containerView)
        
        constrain(containerView) { containerView in
            containerView.edges == containerView.superview!.edges
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        hasMenu = true
        
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func addObservables() {
        super.addObservables()
        
        viewModel.role
            .subscribe(onNext: { [weak self](role) in
                guard let `self` = self else { return }
                if role == .seller {
                    self.navigationItem.title = LocalizedString("fanatick")
                    self.cycleFromViewController(
                        self.buyerViewController,
                        toViewController: self.sellerViewController,
                        completion: { (_) in }
                    )
                } else {
                    self.navigationItem.title = nil
                    self.cycleFromViewController(
                        self.sellerViewController,
                        toViewController: self.buyerViewController,
                        completion: { (_) in }
                    )
                }
            }).disposed(by: disposeBag)
    }
}

