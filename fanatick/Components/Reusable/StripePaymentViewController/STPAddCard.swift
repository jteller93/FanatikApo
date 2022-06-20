//
//  STPAddCard.swift
//  fanatick
//
//  Created by Yashesh on 27/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit
import Stripe
import RxSwift
import RxCocoa

// This class is used to avoid writing boiler plate code.
// @param: vc argument to assign your 'viewcontroller' to present and dismiss stripe payment AddCardViewController

class STPAddCard: NSObject {
    
    weak var viewController: UIViewController?
    var stripeToken = BehaviorRelay<String?>(value: nil)
    
    init(vc: UIViewController) {
        viewController = vc
    }
}

extension STPAddCard: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        viewController?.dismiss(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        stripeToken.accept(token.tokenId)
        viewController?.dismiss(animated: true)
    }
    
    func handleAddPaymentOptionButtonTapped() {
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        // Present add card view controller
        let navigationController = NavigationController(rootViewController: addCardViewController)
        viewController?.present(navigationController, animated: true)
    }
}
