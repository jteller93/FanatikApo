//
//  RootNavigationController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class RootNavigationController: NavigationController {
    let viewModel = RootViewModel()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        MenuViewController.addGesture(navigationController: self)
    }
    
    override func addObservables() {
        super.addObservables()
        viewModel
            .selectMenuAction
            .subscribe(onNext: { [weak self] (item) in
                self?.goTo(item: item)
            }).disposed(by: disposeBag)
    }
    
    private func goTo(item: MenuItem) {
        MenuViewController.dismiss { [weak self] in
            switch item {
            case .about:
                let viewController = AboutViewController()
                self?.viewControllers = [viewController]
            case .home:
                let viewController = HomeViewController()
                self?.viewControllers = [viewController]
            case .myTickets:
                let viewController = MyTicketsViewController()
                self?.viewControllers = [viewController]
            case .notifications:
                let viewController = NotificationsViewController()
                self?.viewControllers = [viewController]
            case .settings:
                let viewController = SettingsViewController()
                self?.viewControllers = [viewController]
            case .tips:
                let viewController = ProTipViewController()
                let navigationController = NavigationController(rootViewController: viewController)
                self?.present(navigationController, animated: true, completion: nil)
            case .wallet:
                if FirebaseSession.shared.user.value?.stripeID == nil {
                    self?.showAlertForStripePayment()
                } else if let url = URL(string: K.URL.stripeUrl) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case .logout:
                FirebaseSession.shared.logout()
                AuthenticationViewController.makeRoot()
            }
        }
    }
}

extension RootNavigationController {
    class func makeRoot() {
        MenuViewModel.shared.selectedItem.accept(.home)
        let homeVC = HomeViewController()
        let navigationController = RootNavigationController(rootViewController: homeVC)
        UIApplication.shared.appDelegate().makeRoot(viewController: navigationController)
    }
}
